import 'package:intl/intl.dart';
import 'package:lifelog/data/db/app_database.dart';

/// 组装发给 AI 的整理 prompt。
///
/// 三个要点：
/// 1. 打开 json 模式时，大多数兼容接口都要求 prompt 里出现 "json" 字样。
/// 2. 必须把「当前时间」明确告诉模型 —— 否则它无法把「明天下午三点」换算成具体日期。
/// 3. 必须明确要求「提炼」和「拆分」—— 用户的原话是口语化的一大段，
///    而日程需要的是短标题 + 一条一件事，模型默认不会主动做这两件事。
String buildOrganizePrompt({
  required List<InboxItem> items,
  required DateTime now,
  Map<int, int> sentImageCounts = const <int, int>{},
  Map<int, int> totalImageCounts = const <int, int>{},
}) {
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('你是日程整理助手。下面是用户随手记下的零散内容，请把它们整理成结构化的日程。');
  buffer.writeln();

  buffer.writeln(
    '当前时间：${DateFormat('yyyy-MM-dd HH:mm').format(now)}'
    '（${_weekdayCn(now)}）',
  );
  buffer.writeln();

  buffer.writeln('【提炼，最重要的一条】');
  buffer.writeln(
    '用户的原话往往啰嗦、口语化、有重复和口头禅。你的任务是**提炼**：'
    '把一大段话浓缩成一个简短、清楚的事件标题，不要照抄原话，'
    '也不要原样搬运语气词。比如「那个，我想着明天有空的话，'
    '要不还是去把那个快递取一下吧，就是前两天买的那个」'
    '应该提炼成「取快递」。',
  );
  buffer.writeln();

  buffer.writeln('【拆分】');
  buffer.writeln(
    '一条内容里如果包含多个不同时间的安排，**必须拆成多条日程**，'
    '每条只描述一件事、只占一个时间段。',
  );
  buffer.writeln(
    '比如「早上记得买杯豆浆，晚上记得喝杯八宝粥」要拆成两条：'
    '一条「买豆浆」排在早上，一条「喝八宝粥」排在晚上。',
  );
  buffer.writeln(
    '绝对不要把它们塞进同一条日程里。'
    '多条日程的 source_indexes 可以指向同一条内容，这是允许的。',
  );
  buffer.writeln();

  buffer.writeln('输出要求：');
  buffer.writeln('1. 只输出 json，不要任何解释文字，不要 markdown 代码块。');
  buffer.writeln('2. json 结构：');
  buffer.writeln(
    '{"schedules":[{"title":"标题","description":null,'
    '"start_at":"2026-10-11T15:00:00","end_at":"2026-10-11T16:00:00",'
    '"is_all_day":false,"location":null,"priority":0,"source_indexes":[1]}]}',
  );
  buffer.writeln(
    '3. title 是提炼后的短标题，不超过 20 字；'
    'description 放必要的补充说明，可以 null。',
  );
  buffer.writeln('4. start_at、end_at 用 ISO 8601 本地时间格式 YYYY-MM-DDTHH:mm:ss。');
  buffer.writeln('5. priority：0 普通，1 重要。');
  buffer.writeln('6. source_indexes 填这条日程来源于下面第几条内容（序号从 1 开始）。');
  buffer.writeln();

  buffer.writeln('时间推断规则：');
  buffer.writeln('- 内容里写了明确时间的，按内容来，比如“明天下午三点”要换算成具体日期时刻。');
  buffer.writeln(
    '- 提到“早上”“中午”“晚上”这类模糊时段的，'
    '分别排到 08:00 / 12:00 / 19:00 左右，持续 30~60 分钟。',
  );
  buffer.writeln('- 没写任何时间、但明显是待办事项的，排到今天剩余时间或明天上午。');
  buffer.writeln('- 纯感想、灵感、吐槽这类不产生行动的，不要生成日程。');
  buffer.writeln('- 如果所有内容都构不成日程，返回 {"schedules":[]}。');
  buffer.writeln();

  buffer.writeln('内容如下：');
  buffer.writeln('（图片按下面这些条目的编号升序发送；同一条目的多张图连续排列。）');
  for (int i = 0; i < items.length; i++) {
    final InboxItem item = items[i];
    final int index = i + 1;
    final String? note = item.content?.trim();

    final int totalImages =
        totalImageCounts[item.id] ?? (item.imagePath == null ? 0 : 1);
    if (totalImages == 0) {
      buffer.writeln('[$index] (文字) ${note ?? ''}');
      continue;
    }

    final bool hasNote = note != null && note.isNotEmpty;
    final String notePart = hasNote ? ' 用户备注：$note' : '';
    final String label = totalImages > 1 ? '图片 × $totalImages' : '图片';
    final int sent = sentImageCounts[item.id] ?? 0;

    if (sent > 0) {
      final String sentPart = sent < totalImages ? '（本次发送 $sent 张，其余未发送）' : '';
      buffer.writeln(
        '[$index] ($label)$sentPart'
        '${hasNote ? notePart : ' 无备注，请看图理解'}',
      );
    } else {
      buffer.writeln(
        '[$index] ($label，本次未发送：文件过大或读取失败或超出上限，'
        '请只根据备注整理)${hasNote ? notePart : ' 无备注'}',
      );
    }
  }

  return buffer.toString();
}

/// 手写星期几，避免为了一个中文 locale 去初始化 intl 的 locale 数据。
String _weekdayCn(DateTime t) {
  const List<String> names = ['一', '二', '三', '四', '五', '六', '日'];
  return '星期${names[t.weekday - 1]}';
}
