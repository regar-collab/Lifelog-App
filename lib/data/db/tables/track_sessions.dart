import 'package:drift/drift.dart';

/// 轨迹会话。默认一天一段，也可按手动开关切分。
@DataClassName('TrackSession')
class TrackSessions extends Table {
  @override
  String get tableName => 'track_sessions';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get startAt => integer()();

  IntColumn get endAt => integer().nullable()();

  IntColumn get pointCount => integer().withDefault(const Constant(0))();

  /// 累计距离（米）
  RealColumn get distanceM => real().withDefault(const Constant(0))();

  /// recording | finished | interrupted（被系统杀掉的那段）
  TextColumn get status => text().withDefault(const Constant('recording'))();

  IntColumn get createdAt => integer()();
}
