import 'package:drift/drift.dart';

/// 收集箱条目：随手记的文字、截图、图片都先落到这里。
@DataClassName('InboxItem')
class InboxItems extends Table {
  @override
  String get tableName => 'inbox_items';

  IntColumn get id => integer().autoIncrement()();

  /// text | image | screenshot
  TextColumn get type => text()();

  /// 文字内容；图片类型时这里是用户备注，可为空
  TextColumn get content => text().nullable()();

  /// 图片相对路径，如 images/2026/10/xxx.jpg（相对应用私有目录）
  TextColumn get imagePath => text().nullable()();

  /// OCR 结果。走「图片直传视觉模型」时这里留空
  TextColumn get ocrText => text().nullable()();

  /// none | pending | done | failed
  TextColumn get ocrStatus => text().withDefault(const Constant('none'))();

  /// pending（待整理）| processed（已整理）| archived（归档）
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// auto（正常参与 AI 整理）| skip（用户明确屏蔽，永不参与整理）
  TextColumn get organizePolicy =>
      text().withDefault(const Constant('auto'))();

  /// manual（手动输入）| share（系统分享进来）| clipboard
  TextColumn get source => text().withDefault(const Constant('manual'))();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();
}
