import 'package:drift/drift.dart';

/// 每次「AI 整理」的执行记录。
///
/// 这张表是 AI 幂等和排障的命脉：
/// - inputItemIds 记录这次整理了哪些收集箱条目，避免重复整理
/// - rawResponse 保留原始返回，解析失败时能救回数据
@DataClassName('AiRun')
class AiRuns extends Table {
  @override
  String get tableName => 'ai_runs';

  IntColumn get id => integer().autoIncrement()();

  /// running | success | failed
  TextColumn get status => text()();

  /// 实际调用的模型名
  TextColumn get model => text()();

  /// JSON 数组，本次参与的收集箱条目 id
  TextColumn get inputItemIds => text().nullable()();

  /// 完整 prompt，便于复盘
  TextColumn get requestPrompt => text().nullable()();

  /// 模型原始返回
  TextColumn get rawResponse => text().nullable()();

  /// 本次生成了几条日程
  IntColumn get createdCount => integer().withDefault(const Constant(0))();

  TextColumn get errorMessage => text().nullable()();

  IntColumn get promptTokens => integer().nullable()();

  IntColumn get completionTokens => integer().nullable()();

  IntColumn get startedAt => integer()();

  IntColumn get finishedAt => integer().nullable()();
}
