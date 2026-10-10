import 'package:flutter/material.dart';
import 'package:lifelog/data/db/app_database.dart';

/// 日程气泡。
///
/// 双击展开，就地露出这条日程来源的收集箱原文 —— 因为 AI 是把用户啰嗦的
/// 原话提炼成短标题，展开才能看到「我当时到底说了什么」。
///
/// 实现上用 DecoratedBox 而不是 Container/AnimatedContainer：后两者会介入
/// 约束计算，在这个「外层 Positioned 给死高度」的场景下会导致内容不渲染。
/// 高度由外层给，这里只负责画内容和背景。
class ScheduleBubble extends StatelessWidget {
  const ScheduleBubble({
    super.key,
    required this.schedule,
    required this.minHeight,
    required this.isExpanded,
    required this.onDoubleTap,
    required this.onEdit,
    required this.onDelete,
    this.sourceItems,
    this.sourceLoading = false,
  });

  final Schedule schedule;

  /// 由时间跨度决定的高度，只用来决定「要不要显示时间标签」
  final double minHeight;

  final bool isExpanded;
  final VoidCallback onDoubleTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// 展开时才由外部传入（异步取来源条目）
  final List<InboxItem>? sourceItems;
  final bool sourceLoading;

  /// 按 id 取色，让同一周的日程颜色错落开，不至于一片同色
  static const List<Color> _palette = [
    Color(0xFF5B8DEF),
    Color(0xFF43B581),
    Color(0xFFE8A33D),
    Color(0xFFE06C75),
    Color(0xFF9575CD),
    Color(0xFF2BB3C0),
    Color(0xFFD96BA0),
    Color(0xFF6C7AE0),
  ];

  Color get _accent => _palette[schedule.id % _palette.length];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = _accent;
    final bool isDone = schedule.status == 'done';

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDone ? 0.10 : 0.17),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accent.withValues(alpha: isExpanded ? 0.6 : 0.32),
            width: isExpanded ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isExpanded ? 0.26 : 0.10),
              blurRadius: isExpanded ? 16 : 5,
              offset: Offset(0, isExpanded ? 6 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 8, 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.title,
                maxLines: isExpanded ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: theme.colorScheme.onSurface,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              if (minHeight >= 56) ...[
                const SizedBox(height: 3),
                Text(
                  _timeLabel(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (isExpanded) _buildDetail(context, theme, accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, ThemeData theme, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Divider(height: 1, color: accent.withValues(alpha: 0.3)),
        const SizedBox(height: 8),
        Text(
          '来自收集箱',
          style: theme.textTheme.labelSmall?.copyWith(
            color: accent,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 6),
        if (sourceLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (sourceItems == null || sourceItems!.isEmpty)
          Text(
            '（手动创建的日程，没有来源）',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline, fontSize: 11),
          )
        else
          for (final InboxItem item in sourceItems!)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.subdirectory_arrow_right, size: 12, color: accent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      (item.content?.trim().isEmpty ?? true)
                          ? '（${item.type == 'text' ? '空' : '图片'}）'
                          : item.content!.trim(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 4),
        Row(
          children: [
            _MiniAction(
              icon: Icons.edit_outlined,
              label: '编辑',
              color: accent,
              onTap: onEdit,
            ),
            const SizedBox(width: 4),
            _MiniAction(
              icon: Icons.delete_outline,
              label: '删除',
              color: theme.colorScheme.error,
              onTap: onDelete,
            ),
          ],
        ),
      ],
    );
  }

  String _timeLabel() {
    final DateTime start =
        DateTime.fromMillisecondsSinceEpoch(schedule.startAt);
    final String hm =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

    if (schedule.isAllDay) return '全天';

    final int? endMs = schedule.endAt;
    if (endMs == null) return hm;

    final DateTime end = DateTime.fromMillisecondsSinceEpoch(endMs);
    final String endHm =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$hm – $endHm';
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
