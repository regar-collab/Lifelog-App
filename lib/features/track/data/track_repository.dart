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
    this.durationMs,
  });

  final int pointCount;
  final double distanceM;
  final int? firstAt;
  final int? lastAt;

  /// 各会话时长之和。跨会话统计时不能用 last-first，
  /// 否则会把两段记录之间的空档也算成“记录时长”。
  final int? durationMs;

  /// 公里数，保留两位
  String get distanceKm => (distanceM / 1000).toStringAsFixed(2);

  /// 时长（分钟）
  int get durationMinutes {
    final int? d = durationMs;
    if (d != null) return (d / 60000).round();
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
  ///
  /// 必须按会话分组累加：上午和下午两段记录之间的位移不是“走”出来的，
  /// 直接按时间排序累加会把坐车/在家的距离也算进去。
  Future<TrackSummary> todaySummary() async {
    final List<TrackPoint> points = await _dao.getPointsByDay(DateTime.now());
    return _summarisePoints(points);
  }

  /// App 启动时，收尾上次没来得及正常结束的会话。
  ///
  /// 进程被杀、手机重启后，数据库里可能残留 status=recording 的会话。
  /// 不处理的话历史里会永远显示“记录中”，统计也失真。
  Future<int> recoverInterruptedSessions() async {
    final List<TrackSession> sessions = await _dao.getRecordingSessions();
    for (final TrackSession session in sessions) {
      final List<TrackPoint> points = await _dao.getPoints(session.id);
      final int at = points.isNotEmpty
          ? points.last.recordedAt
          : DateTime.now().millisecondsSinceEpoch;
      await _dao.finishSession(session.id, at: at, status: 'interrupted');
    }
    return sessions.length;
  }

  TrackSummary _summarisePoints(List<TrackPoint> points) {
    if (points.isEmpty) {
      return const TrackSummary(pointCount: 0, distanceM: 0);
    }

    // 相同会话的点放一组，组内才允许累加距离
    final Map<int, List<TrackPoint>> bySession = <int, List<TrackPoint>>{};
    int? firstAt;
    int? lastAt;
    for (final TrackPoint p in points) {
      bySession.putIfAbsent(p.sessionId, () => <TrackPoint>[]).add(p);
      if (firstAt == null || p.recordedAt < firstAt) firstAt = p.recordedAt;
      if (lastAt == null || p.recordedAt > lastAt) lastAt = p.recordedAt;
    }

    double distance = 0;
    int durationMs = 0;
    for (final List<TrackPoint> group in bySession.values) {
      group.sort(
        (TrackPoint a, TrackPoint b) => a.recordedAt.compareTo(b.recordedAt),
      );
      distance += _distanceForGroup(group);
      if (group.length > 1) {
        durationMs += group.last.recordedAt - group.first.recordedAt;
      }
    }

    return TrackSummary(
      pointCount: points.length,
      distanceM: distance,
      firstAt: firstAt,
      lastAt: lastAt,
      durationMs: durationMs,
    );
  }

  /// 组内里程。精度差于 100 米的点不参与计算，避免 GPS 漂移制造虚假里程；
  /// 相邻两点算出来的速度超过 45 m/s（约 162 km/h）也视为跳点。
  double _distanceForGroup(List<TrackPoint> points) {
    double total = 0;
    TrackPoint? previous;

    for (final TrackPoint p in points) {
      final bool usable = p.accuracy == null || p.accuracy! <= 100;
      if (!usable) {
        // 断掉这一段，避免把坏点前后的两个好点直接连成一条直线
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
        final bool plausible = dtMs > 0 ? d / (dtMs / 1000) <= 45 : d < 5;
        if (plausible) total += d;
      }
      previous = p;
    }

    return total;
  }
}
