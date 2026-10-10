import 'package:lifelog/core/utils/coordinate.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/db/daos/track_dao.dart';

/// 一次采集会话的统计摘要。
class TrackSummary {
  const TrackSummary({
    required this.pointCount,
    required this.distanceM,
    this.firstAt,
    this.lastAt,
  });

  final int pointCount;
  final double distanceM;
  final int? firstAt;
  final int? lastAt;

  /// 公里数，保留两位
  String get distanceKm => (distanceM / 1000).toStringAsFixed(2);

  /// 时长（分钟）
  int get durationMinutes {
    final int? a = firstAt;
    final int? b = lastAt;
    if (a == null || b == null) return 0;
    return ((b - a) / 60000).round();
  }
}

/// 轨迹的业务操作。
class TrackRepository {
  TrackRepository(this._dao);

  final TrackDao _dao;

  Stream<List<TrackSession>> watchSessions() => _dao.watchSessions();

  Future<TrackSession?> getActiveSession() => _dao.getActiveSession();

  Future<TrackSession?> findSession(int id) => _dao.findSession(id);

  Future<List<TrackPoint>> getPoints(int sessionId) =>
      _dao.getPoints(sessionId);

  Future<int> deleteSession(int id) => _dao.deleteSession(id);

  /// 最近一次会话的 id（地图默认显示它）。
  Future<int?> latestSessionId() async {
    final List<TrackSession> list = await _dao.watchSessions(limit: 1).first;
    return list.isEmpty ? null : list.first.id;
  }

  /// 开一段新会话并把行对象返回（采集器需要拿到 id）。
  Future<TrackSession> startSessionAndReturn(int at) async {
    final int id = await _dao.startSession(at);
    final TrackSession? session = await _dao.findSession(id);
    if (session == null) {
      throw StateError('会话创建后读不回来，数据库可能异常');
    }
    return session;
  }

  Future<void> finishSession(
    int sessionId, {
    required int at,
    required String status,
  }) {
    return _dao.finishSession(sessionId, at: at, status: status);
  }

  Future<void> insertPoints(List<TrackPointsCompanion> points) =>
      _dao.insertPoints(points);

  /// 某段会话的统计（从已有的点算，不依赖会话表里缓存的字段）。
  Future<TrackSummary> summarise(int sessionId) async {
    final List<TrackPoint> points = await _dao.getPoints(sessionId);
    return _summarisePoints(points);
  }

  /// 今天的统计：把所有会话的点合起来算。
  Future<TrackSummary> todaySummary() async {
    final List<TrackPoint> points = await _dao.getPointsByDay(DateTime.now());
    return _summarisePoints(points);
  }

  TrackSummary _summarisePoints(List<TrackPoint> points) {
    if (points.isEmpty) {
      return const TrackSummary(pointCount: 0, distanceM: 0);
    }

    double distance = 0;
    for (int i = 1; i < points.length; i++) {
      distance += CoordinateConverter.distanceMeters(
        points[i - 1].latWgs,
        points[i - 1].lngWgs,
        points[i].latWgs,
        points[i].lngWgs,
      );
    }

    return TrackSummary(
      pointCount: points.length,
      distanceM: distance,
      firstAt: points.first.recordedAt,
      lastAt: points.last.recordedAt,
    );
  }
}
