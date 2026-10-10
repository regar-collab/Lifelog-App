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

  /// 存图片（相册选的、或系统分享进来的）。
  ///
  /// 图片会先复制进应用私有目录，数据库里存相对路径。
  Future<int> addImage(
    File file, {
    String? note,
    bool isScreenshot = false,
    String source = 'manual',
  }) async {
    final String relative = await MediaStorage.saveImage(file);
    final int now = DateTime.now().millisecondsSinceEpoch;
    final String? content = note?.trim();

    final int id = await _dao.insertItem(
      InboxItemsCompanion.insert(
        type: isScreenshot ? typeScreenshot : typeImage,
        content: Value(content),
        imagePath: Value(relative),
        source: Value(source),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _recordRevision(
      id,
      revisionCreated,
      content ?? '（图片）',
      now,
    );
    return id;
  }

  // ── 编辑 ──────────────────────────────────────────────────

  /// 编辑条目：文字和图片都能改。
  ///
  /// [newImage] 传进来表示「换成这张」（会先落盘再替换）；
  /// [removeImage] 为 true 表示「把图片删掉」。
  ///
  /// **关键行为**：如果这条已经整理过了（status = processed），改完自动退回
  /// pending —— 否则改动永远不会被重新整理，等于白改。
  ///
  /// 返回是否触发了「退回待整理」，UI 据此给用户提示。
  Future<bool> updateItem(
    InboxItem item, {
    String? content,
    File? newImage,
    bool removeImage = false,
  }) async {
    final String? nextContent = content?.trim();

    final bool contentChanged = nextContent != item.content;
    final bool imageChanged = newImage != null || removeImage;

    // 什么都没变就不写库，避免历史里塞满空记录
    if (!contentChanged && !imageChanged) return false;

    final int now = DateTime.now().millisecondsSinceEpoch;
    final bool needReorganize = item.status == 'processed';

    // 图片被换掉或删掉时，把旧文件清掉，别留垃圾
    final String? oldPath = item.imagePath;
    if (imageChanged && oldPath != null) {
      await MediaStorage.deleteIfExists(oldPath);
    }

    String? finalImagePath = item.imagePath;
    if (removeImage) {
      finalImagePath = null;
    } else if (newImage != null) {
      finalImagePath = await MediaStorage.saveImage(newImage);
    }

    // 类型跟着变：有图就是图片类，没图就是文字类
    final String nextType = finalImagePath != null
        ? (item.type == typeScreenshot ? typeScreenshot : typeImage)
        : typeText;

    await _dao.updateItem(
      item.copyWith(
        content: Value(nextContent),
        imagePath: Value(finalImagePath),
        type: nextType,
        status: needReorganize ? 'pending' : item.status,
        updatedAt: now,
      ),
    );

    // 历史里记一句改了什么，光看内容变化看不出图片的改动
    final String summary = _revisionSummary(
      content: nextContent,
      imageChanged: imageChanged,
      hasImage: finalImagePath != null,
      removeImage: removeImage,
    );
    await _recordRevision(item.id, revisionEdited, summary, now);

    return needReorganize;
  }

  /// 历史条目里显示的一句话。
  String _revisionSummary({
    required String? content,
    required bool imageChanged,
    required bool hasImage,
    required bool removeImage,
  }) {
    final String text = content?.trim() ?? '';
    if (!imageChanged) return text.isEmpty ? '（空）' : text;

    final String imageNote = removeImage
        ? '[已删除图片]'
        : (hasImage ? '[已更新图片]' : '');
    if (text.isEmpty) return imageNote.isEmpty ? '（空）' : imageNote;
    return '$text $imageNote';
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
    final String next =
        item.organizePolicy == policySkip ? policyAuto : policySkip;
    return setOrganizePolicy(item, next);
  }

  // ── 删除 ──────────────────────────────────────────────────

  /// 删除条目，连带清掉它的图片文件。
  /// 历史记录由外键 CASCADE 自动清理。
  Future<void> delete(InboxItem item) async {
    final String? path = item.imagePath;
    if (path != null) {
      await MediaStorage.deleteIfExists(path);
    }
    await _dao.deleteItem(item.id);
  }

  Future<void> markProcessed(List<int> ids) => _dao.markProcessed(ids);

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
