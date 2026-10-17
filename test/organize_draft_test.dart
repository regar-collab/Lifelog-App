import 'package:flutter_test/flutter_test.dart';
import 'package:lifelog/features/ai_organize/domain/organize_draft.dart';

void main() {
  group('OrganizeDraft.fromJson', () {
    test('解析合法草案，并把带时区的时间转成本地时间', () {
      final OrganizeDraft d = OrganizeDraft.fromJson(<String, dynamic>{
        'title': '取快递',
        'start_at': '2026-10-18T15:00:00+08:00',
        'end_at': '2026-10-18T16:00:00+08:00',
        'source_indexes': <dynamic>[1, 2],
        'priority': 1,
      });

      expect(d.title, '取快递');
      expect(
        d.startAt,
        DateTime.parse('2026-10-18T15:00:00+08:00').toLocal(),
      );
      expect(
        d.endAt,
        DateTime.parse('2026-10-18T16:00:00+08:00').toLocal(),
      );
      expect(d.sourceIndexes, <int>[1, 2]);
      expect(d.priority, 1);
    });

    test('缺少开始时间时抛 FormatException，而不是回退到“现在”', () {
      expect(
        () => OrganizeDraft.fromJson(<String, dynamic>{'title': '没有时间'}),
        throwsFormatException,
      );
    });

    test('结束时间早于开始时间时丢弃结束时间', () {
      final OrganizeDraft d = OrganizeDraft.fromJson(<String, dynamic>{
        'title': '时间写反了',
        'start_at': '2026-10-18T15:00:00',
        'end_at': '2026-10-18T14:00:00',
      });

      expect(d.startAt.isAfter(d.endAt ?? d.startAt), isFalse);
      expect(d.endAt, isNull);
    });

    test('source_indexes 类型异常时不崩溃', () {
      final OrganizeDraft d = OrganizeDraft.fromJson(<String, dynamic>{
        'title': '类型异常',
        'start_at': '2026-10-18T15:00:00',
        'source_indexes': 'not-a-list',
      });

      expect(d.sourceIndexes, isEmpty);
    });

    test('标题为空时抛 FormatException', () {
      expect(
        () => OrganizeDraft.fromJson(<String, dynamic>{
          'title': '   ',
          'start_at': '2026-10-18T15:00:00',
        }),
        throwsFormatException,
      );
    });
  });
}
