import 'package:drift/drift.dart';

import 'track_sessions.dart';

/// 轨迹点。
///
/// 同时保存 WGS84 与 GCJ-02 两套坐标：
/// - WGS84 是定位芯片给出的真值，导出 GPX / 换地图 / 做分析都用它
/// - GCJ-02 是高德底图需要的有偏坐标，画图时直接用，省得每次转换
@DataClassName('TrackPoint')
class TrackPoints extends Table {
  @override
  String get tableName => 'track_points';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get sessionId => integer()
      .references(TrackSessions, #id, onDelete: KeyAction.cascade)();

  RealColumn get latWgs => real()();

  RealColumn get lngWgs => real()();

  RealColumn get latGcj => real().nullable()();

  RealColumn get lngGcj => real().nullable()();

  RealColumn get altitude => real().nullable()();

  /// 水平精度（米）
  RealColumn get accuracy => real().nullable()();

  /// 速度（米/秒）
  RealColumn get speed => real().nullable()();

  /// 方位角
  RealColumn get bearing => real().nullable()();

  /// gps | network | fused
  TextColumn get provider => text().nullable()();

  /// 采样时的电量快照，方便排查耗电
  IntColumn get battery => integer().nullable()();

  IntColumn get recordedAt => integer()();
}
