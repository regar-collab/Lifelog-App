import 'dart:convert';

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
    return (select(
      schedules,
    )..orderBy([(t) => OrderingTerm.asc(t.startAt)])).watch();
  }

  /// 某时间区间内的日程（日历视图用）。
  ///
  /// 用「与区间求交」而不是只看 startAt：
  /// 周日 23:30 开始、周一结束的跨周日程，必须能在下一周视图里查到，
  /// 否则整条日程会凭空消失。
  Stream<List<Schedule>> watchRange(int fromMillis, int toMillis) {
    return (select(schedules)
          ..where(
            (t) =>
                t.startAt.isSmallerThanValue(toMillis) &
                ((t.endAt.isNotNull() & t.endAt.isBiggerThanValue(fromMillis)) |
                    (t.endAt.isNull() &
                        t.startAt.isBiggerOrEqualValue(fromMillis))),
          )
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

  /// 找出引用了这些收集箱条目的 AI 日程（包括用户改过的 ai-edited）。
  ///
  /// source_item_ids 是 JSON 数组，SQL 层面不好精确匹配，先取出 AI 日程再解析。
  ///
  /// 为什么连 ai-edited 也返回：用户反馈「修改条目再整理后，旧日程还在」。
  /// 重新整理意味着用新结果取代这批内容的旧 AI 产物，旧的（哪怕改过）
  /// 都应该被替换，否则会出现新旧两份日程并存。
  Future<List<Schedule>> getAiSchedulesBySourceItemIds(
    List<int> itemIds,
  ) async {
    if (itemIds.isEmpty) return const <Schedule>[];
    final Set<int> targets = itemIds.toSet();

    final List<Schedule> rows =
        await (select(schedules)..where(
              (t) => t.origin.equals('ai') | t.origin.equals('ai-edited'),
            ))
            .get();

    return rows.where((Schedule s) {
      final String? raw = s.sourceItemIds;
      if (raw == null || raw.isEmpty) return false;
      try {
        final Object? decoded = jsonDecode(raw);
        if (decoded is! List) return false;
        return decoded
            .whereType<num>()
            .map((num n) => n.toInt())
            .any(targets.contains);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<void> deleteByIds(List<int> ids) async {
    if (ids.isEmpty) return;
    await (delete(schedules)..where((t) => t.id.isIn(ids))).go();
  }
}
