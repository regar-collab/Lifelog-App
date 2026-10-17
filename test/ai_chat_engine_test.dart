import 'package:flutter_test/flutter_test.dart';
import 'package:lifelog/features/ai_chat/data/ai_chat_engine.dart';

void main() {
  group('AiChatEngine.parseTurn', () {
    test('解析 reply 和 actions', () {
      final ChatTurn turn = AiChatEngine.parseTurn(
        '{"reply":"已经带你去轨迹页了",'
        '"actions":[{"name":"navigate","args":{"route":"/track"}}]}',
      );

      expect(turn.reply, '已经带你去轨迹页了');
      expect(turn.actions, hasLength(1));
      expect(turn.actions.single.name, 'navigate');
      expect(turn.actions.single.stringArg('route'), '/track');
    });

    test('兼容 markdown 代码块', () {
      final ChatTurn turn = AiChatEngine.parseTurn(
        '```json\n{"reply":"好的","actions":[]}\n```',
      );

      expect(turn.reply, '好的');
      expect(turn.actions, isEmpty);
    });

    test('不是 JSON 时退回纯文本', () {
      final ChatTurn turn = AiChatEngine.parseTurn('今天走了 3210 步。');
      expect(turn.reply, '今天走了 3210 步。');
      expect(turn.actions, isEmpty);
    });

    test('忽略结构不完整的 action', () {
      final ChatTurn turn = AiChatEngine.parseTurn(
        '{"reply":"好","actions":[{"args":{}},{"name":"remember",'
        '"args":{"text":"喜欢下午开会"}}]}',
      );

      expect(turn.actions, hasLength(1));
      expect(turn.actions.single.name, 'remember');
      expect(turn.actions.single.stringArg('text'), '喜欢下午开会');
    });
  });
}
