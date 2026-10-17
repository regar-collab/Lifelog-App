import 'package:drift/drift.dart';
import 'package:lifelog/core/utils/coordinate.dart';
import 'package:lifelog/data/db/app_database.dart';

part 'track_dao.g.dart';

/// 轨迹的数据库操作。
@DriftAccessor(tables: [TrackSessions, TrackPoints])
class TrackDao extends DatabaseAccessor<AppDatabase> with _$TrackDaoMixin {
  TrackDao(super.db);

  // ── 会话 ──────────────────────────────────────────────────

  /// 当前正在录制的会话（没有则返回 null）。可能不止一条，用列表兜底。
  Future<List<TrackSession>> getRecordingSessions() {
    return (select(trackSessions)
          ..where((t) => t.status.equals('recording'))
          ..orderBy([(t) => OrderingTerm.desc(t.startAt)]))
        .get();
  }

  /// 当前正在录制的会话（没有则返回 null）。
  Future<TrackSession?> getActiveSession() async {
    final List<TrackSession> sessions = await getRecordingSessions();
    return sessions.isEmpty ? null : sessions.first;
  }

  /// 会话列表，新→旧。
  Stream<List<TrackSession>> watchSessions({int limit = 60}) {
    return (select(trackSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.startAt)])
          ..limit(limit))
        .watch();
  }

  Future<TrackSession?> findSession(int id) =>
      (select(trackSessions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> startSession(int at) {
    return into(trackSessions)
        .insert(TrackSessionsCompanion.insert(startAt: at, createdAt: at));
  }

  /// 结束会话：写结束时间，并结算点数与里程。
  Future<void> finishSession(
    int sessionId, {
    required int at,
    required String status,
  }) async {
    final int count = await _countPoints(sessionId);
    final double distance = await _sumDistance(sessionId);

    await (update(trackSessions)..where((t) => t.id.equals(sessionId))).write(
      TrackSessionsCompanion(
        endAt: Value(at),
        status: Value(status),
        pointCount: Value(count),
        distanceM: Value(distance),
      ),
    );
  }

  Future<int> deleteSession(int id) =>
      (delete(trackSessions)..where((t) => t.id.equals(id))).go();

  // ── 轨迹点 ────────────────────────────────────────────────

  /// 批量写点。15 秒采集一个，攒一批再写，避免频繁开事务。
  Future<void> insertPoints(List<TrackPointsCompanion> points) async {
    if (points.isEmpty) return;
    await batch((Batch b) => b.insertAll(trackPoints, points));
  }

  /// 某段会话的全部点，按时间正序（画线必须有序）。
  Future<List<TrackPoint>> getPoints(int sessionId) {
    return (select(trackPoints)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
        .get();
  }

  /// 某天的全部点（跨会话），用于「今天走了多少」这类统计。
  Future<List<TrackPoint>> getPointsByDay(DateTime day) {
    final int from = DateTime(
      day.year,
      day.month,
      day.day,
    ).millisecondsSinceEpoch;
    final int to = from + const Duration(days: 1).inMilliseconds;

    return (select(trackPoints)
          ..where(
            (t) =>
                t.recordedAt.isBiggerOrEqualValue(from) &
                t.recordedAt.isSmallerThanValue(to),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
        .get();
  }

  Future<int> _countPoints(int sessionId) async {
    final Expression<int> count = trackPoints.id.count();
    final query = selectOnly(trackPoints)
      ..addColumns([count])
      ..where(trackPoints.sessionId.equals(sessionId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// 会话总里程：相邻两点距离累加。
  ///
  /// 用 WGS84 原始坐标算 —— GCJ-02 是加了偏移的，算出来的距离会偏大。
  /// 精度差于 100 米的点直接跳过，并断开前后连接，避免 GPS 漂移刷里程。
  Future<double> _sumDistance(int sessionId) async {
    final List<TrackPoint> points = await getPoints(sessionId);

    double total = 0;
    TrackPoint? previous;
    for (final TrackPoint p in points) {
      final bool usable = p.accuracy == null || p.accuracy! <= 100;
      if (!usable) {
        previous = null;
        continue;
      }

      if (previous != null) {
        final double d = CoordinateConverter.distanceMeters(
          previous.latWgs,
          previous.lngWgs,
          p.latWgs,
          p.lngWgs,
        );
        final int dtMs = p.recordedAt - previous.recordedAt;
        // 速度超过 45 m/s（约 162 km/h）视为跳点
        if (dtMs > 0 ? d / (dtMs / 1000) <= 45 : d < 5) {
          total += d;
        }
      }
      previous = p;
    }
    return total;
  }
}
