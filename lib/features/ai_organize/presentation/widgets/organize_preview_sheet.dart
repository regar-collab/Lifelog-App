import 'package:flutter/material.dart';
import 'package:lifelog/features/ai_organize/domain/organize_draft.dart';

/// 整理结果的确认弹窗。
///
/// 模型可能生成离谱的内容，所以这里是最后一道闸门：默认全选，
/// 但用户可以取消勾选任意一条，只有点「写入日程」才会真正落库。
class OrganizePreviewSheet extends StatefulWidget {
  const OrganizePreviewSheet({super.key, required this.outcome});

  final OrganizeOutcome outcome;

  @override
  State<OrganizePreviewSheet> createState() => _OrganizePreviewSheetState();
}

class _OrganizePreviewSheetState extends State<OrganizePreviewSheet> {
  late List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List<bool>.filled(widget.outcome.drafts.length, true);
  }

  int get _selectedCount => _checked.where((bool c) => c).length;

  void _submit() {
    final List<OrganizeDraft> selected = [
      for (int i = 0; i < widget.outcome.drafts.length; i++)
        if (_checked[i]) widget.outcome.drafts[i],
    ];
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<OrganizeDraft> drafts = widget.outcome.drafts;

    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Column(
        children: [
          // 顶部把手
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('整理结果', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '共 ${drafts.length} 条。取消勾选只是不写入；'
                        '来源内容仍会标记为已整理。'
                        '重新整理会替换这些条目之前由 AI 生成的日程（包括改过的）'
                        '${widget.outcome.skippedDrafts > 0 ? '；另有 '
                                  '${widget.outcome.skippedDrafts} 条格式异常已跳过' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final bool allOn = _checked.every((bool c) => c);
                    setState(() {
                      for (int i = 0; i < _checked.length; i++) {
                        _checked[i] = !allOn;
                      }
                    });
                  },
                  child: Text(_checked.every((bool c) => c) ? '全不选' : '全选'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: drafts.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
              itemBuilder: (BuildContext context, int index) {
                final OrganizeDraft draft = drafts[index];
                return CheckboxListTile(
                  value: _checked[index],
                  onChanged: (bool? v) =>
                      setState(() => _checked[index] = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(draft.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 3),
                      Text(
                        _timeLabel(draft),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (draft.location != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          draft.location!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                      if (draft.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          draft.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _selectedCount == 0 ? null : _submit,
                    child: Text('写入日程（$_selectedCount）'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 草案时间标签：今天/明天用相对说法，更远用日期。
  String _timeLabel(OrganizeDraft draft) {
    final DateTime start = draft.startAt;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime thatDay = DateTime(start.year, start.month, start.day);
    final int diff = thatDay.difference(today).inDays;

    final String hm =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final String day = switch (diff) {
      0 => '今天',
      1 => '明天',
      2 => '后天',
      _ => '${start.month}-${start.day}',
    };

    if (draft.isAllDay) return '$day 全天';

    final DateTime? end = draft.endAt;
    if (end != null) {
      final String endHm =
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
      return '$day $hm – $endHm';
    }
    return '$day $hm';
  }
}
