import 'dart:convert';

import 'package:lifelog/data/services/ai/ai_service.dart';

/// AI 输出里的一步操作。
class ChatAction {
  const ChatAction({required this.name, this.args = const <String, dynamic>{}});

  final String name;
  final Map<String, dynamic> args;

  String? stringArg(String key) => args[key]?.toString();
  int? intArg(String key) {
    final Object? value = args[key];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

/// 第一轮 AI 的返回：自然语言 + 要执行的操作。
class ChatTurn {
  const ChatTurn({required this.reply, this.actions = const <ChatAction>[]});

  final String reply;
  final List<ChatAction> actions;
}

/// 负责和模型交互、解析动作协议。
///
/// 不依赖各家的 function calling 格式，统一让模型输出
/// `{"reply": "...", "actions": [...]}`，这样 OpenAI 兼容、
/// Claude、Gemini 三套适配器都能用同一套逻辑。
class AiChatEngine {
  AiChatEngine(this.ai);

  final AiService ai;

  Future<ChatTurn> firstTurn(String prompt) async {
    final String raw = await ai.chat(
      prompt: prompt,
      jsonMode: true,
      temperature: 0.7,
    );
    return parseTurn(raw);
  }

  Future<String> finalTurn(String prompt) {
    return ai.chat(prompt: prompt, jsonMode: false, temperature: 0.7);
  }

  static ChatTurn parseTurn(String raw) {
    final String cleaned = _stripCodeFence(raw);
    try {
      final Object? decoded = jsonDecode(cleaned);
      if (decoded is Map) {
        final String reply = (decoded['reply'] ?? '').toString().trim();
        final List<ChatAction> actions = <ChatAction>[];
        final Object? rawActions = decoded['actions'];
        if (rawActions is List) {
          for (final Object? item in rawActions) {
            if (item is! Map) continue;
            final Object? name = item['name'];
            if (name is! String || name.trim().isEmpty) continue;
            final Object? args = item['args'];
            actions.add(
              ChatAction(
                name: name.trim(),
                args: args is Map
                    ? Map<String, dynamic>.from(args)
                    : const <String, dynamic>{},
              ),
            );
          }
        }
        if (reply.isNotEmpty || actions.isNotEmpty) {
          return ChatTurn(reply: reply, actions: actions);
        }
      }
    } catch (_) {
      // 模型没按 JSON 返回时，直接把它当普通回答
    }
    return ChatTurn(reply: raw.trim());
  }

  static String _stripCodeFence(String text) {
    String t = text.trim();
    if (!t.startsWith('```')) return t;
    final int firstNewline = t.indexOf('\n');
    if (firstNewline != -1) t = t.substring(firstNewline + 1);
    if (t.endsWith('```')) t = t.substring(0, t.length - 3);
    return t.trim();
  }
}
