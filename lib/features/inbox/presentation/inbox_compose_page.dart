import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lifelog/core/utils/date_utils.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/services/media_storage.dart';
import 'package:lifelog/features/inbox/application/inbox_providers.dart';

/// 记一笔 / 编辑条目。
///
/// 新建时可以「文字 + 多张图片」一起存成同一条记录，备注填文字框内容。
/// 编辑时可以继续加图、单独移除某张图，文字和图片都能改。
class InboxComposePage extends ConsumerStatefulWidget {
  const InboxComposePage({super.key, this.itemId});

  final int? itemId;

  @override
  ConsumerState<InboxComposePage> createState() => _InboxComposePageState();
}

class _InboxComposePageState extends ConsumerState<InboxComposePage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  /// 已选、还没落盘的图片。新建和编辑模式都用它。
  final List<File> _picked = [];

  /// 编辑模式下标记要删除的旧图路径（保存后才真正删文件）。
  final Set<String> _removedPaths = <String>{};

  InboxItem? _editing;
  bool _loading = false;
  bool _saving = false;

  bool get _isEditMode => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadExisting();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    final InboxItem? item = await ref
        .read(inboxRepositoryProvider)
        .findById(widget.itemId!);
    if (!mounted) return;
    setState(() {
      _editing = item;
      _controller.text = item?.content ?? '';
      _loading = false;
    });
  }

  /// 新建和编辑都支持一次选多张图。
  Future<void> _pickImages() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage();
      if (files.isEmpty || !mounted) return;
      setState(() {
        _picked.addAll(files.map((XFile f) => File(f.path)));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('选图失败：$e')));
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    final String text = _controller.text.trim();
    final repo = ref.read(inboxRepositoryProvider);

    if (_isEditMode) {
      final InboxItem? item = _editing;
      if (item == null) return;

      setState(() => _saving = true);
      try {
        // 已整理过的条目改了内容，会自动退回待整理（否则改动永远不会被重新整理）
        final bool needReorganize = await repo.updateItem(
          item,
          content: text,
          newImages: _picked,
          removeImagePaths: _removedPaths.toList(),
        );

        if (!mounted) return;
        final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
        context.pop();

        if (needReorganize) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('内容已修改，这条已退回「待整理」，下次整理会重新处理'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('保存失败：${_friendlyError(e)}')));
      }
      return;
    }

    if (_picked.isEmpty && text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('写点什么，或者选张图')));
      return;
    }

    setState(() => _saving = true);
    try {
      if (_picked.isEmpty) {
        await repo.addText(text);
      } else {
        // 多张图作为同一条记录保存
        await repo.addImages(_picked, note: text.isEmpty ? null : text);
      }
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('保存失败：${_friendlyError(e)}')));
    }
  }

  String _friendlyError(Object error) {
    if (error is FileSystemException) {
      return '文件读写失败（${error.osError?.message ?? error.message}）';
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '编辑' : '记一笔'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '保存中…' : '保存'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _controller,
                  maxLines: null,
                  minLines: 5,
                  autofocus: !_isEditMode,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: '想到什么先写下来…',
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
                const SizedBox(height: 12),

                if (!_isEditMode)
                  ..._buildCreateImageSection(theme)
                else
                  ..._buildEditImageSection(theme),

                if (_isEditMode) ...[
                  const SizedBox(height: 28),
                  _RevisionTimeline(itemId: widget.itemId!),
                ],
              ],
            ),
    );
  }

  // ── 新建：一次可以选多张，全部存成同一条记录 ──────────────

  List<Widget> _buildCreateImageSection(ThemeData theme) {
    return [
      if (_picked.isNotEmpty) ...[
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _picked.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, int i) => _PickedThumb(
              file: _picked[i],
              onRemove: () => setState(() => _picked.removeAt(i)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      OutlinedButton.icon(
        onPressed: _pickImages,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(_picked.isEmpty ? '添加截图 / 图片' : '再多选几张'),
      ),
      const SizedBox(height: 12),
      Text(
        '多张图片会作为同一条记录保存。图片复制到 App 私有目录，'
        '写点文字当备注，之后 AI 整理会更好理解上下文。',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    ];
  }

  // ── 编辑：可以继续加图，也可以单独移除某张图 ──────────────

  List<Widget> _buildEditImageSection(ThemeData theme) {
    final List<String> existing = MediaStorage.parsePaths(_editing?.imagePath)
        .where((String path) => !_removedPaths.contains(path))
        .toList();
    final int total = existing.length + _picked.length;

    return [
      if (total > 0) ...[
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: total,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int i) {
              if (i < existing.length) {
                final String path = existing[i];
                final String? absolute = MediaStorage.resolveSync(path);
                if (absolute == null) {
                  return const SizedBox(
                    width: 96,
                    height: 96,
                    child: Icon(Icons.broken_image_outlined),
                  );
                }
                return _PickedThumb(
                  file: File(absolute),
                  onRemove: () => setState(() => _removedPaths.add(path)),
                );
              }

              final File file = _picked[i - existing.length];
              return _PickedThumb(
                file: file,
                onRemove: () =>
                    setState(() => _picked.removeAt(i - existing.length)),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '共 $total 张图片。点右上角 × 可移除，保存后才会真正删除。',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 14),
      ],
      OutlinedButton.icon(
        onPressed: _pickImages,
        icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
        label: Text(total == 0 ? '添加图片' : '继续添加图片'),
      ),
      if (_removedPaths.isNotEmpty) ...[
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 14,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '保存后将删除 ${_removedPaths.length} 张旧图片',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _removedPaths.clear()),
              child: const Text('撤销'),
            ),
          ],
        ),
      ],
      const SizedBox(height: 12),
      Text(
        '图片会复制到 App 私有目录。一条记录可以放多张图，'
        'AI 整理会把它们放在一起理解。',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
          height: 1.4,
        ),
      ),
    ];
  }
}

/// 条目变更历史。像聊天记录一样从上往下排：第一条是创建，之后每次编辑各一条。
class _RevisionTimeline extends ConsumerWidget {
  const _RevisionTimeline({required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<InboxItemRevision>> revisionsAsync = ref.watch(
      inboxRevisionsProvider(itemId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '变更记录',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        switch (revisionsAsync) {
          AsyncData(:final List<InboxItemRevision> value) =>
            value.isEmpty
                ? Text(
                    '没有记录',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < value.length; i++)
                        _RevisionRow(
                          revision: value[i],
                          isFirst: i == 0,
                          isLast: i == value.length - 1,
                        ),
                    ],
                  ),
          AsyncError(:final Object error) => Text('读取失败：$error'),
          _ => const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          ),
        },
      ],
    );
  }
}

class _RevisionRow extends StatelessWidget {
  const _RevisionRow({
    required this.revision,
    required this.isFirst,
    required this.isLast,
  });

  final InboxItemRevision revision;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isCreated = revision.kind == 'created';
    final Color dotColor = isCreated
        ? theme.colorScheme.primary
        : theme.colorScheme.tertiary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                SizedBox(
                  height: 18,
                  child: isFirst
                      ? const SizedBox.shrink()
                      : Center(
                          child: Container(
                            width: 2,
                            height: 18,
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isCreated ? '创建' : '编辑',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: dotColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppDate.friendly(revision.recordedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (revision.content?.trim().isEmpty ?? true)
                        ? '（空）'
                        : revision.content!.trim(),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickedThumb extends StatelessWidget {
  const _PickedThumb({required this.file, required this.onRemove});

  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            file,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
            cacheWidth: 288,
            errorBuilder: (_, _, _) => Container(
              width: 96,
              height: 96,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.broken_image_outlined,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
