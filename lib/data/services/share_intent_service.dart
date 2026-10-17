import 'dart:async';
import 'dart:io';

import 'package:lifelog/features/inbox/data/inbox_repository.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// 接收从系统分享菜单发过来的图片/文字。
///
/// 有两个入口，必须都处理，否则会出现「App 没开时分享进去没反应」的 bug：
/// - 冷启动：App 没在运行，从分享菜单点 Lifelog 打开 → getInitialMedia
/// - 热启动：App 已在后台，分享进来只是切前台 → getMediaStream
class ShareIntentService {
  ShareIntentService(this._repository);

  final InboxRepository _repository;
  StreamSubscription<List<SharedMediaFile>>? _subscription;

  Future<void> start() async {
    _subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) => unawaited(_handle(files)),
      onError: (Object _) {},
    );

    try {
      final List<SharedMediaFile> initial = await ReceiveSharingIntent.instance
          .getInitialMedia();
      if (initial.isNotEmpty) {
        await _handle(initial);
      }
    } catch (_) {
      // 冷启动没有分享内容时会抛异常，忽略即可
    } finally {
      // 无论成功失败都必须 reset：失败时残留的 initial intent 会让
      // Activity/页面重建后把同一批内容再导入一遍。
      try {
        await ReceiveSharingIntent.instance.reset();
      } catch (_) {
        // reset 失败不影响已经导入的内容
      }
    }
  }

  Future<void> _handle(List<SharedMediaFile> files) async {
    final List<File> images = <File>[];
    final List<String> texts = <String>[];

    for (final SharedMediaFile f in files) {
      try {
        switch (f.type) {
          case SharedMediaType.image:
            final File file = File(f.path);
            if (await file.exists()) images.add(file);
          case SharedMediaType.text:
          case SharedMediaType.url:
            final String text = (f.message ?? f.path).trim();
            if (text.isNotEmpty) texts.add(text);
          default:
            // 视频、文件等第一版不收
            break;
        }
      } catch (_) {
        // 单个文件失败不能中断整批分享
      }
    }

    // 一次分享的多张图放成同一条记录；批量失败时退回逐张导入，尽量不丢。
    if (images.isNotEmpty) {
      try {
        await _repository.addImages(images, source: 'share');
      } catch (_) {
        for (final File file in images) {
          try {
            await _repository.addImage(file, source: 'share');
          } catch (_) {
            // 单张也失败就跳过
          }
        }
      }
    }

    for (final String text in texts) {
      try {
        await _repository.addText(text, source: 'share');
      } catch (_) {
        // 单条文字失败不影响其它内容
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
