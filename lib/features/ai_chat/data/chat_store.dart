import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 一条聊天消息。
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.at,
    this.actions = const <String>[],
  });

  final String id;

  /// user | assistant
  final String role;
  final String text;
  final int at;

  /// AI 这次执行了哪些操作（给用户看的短标签）
  final List<String> actions;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'role': role,
      'text': text,
      'at': at,
      'actions': actions,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'assistant',
      text: json['text']?.toString() ?? '',
      at:
          (json['at'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      actions:
          (json['actions'] as List?)?.whereType<String>().toList() ??
          const <String>[],
    );
  }
}

/// 一条长期记忆。
class ChatMemory {
  const ChatMemory({required this.id, required this.text, required this.at});

  final String id;
  final String text;
  final int at;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'text': text,
    'at': at,
  };

  factory ChatMemory.fromJson(Map<String, dynamic> json) {
    return ChatMemory(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      at:
          (json['at'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}

/// 一条知识库内容。
class ChatKnowledge {
  const ChatKnowledge({
    required this.id,
    required this.title,
    required this.content,
    required this.at,
  });

  final String id;
  final String title;
  final String content;
  final int at;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'content': content,
    'at': at,
  };

  factory ChatKnowledge.fromJson(Map<String, dynamic> json) {
    return ChatKnowledge(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      at:
          (json['at'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}

/// AI 聊天的本地存储。
///
/// 聊天记录、长期记忆、知识库都是用户自己的数据，存在应用私有目录的
/// JSON 文件里；不引入新的数据库表，避免迁移风险。
class ChatStore {
  ChatStore._();

  static final ChatStore instance = ChatStore._();

  static const String _messagesFile = 'ai_chat_messages.json';
  static const String _memoriesFile = 'ai_chat_memories.json';
  static const String _knowledgeFile = 'ai_chat_knowledge.json';

  /// 只保留最近这么多条消息，避免单文件无限增长。
  static const int _maxMessages = 500;

  Future<File> _file(String name) async {
    final Directory dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, name));
  }

  Future<List<dynamic>> _readList(String name) async {
    try {
      final File file = await _file(name);
      if (!await file.exists()) return <dynamic>[];
      final Object? decoded = jsonDecode(await file.readAsString());
      return decoded is List ? decoded : <dynamic>[];
    } catch (_) {
      return <dynamic>[];
    }
  }

  Future<void> _writeList(String name, List<dynamic> values) async {
    final File file = await _file(name);
    final File tmp = File('${file.path}.tmp');
    final String payload = jsonEncode(values);
    await tmp.writeAsString(payload, flush: true);
    try {
      await tmp.rename(file.path);
    } catch (_) {
      await file.writeAsString(payload, flush: true);
      try {
        await tmp.delete();
      } catch (_) {
        // ignore
      }
    }
  }

  Future<List<ChatMessage>> loadMessages() async {
    final List<dynamic> raw = await _readList(_messagesFile);
    return raw
        .whereType<Map>()
        .map((Map m) => ChatMessage.fromJson(m.cast<String, dynamic>()))
        .toList();
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    final List<ChatMessage> trimmed = messages.length <= _maxMessages
        ? messages
        : messages.sublist(messages.length - _maxMessages);
    await _writeList(
      _messagesFile,
      trimmed.map((ChatMessage m) => m.toJson()).toList(),
    );
  }

  Future<void> clearMessages() async {
    await _writeList(_messagesFile, <dynamic>[]);
  }

  Future<List<ChatMemory>> loadMemories() async {
    final List<dynamic> raw = await _readList(_memoriesFile);
    return raw
        .whereType<Map>()
        .map((Map m) => ChatMemory.fromJson(m.cast<String, dynamic>()))
        .toList();
  }

  Future<void> saveMemories(List<ChatMemory> memories) async {
    await _writeList(
      _memoriesFile,
      memories.map((ChatMemory m) => m.toJson()).toList(),
    );
  }

  Future<List<ChatKnowledge>> loadKnowledge() async {
    final List<dynamic> raw = await _readList(_knowledgeFile);
    return raw
        .whereType<Map>()
        .map((Map m) => ChatKnowledge.fromJson(m.cast<String, dynamic>()))
        .toList();
  }

  Future<void> saveKnowledge(List<ChatKnowledge> items) async {
    await _writeList(
      _knowledgeFile,
      items.map((ChatKnowledge k) => k.toJson()).toList(),
    );
  }

  static String newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${DateTime.now().millisecond}';
}
