import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lifelog/core/utils/date_utils.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/services/media_storage.dart';

/// 收集箱列表项。
///
/// 有图的显示缩略图（左），没图的显示类型图标；下方是时间、状态和来源。
/// 右侧「⋮」里是这条目的全部操作，包括对 AI 整理队列的控制。
class InboxTile extends StatelessWidget {
  const InboxTile({
    super.key,
    required this.item,
    this.onTap,
    this.onToggleArchive,
    this.onDelete,
    this.onReorganize,
    this.onToggleSkip,
  });

  final InboxItem item;
  final VoidCallback? onTap;
  final VoidCallback? onToggleArchive;
  final VoidCallback? onDelete;

  /// 把已整理的条目退回待整理队列
  final VoidCallback? onReorganize;

  /// 屏蔽 / 恢复这条是否参与 AI 整理
  final VoidCallback? onToggleSkip;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> imagePaths = MediaStorage.parsePaths(item.imagePath);
    final bool hasImage = imagePaths.isNotEmpty;
    final bool isSkipped = item.organizePolicy == 'skip';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              _Thumbnail(
                relativePath: imagePaths.first,
                count: imagePaths.length,
              )
            else
              _TypeIcon(type: item.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        AppDate.friendly(item.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(item: item),
                      if (item.source == 'share') ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.share_outlined,
                          size: 12,
                          color: theme.colorScheme.outline,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 20,
                color: theme.colorScheme.outline,
              ),
              onSelected: (String value) {
                switch (value) {
                  case 'reorganize':
                    onReorganize?.call();
                  case 'skip':
                    onToggleSkip?.call();
                  case 'archive':
                    onToggleArchive?.call();
                  case 'delete':
                    onDelete?.call();
                }
              },
              itemBuilder: (_) => [
                // 只有整理过的条目才谈得上「重新整理」
                if (item.status == 'processed')
                  const PopupMenuItem<String>(
                    value: 'reorganize',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.refresh, size: 20),
                      title: Text('重新整理'),
                    ),
                  ),
                PopupMenuItem<String>(
                  value: 'skip',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSkipped ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    title: Text(isSkipped ? '恢复整理' : '不再整理'),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'archive',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.archive_outlined, size: 20),
                    title: Text(item.status == 'archived' ? '取消归档' : '归档'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(
                      '删除',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _title() {
    final String content = item.content?.trim() ?? '';
    if (content.isNotEmpty) return content;

    final int imageCount = MediaStorage.parsePaths(item.imagePath).length;
    final String imageLabel = imageCount > 1
        ? '（$imageCount 张图片，未加备注）'
        : '（图片，未加备注）';

    return switch (item.type) {
      'screenshot' => imageCount > 1 ? '（$imageCount 张截图，未加备注）' : '（截图，未加备注）',
      'image' => imageLabel,
      _ => '（空）',
    };
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.relativePath, this.count = 1});

  final String relativePath;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? absolute = MediaStorage.resolveSync(relativePath);

    Widget placeholder(IconData icon) => Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: theme.colorScheme.outline, size: 22),
    );

    if (absolute == null) return placeholder(Icons.image_outlined);

    final Widget thumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        File(absolute),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        cacheWidth: 168, // 缩略图只解 3x 分辨率，省内存
        errorBuilder: (_, _, _) => placeholder(Icons.broken_image_outlined),
      ),
    );

    if (count <= 1) return thumbnail;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        thumbnail,
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final IconData icon = switch (type) {
      'screenshot' => Icons.screenshot_monitor_outlined,
      'image' => Icons.image_outlined,
      _ => Icons.notes_outlined,
    };

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: theme.colorScheme.primary, size: 24),
    );
  }
}

/// 状态标签。「被屏蔽」优先于其他状态显示 —— 因为它是用户主动做的决定，
/// 比「待整理」更值得被看见。
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.item});

  final InboxItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final (String label, Color color) = switch (item) {
      InboxItem(status: 'archived') => ('已归档', theme.colorScheme.outline),
      InboxItem(organizePolicy: 'skip') => ('已屏蔽', theme.colorScheme.outline),
      InboxItem(status: 'processed') => ('已整理', theme.colorScheme.primary),
      _ => ('待整理', theme.colorScheme.tertiary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}
