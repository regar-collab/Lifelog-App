import 'package:drift/drift.dart';
import 'package:lifelog/data/db/app_database.dart';

part 'schedule_dao.g.dart';

/// 日程表的数据库操作。
@DriftAccessor(tables: [Schedules])
class ScheduleDao extends DatabaseAccessor<AppDatabase>
    with _$ScheduleDaoMixin {
  ScheduleDao(super.db);

  /// 全部日程，按开始时间正序。
  Stream<List<Schedule>> watchAll() {
    return (select(schedules)
          ..orderBy([(t) => OrderingTerm.asc(t.startAt)]))
        .watch();
  }

  /// 某时间区间内的日程（日历视图用）。
  Stream<List<Schedule>> watchRange(int fromMillis, int toMillis) {
    return (select(schedules)
          ..where((t) =>
              t.startAt.isBiggerOrEqualValue(fromMillis) &
              t.startAt.isSmallerThanValue(toMillis))
          ..orderBy([(t) => OrderingTerm.asc(t.startAt)]))
        .watch();
  }

  Future<int> insertSchedule(SchedulesCompanion entry) =>
      into(schedules).insert(entry);

  /// 批量写入。AI 一次生成多条，逐条 insert 会有多次事务开销。
  Future<void> insertAll(List<SchedulesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((Batch b) => b.insertAll(schedules, entries));
  }

  Future<Schedule?> findById(int id) =>
      (select(schedules)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<bool> updateSchedule(Schedule schedule) =>
      update(schedules).replace(schedule);

  Future<int> deleteSchedule(int id) =>
      (delete(schedules)..where((t) => t.id.equals(id))).go();

  /// 某次 AI 整理产生的全部日程，用于整批撤销。
  Future<List<Schedule>> getByAiRun(int aiRunId) {
    return (select(schedules)..where((t) => t.aiRunId.equals(aiRunId))).get();
  }
}
