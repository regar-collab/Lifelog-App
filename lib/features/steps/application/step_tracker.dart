import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/db/daos/step_dao.dart';
import 'package:lifelog/data/db/database_provider.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

/// 计步状态。
class StepTrackerState {
  const StepTrackerState({
    this.todaySteps = 0,
    this.rawValue = 0,
    this.available = false,
    this.error,
  });

  /// 今天走了多少步
  final int todaySteps;

  /// 传感器原始累计值（开机以来），调试用
  final int rawValue;

  /// 传感器是否可读
  final bool available;

  final String? error;

  StepTrackerState copyWith({
    int? todaySteps,
    int? rawValue,
    bool? available,
    String? error,
    bool clearError = false,
  }) {
    return StepTrackerState(
      todaySteps: todaySteps ?? this.todaySteps,
      rawValue: rawValue ?? this.rawValue,
      available: available ?? this.available,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// 计步器。
///
/// 和轨迹最大的区别：**它不用 GPS，也不用前台服务**。
/// 数据来自手机里的硬件计步芯片（微信运动用的也是这颗），
/// 那颗芯片常年开着、几乎不耗电，系统层面一直在计数。
///
/// 关键机制：传感器给的是「开机以来的累计步数」，重启会清零。
/// 每次读到新值时，用「当前值 − 上次记录的值」算出这段的增量。
///
/// 为了省电和避免竞态，这里做了三件事：
/// - 传感器事件串行处理，不会两个回调抢着读同一个 lastRaw
/// - 当天数据先放内存，按时间/步数节流写库；即使进程被杀，
///   下次也能靠 lastRaw 把这段时间的增量补回来
/// - 跨天时按时间比例把增量拆给昨天和今天，而不是简单全算今天
class StepTracker extends Notifier<StepTrackerState> {
  StreamSubscription<StepCount>? _subscription;

  /// 串行化传感器事件
  Future<void> _queue = Future<void>.value();

  /// 单次增量超过这个值就认为异常（传感器抽风），不累加
  static const int _maxDelta = 20000;

  /// 距上次事件超过这么久，就无法合理分日，只能按时间比例粗略估算
  static const int _maxGapMs = 48 * 60 * 60 * 1000;

  static const int _persistIntervalMs = 5000;
  static const int _persistStepDelta = 20;
  static const int _uiIntervalMs = 500;

  String? _currentDateKey;
  int _todaySteps = 0;
  int _lastRaw = 0;
  int _lastEventAt = 0;
  int _lastPersistedSteps = 0;
  int _lastPersistedAt = 0;
  int _lastUiAt = 0;
  bool _hasBaseline = false;

  @override
  StepTrackerState build() {
    ref.onDispose(() => _subscription?.cancel());
    return const StepTrackerState();
  }

  Future<void> start() async {
    if (_subscription != null) return;

    // Android 10+ 读计步传感器需要「身体活动」权限
    final PermissionStatus status = await Permission.activityRecognition
        .request();
    if (!status.isGranted) {
      state = state.copyWith(error: '需要「身体活动」权限才能计步。到系统设置里允许后重试。');
      return;
    }

    // 先把已存的今日数据和基线读进内存，不用等传感器回调
    await _hydrate();

    try {
      _subscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: (Object e) {
          state = state.copyWith(available: false, error: '这台设备读不到计步传感器：$e');
        },
      );
    } catch (e) {
      state = state.copyWith(available: false, error: '计步启动失败：$e');
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    unawaited(_persist(force: true));
  }

  StepDao get _dao => ref.read(stepDaoProvider);

  /// 启动时把今天的记录和传感器基线读进内存。
  Future<void> _hydrate() async {
    final DateTime now = DateTime.now();
    _currentDateKey = _dateKey(now);

    final DailyStep? today = await _dao.getByDate(_currentDateKey!);
    if (today != null) {
      _todaySteps = today.steps;
      _lastRaw = today.lastRaw;
      _lastEventAt = today.updatedAt;
      _lastPersistedSteps = today.steps;
      _lastPersistedAt = today.updatedAt;
      _hasBaseline = true;
      state = state.copyWith(todaySteps: today.steps, rawValue: today.lastRaw);
      return;
    }

    final DailyStep? prev = await _dao.getLatest();
    if (prev != null) {
      _lastRaw = prev.lastRaw;
      _lastEventAt = prev.updatedAt;
      _lastPersistedAt = prev.updatedAt;
      _hasBaseline = true;
    }
    state = state.copyWith(todaySteps: 0, rawValue: prev?.lastRaw ?? 0);
  }

  void _onStepCount(StepCount event) {
    // 传感器底层用最快频率回调，必须串行处理，否则两个事件会基于
    // 同一个 lastRaw 计算增量，后写的覆盖前写的，长期下来步数偏低。
    _queue = _queue.then((_) => _process(event)).catchError((Object e) {
      state = state.copyWith(error: '计步数据处理失败：$e');
    });
  }

  Future<void> _process(StepCount event) async {
    final DateTime now = DateTime.now();
    final int nowMs = now.millisecondsSinceEpoch;
    final String todayKey = _dateKey(now);

    // 第一次拿到读数：只建立基线。传感器值是开机以来的累计值，
    // 直接当成今天步数会虚高。
    if (!_hasBaseline) {
      _hasBaseline = true;
      _currentDateKey = todayKey;
      _lastRaw = event.steps;
      _lastEventAt = nowMs;
      await _persist(force: true);
      _updateUi(nowMs, force: true);
      return;
    }

    int delta = event.steps - _lastRaw;

    // 传感器值倒退 = 手机重启过。重设基线，这一轮不累加。
    if (delta < 0) {
      _lastRaw = event.steps;
      _lastEventAt = nowMs;
      if (_currentDateKey != todayKey) {
        _currentDateKey = todayKey;
        _todaySteps = 0;
        _lastPersistedSteps = 0;
      }
      await _persist(force: true);
      _updateUi(nowMs, force: true);
      return;
    }

    // 单次跳变过大，当传感器异常，只重设基线
    if (delta > _maxDelta) {
      _lastRaw = event.steps;
      _lastEventAt = nowMs;
      await _persist(force: true);
      _updateUi(nowMs, force: true);
      return;
    }

    final DateTime todayStart = DateTime(now.year, now.month, now.day);
    final int todayStartMs = todayStart.millisecondsSinceEpoch;
    final int totalSpan = nowMs - _lastEventAt;

    // 隔了两天以上没打开 App：无法精确分日，按“今天占这段时长的比例”
    // 估算今天的步数，宁可少算也不要把几天的步数全砸到今天。
    if (totalSpan > _maxGapMs) {
      final int todaySpan =
          nowMs - (todayStartMs > _lastEventAt ? todayStartMs : _lastEventAt);
      final double fraction = totalSpan > 0
          ? (todaySpan / totalSpan).clamp(0.0, 1.0)
          : 1.0;
      _currentDateKey = todayKey;
      _todaySteps = (delta * fraction).round();
      _lastPersistedSteps = 0;
      _lastRaw = event.steps;
      _lastEventAt = nowMs;
      await _persist(force: true);
      _updateUi(nowMs, force: true);
      return;
    }

    if (_currentDateKey != todayKey || _lastEventAt < todayStartMs) {
      // 跨天：把这段增量按时间比例拆给昨天和今天。
      // 例：昨晚 21:00 到今早 08:00 共走了 1100 步，今天占 8/11，
      // 那么约 800 步算今天，300 步补到昨天的记录里。
      final int todaySpan =
          nowMs - (todayStartMs > _lastEventAt ? todayStartMs : _lastEventAt);
      final double todayFraction = totalSpan > 0
          ? (todaySpan / totalSpan).clamp(0.0, 1.0)
          : 1.0;
      final int todayDelta = (delta * todayFraction).round();
      final int yesterdayDelta = delta - todayDelta;

      if (yesterdayDelta > 0) {
        final String prevKey = _dateKey(
          DateTime.fromMillisecondsSinceEpoch(_lastEventAt),
        );
        final DailyStep? prevRow = await _dao.getByDate(prevKey);
        await _dao.upsert(
          prevKey,
          steps: (prevRow?.steps ?? 0) + yesterdayDelta,
          lastRaw: _lastRaw + yesterdayDelta,
        );
      }

      _currentDateKey = todayKey;
      _todaySteps = todayDelta;
      _lastPersistedSteps = 0;
      _lastRaw = event.steps;
      _lastEventAt = nowMs;
    } else {
      _todaySteps += delta;
      _lastRaw = event.steps;
      _lastEventAt = nowMs;
    }

    await _persist();
    _updateUi(nowMs);
  }

  /// 写库节流：每 5 秒或累计 20 步写一次。
  ///
  /// 即使进程在这之前被杀，lastRaw 里的基线也还是旧的，
  /// 下次启动会把这段增量补回来，不会丢步数。
  Future<void> _persist({bool force = false}) async {
    final String? day = _currentDateKey;
    if (day == null) return;

    final int now = DateTime.now().millisecondsSinceEpoch;
    if (!force &&
        now - _lastPersistedAt < _persistIntervalMs &&
        (_todaySteps - _lastPersistedSteps).abs() < _persistStepDelta) {
      return;
    }

    await _dao.upsert(day, steps: _todaySteps, lastRaw: _lastRaw);
    _lastPersistedSteps = _todaySteps;
    _lastPersistedAt = now;
  }

  void _updateUi(int nowMs, {bool force = false}) {
    if (!force && nowMs - _lastUiAt < _uiIntervalMs) return;
    _lastUiAt = nowMs;
    state = state.copyWith(
      todaySteps: _todaySteps,
      rawValue: _lastRaw,
      available: true,
      clearError: true,
    );
  }

  static String _dateKey(DateTime t) {
    final String m = t.month.toString().padLeft(2, '0');
    final String d = t.day.toString().padLeft(2, '0');
    return '${t.year}-$m-$d';
  }
}

final stepDaoProvider = Provider<StepDao>(
  (Ref ref) => StepDao(ref.watch(appDatabaseProvider)),
);

final stepTrackerProvider = NotifierProvider<StepTracker, StepTrackerState>(
  StepTracker.new,
);

/// 今天的步数（直接读库，用于展示）。
final todayStepRecordProvider = StreamProvider<DailyStep?>(
  (Ref ref) => ref
      .watch(stepDaoProvider)
      .watchByDate(StepTracker._dateKey(DateTime.now())),
);
