import 'package:drift/drift.dart';

import 'ai_runs.dart';

/// 日程表。AI 自动填入，用户也能手动增删改。
@DataClassName('Schedule')
class Schedules extends Table {
  @override
  String get tableName => 'schedules';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  /// 开始时间（毫秒时间戳）
  IntColumn get startAt => integer()();

  /// 结束时间，可空 = 没有明确结束点
  IntColumn get endAt => integer().nullable()();

  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();

  TextColumn get location => text().nullable()();

  /// 0 普通 / 1 重要
  IntColumn get priority => integer().withDefault(const Constant(0))();

  /// planned | done | cancelled
  TextColumn get status => text().withDefault(const Constant('planned'))();

  /// manual（手动建）| ai（AI 整理生成）| ai-edited（AI 生成后被用户改过）
  TextColumn get origin => text().withDefault(const Constant('manual'))();

  /// 由哪次 AI 整理产生，便于整批撤销
  IntColumn get aiRunId => integer().nullable().references(
    AiRuns,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// JSON 数组，溯源到收集箱条目 id
  TextColumn get sourceItemIds => text().nullable()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();
}
