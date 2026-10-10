import 'package:drift/drift.dart';

import 'inbox_items.dart';

/// 收集箱条目的变更历史，像聊天记录一样一条条往下排。
///
/// 光有 created_at / updated_at 只能看出「改过」，看不出「改了什么」。
/// 这张表把每次变更的内容快照留下来，用户可以回看这个条目被怎么改过。
///
/// 只读历史，不做版本回滚 —— 回滚会让「当前内容」和「历史」的关系变复杂，
/// 第一版不做。
@DataClassName('InboxItemRevision')
class InboxItemRevisions extends Table {
  @override
  String get tableName => 'inbox_item_revisions';

  IntColumn get id => integer().autoIncrement()();

  /// 条目被删除时历史一并清掉（ON DELETE CASCADE）
  IntColumn get itemId => integer()
      .references(InboxItems, #id, onDelete: KeyAction.cascade)();

  /// created（首次创建）| edited（后续编辑）
  TextColumn get kind => text()();

  /// 这次变更之后的内容快照
  TextColumn get content => text().nullable()();

  /// 记录时间（毫秒时间戳）
  IntColumn get recordedAt => integer()();
}
