import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/db/daos/inbox_dao.dart';
import 'package:lifelog/data/db/daos/schedule_dao.dart';

/// 日程的业务操作。AI 写入和用户手动增删改都走这里。
class ScheduleRepository {
  /// 需要 InboxDao 是为了反查「这条日程来自收集箱里的哪几条内容」——
  /// 双击气泡要展开原文。
  ScheduleRepository(this._dao, this._inboxDao);

  final ScheduleDao _dao;
  final InboxDao _inboxDao;

  Stream<List<Schedule>> watchAll() => _dao.watchAll();

  Stream<List<Schedule>> watchRange(int fromMillis, int toMillis) =>
      _dao.watchRange(fromMillis, toMillis);

  Future<Schedule?> findById(int id) => _dao.findById(id);

  /// 手动新建一条日程。
  Future<int> addManual({
    required String title,
    required DateTime startAt,
    String? description,
    DateTime? endAt,
    bool isAllDay = false,
    String? location,
    int priority = 0,
  }) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    return _dao.insertSchedule(
      SchedulesCompanion.insert(
        title: title.trim(),
        description: Value(description?.trim()),
        startAt: startAt.millisecondsSinceEpoch,
        endAt: Value(endAt?.millisecondsSinceEpoch),
        isAllDay: Value(isAllDay),
        location: Value(location?.trim()),
        priority: Value(priority),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// 编辑已有日程。
  Future<void> edit(
    Schedule schedule, {
    String? title,
    String? description,
    DateTime? startAt,
    DateTime? endAt,
    bool clearEndAt = false,
    bool? isAllDay,
    String? location,
    int? priority,
  }) {
    // 注意 Drift 的 copyWith 参数类型规则：
    // 非空列（title/startAt/isAllDay/priority）用裸类型，null 表示「不修改」；
    // 可空列（description/endAt/location）用 Value<T> 包装，才能区分
    // 「不修改」（Value.absent()）和「设为 null」（Value(null)）。
    final updated = schedule.copyWith(
      title: title?.trim(),
      description: description == null
          ? const Value.absent()
          : Value(description.trim()),
      startAt: startAt?.millisecondsSinceEpoch,
      endAt: clearEndAt
          ? const Value(null)
          : endAt == null
              ? const Value.absent()
              : Value(endAt.millisecondsSinceEpoch),
      isAllDay: isAllDay,
      location:
          location == null ? const Value.absent() : Value(location.trim()),
      priority: priority,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    return _dao.updateSchedule(updated);
  }

  /// 改状态：planned / done / cancelled
  Future<void> updateStatus(Schedule schedule, String status) {
    return _dao.updateSchedule(
      schedule.copyWith(
        status: status,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> delete(int id) => _dao.deleteSchedule(id);

  /// 某次 AI 整理产生的全部日程，用于「撤销这批」。
  Future<List<Schedule>> getByAiRun(int aiRunId) => _dao.getByAiRun(aiRunId);

  /// 反查这条日程来源于收集箱的哪几条内容（双击气泡展开时用）。
  ///
  /// source_item_ids 存的是 JSON 数组；解析失败或字段为空都返回空列表，
  /// 不让脏数据把界面搞崩。
  Future<List<InboxItem>> getSourceItems(Schedule schedule) async {
    final String? raw = schedule.sourceItemIds;
    if (raw == null || raw.isEmpty) return const [];

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final List<int> ids =
          decoded.whereType<num>().map((num n) => n.toInt()).toList();
      if (ids.isEmpty) return const [];

      return await _inboxDao.findByIds(ids);
    } catch (_) {
      return const [];
    }
  }
}
