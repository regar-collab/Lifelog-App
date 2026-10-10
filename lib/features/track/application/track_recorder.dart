import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifelog/core/utils/coordinate.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/db/daos/settings_dao.dart';
import 'package:lifelog/features/settings/application/app_settings_providers.dart';
import 'package:lifelog/features/track/application/track_foreground_service.dart';
import 'package:lifelog/features/track/application/track_providers.dart';
import 'package:lifelog/features/track/data/track_repository.dart';
import 'package:permission_handler/permission_handler.dart';

/// 采集器的对外状态。
class TrackRecorderState {
  const TrackRecorderState({
    this.recording = false,
    this.sessionId,
    this.bufferedCount = 0,
    this.lastLat,
    this.lastLng,
    this.error,
    this.warning,
    this.starting = false,
  });

  final bool recording;
  final int? sessionId;
  final int bufferedCount;
  final double? lastLat;
  final double? lastLng;

  /// 致命问题：记录起不来
  final String? error;

  /// 不致命但值得提醒：比如没给后台定位权限，锁屏后可能断
  final String? warning;

  final bool starting;

  TrackRecorderState copyWith({
    bool? recording,
    int? sessionId,
    int? bufferedCount,
    double? lastLat,
    double? lastLng,
    String? error,
    String? warning,
    bool? starting,
    bool clearError = false,
    bool clearWarning = false,
  }) {
    return TrackRecorderState(
      recording: recording ?? this.recording,
      sessionId: sessionId ?? this.sessionId,
      bufferedCount: bufferedCount ?? this.bufferedCount,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      error: clearError ? null : (error ?? this.error),
      warning: clearWarning ? null : (warning ?? this.warning),
      starting: starting ?? this.starting,
    );
  }
}

/// 轨迹采集器。
///
/// 采集策略：
/// - 用 geolocator 的位置流，`distanceFilter` 让系统只在移动超过阈值时回调，
///   站着不动几乎不耗电（这是控制耗电的主要手段）
/// - 回调里把 WGS84 转成 GCJ-02 一起存下来，画图时不用再转
/// - 点先攒在内存里，够一批或过一段时间再批量写库
///
/// 精度档位由设置页决定（省电 / 平衡 / 高精度），因为它直接决定耗电量。
class TrackRecorder extends Notifier<TrackRecorderState> {
  StreamSubscription<Position>? _subscription;
  Timer? _flushTimer;

  final List<TrackPointsCompanion> _buffer = [];

  /// 攒够多少个点就写一次库
  static const int _flushThreshold = 5;

  @override
  TrackRecorderState build() {
    ref.onDispose(_cleanup);
    return const TrackRecorderState();
  }

  TrackRepository get _repo => ref.read(trackRepositoryProvider);

  /// 开始记录。
  Future<void> start() async {
    if (state.recording || state.starting) return;
    state = state.copyWith(starting: true, clearError: true, clearWarning: true);

    try {
      final String? problem = await _ensureLocationPermission();
      if (problem != null) {
        state = state.copyWith(starting: false, error: problem);
        return;
      }

      // 后台定位权限：拿不到不阻断，但要让用户知道锁屏后可能断
      final String? backgroundWarning = await _ensureBackgroundPermission();

      final bool hasNotification =
          await TrackForegroundService.ensureNotificationPermission();
      if (!hasNotification) {
        state = state.copyWith(
          starting: false,
          error: '需要通知权限才能显示记录状态。请到系统设置里允许 Lifelog 发送通知。',
        );
        return;
      }

      if (!await TrackForegroundService.isIgnoringBatteryOptimizations()) {
        TrackForegroundService.requestIgnoreBatteryOptimization();
      }

      final ServiceRequestResult serviceResult =
          await TrackForegroundService.start();
      if (serviceResult is ServiceRequestFailure) {
        state = state.copyWith(
          starting: false,
          error: '前台服务启动失败：${serviceResult.error}',
        );
        return;
      }

      final TrackAccuracyLevel level =
          await _resolveAccuracyLevel();

      final DateTime now = DateTime.now();
      final TrackSession session =
          await _repo.startSessionAndReturn(now.millisecondsSinceEpoch);

      _subscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: _toGeolocatorAccuracy(level),
          // 移动不足这个距离就不回调 —— 既省电又避免静止时的坐标漂移
          distanceFilter: _distanceFilterFor(level),
        ),
      ).listen(_onPosition, onError: _onStreamError);

