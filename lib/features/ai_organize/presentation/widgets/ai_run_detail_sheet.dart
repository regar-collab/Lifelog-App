import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/core/utils/date_utils.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/services/media_storage.dart';
import 'package:lifelog/features/inbox/application/inbox_providers.dart';

/// 一次 AI 整理的完整详情。
///
/// 列表只加载摘要；点进来时才按需读取 prompt、原始返回和来源条目，
/// 这样历史记录再多也不会把大段文本常驻在内存里。
class AiRunDetailSheet extends ConsumerWidget {
  const AiRunDetailSheet({super.key, required this.run});

  final AiRun run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Column(
        children: [
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
            padding: const EdgeInsets.fromLTRB(20, 6, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text('整理详情', style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: '关闭',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                _MetaRow(label: '状态', value: _statusLabel(run.status)),
                _MetaRow(label: '开始', value: AppDate.friendly(run.startedAt)),
                if (run.finishedAt != null)
                  _MetaRow(
                    label: '结束',
                    value: AppDate.friendly(run.finishedAt!),
                  ),
                _MetaRow(label: '模型', value: run.model),
                _MetaRow(label: '生成日程', value: '${run.createdCount} 条'),
                if (run.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      run.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _SectionTitle(title: '本次整理的内容'),
                const SizedBox(height: 8),
                FutureBuilder<List<InboxItem>>(
                  future: _loadInputItems(ref),
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<List<InboxItem>> snapshot,
                      ) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final List<InboxItem> items =
                            snapshot.data ?? const <InboxItem>[];
                        if (items.isEmpty) {
                          return Text(
                            '没有可展示的来源条目',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          );
                        }
                        return Column(
                          children: [
                            for (final InboxItem item in items)
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  MediaStorage.parsePaths(item.imagePath)
                                          .isEmpty
                                      ? Icons.notes_outlined
                                      : Icons.image_outlined,
                                  size: 20,
                                ),
                                title: Text(
                                  item.content?.trim().isNotEmpty == true
                                      ? item.content!.trim()
                                      : _imageLabel(item),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  AppDate.friendly(item.createdAt),
                                ),
                              ),
                          ],
                        );
                      },
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: '发给模型的 Prompt'),
                const SizedBox(height: 8),
                _CodeBlock(text: run.requestPrompt ?? '（没有保存 Prompt）'),
                const SizedBox(height: 24),
                _SectionTitle(title: '模型原始返回'),
                const SizedBox(height: 8),
                _CodeBlock(text: run.rawResponse ?? '（没有保存原始返回）'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _imageLabel(InboxItem item) {
    final int count = MediaStorage.parsePaths(item.imagePath).length;
    if (count == 0) return '（空）';
    return count > 1 ? '（$count 张图片，无备注）' : '（图片，无备注）';
  }

  Future<List<InboxItem>> _loadInputItems(WidgetRef ref) async {
    final String? raw = run.inputItemIds;
    if (raw == null || raw.isEmpty) return const <InboxItem>[];

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return const <InboxItem>[];
      final List<int> ids = decoded
          .whereType<num>()
          .map((num n) => n.toInt())
          .toList();
      if (ids.isEmpty) return const <InboxItem>[];
      return await ref.read(inboxDaoProvider).findByIds(ids);
    } catch (_) {
      return const <InboxItem>[];
    }
  }

  static String _statusLabel(String status) {
    return switch (status) {
      'success' => '成功',
      'failed' => '失败',
      _ => '进行中',
    };
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SelectableText(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          height: 1.45,
        ),
      ),
    );
  }
}
