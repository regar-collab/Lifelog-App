import 'dart:io';

import 'package:drift/drift.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/db/daos/inbox_dao.dart';
import 'package:lifelog/data/services/media_storage.dart';

/// 收集箱的业务操作。UI 只跟它打交道，不直接碰 DAO。
class InboxRepository {
  InboxRepository(this._dao);

  final InboxDao _dao;

  /// 条目类型常量
  static const String typeText = 'text';
  static const String typeImage = 'image';
  static const String typeScreenshot = 'screenshot';

  /// 整理策略
  static const String policyAuto = 'auto';
  static const String policySkip = 'skip';

  /// 历史记录类型
  static const String revisionCreated = 'created';
  static const String revisionEdited = 'edited';

  Stream<List<InboxItem>> watchAll() => _dao.watchAll();

  /// 已归档的条目。归档并不是删除，用户需要能找回来。
  Stream<List<InboxItem>> watchArchived() => _dao.watchByStatus('archived');

  Stream<int> watchPendingCount() => _dao.watchPendingCount();

  Stream<List<InboxItemRevision>> watchRevisions(int itemId) =>
      _dao.watchRevisions(itemId);

  Future<InboxItem?> findById(int id) => _dao.findById(id);

  Future<List<InboxItem>> getPendingItems() => _dao.getPendingItems();

  // ── 新增 ──────────────────────────────────────────────────

  /// 存一条纯文字，同时留下「创建」历史。
  Future<int> addText(String text, {String source = 'manual'}) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final String content = text.trim();

