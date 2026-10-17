import 'package:drift/drift.dart';
import 'package:lifelog/data/db/app_database.dart';

part 'ai_run_dao.g.dart';

/// 整理记录列表用的轻量行。
///
/// 不把 prompt / rawResponse 一起查出来：这两列可能有几十 KB，
/// 列表页没必要为了显示一行摘要把它们全留在内存里。
class AiRunSummary {
  const AiRunSummary({
    required this.id,
    required this.status,
    required this.model,
    required this.createdCount,
    required this.startedAt,
    this.errorMessage,
    this.finishedAt,
  });

  final int id;
  final String status;
  final String model;
  final int createdCount;
  final int startedAt;
  final String? errorMessage;
  final int? finishedAt;
}

/// AI 整理记录的数据库操作。
@DriftAccessor(tables: [AiRuns])
class AiRunDao extends DatabaseAccessor<AppDatabase> with _$AiRunDaoMixin {
  AiRunDao(super.db);

  /// 最近的整理记录，新→旧。
  Stream<List<AiRun>> watchRecent({int limit = 30}) {
    return (select(aiRuns)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(limit))
        .watch();
  }

  /// 列表页只需要摘要字段，避免把整段 prompt / 原始返回常驻内存。
  Stream<List<AiRunSummary>> watchRecentSummaries({int limit = 30}) {
    final query = selectOnly(aiRuns)
      ..addColumns([
        aiRuns.id,
        aiRuns.status,
        aiRuns.model,
        aiRuns.createdCount,
        aiRuns.startedAt,
        aiRuns.errorMessage,
        aiRuns.finishedAt,
      ])
      ..orderBy([OrderingTerm.desc(aiRuns.startedAt)])
      ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((row) {
        return AiRunSummary(
          id: row.read(aiRuns.id)!,
          status: row.read(aiRuns.status)!,
          model: row.read(aiRuns.model)!,
          createdCount: row.read(aiRuns.createdCount) ?? 0,
          startedAt: row.read(aiRuns.startedAt)!,
          errorMessage: row.read(aiRuns.errorMessage),
          finishedAt: row.read(aiRuns.finishedAt),
        );
      }).toList();
    });
  }

  Future<int> insertRun(AiRunsCompanion entry) => into(aiRuns).insert(entry);

  Future<bool> updateRun(AiRun run) => update(aiRuns).replace(run);

  Future<AiRun?> findById(int id) =>
      (select(aiRuns)..where((t) => t.id.equals(id))).getSingleOrNull();
}
