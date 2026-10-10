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
    _subscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(_handle, onError: (Object _) {});

    try {
      final List<SharedMediaFile> initial =
          await ReceiveSharingIntent.instance.getInitialMedia();
      if (initial.isNotEmpty) {
        await _handle(initial);
        await ReceiveSharingIntent.instance.reset();
      }
    } catch (_) {
      // 冷启动没有分享内容时会抛异常，忽略即可
    }
  }

  Future<void> _handle(List<SharedMediaFile> files) async {
    for (final SharedMediaFile f in files) {
      switch (f.type) {
        case SharedMediaType.image:
          final File file = File(f.path);
          if (await file.exists()) {
            await _repository.addImage(file, source: 'share');
          }
        case SharedMediaType.text:
        case SharedMediaType.url:
          final String text = (f.message ?? f.path).trim();
          if (text.isNotEmpty) {
            await _repository.addText(text, source: 'share');
          }
        default:
          // 视频、文件等第一版不收
          break;
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
