import 'package:lifelog/features/ai_chat/data/chat_store.dart';

const String defaultAiName = 'Lifelog AI';

const String defaultAiPersona =
    '你是住在 Lifelog 里的本地 AI 助手。冷静、可靠、略带未来感，说话简洁自然，'
    '不油腻、不堆砌客套话。你熟悉这个 App 的每一个功能，能直接替用户操作，'
    '也能在用户找不到功能时带他去对应页面。你尊重用户的隐私：所有数据都在手机本地，'
    '不要声称自己能看到手机之外的东西。';

const String _actionSchema = '''
可用操作（actions 数组，可以一次执行多个）：
1. navigate：打开页面
   {"name":"navigate","args":{"route":"/track"}}
   路由：
   /inbox 收集箱；/organize AI 整理；/schedule 日程；/track 轨迹；
   /settings 设置；/ai/settings AI 人设与记忆；/compose 新建笔记；
   /schedule/new 新建日程；/track/health 轨迹后台自检
2. guide：带用户去某个页面并给一句提示
   {"name":"guide","args":{"route":"/settings","tip":"在这里可以配置模型"}}
3. create_note：往收集箱写一条文字
   {"name":"create_note","args":{"content":"..."}}
4. create_schedule：创建日程
   {"name":"create_schedule","args":{"title":"...","start_at":"2026-10-18T15:00:00","end_at":"2026-10-18T16:00:00","description":null,"location":null}}
5. query：查询 App 数据
   {"name":"query","args":{"target":"today"}}
   target：today | inbox | schedules | steps | track
6. search：搜索收集箱和日程
   {"name":"search","args":{"query":"..."}}
7. start_tracking / stop_tracking：开始/停止记录轨迹
   {"name":"start_tracking","args":{}}
8. set_track_accuracy：切换轨迹精度
   {"name":"set_track_accuracy","args":{"level":"low"}}
   level：low 省电 | balanced 平衡 | high 高精度
9. open_location_settings：打开系统定位设置
10. complete_schedule：把日程标记为完成
    {"name":"complete_schedule","args":{"id":123}}
    或 {"name":"complete_schedule","args":{"title":"会议"}}
11. open_schedule：打开某条日程的编辑页
    {"name":"open_schedule","args":{"id":123}}
12. remember / forget：写入或删除一条长期记忆
    {"name":"remember","args":{"text":"用户喜欢..."}}
13. add_knowledge：写入知识库
    {"name":"add_knowledge","args":{"title":"...","content":"..."}}

规则：
- 只输出一个 json 对象，结构：{"reply":"给用户看的话","actions":[...]}。
- 没有要执行的操作时，actions 输出空数组 []。
- 用户问数据（今天走了多少、有什么日程、收集箱有什么）时，先 query，再根据结果回答。
- 用户要找功能或问“在哪”时，用 navigate 或 guide。
- 用户要求开始/停止定位记录时，直接调用动作；如果失败，再说明需要检查权限。
- 用户表达长期偏好、重要事实、称呼、目标时，调用 remember。
- 不要编造 App 里没有的数据；不确定就 query 或问用户。
- reply 要简短、自然，不要输出 markdown 表格。
''';

/// 第一轮的系统提示：人设 + 能力 + 数据 + 记忆 + 知识库。
String buildAiSystemPrompt({
  required String name,
  required String persona,
  required List<ChatMemory> memories,
  required List<ChatKnowledge> knowledge,
  required String context,
  required DateTime now,
}) {
  final StringBuffer buffer = StringBuffer();
  buffer.writeln('你是「$name」。');
  buffer.writeln('人设：$persona');
  buffer.writeln();
  buffer.writeln('当前时间：${_formatDateTime(now)}');
  buffer.writeln('App 当前数据摘要：$context');
  buffer.writeln();
  buffer.writeln(_actionSchema);

  if (memories.isNotEmpty) {
    buffer.writeln();
    buffer.writeln('【长期记忆】');
    for (final ChatMemory memory in memories.take(50)) {
      buffer.writeln('- ${memory.text}');
    }
  }

  if (knowledge.isNotEmpty) {
    buffer.writeln();
    buffer.writeln('【知识库】');
    int budget = 6000;
    for (final ChatKnowledge item in knowledge) {
      final String block = '- ${item.title}：${item.content}';
      if (block.length > budget) break;
      buffer.writeln(block);
      budget -= block.length;
    }
  }

  return buffer.toString();
}

String buildAiConversationPrompt({
  required String system,
  required List<ChatMessage> history,
  required String userText,
}) {
  final StringBuffer buffer = StringBuffer();
  buffer.writeln(system);
  buffer.writeln();
  buffer.writeln('【最近的对话】');
  _writeHistory(buffer, history);
  buffer.writeln();
  buffer.writeln('【用户最新消息】');
  buffer.writeln(userText);
  buffer.writeln();
  buffer.writeln('请只输出 json：{"reply":"...","actions":[...]}。');
  return buffer.toString();
}

String buildAiActionResultPrompt({
  required String system,
  required List<ChatMessage> history,
  required String userText,
  required List<String> results,
}) {
  final StringBuffer buffer = StringBuffer();
  buffer.writeln(system);
  buffer.writeln();
  buffer.writeln('【最近的对话】');
  _writeHistory(buffer, history);
  buffer.writeln();
  buffer.writeln('【用户最新消息】');
  buffer.writeln(userText);
  buffer.writeln();
  buffer.writeln('【系统刚执行的操作及结果】');
  for (final String result in results) {
    buffer.writeln('- $result');
  }
  buffer.writeln();
  buffer.writeln('请直接用自然语言回复用户，不要输出 json，不要再次调用操作。');
  return buffer.toString();
}

void _writeHistory(StringBuffer buffer, List<ChatMessage> history) {
  final List<ChatMessage> recent = history.length > 20
      ? history.sublist(history.length - 20)
      : history;
  if (recent.isEmpty) {
    buffer.writeln('（暂无）');
    return;
  }
  for (final ChatMessage message in recent) {
    buffer.writeln('${message.role == 'user' ? '用户' : '你'}：${message.text}');
  }
}

String _formatDateTime(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)} '
      '${two(t.hour)}:${two(t.minute)}';
}
