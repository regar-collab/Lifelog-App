import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/core/utils/coordinate.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/db/daos/track_dao.dart';
import 'package:lifelog/data/db/database_provider.dart';
import 'package:lifelog/features/track/application/track_recorder.dart';
import 'package:lifelog/features/track/data/track_repository.dart';

// 手写 provider，原因见 inbox_providers.dart（riverpod_generator 解析不了
// drift_dev 生成的行类）。

/// 轨迹的数据库操作。
final trackDaoProvider = Provider<TrackDao>(
  (Ref ref) => TrackDao(ref.watch(appDatabaseProvider)),
);

/// 轨迹业务入口。
final trackRepositoryProvider = Provider<TrackRepository>(
  (Ref ref) => TrackRepository(ref.watch(trackDaoProvider)),
);

/// 采集器：负责权限、定位流、批量落库。
final trackRecorderProvider =
    NotifierProvider<TrackRecorder, TrackRecorderState>(TrackRecorder.new);

/// 历史轨迹会话，新→旧。
final trackSessionsProvider = StreamProvider<List<TrackSession>>(
  (Ref ref) => ref.watch(trackRepositoryProvider).watchSessions(),
);

/// 今天的汇总：点数、里程、时长。
///
/// 依赖采集器的 bufferedCount —— 采集过程中每落一批点就刷新一次统计。
final todaySummaryProvider = FutureProvider<TrackSummary>((Ref ref) async {
  // 订阅一下采集状态，落库批次变化时自动重算
  ref.watch(
    trackRecorderProvider.select((TrackRecorderState s) => s.bufferedCount),
  );
  return ref.watch(trackRepositoryProvider).todaySummary();
});

/// 要画在地图上的轨迹点（GCJ-02 坐标）。
///
/// 正在记录时显示当前会话，否则显示最近一次会话。
final trackMapPointsProvider = FutureProvider.autoDispose<List<LatLng>>((
  Ref ref,
) async {
  // 采集每落一批点就重画一次
  ref.watch(
    trackRecorderProvider.select((TrackRecorderState s) => s.bufferedCount),
  );

  final TrackRepository repo = ref.watch(trackRepositoryProvider);
  final TrackRecorderState recorder = ref.watch(trackRecorderProvider);

  final int? sessionId = recorder.sessionId ?? await repo.latestSessionId();
  if (sessionId == null) return const [];

  final List<TrackPoint> points = await repo.getPoints(sessionId);

  // 只取有 GCJ-02 的点 —— 高德底图要的就是这套坐标
  return points
      .where((TrackPoint p) => p.latGcj != null && p.lngGcj != null)
      .map((TrackPoint p) => LatLng(p.latGcj!, p.lngGcj!))
      .toList();
});
