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