      _flushTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _flush(),
      );

      state = state.copyWith(
        recording: true,
        starting: false,
        sessionId: session.id,
        bufferedCount: 0,
        warning: backgroundWarning,
      );

      await TrackForegroundService.updateText(
        '正在记录 · ${level.label}档',
      );
    } catch (e) {
      state = state.copyWith(starting: false, error: '启动失败：$e');
    }
  }

  /// 停止记录并收尾：落掉缓冲、结束会话、结算里程、关掉前台服务。
  Future<void> stop({String status = 'finished'}) async {
    final int? sessionId = state.sessionId;
    if (sessionId == null) return;

    await _subscription?.cancel();
    _subscription = null;
    _flushTimer?.cancel();
    _flushTimer = null;

    await _flush();
    await _repo.finishSession(
      sessionId,
      at: DateTime.now().millisecondsSinceEpoch,
      status: status,
    );

    await TrackForegroundService.stop();

    state = const TrackRecorderState();
  }

  Future<void> _flush() async {
    if (_buffer.isEmpty) return;

    final List<TrackPointsCompanion> batch = List.of(_buffer);
    _buffer.clear();

    try {
      await _repo.insertPoints(batch);
      state = state.copyWith(bufferedCount: 0);

      final int? sessionId = state.sessionId;
      if (sessionId != null) {
        final TrackSummary summary = await _repo.summarise(sessionId);
        await TrackForegroundService.updateText(
          '已记录 ${summary.distanceKm} 公里 · ${summary.pointCount} 个点',
        );
      }
    } catch (e) {
      // 写失败就把点放回去，下一轮再试，别丢数据
      _buffer.insertAll(0, batch);
      state = state.copyWith(error: '写入失败：$e');
    }
  }

  void _onPosition(Position position) {
    final int? sessionId = state.sessionId;
    if (sessionId == null) return;

    // GPS 给的是 WGS84，高德底图要 GCJ-02，两套都存下来
    final LatLng gcj = CoordinateConverter.wgs84ToGcj02(
      position.latitude,
      position.longitude,
    );

    _buffer.add(
      TrackPointsCompanion.insert(
        sessionId: sessionId,
        latWgs: position.latitude,
        lngWgs: position.longitude,
        latGcj: Value(gcj.lat),
        lngGcj: Value(gcj.lng),
        altitude: Value(position.altitude),
        accuracy: Value(position.accuracy),
        speed: Value(position.speed),
        bearing: Value(position.heading),
        provider: const Value('gps'),
        recordedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    state = state.copyWith(
      bufferedCount: _buffer.length,
      lastLat: position.latitude,
      lastLng: position.longitude,
    );

    if (_buffer.length >= _flushThreshold) {
      _flush();
    }
  }

  void _onStreamError(Object error) {
    state = state.copyWith(error: '定位中断：$error');
  }

  // ── 精度档位 ──────────────────────────────────────────────

  Future<TrackAccuracyLevel> _resolveAccuracyLevel() async {
    final SettingsDao dao = ref.read(settingsDaoProvider);
    final String id = await dao.getOrDefault(
      SettingKeys.trackAccuracy,
      TrackAccuracyLevel.balanced.id,
    );
    return TrackAccuracyLevel.fromId(id);
  }

  LocationAccuracy _toGeolocatorAccuracy(TrackAccuracyLevel level) {
    return switch (level) {
      // geolocator 没有 balanced，最接近的是 medium
      TrackAccuracyLevel.low => LocationAccuracy.low,
      TrackAccuracyLevel.balanced => LocationAccuracy.medium,
      TrackAccuracyLevel.high => LocationAccuracy.high,
    };
  }

  /// 精度越高，允许的采样间距越小 —— 两者一起决定耗电。
  int _distanceFilterFor(TrackAccuracyLevel level) {
    return switch (level) {
      TrackAccuracyLevel.low => 50,
      TrackAccuracyLevel.balanced => 15,
      TrackAccuracyLevel.high => 10,
    };
  }

  // ── 权限 ──────────────────────────────────────────────────

  /// 前台定位权限。返回 null 表示没问题。
  Future<String?> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return '手机的定位服务没打开，请到系统设置里打开定位';
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return '定位权限被拒绝，无法记录轨迹';
    }
    if (permission == LocationPermission.deniedForever) {
      return '定位权限被永久拒绝，需要到系统设置里手动开启';
    }

    return null;
  }

  /// 后台定位权限（Android 10+）。
  ///
  /// 这是「锁屏后还能不能记录」的关键。Android 11+ 规定它不能和前台权限
  /// 一起弹窗，必须单独走一次（会跳到系统设置页让用户选「始终允许」）。
  ///
  /// 拿不到不阻断记录 —— 前台时照样能采，只是锁屏后会断。返回给用户看的提醒。
  Future<String?> _ensureBackgroundPermission() async {
    if (!Platform.isAndroid) return null;

    final PermissionStatus status = await Permission.locationAlways.status;
    if (status.isGranted) return null;

    final PermissionStatus result = await Permission.locationAlways.request();
    if (result.isGranted) return null;

    return '还没获得「始终允许」的定位权限，锁屏后轨迹可能会断。'
        '建议到系统设置里把它改成「始终允许」。';
  }

  void _cleanup() {
    _subscription?.cancel();
    _flushTimer?.cancel();
  }
}
