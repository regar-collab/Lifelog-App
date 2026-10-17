import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 图片落盘。
///
/// 数据库里只存**相对路径**（如 `images/2026/10/1728...jpg`），
/// 因为应用私有目录的绝对路径在换设备、换安装方式后会变。
class MediaStorage {
  MediaStorage._();

  /// 缓存的根目录。列表里每张缩略图都要拼路径，每次都去问一遍
  /// path_provider 会拖慢滚动，所以启动时 [warmUp] 一次就够了。
  static String? _cachedRoot;

  /// App 启动时调一次，之后 [resolveSync] 才能同步拿到路径。
  static Future<void> warmUp() async {
    _cachedRoot ??= (await getApplicationSupportDirectory()).path;
  }

  /// 同步拼出绝对路径。未 warmUp 过则返回 null，调用方显示占位即可。
  static String? resolveSync(String relativePath) {
    final root = _cachedRoot;
    if (root == null) return null;
    return p.join(root, relativePath);
  }

  /// 把 [source] 复制进应用私有目录，返回相对路径。
  static Future<String> saveImage(File source, {String? extension}) async {
    final root = await getApplicationSupportDirectory();
    final now = DateTime.now();

    final ext = (extension ?? p.extension(source.path))
        .replaceFirst('.', '')
        .toLowerCase();
    final safeExt = ext.isEmpty ? 'jpg' : ext;

    final relative = p.join(
      'images',
      '${now.year}',
      now.month.toString().padLeft(2, '0'),
      '${now.millisecondsSinceEpoch}_${now.microsecond % 1000}.$safeExt',
    );

    final dest = File(p.join(root.path, relative));
    await dest.parent.create(recursive: true);
    await source.copy(dest.path);
    return relative;
  }

  /// 相对路径 → 绝对文件对象
  static Future<File> resolve(String relativePath) async {
    final root = await getApplicationSupportDirectory();
    return File(p.join(root.path, relativePath));
  }

  /// 解析条目里的图片路径。
  ///
  /// 兼容两种格式：
  /// - 旧数据：单个相对路径 `images/2026/10/xxx.jpg`
  /// - 多图数据：JSON 数组 `["images/a.jpg","images/b.jpg"]`
  ///
  /// 用文本列存数组而不是新建表，是为了不改数据库 schema、
  /// 不触发代码生成，同时让旧数据可以直接读写。
  static List<String> parsePaths(String? raw) {
    final String? text = raw?.trim();
    if (text == null || text.isEmpty) return const <String>[];

    if (text.startsWith('[')) {
      try {
        final Object? decoded = jsonDecode(text);
        if (decoded is List) {
          return decoded
              .whereType<String>()
              .where((String p) => p.trim().isNotEmpty)
              .toList();
        }
      } catch (_) {
        // 坏数据按「没有图片」处理，不让整条记录打不开
      }
      return const <String>[];
    }

    return <String>[text];
  }

  /// 把路径列表编码回数据库。
  ///
  /// 单张仍然存纯路径，保持和旧版本完全兼容。
  static String? encodePaths(List<String> paths) {
    if (paths.isEmpty) return null;
    if (paths.length == 1) return paths.first;
    return jsonEncode(paths);
  }

  /// 删除条目时顺手清掉图片，避免垃圾文件堆积。
  static Future<void> deleteIfExists(String relativePath) async {
    try {
      final file = await resolve(relativePath);
      if (await file.exists()) {
        await file.delete();
      }
    } on FileSystemException {
      // 文件本来就不在，忽略
    }
  }
}
