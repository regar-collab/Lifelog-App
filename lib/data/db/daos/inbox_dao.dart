import 'package:drift/drift.dart';
import 'package:lifelog/data/db/app_database.dart';

part 'inbox_dao.g.dart';

/// 收集箱的数据库操作。
///
/// 所有查询都返回 Stream，UI 层直接订阅，数据一变界面自动刷新，
/// 不需要手动调 setState。
@DriftAccessor(tables: [InboxItems, InboxItemRevisions])
class InboxDao extends DatabaseAccessor<AppDatabase> with _$InboxDaoMixin {
  InboxDao(super.db);

  /// 全部条目，新→旧。归档默认不显示。
  Stream<List<InboxItem>> watchAll({bool includeArchived = false}) {
    final query = select(inboxItems);
    if (!includeArchived) {
      query.where((t) => t.status.equals('archived').not());
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch();
  }

  /// 按状态过滤：pending / processed / archived
  Stream<List<InboxItem>> watchByStatus(String status) {
    return (select(inboxItems)
          ..where((t) => t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<int> insertItem(InboxItemsCompanion entry) =>
      into(inboxItems).insert(entry);

  Future<InboxItem?> findById(int id) =>
      (select(inboxItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 按 id 批量取（日程双击展开时反查来源条目用）。
  Future<List<InboxItem>> findByIds(List<int> ids) {
    if (ids.isEmpty) return Future.value(const <InboxItem>[]);
    return (select(inboxItems)..where((t) => t.id.isIn(ids))).get();
  }

  Future<bool> updateItem(InboxItem item) => update(inboxItems).replace(item);

  Future<int> deleteItem(int id) =>
      (delete(inboxItems)..where((t) => t.id.equals(id))).go();

  // ── 待整理队列 ────────────────────────────────────────────

  /// 待整理的条目，旧→新（AI 整理按时间顺序理解上下文更准）。
  ///
  /// 两个条件缺一不可：
  /// - status = pending：已整理过的不重复发
  /// - organize_policy = auto：用户明确屏蔽（skip）的永不参与
  Future<List<InboxItem>> getPendingItems() {
    return (select(inboxItems)
          ..where((t) =>
              t.status.equals('pending') & t.organizePolicy.equals('auto'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// 批量标记为已整理。AI 整理成功后调用。
  Future<void> markProcessed(List<int> ids) async {
    if (ids.isEmpty) return;
    final int now = DateTime.now().millisecondsSinceEpoch;
    await (update(inboxItems)..where((t) => t.id.isIn(ids))).write(
      InboxItemsCompanion(
        status: const Value('processed'),
        updatedAt: Value(now),
      ),
    );
  }

  /// 把条目退回待整理队列（用户点「重新整理」时）。
  Future<void> markForReorganize(int id) async {
    await (update(inboxItems)..where((t) => t.id.equals(id))).write(
      InboxItemsCompanion(
        status: const Value('pending'),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// 改整理策略：auto（参与整理）/ skip（屏蔽）
  Future<void> setOrganizePolicy(int id, String policy) async {
    await (update(inboxItems)..where((t) => t.id.equals(id))).write(
      InboxItemsCompanion(
        organizePolicy: Value(policy),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// 待整理条数（同样要排除被屏蔽的），用于 Tab 角标和整理页。
  Stream<int> watchPendingCount() {
    final count = inboxItems.id.count();
    final query = selectOnly(inboxItems)
      ..addColumns([count])
      ..where(inboxItems.status.equals('pending') &
          inboxItems.organizePolicy.equals('auto'));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  // ── 变更历史 ──────────────────────────────────────────────

  Future<void> addRevision(InboxItemRevisionsCompanion entry) =>
      into(inboxItemRevisions).insert(entry);

  /// 某条目的完整变更历史，旧→新（像聊天记录一样从上往下读）。
  Stream<List<InboxItemRevision>> watchRevisions(int itemId) {
    return (select(inboxItemRevisions)
          ..where((t) => t.itemId.equals(itemId))
          ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
        .watch();
  }
}
