// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $InboxItemsTable extends InboxItems
    with TableInfo<$InboxItemsTable, InboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrTextMeta = const VerificationMeta(
    'ocrText',
  );
  @override
  late final GeneratedColumn<String> ocrText = GeneratedColumn<String>(
    'ocr_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrStatusMeta = const VerificationMeta(
    'ocrStatus',
  );
  @override
  late final GeneratedColumn<String> ocrStatus = GeneratedColumn<String>(
    'ocr_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _organizePolicyMeta = const VerificationMeta(
    'organizePolicy',
  );
  @override
  late final GeneratedColumn<String> organizePolicy = GeneratedColumn<String>(
    'organize_policy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    content,
    imagePath,
    ocrText,
    ocrStatus,
    status,
    organizePolicy,
    source,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InboxItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('ocr_text')) {
      context.handle(
        _ocrTextMeta,
        ocrText.isAcceptableOrUnknown(data['ocr_text']!, _ocrTextMeta),
      );
    }
    if (data.containsKey('ocr_status')) {
      context.handle(
        _ocrStatusMeta,
        ocrStatus.isAcceptableOrUnknown(data['ocr_status']!, _ocrStatusMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('organize_policy')) {
      context.handle(
        _organizePolicyMeta,
        organizePolicy.isAcceptableOrUnknown(
          data['organize_policy']!,
          _organizePolicyMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InboxItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      ocrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_text'],
      ),
      ocrStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_status'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      organizePolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organize_policy'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $InboxItemsTable createAlias(String alias) {
    return $InboxItemsTable(attachedDatabase, alias);
  }
}

class InboxItem extends DataClass implements Insertable<InboxItem> {
  final int id;

  /// text | image | screenshot
  final String type;

  /// 文字内容；图片类型时这里是用户备注，可为空
  final String? content;

  /// 图片相对路径，如 images/2026/10/xxx.jpg（相对应用私有目录）
  final String? imagePath;

  /// OCR 结果。走「图片直传视觉模型」时这里留空
  final String? ocrText;

  /// none | pending | done | failed
  final String ocrStatus;

  /// pending（待整理）| processed（已整理）| archived（归档）
  final String status;

  /// auto（正常参与 AI 整理）| skip（用户明确屏蔽，永不参与整理）
  final String organizePolicy;

  /// manual（手动输入）| share（系统分享进来）| clipboard
  final String source;
  final int createdAt;
  final int updatedAt;
  const InboxItem({
    required this.id,
    required this.type,
    this.content,
    this.imagePath,
    this.ocrText,
    required this.ocrStatus,
    required this.status,
    required this.organizePolicy,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || ocrText != null) {
      map['ocr_text'] = Variable<String>(ocrText);
    }
    map['ocr_status'] = Variable<String>(ocrStatus);
    map['status'] = Variable<String>(status);
    map['organize_policy'] = Variable<String>(organizePolicy);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  InboxItemsCompanion toCompanion(bool nullToAbsent) {
    return InboxItemsCompanion(
      id: Value(id),
      type: Value(type),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      ocrText: ocrText == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrText),
      ocrStatus: Value(ocrStatus),
      status: Value(status),
      organizePolicy: Value(organizePolicy),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory InboxItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxItem(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String?>(json['content']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      ocrText: serializer.fromJson<String?>(json['ocrText']),
      ocrStatus: serializer.fromJson<String>(json['ocrStatus']),
      status: serializer.fromJson<String>(json['status']),
      organizePolicy: serializer.fromJson<String>(json['organizePolicy']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String?>(content),
      'imagePath': serializer.toJson<String?>(imagePath),
      'ocrText': serializer.toJson<String?>(ocrText),
      'ocrStatus': serializer.toJson<String>(ocrStatus),
      'status': serializer.toJson<String>(status),
      'organizePolicy': serializer.toJson<String>(organizePolicy),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  InboxItem copyWith({
    int? id,
    String? type,
    Value<String?> content = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    Value<String?> ocrText = const Value.absent(),
    String? ocrStatus,
    String? status,
    String? organizePolicy,
    String? source,
    int? createdAt,
    int? updatedAt,
  }) => InboxItem(
    id: id ?? this.id,
    type: type ?? this.type,
    content: content.present ? content.value : this.content,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    ocrText: ocrText.present ? ocrText.value : this.ocrText,
    ocrStatus: ocrStatus ?? this.ocrStatus,
    status: status ?? this.status,
    organizePolicy: organizePolicy ?? this.organizePolicy,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  InboxItem copyWithCompanion(InboxItemsCompanion data) {
    return InboxItem(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      ocrText: data.ocrText.present ? data.ocrText.value : this.ocrText,
      ocrStatus: data.ocrStatus.present ? data.ocrStatus.value : this.ocrStatus,
      status: data.status.present ? data.status.value : this.status,
      organizePolicy: data.organizePolicy.present
          ? data.organizePolicy.value
          : this.organizePolicy,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxItem(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('imagePath: $imagePath, ')
          ..write('ocrText: $ocrText, ')
          ..write('ocrStatus: $ocrStatus, ')
          ..write('status: $status, ')
          ..write('organizePolicy: $organizePolicy, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    content,
    imagePath,
    ocrText,
    ocrStatus,
    status,
    organizePolicy,
    source,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxItem &&
          other.id == this.id &&
          other.type == this.type &&
          other.content == this.content &&
          other.imagePath == this.imagePath &&
          other.ocrText == this.ocrText &&
          other.ocrStatus == this.ocrStatus &&
          other.status == this.status &&
          other.organizePolicy == this.organizePolicy &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InboxItemsCompanion extends UpdateCompanion<InboxItem> {
  final Value<int> id;
  final Value<String> type;
  final Value<String?> content;
  final Value<String?> imagePath;
  final Value<String?> ocrText;
  final Value<String> ocrStatus;
  final Value<String> status;
  final Value<String> organizePolicy;
  final Value<String> source;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const InboxItemsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.ocrStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.organizePolicy = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  InboxItemsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    this.content = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.ocrStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.organizePolicy = const Value.absent(),
    this.source = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<InboxItem> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? content,
    Expression<String>? imagePath,
    Expression<String>? ocrText,
    Expression<String>? ocrStatus,
    Expression<String>? status,
    Expression<String>? organizePolicy,
    Expression<String>? source,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (imagePath != null) 'image_path': imagePath,
      if (ocrText != null) 'ocr_text': ocrText,
      if (ocrStatus != null) 'ocr_status': ocrStatus,
      if (status != null) 'status': status,
      if (organizePolicy != null) 'organize_policy': organizePolicy,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  InboxItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String?>? content,
    Value<String?>? imagePath,
    Value<String?>? ocrText,
    Value<String>? ocrStatus,
    Value<String>? status,
    Value<String>? organizePolicy,
    Value<String>? source,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return InboxItemsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      ocrText: ocrText ?? this.ocrText,
      ocrStatus: ocrStatus ?? this.ocrStatus,
      status: status ?? this.status,
      organizePolicy: organizePolicy ?? this.organizePolicy,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (ocrText.present) {
      map['ocr_text'] = Variable<String>(ocrText.value);
    }
    if (ocrStatus.present) {
      map['ocr_status'] = Variable<String>(ocrStatus.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (organizePolicy.present) {
      map['organize_policy'] = Variable<String>(organizePolicy.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxItemsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('imagePath: $imagePath, ')
          ..write('ocrText: $ocrText, ')
          ..write('ocrStatus: $ocrStatus, ')
          ..write('status: $status, ')
          ..write('organizePolicy: $organizePolicy, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $InboxItemRevisionsTable extends InboxItemRevisions
    with TableInfo<$InboxItemRevisionsTable, InboxItemRevision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxItemRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES inbox_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<int> recordedAt = GeneratedColumn<int>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, itemId, kind, content, recordedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_item_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<InboxItemRevision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InboxItemRevision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxItemRevision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $InboxItemRevisionsTable createAlias(String alias) {
    return $InboxItemRevisionsTable(attachedDatabase, alias);
  }
}

class InboxItemRevision extends DataClass
    implements Insertable<InboxItemRevision> {
  final int id;

  /// 条目被删除时历史一并清掉（ON DELETE CASCADE）
  final int itemId;

  /// created（首次创建）| edited（后续编辑）
  final String kind;

  /// 这次变更之后的内容快照
  final String? content;

  /// 记录时间（毫秒时间戳）
  final int recordedAt;
  const InboxItemRevision({
    required this.id,
    required this.itemId,
    required this.kind,
    this.content,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<int>(itemId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['recorded_at'] = Variable<int>(recordedAt);
    return map;
  }

  InboxItemRevisionsCompanion toCompanion(bool nullToAbsent) {
    return InboxItemRevisionsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      kind: Value(kind),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      recordedAt: Value(recordedAt),
    );
  }

  factory InboxItemRevision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxItemRevision(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<int>(json['itemId']),
      kind: serializer.fromJson<String>(json['kind']),
      content: serializer.fromJson<String?>(json['content']),
      recordedAt: serializer.fromJson<int>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<int>(itemId),
      'kind': serializer.toJson<String>(kind),
      'content': serializer.toJson<String?>(content),
      'recordedAt': serializer.toJson<int>(recordedAt),
    };
  }

  InboxItemRevision copyWith({
    int? id,
    int? itemId,
    String? kind,
    Value<String?> content = const Value.absent(),
    int? recordedAt,
  }) => InboxItemRevision(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    kind: kind ?? this.kind,
    content: content.present ? content.value : this.content,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  InboxItemRevision copyWithCompanion(InboxItemRevisionsCompanion data) {
    return InboxItemRevision(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      kind: data.kind.present ? data.kind.value : this.kind,
      content: data.content.present ? data.content.value : this.content,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxItemRevision(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('kind: $kind, ')
          ..write('content: $content, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, kind, content, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxItemRevision &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.kind == this.kind &&
          other.content == this.content &&
          other.recordedAt == this.recordedAt);
}

class InboxItemRevisionsCompanion extends UpdateCompanion<InboxItemRevision> {
  final Value<int> id;
  final Value<int> itemId;
  final Value<String> kind;
  final Value<String?> content;
  final Value<int> recordedAt;
  const InboxItemRevisionsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.kind = const Value.absent(),
    this.content = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  InboxItemRevisionsCompanion.insert({
    this.id = const Value.absent(),
    required int itemId,
    required String kind,
    this.content = const Value.absent(),
    required int recordedAt,
  }) : itemId = Value(itemId),
       kind = Value(kind),
       recordedAt = Value(recordedAt);
  static Insertable<InboxItemRevision> custom({
    Expression<int>? id,
    Expression<int>? itemId,
    Expression<String>? kind,
    Expression<String>? content,
    Expression<int>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (kind != null) 'kind': kind,
      if (content != null) 'content': content,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  InboxItemRevisionsCompanion copyWith({
    Value<int>? id,
    Value<int>? itemId,
    Value<String>? kind,
    Value<String?>? content,
    Value<int>? recordedAt,
  }) {
    return InboxItemRevisionsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      kind: kind ?? this.kind,
      content: content ?? this.content,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<int>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxItemRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('kind: $kind, ')
          ..write('content: $content, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $AiRunsTable extends AiRuns with TableInfo<$AiRunsTable, AiRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputItemIdsMeta = const VerificationMeta(
    'inputItemIds',
  );
  @override
  late final GeneratedColumn<String> inputItemIds = GeneratedColumn<String>(
    'input_item_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestPromptMeta = const VerificationMeta(
    'requestPrompt',
  );
  @override
  late final GeneratedColumn<String> requestPrompt = GeneratedColumn<String>(
    'request_prompt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawResponseMeta = const VerificationMeta(
    'rawResponse',
  );
  @override
  late final GeneratedColumn<String> rawResponse = GeneratedColumn<String>(
    'raw_response',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdCountMeta = const VerificationMeta(
    'createdCount',
  );
  @override
  late final GeneratedColumn<int> createdCount = GeneratedColumn<int>(
    'created_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promptTokensMeta = const VerificationMeta(
    'promptTokens',
  );
  @override
  late final GeneratedColumn<int> promptTokens = GeneratedColumn<int>(
    'prompt_tokens',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionTokensMeta = const VerificationMeta(
    'completionTokens',
  );
  @override
  late final GeneratedColumn<int> completionTokens = GeneratedColumn<int>(
    'completion_tokens',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<int> finishedAt = GeneratedColumn<int>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    model,
    inputItemIds,
    requestPrompt,
    rawResponse,
    createdCount,
    errorMessage,
    promptTokens,
    completionTokens,
    startedAt,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('input_item_ids')) {
      context.handle(
        _inputItemIdsMeta,
        inputItemIds.isAcceptableOrUnknown(
          data['input_item_ids']!,
          _inputItemIdsMeta,
        ),
      );
    }
    if (data.containsKey('request_prompt')) {
      context.handle(
        _requestPromptMeta,
        requestPrompt.isAcceptableOrUnknown(
          data['request_prompt']!,
          _requestPromptMeta,
        ),
      );
    }
    if (data.containsKey('raw_response')) {
      context.handle(
        _rawResponseMeta,
        rawResponse.isAcceptableOrUnknown(
          data['raw_response']!,
          _rawResponseMeta,
        ),
      );
    }
    if (data.containsKey('created_count')) {
      context.handle(
        _createdCountMeta,
        createdCount.isAcceptableOrUnknown(
          data['created_count']!,
          _createdCountMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('prompt_tokens')) {
      context.handle(
        _promptTokensMeta,
        promptTokens.isAcceptableOrUnknown(
          data['prompt_tokens']!,
          _promptTokensMeta,
        ),
      );
    }
    if (data.containsKey('completion_tokens')) {
      context.handle(
        _completionTokensMeta,
        completionTokens.isAcceptableOrUnknown(
          data['completion_tokens']!,
          _completionTokensMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      inputItemIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_item_ids'],
      ),
      requestPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_prompt'],
      ),
      rawResponse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_response'],
      ),
      createdCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_count'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      promptTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prompt_tokens'],
      ),
      completionTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completion_tokens'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finished_at'],
      ),
    );
  }

  @override
  $AiRunsTable createAlias(String alias) {
    return $AiRunsTable(attachedDatabase, alias);
  }
}

class AiRun extends DataClass implements Insertable<AiRun> {
  final int id;

  /// running | success | failed
  final String status;

  /// 实际调用的模型名
  final String model;

  /// JSON 数组，本次参与的收集箱条目 id
  final String? inputItemIds;

  /// 完整 prompt，便于复盘
  final String? requestPrompt;

  /// 模型原始返回
  final String? rawResponse;

  /// 本次生成了几条日程
  final int createdCount;
  final String? errorMessage;
  final int? promptTokens;
  final int? completionTokens;
  final int startedAt;
  final int? finishedAt;
  const AiRun({
    required this.id,
    required this.status,
    required this.model,
    this.inputItemIds,
    this.requestPrompt,
    this.rawResponse,
    required this.createdCount,
    this.errorMessage,
    this.promptTokens,
    this.completionTokens,
    required this.startedAt,
    this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['status'] = Variable<String>(status);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || inputItemIds != null) {
      map['input_item_ids'] = Variable<String>(inputItemIds);
    }
    if (!nullToAbsent || requestPrompt != null) {
      map['request_prompt'] = Variable<String>(requestPrompt);
    }
    if (!nullToAbsent || rawResponse != null) {
      map['raw_response'] = Variable<String>(rawResponse);
    }
    map['created_count'] = Variable<int>(createdCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || promptTokens != null) {
      map['prompt_tokens'] = Variable<int>(promptTokens);
    }
    if (!nullToAbsent || completionTokens != null) {
      map['completion_tokens'] = Variable<int>(completionTokens);
    }
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<int>(finishedAt);
    }
    return map;
  }

  AiRunsCompanion toCompanion(bool nullToAbsent) {
    return AiRunsCompanion(
      id: Value(id),
      status: Value(status),
      model: Value(model),
      inputItemIds: inputItemIds == null && nullToAbsent
          ? const Value.absent()
          : Value(inputItemIds),
      requestPrompt: requestPrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(requestPrompt),
      rawResponse: rawResponse == null && nullToAbsent
          ? const Value.absent()
          : Value(rawResponse),
      createdCount: Value(createdCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      promptTokens: promptTokens == null && nullToAbsent
          ? const Value.absent()
          : Value(promptTokens),
      completionTokens: completionTokens == null && nullToAbsent
          ? const Value.absent()
          : Value(completionTokens),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory AiRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiRun(
      id: serializer.fromJson<int>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      model: serializer.fromJson<String>(json['model']),
      inputItemIds: serializer.fromJson<String?>(json['inputItemIds']),
      requestPrompt: serializer.fromJson<String?>(json['requestPrompt']),
      rawResponse: serializer.fromJson<String?>(json['rawResponse']),
      createdCount: serializer.fromJson<int>(json['createdCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      promptTokens: serializer.fromJson<int?>(json['promptTokens']),
      completionTokens: serializer.fromJson<int?>(json['completionTokens']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      finishedAt: serializer.fromJson<int?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'status': serializer.toJson<String>(status),
      'model': serializer.toJson<String>(model),
      'inputItemIds': serializer.toJson<String?>(inputItemIds),
      'requestPrompt': serializer.toJson<String?>(requestPrompt),
      'rawResponse': serializer.toJson<String?>(rawResponse),
      'createdCount': serializer.toJson<int>(createdCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'promptTokens': serializer.toJson<int?>(promptTokens),
      'completionTokens': serializer.toJson<int?>(completionTokens),
      'startedAt': serializer.toJson<int>(startedAt),
      'finishedAt': serializer.toJson<int?>(finishedAt),
    };
  }

  AiRun copyWith({
    int? id,
    String? status,
    String? model,
    Value<String?> inputItemIds = const Value.absent(),
    Value<String?> requestPrompt = const Value.absent(),
    Value<String?> rawResponse = const Value.absent(),
    int? createdCount,
    Value<String?> errorMessage = const Value.absent(),
    Value<int?> promptTokens = const Value.absent(),
    Value<int?> completionTokens = const Value.absent(),
    int? startedAt,
    Value<int?> finishedAt = const Value.absent(),
  }) => AiRun(
    id: id ?? this.id,
    status: status ?? this.status,
    model: model ?? this.model,
    inputItemIds: inputItemIds.present ? inputItemIds.value : this.inputItemIds,
    requestPrompt: requestPrompt.present
        ? requestPrompt.value
        : this.requestPrompt,
    rawResponse: rawResponse.present ? rawResponse.value : this.rawResponse,
    createdCount: createdCount ?? this.createdCount,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    promptTokens: promptTokens.present ? promptTokens.value : this.promptTokens,
    completionTokens: completionTokens.present
        ? completionTokens.value
        : this.completionTokens,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
  );
  AiRun copyWithCompanion(AiRunsCompanion data) {
    return AiRun(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      model: data.model.present ? data.model.value : this.model,
      inputItemIds: data.inputItemIds.present
          ? data.inputItemIds.value
          : this.inputItemIds,
      requestPrompt: data.requestPrompt.present
          ? data.requestPrompt.value
          : this.requestPrompt,
      rawResponse: data.rawResponse.present
          ? data.rawResponse.value
          : this.rawResponse,
      createdCount: data.createdCount.present
          ? data.createdCount.value
          : this.createdCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      promptTokens: data.promptTokens.present
          ? data.promptTokens.value
          : this.promptTokens,
      completionTokens: data.completionTokens.present
          ? data.completionTokens.value
          : this.completionTokens,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiRun(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('model: $model, ')
          ..write('inputItemIds: $inputItemIds, ')
          ..write('requestPrompt: $requestPrompt, ')
          ..write('rawResponse: $rawResponse, ')
          ..write('createdCount: $createdCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('completionTokens: $completionTokens, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    status,
    model,
    inputItemIds,
    requestPrompt,
    rawResponse,
    createdCount,
    errorMessage,
    promptTokens,
    completionTokens,
    startedAt,
    finishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiRun &&
          other.id == this.id &&
          other.status == this.status &&
          other.model == this.model &&
          other.inputItemIds == this.inputItemIds &&
          other.requestPrompt == this.requestPrompt &&
          other.rawResponse == this.rawResponse &&
          other.createdCount == this.createdCount &&
          other.errorMessage == this.errorMessage &&
          other.promptTokens == this.promptTokens &&
          other.completionTokens == this.completionTokens &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt);
}

class AiRunsCompanion extends UpdateCompanion<AiRun> {
  final Value<int> id;
  final Value<String> status;
  final Value<String> model;
  final Value<String?> inputItemIds;
  final Value<String?> requestPrompt;
  final Value<String?> rawResponse;
  final Value<int> createdCount;
  final Value<String?> errorMessage;
  final Value<int?> promptTokens;
  final Value<int?> completionTokens;
  final Value<int> startedAt;
  final Value<int?> finishedAt;
  const AiRunsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.model = const Value.absent(),
    this.inputItemIds = const Value.absent(),
    this.requestPrompt = const Value.absent(),
    this.rawResponse = const Value.absent(),
    this.createdCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.promptTokens = const Value.absent(),
    this.completionTokens = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
  });
  AiRunsCompanion.insert({
    this.id = const Value.absent(),
    required String status,
    required String model,
    this.inputItemIds = const Value.absent(),
    this.requestPrompt = const Value.absent(),
    this.rawResponse = const Value.absent(),
    this.createdCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.promptTokens = const Value.absent(),
    this.completionTokens = const Value.absent(),
    required int startedAt,
    this.finishedAt = const Value.absent(),
  }) : status = Value(status),
       model = Value(model),
       startedAt = Value(startedAt);
  static Insertable<AiRun> custom({
    Expression<int>? id,
    Expression<String>? status,
    Expression<String>? model,
    Expression<String>? inputItemIds,
    Expression<String>? requestPrompt,
    Expression<String>? rawResponse,
    Expression<int>? createdCount,
    Expression<String>? errorMessage,
    Expression<int>? promptTokens,
    Expression<int>? completionTokens,
    Expression<int>? startedAt,
    Expression<int>? finishedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (model != null) 'model': model,
      if (inputItemIds != null) 'input_item_ids': inputItemIds,
      if (requestPrompt != null) 'request_prompt': requestPrompt,
      if (rawResponse != null) 'raw_response': rawResponse,
      if (createdCount != null) 'created_count': createdCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (promptTokens != null) 'prompt_tokens': promptTokens,
      if (completionTokens != null) 'completion_tokens': completionTokens,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
    });
  }

  AiRunsCompanion copyWith({
    Value<int>? id,
    Value<String>? status,
    Value<String>? model,
    Value<String?>? inputItemIds,
    Value<String?>? requestPrompt,
    Value<String?>? rawResponse,
    Value<int>? createdCount,
    Value<String?>? errorMessage,
    Value<int?>? promptTokens,
    Value<int?>? completionTokens,
    Value<int>? startedAt,
    Value<int?>? finishedAt,
  }) {
    return AiRunsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      model: model ?? this.model,
      inputItemIds: inputItemIds ?? this.inputItemIds,
      requestPrompt: requestPrompt ?? this.requestPrompt,
      rawResponse: rawResponse ?? this.rawResponse,
      createdCount: createdCount ?? this.createdCount,
      errorMessage: errorMessage ?? this.errorMessage,
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens ?? this.completionTokens,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (inputItemIds.present) {
      map['input_item_ids'] = Variable<String>(inputItemIds.value);
    }
    if (requestPrompt.present) {
      map['request_prompt'] = Variable<String>(requestPrompt.value);
    }
    if (rawResponse.present) {
      map['raw_response'] = Variable<String>(rawResponse.value);
    }
    if (createdCount.present) {
      map['created_count'] = Variable<int>(createdCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (promptTokens.present) {
      map['prompt_tokens'] = Variable<int>(promptTokens.value);
    }
    if (completionTokens.present) {
      map['completion_tokens'] = Variable<int>(completionTokens.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<int>(finishedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiRunsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('model: $model, ')
          ..write('inputItemIds: $inputItemIds, ')
          ..write('requestPrompt: $requestPrompt, ')
          ..write('rawResponse: $rawResponse, ')
          ..write('createdCount: $createdCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('completionTokens: $completionTokens, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }
}

class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<int> startAt = GeneratedColumn<int>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<int> endAt = GeneratedColumn<int>(
    'end_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAllDayMeta = const VerificationMeta(
    'isAllDay',
  );
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
    'is_all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _aiRunIdMeta = const VerificationMeta(
    'aiRunId',
  );
  @override
  late final GeneratedColumn<int> aiRunId = GeneratedColumn<int>(
    'ai_run_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ai_runs (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _sourceItemIdsMeta = const VerificationMeta(
    'sourceItemIds',
  );
  @override
  late final GeneratedColumn<String> sourceItemIds = GeneratedColumn<String>(
    'source_item_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    startAt,
    endAt,
    isAllDay,
    location,
    priority,
    status,
    origin,
    aiRunId,
    sourceItemIds,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<Schedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    }
    if (data.containsKey('is_all_day')) {
      context.handle(
        _isAllDayMeta,
        isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('ai_run_id')) {
      context.handle(
        _aiRunIdMeta,
        aiRunId.isAcceptableOrUnknown(data['ai_run_id']!, _aiRunIdMeta),
      );
    }
    if (data.containsKey('source_item_ids')) {
      context.handle(
        _sourceItemIdsMeta,
        sourceItemIds.isAcceptableOrUnknown(
          data['source_item_ids']!,
          _sourceItemIdsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_at'],
      ),
      isAllDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_all_day'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      aiRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ai_run_id'],
      ),
      sourceItemIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_item_ids'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final int id;
  final String title;
  final String? description;

  /// 开始时间（毫秒时间戳）
  final int startAt;

  /// 结束时间，可空 = 没有明确结束点
  final int? endAt;
  final bool isAllDay;
  final String? location;

  /// 0 普通 / 1 重要
  final int priority;

  /// planned | done | cancelled
  final String status;

  /// manual（手动建）| ai（AI 整理生成）
  final String origin;

  /// 由哪次 AI 整理产生，便于整批撤销
  final int? aiRunId;

  /// JSON 数组，溯源到收集箱条目 id
  final String? sourceItemIds;
  final int createdAt;
  final int updatedAt;
  const Schedule({
    required this.id,
    required this.title,
    this.description,
    required this.startAt,
    this.endAt,
    required this.isAllDay,
    this.location,
    required this.priority,
    required this.status,
    required this.origin,
    this.aiRunId,
    this.sourceItemIds,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_at'] = Variable<int>(startAt);
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<int>(endAt);
    }
    map['is_all_day'] = Variable<bool>(isAllDay);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<String>(status);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || aiRunId != null) {
      map['ai_run_id'] = Variable<int>(aiRunId);
    }
    if (!nullToAbsent || sourceItemIds != null) {
      map['source_item_ids'] = Variable<String>(sourceItemIds);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startAt: Value(startAt),
      endAt: endAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endAt),
      isAllDay: Value(isAllDay),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      priority: Value(priority),
      status: Value(status),
      origin: Value(origin),
      aiRunId: aiRunId == null && nullToAbsent
          ? const Value.absent()
          : Value(aiRunId),
      sourceItemIds: sourceItemIds == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceItemIds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Schedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      startAt: serializer.fromJson<int>(json['startAt']),
      endAt: serializer.fromJson<int?>(json['endAt']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      location: serializer.fromJson<String?>(json['location']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      origin: serializer.fromJson<String>(json['origin']),
      aiRunId: serializer.fromJson<int?>(json['aiRunId']),
      sourceItemIds: serializer.fromJson<String?>(json['sourceItemIds']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'startAt': serializer.toJson<int>(startAt),
      'endAt': serializer.toJson<int?>(endAt),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'location': serializer.toJson<String?>(location),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<String>(status),
      'origin': serializer.toJson<String>(origin),
      'aiRunId': serializer.toJson<int?>(aiRunId),
      'sourceItemIds': serializer.toJson<String?>(sourceItemIds),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Schedule copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    int? startAt,
    Value<int?> endAt = const Value.absent(),
    bool? isAllDay,
    Value<String?> location = const Value.absent(),
    int? priority,
    String? status,
    String? origin,
    Value<int?> aiRunId = const Value.absent(),
    Value<String?> sourceItemIds = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => Schedule(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    startAt: startAt ?? this.startAt,
    endAt: endAt.present ? endAt.value : this.endAt,
    isAllDay: isAllDay ?? this.isAllDay,
    location: location.present ? location.value : this.location,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    origin: origin ?? this.origin,
    aiRunId: aiRunId.present ? aiRunId.value : this.aiRunId,
    sourceItemIds: sourceItemIds.present
        ? sourceItemIds.value
        : this.sourceItemIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      location: data.location.present ? data.location.value : this.location,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      origin: data.origin.present ? data.origin.value : this.origin,
      aiRunId: data.aiRunId.present ? data.aiRunId.value : this.aiRunId,
      sourceItemIds: data.sourceItemIds.present
          ? data.sourceItemIds.value
          : this.sourceItemIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('location: $location, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('aiRunId: $aiRunId, ')
          ..write('sourceItemIds: $sourceItemIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    startAt,
    endAt,
    isAllDay,
    location,
    priority,
    status,
    origin,
    aiRunId,
    sourceItemIds,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.isAllDay == this.isAllDay &&
          other.location == this.location &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.origin == this.origin &&
          other.aiRunId == this.aiRunId &&
          other.sourceItemIds == this.sourceItemIds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> startAt;
  final Value<int?> endAt;
  final Value<bool> isAllDay;
  final Value<String?> location;
  final Value<int> priority;
  final Value<String> status;
  final Value<String> origin;
  final Value<int?> aiRunId;
  final Value<String?> sourceItemIds;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.location = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.aiRunId = const Value.absent(),
    this.sourceItemIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required int startAt,
    this.endAt = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.location = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.aiRunId = const Value.absent(),
    this.sourceItemIds = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : title = Value(title),
       startAt = Value(startAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Schedule> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? startAt,
    Expression<int>? endAt,
    Expression<bool>? isAllDay,
    Expression<String>? location,
    Expression<int>? priority,
    Expression<String>? status,
    Expression<String>? origin,
    Expression<int>? aiRunId,
    Expression<String>? sourceItemIds,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (location != null) 'location': location,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (origin != null) 'origin': origin,
      if (aiRunId != null) 'ai_run_id': aiRunId,
      if (sourceItemIds != null) 'source_item_ids': sourceItemIds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SchedulesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? startAt,
    Value<int?>? endAt,
    Value<bool>? isAllDay,
    Value<String?>? location,
    Value<int>? priority,
    Value<String>? status,
    Value<String>? origin,
    Value<int?>? aiRunId,
    Value<String?>? sourceItemIds,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return SchedulesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      aiRunId: aiRunId ?? this.aiRunId,
      sourceItemIds: sourceItemIds ?? this.sourceItemIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<int>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<int>(endAt.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (aiRunId.present) {
      map['ai_run_id'] = Variable<int>(aiRunId.value);
    }
    if (sourceItemIds.present) {
      map['source_item_ids'] = Variable<String>(sourceItemIds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('location: $location, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('aiRunId: $aiRunId, ')
          ..write('sourceItemIds: $sourceItemIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TrackSessionsTable extends TrackSessions
    with TableInfo<$TrackSessionsTable, TrackSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<int> startAt = GeneratedColumn<int>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<int> endAt = GeneratedColumn<int>(
    'end_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pointCountMeta = const VerificationMeta(
    'pointCount',
  );
  @override
  late final GeneratedColumn<int> pointCount = GeneratedColumn<int>(
    'point_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('recording'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startAt,
    endAt,
    pointCount,
    distanceM,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    }
    if (data.containsKey('point_count')) {
      context.handle(
        _pointCountMeta,
        pointCount.isAcceptableOrUnknown(data['point_count']!, _pointCountMeta),
      );
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_at'],
      ),
      pointCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}point_count'],
      )!,
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_m'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TrackSessionsTable createAlias(String alias) {
    return $TrackSessionsTable(attachedDatabase, alias);
  }
}

class TrackSession extends DataClass implements Insertable<TrackSession> {
  final int id;
  final int startAt;
  final int? endAt;
  final int pointCount;

  /// 累计距离（米）
  final double distanceM;

  /// recording | finished | interrupted（被系统杀掉的那段）
  final String status;
  final int createdAt;
  const TrackSession({
    required this.id,
    required this.startAt,
    this.endAt,
    required this.pointCount,
    required this.distanceM,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_at'] = Variable<int>(startAt);
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<int>(endAt);
    }
    map['point_count'] = Variable<int>(pointCount);
    map['distance_m'] = Variable<double>(distanceM);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TrackSessionsCompanion toCompanion(bool nullToAbsent) {
    return TrackSessionsCompanion(
      id: Value(id),
      startAt: Value(startAt),
      endAt: endAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endAt),
      pointCount: Value(pointCount),
      distanceM: Value(distanceM),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory TrackSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackSession(
      id: serializer.fromJson<int>(json['id']),
      startAt: serializer.fromJson<int>(json['startAt']),
      endAt: serializer.fromJson<int?>(json['endAt']),
      pointCount: serializer.fromJson<int>(json['pointCount']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startAt': serializer.toJson<int>(startAt),
      'endAt': serializer.toJson<int?>(endAt),
      'pointCount': serializer.toJson<int>(pointCount),
      'distanceM': serializer.toJson<double>(distanceM),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  TrackSession copyWith({
    int? id,
    int? startAt,
    Value<int?> endAt = const Value.absent(),
    int? pointCount,
    double? distanceM,
    String? status,
    int? createdAt,
  }) => TrackSession(
    id: id ?? this.id,
    startAt: startAt ?? this.startAt,
    endAt: endAt.present ? endAt.value : this.endAt,
    pointCount: pointCount ?? this.pointCount,
    distanceM: distanceM ?? this.distanceM,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  TrackSession copyWithCompanion(TrackSessionsCompanion data) {
    return TrackSession(
      id: data.id.present ? data.id.value : this.id,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      pointCount: data.pointCount.present
          ? data.pointCount.value
          : this.pointCount,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackSession(')
          ..write('id: $id, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('pointCount: $pointCount, ')
          ..write('distanceM: $distanceM, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startAt, endAt, pointCount, distanceM, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackSession &&
          other.id == this.id &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.pointCount == this.pointCount &&
          other.distanceM == this.distanceM &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class TrackSessionsCompanion extends UpdateCompanion<TrackSession> {
  final Value<int> id;
  final Value<int> startAt;
  final Value<int?> endAt;
  final Value<int> pointCount;
  final Value<double> distanceM;
  final Value<String> status;
  final Value<int> createdAt;
  const TrackSessionsCompanion({
    this.id = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.pointCount = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TrackSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int startAt,
    this.endAt = const Value.absent(),
    this.pointCount = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
  }) : startAt = Value(startAt),
       createdAt = Value(createdAt);
  static Insertable<TrackSession> custom({
    Expression<int>? id,
    Expression<int>? startAt,
    Expression<int>? endAt,
    Expression<int>? pointCount,
    Expression<double>? distanceM,
    Expression<String>? status,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (pointCount != null) 'point_count': pointCount,
      if (distanceM != null) 'distance_m': distanceM,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TrackSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? startAt,
    Value<int?>? endAt,
    Value<int>? pointCount,
    Value<double>? distanceM,
    Value<String>? status,
    Value<int>? createdAt,
  }) {
    return TrackSessionsCompanion(
      id: id ?? this.id,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      pointCount: pointCount ?? this.pointCount,
      distanceM: distanceM ?? this.distanceM,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<int>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<int>(endAt.value);
    }
    if (pointCount.present) {
      map['point_count'] = Variable<int>(pointCount.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('pointCount: $pointCount, ')
          ..write('distanceM: $distanceM, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TrackPointsTable extends TrackPoints
    with TableInfo<$TrackPointsTable, TrackPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _latWgsMeta = const VerificationMeta('latWgs');
  @override
  late final GeneratedColumn<double> latWgs = GeneratedColumn<double>(
    'lat_wgs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngWgsMeta = const VerificationMeta('lngWgs');
  @override
  late final GeneratedColumn<double> lngWgs = GeneratedColumn<double>(
    'lng_wgs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latGcjMeta = const VerificationMeta('latGcj');
  @override
  late final GeneratedColumn<double> latGcj = GeneratedColumn<double>(
    'lat_gcj',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngGcjMeta = const VerificationMeta('lngGcj');
  @override
  late final GeneratedColumn<double> lngGcj = GeneratedColumn<double>(
    'lng_gcj',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bearingMeta = const VerificationMeta(
    'bearing',
  );
  @override
  late final GeneratedColumn<double> bearing = GeneratedColumn<double>(
    'bearing',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryMeta = const VerificationMeta(
    'battery',
  );
  @override
  late final GeneratedColumn<int> battery = GeneratedColumn<int>(
    'battery',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<int> recordedAt = GeneratedColumn<int>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    latWgs,
    lngWgs,
    latGcj,
    lngGcj,
    altitude,
    accuracy,
    speed,
    bearing,
    provider,
    battery,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('lat_wgs')) {
      context.handle(
        _latWgsMeta,
        latWgs.isAcceptableOrUnknown(data['lat_wgs']!, _latWgsMeta),
      );
    } else if (isInserting) {
      context.missing(_latWgsMeta);
    }
    if (data.containsKey('lng_wgs')) {
      context.handle(
        _lngWgsMeta,
        lngWgs.isAcceptableOrUnknown(data['lng_wgs']!, _lngWgsMeta),
      );
    } else if (isInserting) {
      context.missing(_lngWgsMeta);
    }
    if (data.containsKey('lat_gcj')) {
      context.handle(
        _latGcjMeta,
        latGcj.isAcceptableOrUnknown(data['lat_gcj']!, _latGcjMeta),
      );
    }
    if (data.containsKey('lng_gcj')) {
      context.handle(
        _lngGcjMeta,
        lngGcj.isAcceptableOrUnknown(data['lng_gcj']!, _lngGcjMeta),
      );
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('bearing')) {
      context.handle(
        _bearingMeta,
        bearing.isAcceptableOrUnknown(data['bearing']!, _bearingMeta),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('battery')) {
      context.handle(
        _batteryMeta,
        battery.isAcceptableOrUnknown(data['battery']!, _batteryMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      latWgs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat_wgs'],
      )!,
      lngWgs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng_wgs'],
      )!,
      latGcj: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat_gcj'],
      ),
      lngGcj: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng_gcj'],
      ),
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      ),
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      ),
      bearing: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bearing'],
      ),
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      battery: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $TrackPointsTable createAlias(String alias) {
    return $TrackPointsTable(attachedDatabase, alias);
  }
}

class TrackPoint extends DataClass implements Insertable<TrackPoint> {
  final int id;
  final int sessionId;
  final double latWgs;
  final double lngWgs;
  final double? latGcj;
  final double? lngGcj;
  final double? altitude;

  /// 水平精度（米）
  final double? accuracy;

  /// 速度（米/秒）
  final double? speed;

  /// 方位角
  final double? bearing;

  /// gps | network | fused
  final String? provider;

  /// 采样时的电量快照，方便排查耗电
  final int? battery;
  final int recordedAt;
  const TrackPoint({
    required this.id,
    required this.sessionId,
    required this.latWgs,
    required this.lngWgs,
    this.latGcj,
    this.lngGcj,
    this.altitude,
    this.accuracy,
    this.speed,
    this.bearing,
    this.provider,
    this.battery,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['lat_wgs'] = Variable<double>(latWgs);
    map['lng_wgs'] = Variable<double>(lngWgs);
    if (!nullToAbsent || latGcj != null) {
      map['lat_gcj'] = Variable<double>(latGcj);
    }
    if (!nullToAbsent || lngGcj != null) {
      map['lng_gcj'] = Variable<double>(lngGcj);
    }
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    if (!nullToAbsent || bearing != null) {
      map['bearing'] = Variable<double>(bearing);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || battery != null) {
      map['battery'] = Variable<int>(battery);
    }
    map['recorded_at'] = Variable<int>(recordedAt);
    return map;
  }

  TrackPointsCompanion toCompanion(bool nullToAbsent) {
    return TrackPointsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      latWgs: Value(latWgs),
      lngWgs: Value(lngWgs),
      latGcj: latGcj == null && nullToAbsent
          ? const Value.absent()
          : Value(latGcj),
      lngGcj: lngGcj == null && nullToAbsent
          ? const Value.absent()
          : Value(lngGcj),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      speed: speed == null && nullToAbsent
          ? const Value.absent()
          : Value(speed),
      bearing: bearing == null && nullToAbsent
          ? const Value.absent()
          : Value(bearing),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      battery: battery == null && nullToAbsent
          ? const Value.absent()
          : Value(battery),
      recordedAt: Value(recordedAt),
    );
  }

  factory TrackPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackPoint(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      latWgs: serializer.fromJson<double>(json['latWgs']),
      lngWgs: serializer.fromJson<double>(json['lngWgs']),
      latGcj: serializer.fromJson<double?>(json['latGcj']),
      lngGcj: serializer.fromJson<double?>(json['lngGcj']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      speed: serializer.fromJson<double?>(json['speed']),
      bearing: serializer.fromJson<double?>(json['bearing']),
      provider: serializer.fromJson<String?>(json['provider']),
      battery: serializer.fromJson<int?>(json['battery']),
      recordedAt: serializer.fromJson<int>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'latWgs': serializer.toJson<double>(latWgs),
      'lngWgs': serializer.toJson<double>(lngWgs),
      'latGcj': serializer.toJson<double?>(latGcj),
      'lngGcj': serializer.toJson<double?>(lngGcj),
      'altitude': serializer.toJson<double?>(altitude),
      'accuracy': serializer.toJson<double?>(accuracy),
      'speed': serializer.toJson<double?>(speed),
      'bearing': serializer.toJson<double?>(bearing),
      'provider': serializer.toJson<String?>(provider),
      'battery': serializer.toJson<int?>(battery),
      'recordedAt': serializer.toJson<int>(recordedAt),
    };
  }

  TrackPoint copyWith({
    int? id,
    int? sessionId,
    double? latWgs,
    double? lngWgs,
    Value<double?> latGcj = const Value.absent(),
    Value<double?> lngGcj = const Value.absent(),
    Value<double?> altitude = const Value.absent(),
    Value<double?> accuracy = const Value.absent(),
    Value<double?> speed = const Value.absent(),
    Value<double?> bearing = const Value.absent(),
    Value<String?> provider = const Value.absent(),
    Value<int?> battery = const Value.absent(),
    int? recordedAt,
  }) => TrackPoint(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    latWgs: latWgs ?? this.latWgs,
    lngWgs: lngWgs ?? this.lngWgs,
    latGcj: latGcj.present ? latGcj.value : this.latGcj,
    lngGcj: lngGcj.present ? lngGcj.value : this.lngGcj,
    altitude: altitude.present ? altitude.value : this.altitude,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    speed: speed.present ? speed.value : this.speed,
    bearing: bearing.present ? bearing.value : this.bearing,
    provider: provider.present ? provider.value : this.provider,
    battery: battery.present ? battery.value : this.battery,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  TrackPoint copyWithCompanion(TrackPointsCompanion data) {
    return TrackPoint(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      latWgs: data.latWgs.present ? data.latWgs.value : this.latWgs,
      lngWgs: data.lngWgs.present ? data.lngWgs.value : this.lngWgs,
      latGcj: data.latGcj.present ? data.latGcj.value : this.latGcj,
      lngGcj: data.lngGcj.present ? data.lngGcj.value : this.lngGcj,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      speed: data.speed.present ? data.speed.value : this.speed,
      bearing: data.bearing.present ? data.bearing.value : this.bearing,
      provider: data.provider.present ? data.provider.value : this.provider,
      battery: data.battery.present ? data.battery.value : this.battery,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackPoint(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('latWgs: $latWgs, ')
          ..write('lngWgs: $lngWgs, ')
          ..write('latGcj: $latGcj, ')
          ..write('lngGcj: $lngGcj, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('speed: $speed, ')
          ..write('bearing: $bearing, ')
          ..write('provider: $provider, ')
          ..write('battery: $battery, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    latWgs,
    lngWgs,
    latGcj,
    lngGcj,
    altitude,
    accuracy,
    speed,
    bearing,
    provider,
    battery,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackPoint &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.latWgs == this.latWgs &&
          other.lngWgs == this.lngWgs &&
          other.latGcj == this.latGcj &&
          other.lngGcj == this.lngGcj &&
          other.altitude == this.altitude &&
          other.accuracy == this.accuracy &&
          other.speed == this.speed &&
          other.bearing == this.bearing &&
          other.provider == this.provider &&
          other.battery == this.battery &&
          other.recordedAt == this.recordedAt);
}

class TrackPointsCompanion extends UpdateCompanion<TrackPoint> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<double> latWgs;
  final Value<double> lngWgs;
  final Value<double?> latGcj;
  final Value<double?> lngGcj;
  final Value<double?> altitude;
  final Value<double?> accuracy;
  final Value<double?> speed;
  final Value<double?> bearing;
  final Value<String?> provider;
  final Value<int?> battery;
  final Value<int> recordedAt;
  const TrackPointsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.latWgs = const Value.absent(),
    this.lngWgs = const Value.absent(),
    this.latGcj = const Value.absent(),
    this.lngGcj = const Value.absent(),
    this.altitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.speed = const Value.absent(),
    this.bearing = const Value.absent(),
    this.provider = const Value.absent(),
    this.battery = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  TrackPointsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required double latWgs,
    required double lngWgs,
    this.latGcj = const Value.absent(),
    this.lngGcj = const Value.absent(),
    this.altitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.speed = const Value.absent(),
    this.bearing = const Value.absent(),
    this.provider = const Value.absent(),
    this.battery = const Value.absent(),
    required int recordedAt,
  }) : sessionId = Value(sessionId),
       latWgs = Value(latWgs),
       lngWgs = Value(lngWgs),
       recordedAt = Value(recordedAt);
  static Insertable<TrackPoint> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<double>? latWgs,
    Expression<double>? lngWgs,
    Expression<double>? latGcj,
    Expression<double>? lngGcj,
    Expression<double>? altitude,
    Expression<double>? accuracy,
    Expression<double>? speed,
    Expression<double>? bearing,
    Expression<String>? provider,
    Expression<int>? battery,
    Expression<int>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (latWgs != null) 'lat_wgs': latWgs,
      if (lngWgs != null) 'lng_wgs': lngWgs,
      if (latGcj != null) 'lat_gcj': latGcj,
      if (lngGcj != null) 'lng_gcj': lngGcj,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (bearing != null) 'bearing': bearing,
      if (provider != null) 'provider': provider,
      if (battery != null) 'battery': battery,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  TrackPointsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<double>? latWgs,
    Value<double>? lngWgs,
    Value<double?>? latGcj,
    Value<double?>? lngGcj,
    Value<double?>? altitude,
    Value<double?>? accuracy,
    Value<double?>? speed,
    Value<double?>? bearing,
    Value<String?>? provider,
    Value<int?>? battery,
    Value<int>? recordedAt,
  }) {
    return TrackPointsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      latWgs: latWgs ?? this.latWgs,
      lngWgs: lngWgs ?? this.lngWgs,
      latGcj: latGcj ?? this.latGcj,
      lngGcj: lngGcj ?? this.lngGcj,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      bearing: bearing ?? this.bearing,
      provider: provider ?? this.provider,
      battery: battery ?? this.battery,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (latWgs.present) {
      map['lat_wgs'] = Variable<double>(latWgs.value);
    }
    if (lngWgs.present) {
      map['lng_wgs'] = Variable<double>(lngWgs.value);
    }
    if (latGcj.present) {
      map['lat_gcj'] = Variable<double>(latGcj.value);
    }
    if (lngGcj.present) {
      map['lng_gcj'] = Variable<double>(lngGcj.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (bearing.present) {
      map['bearing'] = Variable<double>(bearing.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (battery.present) {
      map['battery'] = Variable<int>(battery.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<int>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackPointsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('latWgs: $latWgs, ')
          ..write('lngWgs: $lngWgs, ')
          ..write('latGcj: $latGcj, ')
          ..write('lngGcj: $lngGcj, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('speed: $speed, ')
          ..write('bearing: $bearing, ')
          ..write('provider: $provider, ')
          ..write('battery: $battery, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $DailyStepsTable extends DailySteps
    with TableInfo<$DailyStepsTable, DailyStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastRawMeta = const VerificationMeta(
    'lastRaw',
  );
  @override
  late final GeneratedColumn<int> lastRaw = GeneratedColumn<int>(
    'last_raw',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dateKey, steps, lastRaw, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('last_raw')) {
      context.handle(
        _lastRawMeta,
        lastRaw.isAcceptableOrUnknown(data['last_raw']!, _lastRawMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateKey};
  @override
  DailyStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStep(
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      )!,
      lastRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_raw'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyStepsTable createAlias(String alias) {
    return $DailyStepsTable(attachedDatabase, alias);
  }
}

class DailyStep extends DataClass implements Insertable<DailyStep> {
  /// 日期键，格式 `yyyy-MM-dd`
  final String dateKey;

  /// 当天累计步数
  final int steps;

  /// 上次读到的传感器原始累计值
  final int lastRaw;
  final int updatedAt;
  const DailyStep({
    required this.dateKey,
    required this.steps,
    required this.lastRaw,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_key'] = Variable<String>(dateKey);
    map['steps'] = Variable<int>(steps);
    map['last_raw'] = Variable<int>(lastRaw);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DailyStepsCompanion toCompanion(bool nullToAbsent) {
    return DailyStepsCompanion(
      dateKey: Value(dateKey),
      steps: Value(steps),
      lastRaw: Value(lastRaw),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStep(
      dateKey: serializer.fromJson<String>(json['dateKey']),
      steps: serializer.fromJson<int>(json['steps']),
      lastRaw: serializer.fromJson<int>(json['lastRaw']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateKey': serializer.toJson<String>(dateKey),
      'steps': serializer.toJson<int>(steps),
      'lastRaw': serializer.toJson<int>(lastRaw),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DailyStep copyWith({
    String? dateKey,
    int? steps,
    int? lastRaw,
    int? updatedAt,
  }) => DailyStep(
    dateKey: dateKey ?? this.dateKey,
    steps: steps ?? this.steps,
    lastRaw: lastRaw ?? this.lastRaw,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyStep copyWithCompanion(DailyStepsCompanion data) {
    return DailyStep(
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      steps: data.steps.present ? data.steps.value : this.steps,
      lastRaw: data.lastRaw.present ? data.lastRaw.value : this.lastRaw,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStep(')
          ..write('dateKey: $dateKey, ')
          ..write('steps: $steps, ')
          ..write('lastRaw: $lastRaw, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dateKey, steps, lastRaw, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStep &&
          other.dateKey == this.dateKey &&
          other.steps == this.steps &&
          other.lastRaw == this.lastRaw &&
          other.updatedAt == this.updatedAt);
}

class DailyStepsCompanion extends UpdateCompanion<DailyStep> {
  final Value<String> dateKey;
  final Value<int> steps;
  final Value<int> lastRaw;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const DailyStepsCompanion({
    this.dateKey = const Value.absent(),
    this.steps = const Value.absent(),
    this.lastRaw = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyStepsCompanion.insert({
    required String dateKey,
    this.steps = const Value.absent(),
    this.lastRaw = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : dateKey = Value(dateKey),
       updatedAt = Value(updatedAt);
  static Insertable<DailyStep> custom({
    Expression<String>? dateKey,
    Expression<int>? steps,
    Expression<int>? lastRaw,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dateKey != null) 'date_key': dateKey,
      if (steps != null) 'steps': steps,
      if (lastRaw != null) 'last_raw': lastRaw,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyStepsCompanion copyWith({
    Value<String>? dateKey,
    Value<int>? steps,
    Value<int>? lastRaw,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return DailyStepsCompanion(
      dateKey: dateKey ?? this.dateKey,
      steps: steps ?? this.steps,
      lastRaw: lastRaw ?? this.lastRaw,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (lastRaw.present) {
      map['last_raw'] = Variable<int>(lastRaw.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStepsCompanion(')
          ..write('dateKey: $dateKey, ')
          ..write('steps: $steps, ')
          ..write('lastRaw: $lastRaw, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String? value;
  const AppSetting({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppSetting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppSetting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InboxItemsTable inboxItems = $InboxItemsTable(this);
  late final $InboxItemRevisionsTable inboxItemRevisions =
      $InboxItemRevisionsTable(this);
  late final $AiRunsTable aiRuns = $AiRunsTable(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $TrackSessionsTable trackSessions = $TrackSessionsTable(this);
  late final $TrackPointsTable trackPoints = $TrackPointsTable(this);
  late final $DailyStepsTable dailySteps = $DailyStepsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    inboxItems,
    inboxItemRevisions,
    aiRuns,
    schedules,
    trackSessions,
    trackPoints,
    dailySteps,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'inbox_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('inbox_item_revisions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ai_runs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('schedules', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_points', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$InboxItemsTableCreateCompanionBuilder = InboxItemsCompanion Function({
  Value<int> id,
  required String type,
  Value<String?> content,
  Value<String?> imagePath,
  Value<String?> ocrText,
  Value<String> ocrStatus,
  Value<String> status,
  Value<String> organizePolicy,
  Value<String> source,
  required int createdAt,
  required int updatedAt,
});
typedef $$InboxItemsTableUpdateCompanionBuilder = InboxItemsCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<String?> content,
  Value<String?> imagePath,
  Value<String?> ocrText,
  Value<String> ocrStatus,
  Value<String> status,
  Value<String> organizePolicy,
  Value<String> source,
  Value<int> createdAt,
  Value<int> updatedAt,
});

final class $$InboxItemsTableReferences
    extends BaseReferences<_$AppDatabase, $InboxItemsTable, InboxItem> {
  $$InboxItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InboxItemRevisionsTable, List<InboxItemRevision>>
  _inboxItemRevisionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.inboxItemRevisions,
        aliasName: 'inbox_items__id__inbox_item_revisions__item_id',
      );

  $$InboxItemRevisionsTableProcessedTableManager get inboxItemRevisionsRefs {
    final manager = $$InboxItemRevisionsTableTableManager(
      $_db,
      $_db.inboxItemRevisions,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _inboxItemRevisionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InboxItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrStatus => $composableBuilder(
    column: $table.ocrStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organizePolicy => $composableBuilder(
    column: $table.organizePolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> inboxItemRevisionsRefs(
    Expression<bool> Function($$InboxItemRevisionsTableFilterComposer f) f,
  ) {
    final $$InboxItemRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inboxItemRevisions,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InboxItemRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.inboxItemRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InboxItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrStatus => $composableBuilder(
    column: $table.ocrStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organizePolicy => $composableBuilder(
    column: $table.organizePolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InboxItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get ocrText =>
      $composableBuilder(column: $table.ocrText, builder: (column) => column);

  GeneratedColumn<String> get ocrStatus =>
      $composableBuilder(column: $table.ocrStatus, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get organizePolicy => $composableBuilder(
    column: $table.organizePolicy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> inboxItemRevisionsRefs<T extends Object>(
    Expression<T> Function($$InboxItemRevisionsTableAnnotationComposer a) f,
  ) {
    final $$InboxItemRevisionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inboxItemRevisions,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InboxItemRevisionsTableAnnotationComposer(
                $db: $db,
                $table: $db.inboxItemRevisions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InboxItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InboxItemsTable,
          InboxItem,
          $$InboxItemsTableFilterComposer,
          $$InboxItemsTableOrderingComposer,
          $$InboxItemsTableAnnotationComposer,
          $$InboxItemsTableCreateCompanionBuilder,
          $$InboxItemsTableUpdateCompanionBuilder,
          (InboxItem, $$InboxItemsTableReferences),
          InboxItem,
          PrefetchHooks Function({bool inboxItemRevisionsRefs})
        > {
  $$InboxItemsTableTableManager(_$AppDatabase db, $InboxItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InboxItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InboxItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InboxItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> ocrText = const Value.absent(),
                Value<String> ocrStatus = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> organizePolicy = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => InboxItemsCompanion(
                id: id,
                type: type,
                content: content,
                imagePath: imagePath,
                ocrText: ocrText,
                ocrStatus: ocrStatus,
                status: status,
                organizePolicy: organizePolicy,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                Value<String?> content = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> ocrText = const Value.absent(),
                Value<String> ocrStatus = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> organizePolicy = const Value.absent(),
                Value<String> source = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => InboxItemsCompanion.insert(
                id: id,
                type: type,
                content: content,
                imagePath: imagePath,
                ocrText: ocrText,
                ocrStatus: ocrStatus,
                status: status,
                organizePolicy: organizePolicy,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InboxItemsTable, InboxItem>(table),
                  $$InboxItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({inboxItemRevisionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (inboxItemRevisionsRefs) db.inboxItemRevisions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (inboxItemRevisionsRefs)
                    await $_getPrefetchedData<
                      InboxItem,
                      $InboxItemsTable,
                      InboxItemRevision
                    >(
                      currentTable: table,
                      referencedTable: $$InboxItemsTableReferences
                          ._inboxItemRevisionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$InboxItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).inboxItemRevisionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$InboxItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InboxItemsTable,
      InboxItem,
      $$InboxItemsTableFilterComposer,
      $$InboxItemsTableOrderingComposer,
      $$InboxItemsTableAnnotationComposer,
      $$InboxItemsTableCreateCompanionBuilder,
      $$InboxItemsTableUpdateCompanionBuilder,
      (InboxItem, $$InboxItemsTableReferences),
      InboxItem,
      PrefetchHooks Function({bool inboxItemRevisionsRefs})
    >;
typedef $$InboxItemRevisionsTableCreateCompanionBuilder =
    InboxItemRevisionsCompanion Function({
      Value<int> id,
      required int itemId,
      required String kind,
      Value<String?> content,
      required int recordedAt,
    });
typedef $$InboxItemRevisionsTableUpdateCompanionBuilder =
    InboxItemRevisionsCompanion Function({
      Value<int> id,
      Value<int> itemId,
      Value<String> kind,
      Value<String?> content,
      Value<int> recordedAt,
    });

final class $$InboxItemRevisionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InboxItemRevisionsTable,
          InboxItemRevision
        > {
  $$InboxItemRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InboxItemsTable _itemIdTable(_$AppDatabase db) => db.inboxItems
      .createAlias('inbox_item_revisions__item_id__inbox_items__id');

  $$InboxItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$InboxItemsTableTableManager(
      $_db,
      $_db.inboxItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InboxItemRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $InboxItemRevisionsTable> {
  $$InboxItemRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$InboxItemsTableFilterComposer get itemId {
    final $$InboxItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inboxItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InboxItemsTableFilterComposer(
            $db: $db,
            $table: $db.inboxItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InboxItemRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $InboxItemRevisionsTable> {
  $$InboxItemRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$InboxItemsTableOrderingComposer get itemId {
    final $$InboxItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inboxItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InboxItemsTableOrderingComposer(
            $db: $db,
            $table: $db.inboxItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InboxItemRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InboxItemRevisionsTable> {
  $$InboxItemRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  $$InboxItemsTableAnnotationComposer get itemId {
    final $$InboxItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.inboxItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InboxItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.inboxItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InboxItemRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InboxItemRevisionsTable,
          InboxItemRevision,
          $$InboxItemRevisionsTableFilterComposer,
          $$InboxItemRevisionsTableOrderingComposer,
          $$InboxItemRevisionsTableAnnotationComposer,
          $$InboxItemRevisionsTableCreateCompanionBuilder,
          $$InboxItemRevisionsTableUpdateCompanionBuilder,
          (InboxItemRevision, $$InboxItemRevisionsTableReferences),
          InboxItemRevision,
          PrefetchHooks Function({bool itemId})
        > {
  $$InboxItemRevisionsTableTableManager(
    _$AppDatabase db,
    $InboxItemRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InboxItemRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InboxItemRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InboxItemRevisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<int> recordedAt = const Value.absent(),
              }) => InboxItemRevisionsCompanion(
                id: id,
                itemId: itemId,
                kind: kind,
                content: content,
                recordedAt: recordedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int itemId,
                required String kind,
                Value<String?> content = const Value.absent(),
                required int recordedAt,
              }) => InboxItemRevisionsCompanion.insert(
                id: id,
                itemId: itemId,
                kind: kind,
                content: content,
                recordedAt: recordedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InboxItemRevisionsTable, InboxItemRevision>(
                    table,
                  ),
                  $$InboxItemRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$InboxItemRevisionsTableReferences
                            ._itemIdTable(db),
                        referencedColumn: $$InboxItemRevisionsTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InboxItemRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InboxItemRevisionsTable,
      InboxItemRevision,
      $$InboxItemRevisionsTableFilterComposer,
      $$InboxItemRevisionsTableOrderingComposer,
      $$InboxItemRevisionsTableAnnotationComposer,
      $$InboxItemRevisionsTableCreateCompanionBuilder,
      $$InboxItemRevisionsTableUpdateCompanionBuilder,
      (InboxItemRevision, $$InboxItemRevisionsTableReferences),
      InboxItemRevision,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$AiRunsTableCreateCompanionBuilder = AiRunsCompanion Function({
  Value<int> id,
  required String status,
  required String model,
  Value<String?> inputItemIds,
  Value<String?> requestPrompt,
  Value<String?> rawResponse,
  Value<int> createdCount,
  Value<String?> errorMessage,
  Value<int?> promptTokens,
  Value<int?> completionTokens,
  required int startedAt,
  Value<int?> finishedAt,
});
typedef $$AiRunsTableUpdateCompanionBuilder = AiRunsCompanion Function({
  Value<int> id,
  Value<String> status,
  Value<String> model,
  Value<String?> inputItemIds,
  Value<String?> requestPrompt,
  Value<String?> rawResponse,
  Value<int> createdCount,
  Value<String?> errorMessage,
  Value<int?> promptTokens,
  Value<int?> completionTokens,
  Value<int> startedAt,
  Value<int?> finishedAt,
});

final class $$AiRunsTableReferences
    extends BaseReferences<_$AppDatabase, $AiRunsTable, AiRun> {
  $$AiRunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SchedulesTable, List<Schedule>>
  _schedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.schedules,
    aliasName: 'ai_runs__id__schedules__ai_run_id',
  );

  $$SchedulesTableProcessedTableManager get schedulesRefs {
    final manager = $$SchedulesTableTableManager(
      $_db,
      $_db.schedules,
    ).filter((f) => f.aiRunId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_schedulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AiRunsTableFilterComposer
    extends Composer<_$AppDatabase, $AiRunsTable> {
  $$AiRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputItemIds => $composableBuilder(
    column: $table.inputItemIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestPrompt => $composableBuilder(
    column: $table.requestPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawResponse => $composableBuilder(
    column: $table.rawResponse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdCount => $composableBuilder(
    column: $table.createdCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> schedulesRefs(
    Expression<bool> Function($$SchedulesTableFilterComposer f) f,
  ) {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.aiRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableFilterComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AiRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiRunsTable> {
  $$AiRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputItemIds => $composableBuilder(
    column: $table.inputItemIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestPrompt => $composableBuilder(
    column: $table.requestPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawResponse => $composableBuilder(
    column: $table.rawResponse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdCount => $composableBuilder(
    column: $table.createdCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiRunsTable> {
  $$AiRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get inputItemIds => $composableBuilder(
    column: $table.inputItemIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestPrompt => $composableBuilder(
    column: $table.requestPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawResponse => $composableBuilder(
    column: $table.rawResponse,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdCount => $composableBuilder(
    column: $table.createdCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  Expression<T> schedulesRefs<T extends Object>(
    Expression<T> Function($$SchedulesTableAnnotationComposer a) f,
  ) {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.aiRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AiRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiRunsTable,
          AiRun,
          $$AiRunsTableFilterComposer,
          $$AiRunsTableOrderingComposer,
          $$AiRunsTableAnnotationComposer,
          $$AiRunsTableCreateCompanionBuilder,
          $$AiRunsTableUpdateCompanionBuilder,
          (AiRun, $$AiRunsTableReferences),
          AiRun,
          PrefetchHooks Function({bool schedulesRefs})
        > {
  $$AiRunsTableTableManager(_$AppDatabase db, $AiRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String?> inputItemIds = const Value.absent(),
                Value<String?> requestPrompt = const Value.absent(),
                Value<String?> rawResponse = const Value.absent(),
                Value<int> createdCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> promptTokens = const Value.absent(),
                Value<int?> completionTokens = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> finishedAt = const Value.absent(),
              }) => AiRunsCompanion(
                id: id,
                status: status,
                model: model,
                inputItemIds: inputItemIds,
                requestPrompt: requestPrompt,
                rawResponse: rawResponse,
                createdCount: createdCount,
                errorMessage: errorMessage,
                promptTokens: promptTokens,
                completionTokens: completionTokens,
                startedAt: startedAt,
                finishedAt: finishedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String status,
                required String model,
                Value<String?> inputItemIds = const Value.absent(),
                Value<String?> requestPrompt = const Value.absent(),
                Value<String?> rawResponse = const Value.absent(),
                Value<int> createdCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> promptTokens = const Value.absent(),
                Value<int?> completionTokens = const Value.absent(),
                required int startedAt,
                Value<int?> finishedAt = const Value.absent(),
              }) => AiRunsCompanion.insert(
                id: id,
                status: status,
                model: model,
                inputItemIds: inputItemIds,
                requestPrompt: requestPrompt,
                rawResponse: rawResponse,
                createdCount: createdCount,
                errorMessage: errorMessage,
                promptTokens: promptTokens,
                completionTokens: completionTokens,
                startedAt: startedAt,
                finishedAt: finishedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiRunsTable, AiRun>(table),
                  $$AiRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({schedulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (schedulesRefs) db.schedules],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (schedulesRefs)
                    await $_getPrefetchedData<AiRun, $AiRunsTable, Schedule>(
                      currentTable: table,
                      referencedTable: $$AiRunsTableReferences
                          ._schedulesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AiRunsTableReferences(db, table, p0).schedulesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.aiRunId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AiRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiRunsTable,
      AiRun,
      $$AiRunsTableFilterComposer,
      $$AiRunsTableOrderingComposer,
      $$AiRunsTableAnnotationComposer,
      $$AiRunsTableCreateCompanionBuilder,
      $$AiRunsTableUpdateCompanionBuilder,
      (AiRun, $$AiRunsTableReferences),
      AiRun,
      PrefetchHooks Function({bool schedulesRefs})
    >;
typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  required int startAt,
  Value<int?> endAt,
  Value<bool> isAllDay,
  Value<String?> location,
  Value<int> priority,
  Value<String> status,
  Value<String> origin,
  Value<int?> aiRunId,
  Value<String?> sourceItemIds,
  required int createdAt,
  required int updatedAt,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<int> startAt,
  Value<int?> endAt,
  Value<bool> isAllDay,
  Value<String?> location,
  Value<int> priority,
  Value<String> status,
  Value<String> origin,
  Value<int?> aiRunId,
  Value<String?> sourceItemIds,
  Value<int> createdAt,
  Value<int> updatedAt,
});

final class $$SchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $SchedulesTable, Schedule> {
  $$SchedulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AiRunsTable _aiRunIdTable(_$AppDatabase db) =>
      db.aiRuns.createAlias('schedules__ai_run_id__ai_runs__id');

  $$AiRunsTableProcessedTableManager? get aiRunId {
    final $_column = $_itemColumn<int>('ai_run_id');
    if ($_column == null) return null;
    final manager = $$AiRunsTableTableManager(
      $_db,
      $_db.aiRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_aiRunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceItemIds => $composableBuilder(
    column: $table.sourceItemIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AiRunsTableFilterComposer get aiRunId {
    final $$AiRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aiRunId,
      referencedTable: $db.aiRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiRunsTableFilterComposer(
            $db: $db,
            $table: $db.aiRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceItemIds => $composableBuilder(
    column: $table.sourceItemIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AiRunsTableOrderingComposer get aiRunId {
    final $$AiRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aiRunId,
      referencedTable: $db.aiRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiRunsTableOrderingComposer(
            $db: $db,
            $table: $db.aiRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<int> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get sourceItemIds => $composableBuilder(
    column: $table.sourceItemIds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AiRunsTableAnnotationComposer get aiRunId {
    final $$AiRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aiRunId,
      referencedTable: $db.aiRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.aiRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchedulesTable,
          Schedule,
          $$SchedulesTableFilterComposer,
          $$SchedulesTableOrderingComposer,
          $$SchedulesTableAnnotationComposer,
          $$SchedulesTableCreateCompanionBuilder,
          $$SchedulesTableUpdateCompanionBuilder,
          (Schedule, $$SchedulesTableReferences),
          Schedule,
          PrefetchHooks Function({bool aiRunId})
        > {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> startAt = const Value.absent(),
                Value<int?> endAt = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int?> aiRunId = const Value.absent(),
                Value<String?> sourceItemIds = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => SchedulesCompanion(
                id: id,
                title: title,
                description: description,
                startAt: startAt,
                endAt: endAt,
                isAllDay: isAllDay,
                location: location,
                priority: priority,
                status: status,
                origin: origin,
                aiRunId: aiRunId,
                sourceItemIds: sourceItemIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required int startAt,
                Value<int?> endAt = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int?> aiRunId = const Value.absent(),
                Value<String?> sourceItemIds = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => SchedulesCompanion.insert(
                id: id,
                title: title,
                description: description,
                startAt: startAt,
                endAt: endAt,
                isAllDay: isAllDay,
                location: location,
                priority: priority,
                status: status,
                origin: origin,
                aiRunId: aiRunId,
                sourceItemIds: sourceItemIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchedulesTable, Schedule>(table),
                  $$SchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({aiRunId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (aiRunId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.aiRunId,
                        referencedTable: $$SchedulesTableReferences
                            ._aiRunIdTable(db),
                        referencedColumn: $$SchedulesTableReferences
                            ._aiRunIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchedulesTable,
      Schedule,
      $$SchedulesTableFilterComposer,
      $$SchedulesTableOrderingComposer,
      $$SchedulesTableAnnotationComposer,
      $$SchedulesTableCreateCompanionBuilder,
      $$SchedulesTableUpdateCompanionBuilder,
      (Schedule, $$SchedulesTableReferences),
      Schedule,
      PrefetchHooks Function({bool aiRunId})
    >;
typedef $$TrackSessionsTableCreateCompanionBuilder =
    TrackSessionsCompanion Function({
      Value<int> id,
      required int startAt,
      Value<int?> endAt,
      Value<int> pointCount,
      Value<double> distanceM,
      Value<String> status,
      required int createdAt,
    });
typedef $$TrackSessionsTableUpdateCompanionBuilder =
    TrackSessionsCompanion Function({
      Value<int> id,
      Value<int> startAt,
      Value<int?> endAt,
      Value<int> pointCount,
      Value<double> distanceM,
      Value<String> status,
      Value<int> createdAt,
    });

final class $$TrackSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $TrackSessionsTable, TrackSession> {
  $$TrackSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TrackPointsTable, List<TrackPoint>>
  _trackPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackPoints,
    aliasName: 'track_sessions__id__track_points__session_id',
  );

  $$TrackPointsTableProcessedTableManager get trackPointsRefs {
    final manager = $$TrackPointsTableTableManager(
      $_db,
      $_db.trackPoints,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrackSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackSessionsTable> {
  $$TrackSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointCount => $composableBuilder(
    column: $table.pointCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trackPointsRefs(
    Expression<bool> Function($$TrackPointsTableFilterComposer f) f,
  ) {
    final $$TrackPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableFilterComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackSessionsTable> {
  $$TrackSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointCount => $composableBuilder(
    column: $table.pointCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackSessionsTable> {
  $$TrackSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<int> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<int> get pointCount => $composableBuilder(
    column: $table.pointCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> trackPointsRefs<T extends Object>(
    Expression<T> Function($$TrackPointsTableAnnotationComposer a) f,
  ) {
    final $$TrackPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackSessionsTable,
          TrackSession,
          $$TrackSessionsTableFilterComposer,
          $$TrackSessionsTableOrderingComposer,
          $$TrackSessionsTableAnnotationComposer,
          $$TrackSessionsTableCreateCompanionBuilder,
          $$TrackSessionsTableUpdateCompanionBuilder,
          (TrackSession, $$TrackSessionsTableReferences),
          TrackSession,
          PrefetchHooks Function({bool trackPointsRefs})
        > {
  $$TrackSessionsTableTableManager(_$AppDatabase db, $TrackSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> startAt = const Value.absent(),
                Value<int?> endAt = const Value.absent(),
                Value<int> pointCount = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => TrackSessionsCompanion(
                id: id,
                startAt: startAt,
                endAt: endAt,
                pointCount: pointCount,
                distanceM: distanceM,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int startAt,
                Value<int?> endAt = const Value.absent(),
                Value<int> pointCount = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int createdAt,
              }) => TrackSessionsCompanion.insert(
                id: id,
                startAt: startAt,
                endAt: endAt,
                pointCount: pointCount,
                distanceM: distanceM,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackSessionsTable, TrackSession>(table),
                  $$TrackSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackPointsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (trackPointsRefs) db.trackPoints],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trackPointsRefs)
                    await $_getPrefetchedData<
                      TrackSession,
                      $TrackSessionsTable,
                      TrackPoint
                    >(
                      currentTable: table,
                      referencedTable: $$TrackSessionsTableReferences
                          ._trackPointsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TrackSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).trackPointsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TrackSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackSessionsTable,
      TrackSession,
      $$TrackSessionsTableFilterComposer,
      $$TrackSessionsTableOrderingComposer,
      $$TrackSessionsTableAnnotationComposer,
      $$TrackSessionsTableCreateCompanionBuilder,
      $$TrackSessionsTableUpdateCompanionBuilder,
      (TrackSession, $$TrackSessionsTableReferences),
      TrackSession,
      PrefetchHooks Function({bool trackPointsRefs})
    >;
typedef $$TrackPointsTableCreateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      required int sessionId,
      required double latWgs,
      required double lngWgs,
      Value<double?> latGcj,
      Value<double?> lngGcj,
      Value<double?> altitude,
      Value<double?> accuracy,
      Value<double?> speed,
      Value<double?> bearing,
      Value<String?> provider,
      Value<int?> battery,
      required int recordedAt,
    });
typedef $$TrackPointsTableUpdateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<double> latWgs,
      Value<double> lngWgs,
      Value<double?> latGcj,
      Value<double?> lngGcj,
      Value<double?> altitude,
      Value<double?> accuracy,
      Value<double?> speed,
      Value<double?> bearing,
      Value<String?> provider,
      Value<int?> battery,
      Value<int> recordedAt,
    });

final class $$TrackPointsTableReferences
    extends BaseReferences<_$AppDatabase, $TrackPointsTable, TrackPoint> {
  $$TrackPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrackSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .trackSessions
      .createAlias('track_points__session_id__track_sessions__id');

  $$TrackSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$TrackSessionsTableTableManager(
      $_db,
      $_db.trackSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackPointsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latWgs => $composableBuilder(
    column: $table.latWgs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lngWgs => $composableBuilder(
    column: $table.lngWgs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latGcj => $composableBuilder(
    column: $table.latGcj,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lngGcj => $composableBuilder(
    column: $table.lngGcj,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bearing => $composableBuilder(
    column: $table.bearing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get battery => $composableBuilder(
    column: $table.battery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackSessionsTableFilterComposer get sessionId {
    final $$TrackSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trackSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latWgs => $composableBuilder(
    column: $table.latWgs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lngWgs => $composableBuilder(
    column: $table.lngWgs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latGcj => $composableBuilder(
    column: $table.latGcj,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lngGcj => $composableBuilder(
    column: $table.lngGcj,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bearing => $composableBuilder(
    column: $table.bearing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get battery => $composableBuilder(
    column: $table.battery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackSessionsTableOrderingComposer get sessionId {
    final $$TrackSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.trackSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latWgs =>
      $composableBuilder(column: $table.latWgs, builder: (column) => column);

  GeneratedColumn<double> get lngWgs =>
      $composableBuilder(column: $table.lngWgs, builder: (column) => column);

  GeneratedColumn<double> get latGcj =>
      $composableBuilder(column: $table.latGcj, builder: (column) => column);

  GeneratedColumn<double> get lngGcj =>
      $composableBuilder(column: $table.lngGcj, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get bearing =>
      $composableBuilder(column: $table.bearing, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<int> get battery =>
      $composableBuilder(column: $table.battery, builder: (column) => column);

  GeneratedColumn<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  $$TrackSessionsTableAnnotationComposer get sessionId {
    final $$TrackSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackPointsTable,
          TrackPoint,
          $$TrackPointsTableFilterComposer,
          $$TrackPointsTableOrderingComposer,
          $$TrackPointsTableAnnotationComposer,
          $$TrackPointsTableCreateCompanionBuilder,
          $$TrackPointsTableUpdateCompanionBuilder,
          (TrackPoint, $$TrackPointsTableReferences),
          TrackPoint,
          PrefetchHooks Function({bool sessionId})
        > {
  $$TrackPointsTableTableManager(_$AppDatabase db, $TrackPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<double> latWgs = const Value.absent(),
                Value<double> lngWgs = const Value.absent(),
                Value<double?> latGcj = const Value.absent(),
                Value<double?> lngGcj = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<double?> bearing = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<int?> battery = const Value.absent(),
                Value<int> recordedAt = const Value.absent(),
              }) => TrackPointsCompanion(
                id: id,
                sessionId: sessionId,
                latWgs: latWgs,
                lngWgs: lngWgs,
                latGcj: latGcj,
                lngGcj: lngGcj,
                altitude: altitude,
                accuracy: accuracy,
                speed: speed,
                bearing: bearing,
                provider: provider,
                battery: battery,
                recordedAt: recordedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required double latWgs,
                required double lngWgs,
                Value<double?> latGcj = const Value.absent(),
                Value<double?> lngGcj = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<double?> bearing = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<int?> battery = const Value.absent(),
                required int recordedAt,
              }) => TrackPointsCompanion.insert(
                id: id,
                sessionId: sessionId,
                latWgs: latWgs,
                lngWgs: lngWgs,
                latGcj: latGcj,
                lngGcj: lngGcj,
                altitude: altitude,
                accuracy: accuracy,
                speed: speed,
                bearing: bearing,
                provider: provider,
                battery: battery,
                recordedAt: recordedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackPointsTable, TrackPoint>(table),
                  $$TrackPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$TrackPointsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$TrackPointsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackPointsTable,
      TrackPoint,
      $$TrackPointsTableFilterComposer,
      $$TrackPointsTableOrderingComposer,
      $$TrackPointsTableAnnotationComposer,
      $$TrackPointsTableCreateCompanionBuilder,
      $$TrackPointsTableUpdateCompanionBuilder,
      (TrackPoint, $$TrackPointsTableReferences),
      TrackPoint,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$DailyStepsTableCreateCompanionBuilder = DailyStepsCompanion Function({
  required String dateKey,
  Value<int> steps,
  Value<int> lastRaw,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$DailyStepsTableUpdateCompanionBuilder = DailyStepsCompanion Function({
  Value<String> dateKey,
  Value<int> steps,
  Value<int> lastRaw,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$DailyStepsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyStepsTable> {
  $$DailyStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastRaw => $composableBuilder(
    column: $table.lastRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyStepsTable> {
  $$DailyStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastRaw => $composableBuilder(
    column: $table.lastRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyStepsTable> {
  $$DailyStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<int> get lastRaw =>
      $composableBuilder(column: $table.lastRaw, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyStepsTable,
          DailyStep,
          $$DailyStepsTableFilterComposer,
          $$DailyStepsTableOrderingComposer,
          $$DailyStepsTableAnnotationComposer,
          $$DailyStepsTableCreateCompanionBuilder,
          $$DailyStepsTableUpdateCompanionBuilder,
          (
            DailyStep,
            BaseReferences<_$AppDatabase, $DailyStepsTable, DailyStep>,
          ),
          DailyStep,
          PrefetchHooks Function()
        > {
  $$DailyStepsTableTableManager(_$AppDatabase db, $DailyStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dateKey = const Value.absent(),
                Value<int> steps = const Value.absent(),
                Value<int> lastRaw = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStepsCompanion(
                dateKey: dateKey,
                steps: steps,
                lastRaw: lastRaw,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dateKey,
                Value<int> steps = const Value.absent(),
                Value<int> lastRaw = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyStepsCompanion.insert(
                dateKey: dateKey,
                steps: steps,
                lastRaw: lastRaw,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyStepsTable, DailyStep>(table),
                  BaseReferences<_$AppDatabase, $DailyStepsTable, DailyStep>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyStepsTable,
      DailyStep,
      $$DailyStepsTableFilterComposer,
      $$DailyStepsTableOrderingComposer,
      $$DailyStepsTableAnnotationComposer,
      $$DailyStepsTableCreateCompanionBuilder,
      $$DailyStepsTableUpdateCompanionBuilder,
      (DailyStep, BaseReferences<_$AppDatabase, $DailyStepsTable, DailyStep>),
      DailyStep,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InboxItemsTableTableManager get inboxItems =>
      $$InboxItemsTableTableManager(_db, _db.inboxItems);
  $$InboxItemRevisionsTableTableManager get inboxItemRevisions =>
      $$InboxItemRevisionsTableTableManager(_db, _db.inboxItemRevisions);
  $$AiRunsTableTableManager get aiRuns =>
      $$AiRunsTableTableManager(_db, _db.aiRuns);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$TrackSessionsTableTableManager get trackSessions =>
      $$TrackSessionsTableTableManager(_db, _db.trackSessions);
  $$TrackPointsTableTableManager get trackPoints =>
      $$TrackPointsTableTableManager(_db, _db.trackPoints);
  $$DailyStepsTableTableManager get dailySteps =>
      $$DailyStepsTableTableManager(_db, _db.dailySteps);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
