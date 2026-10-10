import 'package:drift/drift.dart';
import 'package:lifelog/core/utils/coordinate.dart';
import 'package:lifelog/data/db/app_database.dart';

part 'track_dao.g.dart';

/// 轨迹的数据库操作。
@DriftAccessor(tables: [TrackSessions, TrackPoints])
class TrackDao extends DatabaseAccessor<AppDatabase> with _$TrackDaoMixin {
  TrackDao(super.db);

  // ── 会话 ──────────────────────────────────────────────────

  /// 当前正在录制的会话（没有则返回 null）。
  Future<TrackSession?> getActiveSession() {
    return (select(trackSessions)
          ..where((t) => t.status.equals('recording'))
          ..orderBy([(t) => OrderingTerm.desc(t.startAt)]))
        .getSingleOrNull();
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
    return into(trackSessions).insert(
      TrackSessionsCompanion.insert(startAt: at, createdAt: at),
    );
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
    final int from =
        DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
    final int to = from + const Duration(days: 1).inMilliseconds;

    return (select(trackPoints)
          ..where((t) =>
              t.recordedAt.isBiggerOrEqualValue(from) &
              t.recordedAt.isSmallerThanValue(to))
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
  Future<double> _sumDistance(int sessionId) async {
    final List<TrackPoint> points = await getPoints(sessionId);

    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += CoordinateConverter.distanceMeters(
        points[i - 1].latWgs,
        points[i - 1].lngWgs,
        points[i].latWgs,
        points[i].lngWgs,
      );
    }
    return total;
  }
}
