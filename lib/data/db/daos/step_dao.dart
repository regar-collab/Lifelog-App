import 'package:drift/drift.dart';
import 'package:lifelog/data/db/app_database.dart';

part 'step_dao.g.dart';

/// 每日步数的读写。
@DriftAccessor(tables: [DailySteps])
class StepDao extends DatabaseAccessor<AppDatabase> with _$StepDaoMixin {
  StepDao(super.db);

  Future<DailyStep?> getByDate(String dateKey) {
    return (select(dailySteps)..where((t) => t.dateKey.equals(dateKey)))
        .getSingleOrNull();
  }

  Stream<DailyStep?> watchByDate(String dateKey) {
    return (select(dailySteps)..where((t) => t.dateKey.equals(dateKey)))
        .watchSingleOrNull();
  }

  Future<void> upsert(
    String dateKey, {
    required int steps,
    required int lastRaw,
  }) {
    return into(dailySteps).insertOnConflictUpdate(
      DailyStepsCompanion.insert(
        dateKey: dateKey,
        steps: Value(steps),
        lastRaw: Value(lastRaw),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// 最近几天的步数，新→旧。
  Stream<List<DailyStep>> watchRecent({int limit = 30}) {
    return (select(dailySteps)
          ..orderBy([(t) => OrderingTerm.desc(t.dateKey)])
          ..limit(limit))
        .watch();
  }

  /// 最近一条记录（通常是昨天），用来判断「隔了多久没读到传感器」。
  Future<DailyStep?> getLatest() {
    return (select(dailySteps)
          ..orderBy([(t) => OrderingTerm.desc(t.dateKey)])
          ..limit(1))
        .getSingleOrNull();
  }
}
