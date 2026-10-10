import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/features/inbox/application/inbox_providers.dart';
import 'package:lifelog/features/inbox/data/inbox_repository.dart';
import 'package:lifelog/features/inbox/presentation/widgets/inbox_tile.dart';
import 'package:lifelog/shared/widgets/empty_state.dart';

/// 模块 1 收集箱：文字、截图、图片先全部扔进来，不分类不整理。
class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<InboxItem>> itemsAsync =
        ref.watch(inboxItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('收集箱'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '设置',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/compose'),
        icon: const Icon(Icons.add),
        label: const Text('记一笔'),
      ),
      body: switch (itemsAsync) {
        AsyncData(:final List<InboxItem> value) =>
          _buildList(context, ref, value),
        AsyncError(:final Object error) =>
          Center(child: Text('读取失败：$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<InboxItem> items,
  ) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: '收集箱还是空的',
        subtitle: '点右下角「记一笔」，把想法、截图、图片先扔进来',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 84),
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];
        return InboxTile(
          item: item,
          onTap: () => context.push('/compose?id=${item.id}'),
          onToggleArchive: () => _toggleArchive(ref, item),
          onDelete: () => _confirmDelete(context, ref, item),
          onReorganize: () => _reorganize(context, ref, item),
          onToggleSkip: () => _toggleSkip(context, ref, item),
        );
      },
    );
  }

  /// 把已整理过的条目退回待整理队列，下次整理会带上它。
  Future<void> _reorganize(
    BuildContext context,
    WidgetRef ref,
    InboxItem item,
  ) async {
    await ref.read(inboxRepositoryProvider).markForReorganize(item);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已退回「待整理」，下次整理会重新处理这条')),
    );
  }

  /// 屏蔽 / 恢复这条是否参与 AI 整理。
  Future<void> _toggleSkip(
    BuildContext context,
    WidgetRef ref,
    InboxItem item,
  ) async {
    final repo = ref.read(inboxRepositoryProvider);
    final bool wasSkipped = item.organizePolicy == InboxRepository.policySkip;
    await repo.toggleSkip(item);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(wasSkipped ? '已恢复：这条会正常参与整理' : '已屏蔽：这条不再参与整理'),
      ),
    );
  }

  Future<void> _toggleArchive(WidgetRef ref, InboxItem item) async {
    await ref.read(inboxRepositoryProvider).updateStatus(
          item,
          item.status == 'archived' ? 'pending' : 'archived',
        );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    InboxItem item,
  ) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('删除这条？'),
        content: const Text('删除后无法恢复，图片也会一并清掉。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    await ref.read(inboxRepositoryProvider).delete(item);
  }
}
