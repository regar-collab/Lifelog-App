import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/core/router/app_router.dart';
import 'package:lifelog/core/utils/date_utils.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/services/ai/ai_service.dart';
import 'package:lifelog/data/services/media_storage.dart';
import 'package:lifelog/features/ai_chat/data/ai_chat_engine.dart';
import 'package:lifelog/features/ai_chat/data/ai_chat_prompt.dart';
import 'package:lifelog/features/ai_chat/data/chat_action_executor.dart';
import 'package:lifelog/features/ai_chat/data/chat_store.dart';
import 'package:lifelog/features/inbox/application/inbox_providers.dart';
import 'package:lifelog/features/schedule/application/schedule_providers.dart';
import 'package:lifelog/features/settings/application/ai_providers.dart';
import 'package:lifelog/features/settings/application/app_settings_providers.dart';
import 'package:lifelog/features/steps/application/step_tracker.dart';
import 'package:lifelog/features/track/application/track_providers.dart';

/// AI 聊天主页。
///
/// 这不是一个只会说话的聊天框：模型可以按协议返回 action，
/// 由 [ChatActionExecutor] 真正操作 App（导航、建日程、开关轨迹等），
/// 然后再把执行结果交给模型做自然语言总结。
class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ChatStore _store = ChatStore.instance;

  final List<ChatMessage> _messages = <ChatMessage>[];

  bool _loading = true;
  bool _sending = false;

  String _name = defaultAiName;
  String _persona = defaultAiPersona;
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
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final List<ChatMessage> messages = await _store.loadMessages();
    await _reloadProfile();
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(messages);
      _loading = false;
    });
    _scrollToBottom();
  }

  Future<void> _reloadProfile() async {
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
      _name = name.trim().isEmpty ? defaultAiName : name.trim();
      _persona = persona.trim().isEmpty ? defaultAiPersona : persona.trim();
      _avatarPath = avatar.trim().isEmpty ? null : avatar.trim();
      _memories = memories;
      _knowledge = knowledge;
    });
  }

  Future<void> _openSettings() async {
    await appRouter.push('/ai/settings');
    await _reloadProfile();
  }

  Future<void> _newChat() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('开一个新对话？'),
        content: const Text('当前聊天记录会被清空，但长期记忆和知识库不受影响。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('新对话'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _store.clearMessages();
    if (!mounted) return;
    setState(() => _messages.clear());
  }

  Future<void> _sendText(String text) async {
    final String userText = text.trim();
    if (userText.isEmpty || _sending) return;

    final ChatMessage userMessage = ChatMessage(
      id: ChatStore.newId(),
      role: 'user',
      text: userText,
      at: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.add(userMessage);
      _sending = true;
    });
    _input.clear();
    await _store.saveMessages(_messages);
    _scrollToBottom();

    try {
      final AiService ai = await ref.read(aiServiceProvider.future);
      final String context = await _buildContext();
      final List<ChatMessage> history = _messages.sublist(
        0,
        _messages.length - 1,
      );
      final String system = buildAiSystemPrompt(
        name: _name,
        persona: _persona,
        memories: _memories,
        knowledge: _knowledge,
        context: context,
        now: DateTime.now(),
      );

      final AiChatEngine engine = AiChatEngine(ai);
      final ChatTurn turn = await engine.firstTurn(
        buildAiConversationPrompt(
          system: system,
          history: history,
          userText: userText,
        ),
      );

      String reply = turn.reply.trim();
      final List<String> actionLabels = <String>[];

      if (turn.actions.isNotEmpty) {
        final ChatActionExecutor executor = ChatActionExecutor(ref);
        final List<String> results = <String>[];

        for (final ChatAction action in turn.actions) {
          final String result = await executor.execute(action);
          results.add('${action.name}：$result');
          actionLabels.add(_actionLabel(action.name));
        }

        // 把执行结果交回模型，让它用自然语言总结。
        try {
          final String finalReply = await engine.finalTurn(
            buildAiActionResultPrompt(
              system: system,
              history: history,
              userText: userText,
              results: results,
            ),
          );
          if (finalReply.trim().isNotEmpty) reply = finalReply.trim();
        } catch (_) {
          if (reply.isEmpty) reply = results.join('\n');
        }
      }

      if (reply.isEmpty) {
        reply = turn.actions.isEmpty ? '我在。' : '操作完成了。';
      }

      final ChatMessage assistantMessage = ChatMessage(
        id: ChatStore.newId(),
        role: 'assistant',
        text: reply,
        at: DateTime.now().millisecondsSinceEpoch,
        actions: actionLabels,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(assistantMessage);
        _sending = false;
      });
      await _store.saveMessages(_messages);
      await _reloadProfile();
      _scrollToBottom();
    } on AiException catch (e) {
      await _appendError(e.message);
    } catch (e) {
      await _appendError('暂时没能完成：$e');
    }
  }

  Future<void> _appendError(String message) async {
    final ChatMessage errorMessage = ChatMessage(
      id: ChatStore.newId(),
      role: 'assistant',
      text: message,
      at: DateTime.now().millisecondsSinceEpoch,
    );
    if (!mounted) return;
    setState(() {
      _messages.add(errorMessage);
      _sending = false;
    });
    await _store.saveMessages(_messages);
    _scrollToBottom();
  }

  Future<String> _buildContext() async {
    final DateTime now = DateTime.now();
    final int pending =
        (await ref.read(inboxDaoProvider).getPendingItems()).length;
    final DailyStep? steps = await ref
        .read(stepDaoProvider)
        .getByDate(_dateKey(now));
    final summary = await ref.read(trackRepositoryProvider).todaySummary();
    final List<Schedule> all = await ref
        .read(scheduleDaoProvider)
        .watchAll()
        .first;
    final int nowMs = now.millisecondsSinceEpoch;
    final String schedules = all
        .where((Schedule s) => s.status == 'planned' && s.startAt > nowMs)
        .take(5)
        .map((Schedule s) => '${_shortDate(s.startAt)} ${s.title}')
        .join('；');
    return '待整理 $pending 条；今日步数 ${steps?.steps ?? 0}；'
        '今日轨迹 ${summary.distanceKm} 公里；'
        '未来日程：${schedules.isEmpty ? '无' : schedules}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  String _dateKey(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)}';
  }

  String _shortDate(int millis) {
    final DateTime t = DateTime.fromMillisecondsSinceEpoch(millis);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }

  String _actionLabel(String name) {
    return switch (name) {
      'navigate' => '打开页面',
      'guide' => '带路',
      'create_note' => '写入收集箱',
      'create_schedule' => '创建日程',
      'query' => '查询数据',
      'search' => '搜索',
      'start_tracking' => '开始记录轨迹',
      'stop_tracking' => '停止记录轨迹',
      'set_track_accuracy' => '切换轨迹精度',
      'open_location_settings' => '定位设置',
      'complete_schedule' => '完成日程',
      'open_schedule' => '打开日程',
      'remember' => '记住',
      'forget' => '忘记',
      'add_knowledge' => '写入知识库',
      _ => name,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<AiConfig> configAsync = ref.watch(aiConfigProvider);
    final bool needsKey = switch (configAsync) {
      AsyncData(:final AiConfig value) =>
        value.apiKey.trim().isEmpty &&
            value.providerId != 'ollama' &&
            value.providerId != 'custom',
      _ => false,
    };

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              theme.colorScheme.surface,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme),
              if (needsKey) _buildKeyBanner(theme),
              Expanded(
                child: _messages.isEmpty
                    ? _buildWelcome(theme)
                    : _buildMessages(theme),
              ),
              if (_sending) _buildThinking(theme),
              _buildInputBar(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
      child: Row(
        children: [
          _avatar(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF35C98A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '本地 AI · 可操作 App',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '新对话',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: _newChat,
          ),
          IconButton(
            tooltip: 'AI 人设与记忆',
            icon: const Icon(Icons.tune),
            onPressed: _openSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildKeyBanner(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.key_outlined, size: 18, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '还没有配置 AI API Key，聊天暂时不可用。',
              style: theme.textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () => appRouter.push('/settings'),
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome(ThemeData theme) {
    final List<String> suggestions = <String>[
      '今天走了多少？',
      '帮我安排明天下午 3 点开会',
      '开始记录轨迹',
      '带我去设置',
      '帮我看看未来日程',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      children: [
        Center(child: _avatar(size: 84, glow: true)),
        const SizedBox(height: 22),
        Text(
          '你好，我是 $_name',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '我可以帮你记东西、排日程、查步数和轨迹，'
          '也能直接打开 App 的任意页面。所有数据都在你的手机本地。',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final String text in suggestions)
              ActionChip(label: Text(text), onPressed: () => _sendText(text)),
          ],
        ),
      ],
    );
  }

  Widget _buildMessages(ThemeData theme) {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      itemCount: _messages.length,
      itemBuilder: (BuildContext context, int index) {
        final ChatMessage message = _messages[index];
        return _MessageBubble(
          message: message,
          name: _name,
          avatar: _avatar(size: 30),
          theme: theme,
        );
      },
    );
  }

  Widget _buildThinking(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _avatar(size: 28),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text('正在思考…', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      padding: const EdgeInsets.fromLTRB(16, 4, 6, 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              enabled: !_sending,
              onSubmitted: (String value) => _sendText(value),
              decoration: InputDecoration(
                hintText: '和 $_name 说点什么…',
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ),
          IconButton.filled(
            tooltip: '发送',
            onPressed: _sending ? null : () => _sendText(_input.text),
            icon: const Icon(Icons.arrow_upward_rounded),
          ),
        ],
      ),
    );
  }

  Widget _avatar({double size = 40, bool glow = false}) {
    final String? path = _avatarPath;
    final String? absolute = path == null
        ? null
        : MediaStorage.resolveSync(path);
    if (absolute != null && File(absolute).existsSync()) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(File(absolute)),
      );
    }

    final ThemeData theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
        ),
        boxShadow: glow
            ? <BoxShadow>[
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: Icon(Icons.auto_awesome, color: Colors.white, size: size * 0.46),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.name,
    required this.avatar,
    required this.theme,
  });

  final ChatMessage message;
  final String name;
  final Widget avatar;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.role == 'user';

    final Widget bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.76,
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: isUser
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 5),
          bottomRight: Radius.circular(isUser ? 5 : 18),
        ),
        border: isUser
            ? null
            : Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.18),
              ),
      ),
      child: SelectableText(
        message.text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isUser ? theme.colorScheme.onPrimary : null,
          height: 1.5,
        ),
      ),
    );

    final Widget meta = Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        AppDate.short(message.at),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.outline,
          fontSize: 10,
        ),
      ),
    );

    final List<Widget> actionChips = <Widget>[
      for (final String action in message.actions)
        Container(
          margin: const EdgeInsets.only(top: 6, right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            action,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 10,
            ),
          ),
        ),
    ];

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [bubble, meta],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          avatar,
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                bubble,
                if (actionChips.isNotEmpty) Wrap(children: actionChips),
                meta,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
