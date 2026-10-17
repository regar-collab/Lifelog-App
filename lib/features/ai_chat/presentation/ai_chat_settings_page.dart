import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lifelog/data/services/media_storage.dart';
import 'package:lifelog/features/ai_chat/data/ai_chat_prompt.dart';
import 'package:lifelog/features/ai_chat/data/chat_store.dart';
import 'package:lifelog/features/settings/application/app_settings_providers.dart';

/// AI 人设、头像、长期记忆、知识库、对话记录管理。
class AiChatSettingsPage extends ConsumerStatefulWidget {
  const AiChatSettingsPage({super.key});

  @override
  ConsumerState<AiChatSettingsPage> createState() => _AiChatSettingsPageState();
}

class _AiChatSettingsPageState extends ConsumerState<AiChatSettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _personaController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ChatStore _store = ChatStore.instance;

  bool _loading = true;
  bool _saving = false;
  String? _avatarPath;

  List<ChatMemory> _memories = <ChatMemory>[];
  List<ChatKnowledge> _knowledge = <ChatKnowledge>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _personaController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final dao = ref.read(settingsDaoProvider);
    final String name = await dao.getOrDefault(
      SettingKeys.aiChatName,
      defaultAiName,
    );
    final String persona = await dao.getOrDefault(
      SettingKeys.aiChatPersona,
      defaultAiPersona,
    );
    final String avatar = await dao.getOrDefault(
      SettingKeys.aiChatAvatarPath,
      '',
    );
    final List<ChatMemory> memories = await _store.loadMemories();
    final List<ChatKnowledge> knowledge = await _store.loadKnowledge();

    if (!mounted) return;
    setState(() {
      _nameController.text = name;
      _personaController.text = persona;
      _avatarPath = avatar.trim().isEmpty ? null : avatar.trim();
      _memories = memories;
      _knowledge = knowledge;
      _loading = false;
    });
  }

  Future<void> _savePersona() async {
    setState(() => _saving = true);
    final dao = ref.read(settingsDaoProvider);
    final String name = _nameController.text.trim().isEmpty
        ? defaultAiName
        : _nameController.text.trim();
    final String persona = _personaController.text.trim().isEmpty
        ? defaultAiPersona
        : _personaController.text.trim();
    await dao.set(SettingKeys.aiChatName, name);
    await dao.set(SettingKeys.aiChatPersona, persona);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('人设已保存')));
  }

  Future<void> _pickAvatar() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;

    final String saved = await MediaStorage.saveImage(File(file.path));
    final dao = ref.read(settingsDaoProvider);
    final String? old = await dao.get(SettingKeys.aiChatAvatarPath);
    await dao.set(SettingKeys.aiChatAvatarPath, saved);
    if (old != null && old.trim().isNotEmpty) {
      try {
        await MediaStorage.deleteIfExists(old);
      } catch (_) {
        // ignore
      }
    }
    if (!mounted) return;
    setState(() => _avatarPath = saved);
  }

  Future<void> _clearAvatar() async {
    final dao = ref.read(settingsDaoProvider);
    final String? old = await dao.get(SettingKeys.aiChatAvatarPath);
    await dao.set(SettingKeys.aiChatAvatarPath, '');
    if (old != null && old.trim().isNotEmpty) {
      try {
        await MediaStorage.deleteIfExists(old);
      } catch (_) {
        // ignore
      }
    }
    if (!mounted) return;
    setState(() => _avatarPath = null);
  }

  Future<void> _addMemory() async {
    final TextEditingController controller = TextEditingController();
    final String? text = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('添加一条长期记忆'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(hintText: '例如：用户喜欢把会议安排在下午'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('添加'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;

    _memories = <ChatMemory>[
      ..._memories,
      ChatMemory(id: ChatStore.newId(), text: text, at: _nowMs),
    ];
    await _store.saveMemories(_memories);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _deleteMemory(ChatMemory memory) async {
    _memories = _memories.where((ChatMemory m) => m.id != memory.id).toList();
    await _store.saveMemories(_memories);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _editKnowledge([ChatKnowledge? existing]) async {
    final TextEditingController titleController = TextEditingController(
      text: existing?.title ?? '',
    );
    final TextEditingController contentController = TextEditingController(
      text: existing?.content ?? '',
    );

    final ChatKnowledge? result = await showDialog<ChatKnowledge>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(existing == null ? '添加知识' : '编辑知识'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '例如：我的工作习惯',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: '内容',
                  hintText: 'AI 会在对话时参考这段内容',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final String title = titleController.text.trim();
              final String content = contentController.text.trim();
              if (title.isEmpty || content.isEmpty) return;
              Navigator.pop(
                ctx,
                ChatKnowledge(
                  id: existing?.id ?? ChatStore.newId(),
                  title: title,
                  content: content,
                  at: existing?.at ?? _nowMs,
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == null) return;
    if (existing == null) {
      _knowledge = <ChatKnowledge>[..._knowledge, result];
    } else {
      _knowledge = _knowledge
          .map((ChatKnowledge k) => k.id == result.id ? result : k)
          .toList();
    }
    await _store.saveKnowledge(_knowledge);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _deleteKnowledge(ChatKnowledge item) async {
    _knowledge = _knowledge
        .where((ChatKnowledge k) => k.id != item.id)
        .toList();
    await _store.saveKnowledge(_knowledge);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _clearChat() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('清空聊天记录？'),
        content: const Text('只删除聊天消息，人设、记忆和知识库都会保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _store.clearMessages();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('聊天记录已清空')));
  }

  int get _nowMs => DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AI 人设与记忆')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                const _SectionTitle('人设'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            _buildAvatar(theme),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _pickAvatar,
                                    icon: const Icon(
                                      Icons.photo_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('选择头像'),
                                  ),
                                  if (_avatarPath != null)
                                    TextButton(
                                      onPressed: _clearAvatar,
                                      child: const Text('恢复默认头像'),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: '名字',
                            hintText: '例如：Muse / 小生 / 你的助手',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _personaController,
                          minLines: 4,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            labelText: '人设 / 说话风格',
                            hintText: '描述它是什么性格、怎么和你说话',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: _saving ? null : _savePersona,
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined, size: 18),
                          label: const Text('保存人设'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitleRow(
                  title: '长期记忆',
                  actionLabel: '添加',
                  onAction: _addMemory,
                ),
                Card(
                  child: _memories.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('还没有长期记忆。聊天时说“记住……”或在这里手动添加。'),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < _memories.length; i++) ...[
                              if (i > 0) const Divider(height: 1, indent: 16),
                              ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.psychology_outlined,
                                  size: 20,
                                ),
                                title: Text(_memories[i].text),
                                trailing: IconButton(
                                  tooltip: '删除',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  onPressed: () => _deleteMemory(_memories[i]),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                _SectionTitleRow(
                  title: '知识库',
                  actionLabel: '添加',
                  onAction: () => _editKnowledge(),
                ),
                Card(
                  child: _knowledge.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('还没有知识条目。可以添加你的习惯、项目背景、常用信息等。'),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < _knowledge.length; i++) ...[
                              if (i > 0) const Divider(height: 1, indent: 16),
                              ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.menu_book_outlined,
                                  size: 20,
                                ),
                                title: Text(_knowledge[i].title),
                                subtitle: Text(
                                  _knowledge[i].content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _editKnowledge(_knowledge[i]),
                                trailing: IconButton(
                                  tooltip: '删除',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      _deleteKnowledge(_knowledge[i]),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                const _SectionTitle('对话'),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.delete_sweep_outlined),
                    title: const Text('清空聊天记录'),
                    subtitle: const Text('不影响人设、记忆和知识库'),
                    onTap: _clearChat,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '聊天记录、记忆和知识库都保存在手机本地，不会上传到第三方。'
                  '只有聊天时会把当前对话和相关信息发送给你配置的 AI 服务商。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    height: 1.5,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final String? path = _avatarPath;
    final String? absolute = path == null
        ? null
        : MediaStorage.resolveSync(path);
    if (absolute != null && File(absolute).existsSync()) {
      return CircleAvatar(
        radius: 34,
        backgroundImage: FileImage(File(absolute)),
      );
    }
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: <Color>[
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
        ),
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
