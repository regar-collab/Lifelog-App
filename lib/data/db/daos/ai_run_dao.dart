import 'package:drift/drift.dart';
import 'package:lifelog/data/db/app_database.dart';

part 'ai_run_dao.g.dart';

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

  Future<int> insertRun(AiRunsCompanion entry) => into(aiRuns).insert(entry);

  Future<bool> updateRun(AiRun run) => update(aiRuns).replace(run);

  Future<AiRun?> findById(int id) =>
      (select(aiRuns)..where((t) => t.id.equals(id))).getSingleOrNull();
}
