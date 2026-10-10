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
/// 所以每次读到新值时，用「当前值 − 上次记录的值」算出这段的增量，
/// 累加到当天步数上。App 关着的时候芯片照样在数，重新打开时
/// 一次性把这期间走的路补上 —— 只要每天至少打开一次 App，数据就是准的。
class StepTracker extends Notifier<StepTrackerState> {
  StreamSubscription<StepCount>? _subscription;

  /// 单次增量超过这个值就认为异常（传感器抽风），不累加
  static const int _maxDelta = 20000;

  /// 距上次记录超过这么久，就不敢用它当基线了（会虚高）
  static const int _maxGapMs = 12 * 60 * 60 * 1000;

  @override
  StepTrackerState build() {
    ref.onDispose(() => _subscription?.cancel());
    return const StepTrackerState();
  }

  Future<void> start() async {
    if (_subscription != null) return;

    // Android 10+ 读计步传感器需要「身体活动」权限
    final PermissionStatus status =
        await Permission.activityRecognition.request();
    if (!status.isGranted) {
      state = state.copyWith(
        error: '需要「身体活动」权限才能计步。到系统设置里允许后重试。',
      );
      return;
    }

    // 先把已存的今日数据读出来显示，不用等传感器回调
    await _loadToday();

    try {
      _subscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: (Object e) {
          state = state.copyWith(
            available: false,
            error: '这台设备读不到计步传感器：$e',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(available: false, error: '计步启动失败：$e');
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _loadToday() async {
    final DailyStep? row =
        await _dao.getByDate(_dateKey(DateTime.now()));
    if (row == null) return;
    state = state.copyWith(todaySteps: row.steps, rawValue: row.lastRaw);
  }

  StepDao get _dao => ref.read(stepDaoProvider);

  Future<void> _onStepCount(StepCount event) async {
    final String today = _dateKey(DateTime.now());
    final DailyStep? row = await _dao.getByDate(today);

    int newSteps;

    if (row == null) {
      // 今天第一次读到传感器。
      //
      // 传感器只给「开机以来的累计值」，没有「今天从 0 开始」的概念，
      // 所以这里要自己选一个基线。策略：
      // - 距上次记录不到 12 小时（比如昨晚 App 还开着，今早再打开）
      //   → 用上次的值当基线，这样隔夜走的步数能算进今天，误差只有几小时
      // - 隔得太久（好几天没打开过 App）
      //   → 老实用当前值当基线，从 0 开始计。宁可少算，也不要把前几天的
      //     步数一股脑算到今天，那样数字会虚高得离谱
      final DailyStep? prev = await _dao.getLatest();
      final int now = DateTime.now().millisecondsSinceEpoch;

      final bool recentEnough = prev != null &&
          (now - prev.updatedAt) < _maxGapMs &&
          event.steps >= prev.lastRaw;

      if (recentEnough) {
        final int delta = event.steps - prev.lastRaw;
        newSteps = delta <= _maxDelta ? delta : 0;
      } else {
        newSteps = 0;
      }
    } else {
      final int delta = event.steps - row.lastRaw;

      if (delta < 0) {
        // 传感器值倒退了 —— 手机重启过，重新设基线，这轮不累加
        newSteps = row.steps;
      } else if (delta > _maxDelta) {
        // 单次跳变过大，当异常处理
        newSteps = row.steps;
      } else {
        newSteps = row.steps + delta;
      }
    }

    await _dao.upsert(today, steps: newSteps, lastRaw: event.steps);

    state = state.copyWith(
      todaySteps: newSteps,
      rawValue: event.steps,
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

final stepTrackerProvider =
    NotifierProvider<StepTracker, StepTrackerState>(StepTracker.new);

/// 今天的步数（直接读库，用于展示）。
final todayStepRecordProvider = StreamProvider<DailyStep?>(
  (Ref ref) => ref
      .watch(stepDaoProvider)
      .watchByDate(StepTracker._dateKey(DateTime.now())),
);