    final int id = await _dao.insertItem(
      InboxItemsCompanion.insert(
        type: typeText,
        content: Value(content),
        source: Value(source),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _recordRevision(id, revisionCreated, content, now);
    return id;
  }

  /// 存单张图片（系统分享等旧入口）。
  ///
  /// 内部统一走 [addImages]，多图只是列表里多一项。
  Future<int> addImage(
    File file, {
    String? note,
    bool isScreenshot = false,
    String source = 'manual',
  }) {
    return addImages(
      <File>[file],
      note: note,
      isScreenshot: isScreenshot,
      source: source,
    );
  }

  /// 把多张图片存成**同一条**收集箱记录。
  ///
  /// 图片先全部复制进应用私有目录，再一次性入库；任一环节失败会
  /// 清掉这次新复制的文件，不留下半条记录或孤儿图片。
  Future<int> addImages(
    List<File> files, {
    String? note,
    bool isScreenshot = false,
    String source = 'manual',
  }) async {
    if (files.isEmpty) {
      throw ArgumentError('至少需要一张图片');
    }

    final List<String> saved = <String>[];
    try {
      for (final File file in files) {
        saved.add(await MediaStorage.saveImage(file));
      }
    } catch (_) {
      await _deleteFiles(saved);
      rethrow;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final String? content = note?.trim();

    try {
      // 写库和历史记录放同一事务，避免出现「有条目没历史」的半成品
      return await _dao.transaction(() async {
        final int id = await _dao.insertItem(
          InboxItemsCompanion.insert(
            type: isScreenshot ? typeScreenshot : typeImage,
            content: Value(content),
            imagePath: Value(MediaStorage.encodePaths(saved)),
            source: Value(source),
            createdAt: now,
            updatedAt: now,
          ),
        );

        final String summary = content?.isNotEmpty == true
            ? content!
            : (files.length == 1 ? '（图片）' : '（${files.length} 张图片）');
        await _recordRevision(id, revisionCreated, summary, now);
        return id;
      });
    } catch (_) {
      await _deleteFiles(saved);
      rethrow;
    }
  }

  // ── 编辑 ──────────────────────────────────────────────────

  /// 编辑条目：文字和多张图片都能改。
  ///
  /// [newImages] 是这次新加进来的图片；[removeImagePaths] 是要删除的旧图路径。
  /// 保留的旧图 + 新图 = 最终图片列表。
  ///
  /// **关键行为**：如果这条已经整理过了（status = processed），改完自动退回
  /// pending —— 否则改动永远不会被重新整理，等于白改。
  ///
  /// 返回是否触发了「退回待整理」，UI 据此给用户提示。
  Future<bool> updateItem(
    InboxItem item, {
    String? content,
    List<File> newImages = const <File>[],
    List<String> removeImagePaths = const <String>[],
  }) async {
    final String? nextContent = content?.trim();

    final List<String> existing = MediaStorage.parsePaths(item.imagePath);
    final Set<String> removeSet = removeImagePaths.toSet();
    final List<String> remaining = existing
        .where((String path) => !removeSet.contains(path))
        .toList();
    final List<String> removed = existing
        .where((String path) => removeSet.contains(path))
        .toList();

    final bool contentChanged = nextContent != item.content;
    final bool imageChanged = newImages.isNotEmpty || removed.isNotEmpty;

    // 什么都没变就不写库，避免历史里塞满空记录
    if (!contentChanged && !imageChanged) return false;

    final int now = DateTime.now().millisecondsSinceEpoch;
    final bool needReorganize = item.status == 'processed';

    // 顺序很重要：先把新图落盘，再写数据库，最后才删旧图。
    final List<String> savedNew = <String>[];
    try {
      for (final File file in newImages) {
        savedNew.add(await MediaStorage.saveImage(file));
      }
    } catch (_) {
      await _deleteFiles(savedNew);
      rethrow;
    }

    final List<String> finalPaths = <String>[...remaining, ...savedNew];
    final String? finalImagePath = MediaStorage.encodePaths(finalPaths);

    // 类型跟着变：有图就是图片类，没图就是文字类
    final String nextType = finalPaths.isNotEmpty
        ? (item.type == typeScreenshot ? typeScreenshot : typeImage)
        : typeText;

    // 历史里记一句改了什么，光看内容变化看不出图片的改动
    final String summary = _revisionSummary(
      content: nextContent,
      addedCount: savedNew.length,
      removedCount: removed.length,
    );

    try {
      // 数据库更新和历史记录放进同一事务：要么都成功，要么都回滚
      await _dao.transaction(() async {
        await _dao.updateItem(
          item.copyWith(
            content: Value(nextContent),
            imagePath: Value(finalImagePath),
            type: nextType,
            status: needReorganize ? 'pending' : item.status,
            updatedAt: now,
          ),
        );
        await _recordRevision(item.id, revisionEdited, summary, now);
      });
    } catch (_) {
      // 写库失败：清掉刚复制进来的新图，旧图和数据库保持原样
      await _deleteFiles(savedNew);
      rethrow;
    }

    // 数据库已经指向新状态，这时删被移除的旧图才安全
    await _deleteFiles(removed);
    return needReorganize;
  }

  /// 历史条目里显示的一句话。
  String _revisionSummary({
    required String? content,
    required int addedCount,
    required int removedCount,
  }) {
    final String text = content?.trim() ?? '';
    final List<String> notes = <String>[
      if (addedCount > 0) '[新增 $addedCount 张图片]',
      if (removedCount > 0) '[删除 $removedCount 张图片]',
    ];
    final String imageNote = notes.join(' ');
    if (text.isEmpty) return imageNote.isEmpty ? '（空）' : imageNote;
    return imageNote.isEmpty ? text : '$text $imageNote';
  }

  /// 改状态：pending / processed / archived
  Future<void> updateStatus(InboxItem item, String status) async {
    await _dao.updateItem(
      item.copyWith(
        status: status,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // ── 整理队列控制 ──────────────────────────────────────────

  /// 把已整理过的条目退回待整理队列。
  Future<void> markForReorganize(InboxItem item) =>
      _dao.markForReorganize(item.id);

  /// 屏蔽 / 恢复：skip 的条目永不参与 AI 整理。
  Future<void> setOrganizePolicy(InboxItem item, String policy) =>
      _dao.setOrganizePolicy(item.id, policy);

  Future<void> toggleSkip(InboxItem item) {
    final String next = item.organizePolicy == policySkip
        ? policyAuto
        : policySkip;
    return setOrganizePolicy(item, next);
  }

  // ── 删除 ──────────────────────────────────────────────────

  /// 删除条目，连带清掉它的图片文件。
  /// 历史记录由外键 CASCADE 自动清理。
  ///
  /// 先删数据库行、后删文件：文件删失败最多留个孤儿文件；
  /// 反过来则可能「记录还在但图片没了」。
  Future<void> delete(InboxItem item) async {
    final List<String> paths = MediaStorage.parsePaths(item.imagePath);
    await _dao.deleteItem(item.id);
    await _deleteFiles(paths);
  }

  Future<void> markProcessed(List<int> ids) => _dao.markProcessed(ids);

  /// 清理图片文件；单个失败不影响其它文件，也不影响主流程。
  Future<void> _deleteFiles(Iterable<String> paths) async {
    for (final String path in paths) {
      try {
        await MediaStorage.deleteIfExists(path);
      } catch (_) {
        // 留个孤儿文件比丢数据好
      }
    }
  }

  Future<void> _recordRevision(
    int itemId,
    String kind,
    String content,
    int at,
  ) {
    return _dao.addRevision(
      InboxItemRevisionsCompanion.insert(
        itemId: itemId,
        kind: kind,
        content: Value(content),
        recordedAt: at,
      ),
    );
  }
}
