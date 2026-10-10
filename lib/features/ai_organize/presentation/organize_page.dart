import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/core/utils/date_utils.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/services/deepseek_service.dart';
import 'package:lifelog/features/ai_organize/application/organize_providers.dart';
import 'package:lifelog/features/ai_organize/data/organize_repository.dart';
import 'package:lifelog/features/ai_organize/domain/organize_draft.dart';
import 'package:lifelog/features/ai_organize/presentation/widgets/organize_preview_sheet.dart';
import 'package:lifelog/features/inbox/application/inbox_providers.dart';
import 'package:lifelog/features/settings/application/settings_providers.dart';

/// 模块 2 AI 整理。
///
/// 流程：点「开始整理」→ 模型生成草案 → 底部弹窗让用户勾选 → 确认后才写日程表。
class OrganizePage extends ConsumerStatefulWidget {
  const OrganizePage({super.key});

  @override
  ConsumerState<OrganizePage> createState() => _OrganizePageState();
}

class _OrganizePageState extends ConsumerState<OrganizePage> {
  bool _running = false;

  Future<void> _start() async {
    FocusScope.of(context).unfocus();
    setState(() => _running = true);

    try {
      final ai = await ref.read(deepSeekServiceProvider.future);
      final repo = ref.read(organizeRepositoryProvider);
      final OrganizeOutcome outcome = await repo.generateDrafts(ai);

      if (!mounted) return;
      setState(() => _running = false);

      if (outcome.drafts.isEmpty) {
        await _handleEmptyDrafts(outcome);
        return;
      }

      final List<OrganizeDraft>? selected =
          await showModalBottomSheet<List<OrganizeDraft>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => OrganizePreviewSheet(outcome: outcome),
      );

      if (selected == null || !mounted) return;

      final int count = await repo.commit(
        outcome: outcome,
        selected: selected,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 0
                ? '没有写入日程，收集箱条目已标记为已整理'
                : '已写入 $count 条日程',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  /// 模型认为这批内容构不成日程。问一下用户要不要把它们标记成已整理，
  /// 否则它们会永远挂在待整理里，每次整理都要重发一遍。
  Future<void> _handleEmptyDrafts(OrganizeOutcome outcome) async {
    final bool? mark = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('没识别出可安排的日程'),
        content: Text(
          '这次处理了 ${outcome.inboxItemIds.length} 条内容，'
          '但它们更像零散的想法或信息，没有可以排进日程的事项。\n\n'
          '要把这些条目标记为「已整理」吗？标记后它们不会再出现在下次整理里。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('先留着'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('标记已整理'),
          ),
        ],
      ),
    );

    if (mark != true) return;
    await ref
        .read(organizeRepositoryProvider)
        .commit(outcome: outcome, selected: const []);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已标记为已整理')),
    );
  }

  void _showError(Object e) {
    final String message = switch (e) {
      DeepSeekException(:final String message) => message,
      OrganizeException(:final String message) => message,
      _ => e.toString(),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final AsyncValue<int> pendingAsync = ref.watch(inboxPendingCountProvider);
    final AsyncValue<List<AiRun>> runsAsync = ref.watch(aiRunsProvider);

    final int pending = switch (pendingAsync) {
      AsyncData(:final int value) => value,
      _ => 0,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('AI 整理')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        '待整理 $pending 条',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '把收集箱里攒下的文字和图片发给 DeepSeek，整理成日程草案。'
                    '在你确认之前，不会写进日程表。',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: (_running || pending == 0) ? null : _start,
                    icon: _running
                        ? const _MiniSpinner()
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(_running ? '整理中，请稍候…' : '开始整理'),
                  ),
                  if (pending == 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      '收集箱里没有待整理的内容',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '整理记录',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          switch (runsAsync) {
            AsyncData(:final List<AiRun> value) => value.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      '还没有整理过',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  )
                : Card(
                    child: Column(
                      children: [
                        for (int i = 0; i < value.length; i++) ...[
                          if (i > 0) const Divider(height: 1, indent: 16),
                          _RunTile(run: value[i]),
                        ],
                      ],
                    ),
                  ),
            AsyncError(:final Object error) => Text('读取失败：$error'),
            _ => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
          },
        ],
      ),
    );
  }
}

class _RunTile extends StatelessWidget {
  const _RunTile({required this.run});

  final AiRun run;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final (String label, Color color, IconData icon) = switch (run.status) {
      'success' => ('成功', theme.colorScheme.primary, Icons.check_circle_outline),
      'failed' => ('失败', theme.colorScheme.error, Icons.error_outline),
      _ => ('进行中', theme.colorScheme.tertiary, Icons.hourglass_empty),
    };

    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: color),
      title: Text(
        run.status == 'success'
            ? '生成 ${run.createdCount} 条日程'
            : label,
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Text(
        run.status == 'failed' && run.errorMessage != null
            ? '${AppDate.friendly(run.startedAt)} · ${run.errorMessage}'
            : AppDate.friendly(run.startedAt),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.outline),
      ),
    );
  }
}

class _MiniSpinner extends StatelessWidget {
  const _MiniSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
