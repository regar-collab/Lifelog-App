import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// 前台服务的任务处理器。
///
/// **这个类运行在独立 isolate**，不是主 isolate —— 所以它不碰数据库、
/// 不碰 Riverpod，只负责让服务活着。
///
/// 真正的定位采集放在主 isolate 做（见 track_recorder.dart）：
/// 有了前台服务，App 进程不会被系统冻结，geolocator 的位置流就能一直回调。
/// 反过来如果在这里采集，就要面对「两个 isolate 同时写 SQLite」的麻烦。
class TrackTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // 服务已启动，无需额外动作
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // 周期性回调，这里刻意留空。
    // 采集不依赖它，保留只是让服务有一个稳定的「活着」的表现。
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // 服务被销毁。不在这里做收尾 —— 收尾由主 isolate 的 stop() 负责，
    // 免得两个 isolate 抢着写同一条会话记录。
  }
}

/// 服务入口。必须是**顶层函数**并带 @pragma('vm:entry-point')，
/// 否则 release 版会被 tree-shaking 掉，服务起不来。
@pragma('vm:entry-point')
void trackServiceCallback() {
  FlutterForegroundTask.setTaskHandler(TrackTaskHandler());
}
