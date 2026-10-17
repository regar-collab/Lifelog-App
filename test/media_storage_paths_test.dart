import 'package:flutter_test/flutter_test.dart';
import 'package:lifelog/data/services/media_storage.dart';

void main() {
  group('MediaStorage 图片路径编解码', () {
    test('旧版单路径原样返回', () {
      expect(MediaStorage.parsePaths('images/2026/10/a.jpg'), <String>[
        'images/2026/10/a.jpg',
      ]);
    });

    test('解析 JSON 数组', () {
      expect(
        MediaStorage.parsePaths(
          '["images/2026/10/a.jpg","images/2026/10/b.jpg"]',
        ),
        <String>['images/2026/10/a.jpg', 'images/2026/10/b.jpg'],
      );
    });

    test('空值和坏数据返回空列表', () {
      expect(MediaStorage.parsePaths(null), isEmpty);
      expect(MediaStorage.parsePaths(''), isEmpty);
      expect(MediaStorage.parsePaths('[broken'), isEmpty);
    });

    test('单张编码成纯路径，多张编码成 JSON 数组', () {
      expect(MediaStorage.encodePaths(<String>['a.jpg']), 'a.jpg');
      expect(
        MediaStorage.encodePaths(<String>['a.jpg', 'b.jpg']),
        '["a.jpg","b.jpg"]',
      );
      expect(MediaStorage.encodePaths(const <String>[]), isNull);
    });

    test('编码后再解析能还原', () {
      final List<String> paths = <String>['a.jpg', 'b.jpg', 'c.jpg'];
      expect(MediaStorage.parsePaths(MediaStorage.encodePaths(paths)), paths);
    });
  });
}
