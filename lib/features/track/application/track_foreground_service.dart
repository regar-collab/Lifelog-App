import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:lifelog/core/constants/app_constants.dart';
import 'package:lifelog/features/track/application/track_task_handler.dart';

/// 轨迹采集用的前台服务。
///
/// 这是「全天记录」能不能成立的关键：
/// 没有它，App 一退到后台就会被系统限制，位置流断掉，轨迹就断了。
class TrackForegroundService {
  TrackForegroundService._();

  static bool _initialized = false;

  /// 申请通知权限 —— Android 13+ 没有它，前台服务的常驻通知不显示，
  /// 服务会被系统判定为「没有可见通知」而拒绝启动。
  static Future<bool> ensureNotificationPermission() async {
    final NotificationPermission permission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (permission == NotificationPermission.granted) return true;

    final NotificationPermission result =
        await FlutterForegroundTask.requestNotificationPermission();
    return result == NotificationPermission.granted;
  }

  /// 引导用户关闭电池优化。
  ///
  /// 国内 ROM（你这台 iQOO 就是重灾区）对后台限制极狠，
  /// 不关掉电池优化的话，前台服务也可能被掐。
  static Future<bool> isIgnoringBatteryOptimizations() {
    return FlutterForegroundTask.isIgnoringBatteryOptimizations;
  }

  /// 注意：插件这个方法返回 void（它会跳到系统设置页），不是 Future。
  static void requestIgnoreBatteryOptimization() {
    FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }

  /// App 启动时调一次。重复调用是安全的。
  ///
  /// 插件这个 init 返回 void（不是 Future），所以不要 await。
  static void init() {
    if (_initialized) return;
    _initialized = true;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: AppConstants.trackChannelId,
        channelName: AppConstants.trackChannelName,
        channelDescription: AppConstants.trackChannelDesc,
        onlyAlertOnce: true, // 更新通知内容时不重复响铃
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // 30 秒一次的心跳。采集不靠它，只是让服务有稳定的活动节奏。
        eventAction: ForegroundTaskEventAction.repeat(30000),
        // 不开机自启：用户没开记录时不该有常驻通知
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// 启动前台服务。类型必须是 location，否则 Android 14+ 直接拒绝启动。
  static Future<ServiceRequestResult> start() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    }

    return FlutterForegroundTask.startService(
      serviceId: AppConstants.trackNotificationId,
      serviceTypes: const [ForegroundServiceTypes.location],
      notificationTitle: '轨迹记录中',
      notificationText: '正在记录你的位置',
      notificationIcon: null,
      callback: trackServiceCallback,
    );
  }

  /// 更新通知文字（比如显示已记录的点数 / 里程）。
  static Future<ServiceRequestResult> updateText(String text) {
    return FlutterForegroundTask.updateService(notificationText: text);
  }

  static Future<ServiceRequestResult> stop() {
    return FlutterForegroundTask.stopService();
  }

  static Future<bool> isRunning() => FlutterForegroundTask.isRunningService;
}
