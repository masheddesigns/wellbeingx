// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsageEventsTable extends UsageEvents
    with TableInfo<$UsageEventsTable, UsageEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsageEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<int> eventType = GeneratedColumn<int>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
    'timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _classNameMeta = const VerificationMeta(
    'className',
  );
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
    'class_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    eventType,
    timestampMs,
    durationMs,
    className,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usage_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsageEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('class_name')) {
      context.handle(
        _classNameMeta,
        className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsageEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsageEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_type'],
      )!,
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      className: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_name'],
      ),
    );
  }

  @override
  $UsageEventsTable createAlias(String alias) {
    return $UsageEventsTable(attachedDatabase, alias);
  }
}

class UsageEventRow extends DataClass implements Insertable<UsageEventRow> {
  final int id;
  final String packageName;
  final int eventType;
  final int timestampMs;
  final int durationMs;
  final String? className;
  const UsageEventRow({
    required this.id,
    required this.packageName,
    required this.eventType,
    required this.timestampMs,
    required this.durationMs,
    this.className,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['event_type'] = Variable<int>(eventType);
    map['timestamp_ms'] = Variable<int>(timestampMs);
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || className != null) {
      map['class_name'] = Variable<String>(className);
    }
    return map;
  }

  UsageEventsCompanion toCompanion(bool nullToAbsent) {
    return UsageEventsCompanion(
      id: Value(id),
      packageName: Value(packageName),
      eventType: Value(eventType),
      timestampMs: Value(timestampMs),
      durationMs: Value(durationMs),
      className: className == null && nullToAbsent
          ? const Value.absent()
          : Value(className),
    );
  }

  factory UsageEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsageEventRow(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      eventType: serializer.fromJson<int>(json['eventType']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      className: serializer.fromJson<String?>(json['className']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'eventType': serializer.toJson<int>(eventType),
      'timestampMs': serializer.toJson<int>(timestampMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'className': serializer.toJson<String?>(className),
    };
  }

  UsageEventRow copyWith({
    int? id,
    String? packageName,
    int? eventType,
    int? timestampMs,
    int? durationMs,
    Value<String?> className = const Value.absent(),
  }) => UsageEventRow(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    eventType: eventType ?? this.eventType,
    timestampMs: timestampMs ?? this.timestampMs,
    durationMs: durationMs ?? this.durationMs,
    className: className.present ? className.value : this.className,
  );
  UsageEventRow copyWithCompanion(UsageEventsCompanion data) {
    return UsageEventRow(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      className: data.className.present ? data.className.value : this.className,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsageEventRow(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('eventType: $eventType, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('className: $className')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    eventType,
    timestampMs,
    durationMs,
    className,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageEventRow &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.eventType == this.eventType &&
          other.timestampMs == this.timestampMs &&
          other.durationMs == this.durationMs &&
          other.className == this.className);
}

class UsageEventsCompanion extends UpdateCompanion<UsageEventRow> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<int> eventType;
  final Value<int> timestampMs;
  final Value<int> durationMs;
  final Value<String?> className;
  const UsageEventsCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.eventType = const Value.absent(),
    this.timestampMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.className = const Value.absent(),
  });
  UsageEventsCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required int eventType,
    required int timestampMs,
    this.durationMs = const Value.absent(),
    this.className = const Value.absent(),
  }) : packageName = Value(packageName),
       eventType = Value(eventType),
       timestampMs = Value(timestampMs);
  static Insertable<UsageEventRow> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<int>? eventType,
    Expression<int>? timestampMs,
    Expression<int>? durationMs,
    Expression<String>? className,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (eventType != null) 'event_type': eventType,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (className != null) 'class_name': className,
    });
  }

  UsageEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<int>? eventType,
    Value<int>? timestampMs,
    Value<int>? durationMs,
    Value<String?>? className,
  }) {
    return UsageEventsCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      eventType: eventType ?? this.eventType,
      timestampMs: timestampMs ?? this.timestampMs,
      durationMs: durationMs ?? this.durationMs,
      className: className ?? this.className,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<int>(eventType.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsageEventsCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('eventType: $eventType, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('className: $className')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTableTable extends NotificationsTable
    with TableInfo<$NotificationsTableTable, NotificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
    'timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, packageName, timestampMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_ms'],
      )!,
    );
  }

  @override
  $NotificationsTableTable createAlias(String alias) {
    return $NotificationsTableTable(attachedDatabase, alias);
  }
}

class NotificationRow extends DataClass implements Insertable<NotificationRow> {
  final int id;
  final String packageName;
  final int timestampMs;
  const NotificationRow({
    required this.id,
    required this.packageName,
    required this.timestampMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['timestamp_ms'] = Variable<int>(timestampMs);
    return map;
  }

  NotificationsTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationsTableCompanion(
      id: Value(id),
      packageName: Value(packageName),
      timestampMs: Value(timestampMs),
    );
  }

  factory NotificationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRow(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'timestampMs': serializer.toJson<int>(timestampMs),
    };
  }

  NotificationRow copyWith({int? id, String? packageName, int? timestampMs}) =>
      NotificationRow(
        id: id ?? this.id,
        packageName: packageName ?? this.packageName,
        timestampMs: timestampMs ?? this.timestampMs,
      );
  NotificationRow copyWithCompanion(NotificationsTableCompanion data) {
    return NotificationRow(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRow(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('timestampMs: $timestampMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, packageName, timestampMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRow &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.timestampMs == this.timestampMs);
}

class NotificationsTableCompanion extends UpdateCompanion<NotificationRow> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<int> timestampMs;
  const NotificationsTableCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.timestampMs = const Value.absent(),
  });
  NotificationsTableCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required int timestampMs,
  }) : packageName = Value(packageName),
       timestampMs = Value(timestampMs);
  static Insertable<NotificationRow> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<int>? timestampMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
    });
  }

  NotificationsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<int>? timestampMs,
  }) {
    return NotificationsTableCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      timestampMs: timestampMs ?? this.timestampMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsTableCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('timestampMs: $timestampMs')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _isUserOverrideMeta = const VerificationMeta(
    'isUserOverride',
  );
  @override
  late final GeneratedColumn<bool> isUserOverride = GeneratedColumn<bool>(
    'is_user_override',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_user_override" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _installedAtMsMeta = const VerificationMeta(
    'installedAtMs',
  );
  @override
  late final GeneratedColumn<int> installedAtMs = GeneratedColumn<int>(
    'installed_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _iconBase64Meta = const VerificationMeta(
    'iconBase64',
  );
  @override
  late final GeneratedColumn<String> iconBase64 = GeneratedColumn<String>(
    'icon_base64',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    packageName,
    displayName,
    category,
    isUserOverride,
    installedAtMs,
    iconBase64,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_user_override')) {
      context.handle(
        _isUserOverrideMeta,
        isUserOverride.isAcceptableOrUnknown(
          data['is_user_override']!,
          _isUserOverrideMeta,
        ),
      );
    }
    if (data.containsKey('installed_at_ms')) {
      context.handle(
        _installedAtMsMeta,
        installedAtMs.isAcceptableOrUnknown(
          data['installed_at_ms']!,
          _installedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('icon_base64')) {
      context.handle(
        _iconBase64Meta,
        iconBase64.isAcceptableOrUnknown(data['icon_base64']!, _iconBase64Meta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageName};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      isUserOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_user_override'],
      )!,
      installedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installed_at_ms'],
      )!,
      iconBase64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_base64'],
      ),
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  final String packageName;
  final String displayName;
  final String category;
  final bool isUserOverride;
  final int installedAtMs;
  final String? iconBase64;
  const AppMetaRow({
    required this.packageName,
    required this.displayName,
    required this.category,
    required this.isUserOverride,
    required this.installedAtMs,
    this.iconBase64,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_name'] = Variable<String>(packageName);
    map['display_name'] = Variable<String>(displayName);
    map['category'] = Variable<String>(category);
    map['is_user_override'] = Variable<bool>(isUserOverride);
    map['installed_at_ms'] = Variable<int>(installedAtMs);
    if (!nullToAbsent || iconBase64 != null) {
      map['icon_base64'] = Variable<String>(iconBase64);
    }
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(
      packageName: Value(packageName),
      displayName: Value(displayName),
      category: Value(category),
      isUserOverride: Value(isUserOverride),
      installedAtMs: Value(installedAtMs),
      iconBase64: iconBase64 == null && nullToAbsent
          ? const Value.absent()
          : Value(iconBase64),
    );
  }

  factory AppMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      packageName: serializer.fromJson<String>(json['packageName']),
      displayName: serializer.fromJson<String>(json['displayName']),
      category: serializer.fromJson<String>(json['category']),
      isUserOverride: serializer.fromJson<bool>(json['isUserOverride']),
      installedAtMs: serializer.fromJson<int>(json['installedAtMs']),
      iconBase64: serializer.fromJson<String?>(json['iconBase64']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageName': serializer.toJson<String>(packageName),
      'displayName': serializer.toJson<String>(displayName),
      'category': serializer.toJson<String>(category),
      'isUserOverride': serializer.toJson<bool>(isUserOverride),
      'installedAtMs': serializer.toJson<int>(installedAtMs),
      'iconBase64': serializer.toJson<String?>(iconBase64),
    };
  }

  AppMetaRow copyWith({
    String? packageName,
    String? displayName,
    String? category,
    bool? isUserOverride,
    int? installedAtMs,
    Value<String?> iconBase64 = const Value.absent(),
  }) => AppMetaRow(
    packageName: packageName ?? this.packageName,
    displayName: displayName ?? this.displayName,
    category: category ?? this.category,
    isUserOverride: isUserOverride ?? this.isUserOverride,
    installedAtMs: installedAtMs ?? this.installedAtMs,
    iconBase64: iconBase64.present ? iconBase64.value : this.iconBase64,
  );
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      category: data.category.present ? data.category.value : this.category,
      isUserOverride: data.isUserOverride.present
          ? data.isUserOverride.value
          : this.isUserOverride,
      installedAtMs: data.installedAtMs.present
          ? data.installedAtMs.value
          : this.installedAtMs,
      iconBase64: data.iconBase64.present
          ? data.iconBase64.value
          : this.iconBase64,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('packageName: $packageName, ')
          ..write('displayName: $displayName, ')
          ..write('category: $category, ')
          ..write('isUserOverride: $isUserOverride, ')
          ..write('installedAtMs: $installedAtMs, ')
          ..write('iconBase64: $iconBase64')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    packageName,
    displayName,
    category,
    isUserOverride,
    installedAtMs,
    iconBase64,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow &&
          other.packageName == this.packageName &&
          other.displayName == this.displayName &&
          other.category == this.category &&
          other.isUserOverride == this.isUserOverride &&
          other.installedAtMs == this.installedAtMs &&
          other.iconBase64 == this.iconBase64);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> packageName;
  final Value<String> displayName;
  final Value<String> category;
  final Value<bool> isUserOverride;
  final Value<int> installedAtMs;
  final Value<String?> iconBase64;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.packageName = const Value.absent(),
    this.displayName = const Value.absent(),
    this.category = const Value.absent(),
    this.isUserOverride = const Value.absent(),
    this.installedAtMs = const Value.absent(),
    this.iconBase64 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String packageName,
    required String displayName,
    this.category = const Value.absent(),
    this.isUserOverride = const Value.absent(),
    this.installedAtMs = const Value.absent(),
    this.iconBase64 = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : packageName = Value(packageName),
       displayName = Value(displayName);
  static Insertable<AppMetaRow> custom({
    Expression<String>? packageName,
    Expression<String>? displayName,
    Expression<String>? category,
    Expression<bool>? isUserOverride,
    Expression<int>? installedAtMs,
    Expression<String>? iconBase64,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageName != null) 'package_name': packageName,
      if (displayName != null) 'display_name': displayName,
      if (category != null) 'category': category,
      if (isUserOverride != null) 'is_user_override': isUserOverride,
      if (installedAtMs != null) 'installed_at_ms': installedAtMs,
      if (iconBase64 != null) 'icon_base64': iconBase64,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? packageName,
    Value<String>? displayName,
    Value<String>? category,
    Value<bool>? isUserOverride,
    Value<int>? installedAtMs,
    Value<String?>? iconBase64,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      packageName: packageName ?? this.packageName,
      displayName: displayName ?? this.displayName,
      category: category ?? this.category,
      isUserOverride: isUserOverride ?? this.isUserOverride,
      installedAtMs: installedAtMs ?? this.installedAtMs,
      iconBase64: iconBase64 ?? this.iconBase64,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isUserOverride.present) {
      map['is_user_override'] = Variable<bool>(isUserOverride.value);
    }
    if (installedAtMs.present) {
      map['installed_at_ms'] = Variable<int>(installedAtMs.value);
    }
    if (iconBase64.present) {
      map['icon_base64'] = Variable<String>(iconBase64.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('packageName: $packageName, ')
          ..write('displayName: $displayName, ')
          ..write('category: $category, ')
          ..write('isUserOverride: $isUserOverride, ')
          ..write('installedAtMs: $installedAtMs, ')
          ..write('iconBase64: $iconBase64, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyAggregatesTable extends DailyAggregates
    with TableInfo<$DailyAggregatesTable, DailyAggRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyAggregatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayEpochMeta = const VerificationMeta(
    'dayEpoch',
  );
  @override
  late final GeneratedColumn<int> dayEpoch = GeneratedColumn<int>(
    'day_epoch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foregroundMsMeta = const VerificationMeta(
    'foregroundMs',
  );
  @override
  late final GeneratedColumn<int> foregroundMs = GeneratedColumn<int>(
    'foreground_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _opensMeta = const VerificationMeta('opens');
  @override
  late final GeneratedColumn<int> opens = GeneratedColumn<int>(
    'opens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notificationsMeta = const VerificationMeta(
    'notifications',
  );
  @override
  late final GeneratedColumn<int> notifications = GeneratedColumn<int>(
    'notifications',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    dayEpoch,
    packageName,
    foregroundMs,
    opens,
    notifications,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_aggregates';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyAggRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_epoch')) {
      context.handle(
        _dayEpochMeta,
        dayEpoch.isAcceptableOrUnknown(data['day_epoch']!, _dayEpochMeta),
      );
    } else if (isInserting) {
      context.missing(_dayEpochMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('foreground_ms')) {
      context.handle(
        _foregroundMsMeta,
        foregroundMs.isAcceptableOrUnknown(
          data['foreground_ms']!,
          _foregroundMsMeta,
        ),
      );
    }
    if (data.containsKey('opens')) {
      context.handle(
        _opensMeta,
        opens.isAcceptableOrUnknown(data['opens']!, _opensMeta),
      );
    }
    if (data.containsKey('notifications')) {
      context.handle(
        _notificationsMeta,
        notifications.isAcceptableOrUnknown(
          data['notifications']!,
          _notificationsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayEpoch, packageName};
  @override
  DailyAggRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyAggRow(
      dayEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_epoch'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      foregroundMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}foreground_ms'],
      )!,
      opens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opens'],
      )!,
      notifications: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notifications'],
      )!,
    );
  }

  @override
  $DailyAggregatesTable createAlias(String alias) {
    return $DailyAggregatesTable(attachedDatabase, alias);
  }
}

class DailyAggRow extends DataClass implements Insertable<DailyAggRow> {
  final int dayEpoch;
  final String packageName;
  final int foregroundMs;
  final int opens;
  final int notifications;
  const DailyAggRow({
    required this.dayEpoch,
    required this.packageName,
    required this.foregroundMs,
    required this.opens,
    required this.notifications,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_epoch'] = Variable<int>(dayEpoch);
    map['package_name'] = Variable<String>(packageName);
    map['foreground_ms'] = Variable<int>(foregroundMs);
    map['opens'] = Variable<int>(opens);
    map['notifications'] = Variable<int>(notifications);
    return map;
  }

  DailyAggregatesCompanion toCompanion(bool nullToAbsent) {
    return DailyAggregatesCompanion(
      dayEpoch: Value(dayEpoch),
      packageName: Value(packageName),
      foregroundMs: Value(foregroundMs),
      opens: Value(opens),
      notifications: Value(notifications),
    );
  }

  factory DailyAggRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyAggRow(
      dayEpoch: serializer.fromJson<int>(json['dayEpoch']),
      packageName: serializer.fromJson<String>(json['packageName']),
      foregroundMs: serializer.fromJson<int>(json['foregroundMs']),
      opens: serializer.fromJson<int>(json['opens']),
      notifications: serializer.fromJson<int>(json['notifications']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayEpoch': serializer.toJson<int>(dayEpoch),
      'packageName': serializer.toJson<String>(packageName),
      'foregroundMs': serializer.toJson<int>(foregroundMs),
      'opens': serializer.toJson<int>(opens),
      'notifications': serializer.toJson<int>(notifications),
    };
  }

  DailyAggRow copyWith({
    int? dayEpoch,
    String? packageName,
    int? foregroundMs,
    int? opens,
    int? notifications,
  }) => DailyAggRow(
    dayEpoch: dayEpoch ?? this.dayEpoch,
    packageName: packageName ?? this.packageName,
    foregroundMs: foregroundMs ?? this.foregroundMs,
    opens: opens ?? this.opens,
    notifications: notifications ?? this.notifications,
  );
  DailyAggRow copyWithCompanion(DailyAggregatesCompanion data) {
    return DailyAggRow(
      dayEpoch: data.dayEpoch.present ? data.dayEpoch.value : this.dayEpoch,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      foregroundMs: data.foregroundMs.present
          ? data.foregroundMs.value
          : this.foregroundMs,
      opens: data.opens.present ? data.opens.value : this.opens,
      notifications: data.notifications.present
          ? data.notifications.value
          : this.notifications,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyAggRow(')
          ..write('dayEpoch: $dayEpoch, ')
          ..write('packageName: $packageName, ')
          ..write('foregroundMs: $foregroundMs, ')
          ..write('opens: $opens, ')
          ..write('notifications: $notifications')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(dayEpoch, packageName, foregroundMs, opens, notifications);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyAggRow &&
          other.dayEpoch == this.dayEpoch &&
          other.packageName == this.packageName &&
          other.foregroundMs == this.foregroundMs &&
          other.opens == this.opens &&
          other.notifications == this.notifications);
}

class DailyAggregatesCompanion extends UpdateCompanion<DailyAggRow> {
  final Value<int> dayEpoch;
  final Value<String> packageName;
  final Value<int> foregroundMs;
  final Value<int> opens;
  final Value<int> notifications;
  final Value<int> rowid;
  const DailyAggregatesCompanion({
    this.dayEpoch = const Value.absent(),
    this.packageName = const Value.absent(),
    this.foregroundMs = const Value.absent(),
    this.opens = const Value.absent(),
    this.notifications = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyAggregatesCompanion.insert({
    required int dayEpoch,
    required String packageName,
    this.foregroundMs = const Value.absent(),
    this.opens = const Value.absent(),
    this.notifications = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dayEpoch = Value(dayEpoch),
       packageName = Value(packageName);
  static Insertable<DailyAggRow> custom({
    Expression<int>? dayEpoch,
    Expression<String>? packageName,
    Expression<int>? foregroundMs,
    Expression<int>? opens,
    Expression<int>? notifications,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayEpoch != null) 'day_epoch': dayEpoch,
      if (packageName != null) 'package_name': packageName,
      if (foregroundMs != null) 'foreground_ms': foregroundMs,
      if (opens != null) 'opens': opens,
      if (notifications != null) 'notifications': notifications,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyAggregatesCompanion copyWith({
    Value<int>? dayEpoch,
    Value<String>? packageName,
    Value<int>? foregroundMs,
    Value<int>? opens,
    Value<int>? notifications,
    Value<int>? rowid,
  }) {
    return DailyAggregatesCompanion(
      dayEpoch: dayEpoch ?? this.dayEpoch,
      packageName: packageName ?? this.packageName,
      foregroundMs: foregroundMs ?? this.foregroundMs,
      opens: opens ?? this.opens,
      notifications: notifications ?? this.notifications,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayEpoch.present) {
      map['day_epoch'] = Variable<int>(dayEpoch.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (foregroundMs.present) {
      map['foreground_ms'] = Variable<int>(foregroundMs.value);
    }
    if (opens.present) {
      map['opens'] = Variable<int>(opens.value);
    }
    if (notifications.present) {
      map['notifications'] = Variable<int>(notifications.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyAggregatesCompanion(')
          ..write('dayEpoch: $dayEpoch, ')
          ..write('packageName: $packageName, ')
          ..write('foregroundMs: $foregroundMs, ')
          ..write('opens: $opens, ')
          ..write('notifications: $notifications, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HourBucketsTable extends HourBuckets
    with TableInfo<$HourBucketsTable, HourBucketRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HourBucketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayEpochMeta = const VerificationMeta(
    'dayEpoch',
  );
  @override
  late final GeneratedColumn<int> dayEpoch = GeneratedColumn<int>(
    'day_epoch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foregroundMsMeta = const VerificationMeta(
    'foregroundMs',
  );
  @override
  late final GeneratedColumn<int> foregroundMs = GeneratedColumn<int>(
    'foreground_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unlocksMeta = const VerificationMeta(
    'unlocks',
  );
  @override
  late final GeneratedColumn<int> unlocks = GeneratedColumn<int>(
    'unlocks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pickupsMeta = const VerificationMeta(
    'pickups',
  );
  @override
  late final GeneratedColumn<int> pickups = GeneratedColumn<int>(
    'pickups',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    dayEpoch,
    hour,
    foregroundMs,
    unlocks,
    pickups,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hour_buckets';
  @override
  VerificationContext validateIntegrity(
    Insertable<HourBucketRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_epoch')) {
      context.handle(
        _dayEpochMeta,
        dayEpoch.isAcceptableOrUnknown(data['day_epoch']!, _dayEpochMeta),
      );
    } else if (isInserting) {
      context.missing(_dayEpochMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('foreground_ms')) {
      context.handle(
        _foregroundMsMeta,
        foregroundMs.isAcceptableOrUnknown(
          data['foreground_ms']!,
          _foregroundMsMeta,
        ),
      );
    }
    if (data.containsKey('unlocks')) {
      context.handle(
        _unlocksMeta,
        unlocks.isAcceptableOrUnknown(data['unlocks']!, _unlocksMeta),
      );
    }
    if (data.containsKey('pickups')) {
      context.handle(
        _pickupsMeta,
        pickups.isAcceptableOrUnknown(data['pickups']!, _pickupsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayEpoch, hour};
  @override
  HourBucketRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HourBucketRow(
      dayEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_epoch'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      foregroundMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}foreground_ms'],
      )!,
      unlocks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlocks'],
      )!,
      pickups: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pickups'],
      )!,
    );
  }

  @override
  $HourBucketsTable createAlias(String alias) {
    return $HourBucketsTable(attachedDatabase, alias);
  }
}

class HourBucketRow extends DataClass implements Insertable<HourBucketRow> {
  final int dayEpoch;
  final int hour;
  final int foregroundMs;
  final int unlocks;
  final int pickups;
  const HourBucketRow({
    required this.dayEpoch,
    required this.hour,
    required this.foregroundMs,
    required this.unlocks,
    required this.pickups,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_epoch'] = Variable<int>(dayEpoch);
    map['hour'] = Variable<int>(hour);
    map['foreground_ms'] = Variable<int>(foregroundMs);
    map['unlocks'] = Variable<int>(unlocks);
    map['pickups'] = Variable<int>(pickups);
    return map;
  }

  HourBucketsCompanion toCompanion(bool nullToAbsent) {
    return HourBucketsCompanion(
      dayEpoch: Value(dayEpoch),
      hour: Value(hour),
      foregroundMs: Value(foregroundMs),
      unlocks: Value(unlocks),
      pickups: Value(pickups),
    );
  }

  factory HourBucketRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HourBucketRow(
      dayEpoch: serializer.fromJson<int>(json['dayEpoch']),
      hour: serializer.fromJson<int>(json['hour']),
      foregroundMs: serializer.fromJson<int>(json['foregroundMs']),
      unlocks: serializer.fromJson<int>(json['unlocks']),
      pickups: serializer.fromJson<int>(json['pickups']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayEpoch': serializer.toJson<int>(dayEpoch),
      'hour': serializer.toJson<int>(hour),
      'foregroundMs': serializer.toJson<int>(foregroundMs),
      'unlocks': serializer.toJson<int>(unlocks),
      'pickups': serializer.toJson<int>(pickups),
    };
  }

  HourBucketRow copyWith({
    int? dayEpoch,
    int? hour,
    int? foregroundMs,
    int? unlocks,
    int? pickups,
  }) => HourBucketRow(
    dayEpoch: dayEpoch ?? this.dayEpoch,
    hour: hour ?? this.hour,
    foregroundMs: foregroundMs ?? this.foregroundMs,
    unlocks: unlocks ?? this.unlocks,
    pickups: pickups ?? this.pickups,
  );
  HourBucketRow copyWithCompanion(HourBucketsCompanion data) {
    return HourBucketRow(
      dayEpoch: data.dayEpoch.present ? data.dayEpoch.value : this.dayEpoch,
      hour: data.hour.present ? data.hour.value : this.hour,
      foregroundMs: data.foregroundMs.present
          ? data.foregroundMs.value
          : this.foregroundMs,
      unlocks: data.unlocks.present ? data.unlocks.value : this.unlocks,
      pickups: data.pickups.present ? data.pickups.value : this.pickups,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HourBucketRow(')
          ..write('dayEpoch: $dayEpoch, ')
          ..write('hour: $hour, ')
          ..write('foregroundMs: $foregroundMs, ')
          ..write('unlocks: $unlocks, ')
          ..write('pickups: $pickups')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(dayEpoch, hour, foregroundMs, unlocks, pickups);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HourBucketRow &&
          other.dayEpoch == this.dayEpoch &&
          other.hour == this.hour &&
          other.foregroundMs == this.foregroundMs &&
          other.unlocks == this.unlocks &&
          other.pickups == this.pickups);
}

class HourBucketsCompanion extends UpdateCompanion<HourBucketRow> {
  final Value<int> dayEpoch;
  final Value<int> hour;
  final Value<int> foregroundMs;
  final Value<int> unlocks;
  final Value<int> pickups;
  final Value<int> rowid;
  const HourBucketsCompanion({
    this.dayEpoch = const Value.absent(),
    this.hour = const Value.absent(),
    this.foregroundMs = const Value.absent(),
    this.unlocks = const Value.absent(),
    this.pickups = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HourBucketsCompanion.insert({
    required int dayEpoch,
    required int hour,
    this.foregroundMs = const Value.absent(),
    this.unlocks = const Value.absent(),
    this.pickups = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dayEpoch = Value(dayEpoch),
       hour = Value(hour);
  static Insertable<HourBucketRow> custom({
    Expression<int>? dayEpoch,
    Expression<int>? hour,
    Expression<int>? foregroundMs,
    Expression<int>? unlocks,
    Expression<int>? pickups,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayEpoch != null) 'day_epoch': dayEpoch,
      if (hour != null) 'hour': hour,
      if (foregroundMs != null) 'foreground_ms': foregroundMs,
      if (unlocks != null) 'unlocks': unlocks,
      if (pickups != null) 'pickups': pickups,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HourBucketsCompanion copyWith({
    Value<int>? dayEpoch,
    Value<int>? hour,
    Value<int>? foregroundMs,
    Value<int>? unlocks,
    Value<int>? pickups,
    Value<int>? rowid,
  }) {
    return HourBucketsCompanion(
      dayEpoch: dayEpoch ?? this.dayEpoch,
      hour: hour ?? this.hour,
      foregroundMs: foregroundMs ?? this.foregroundMs,
      unlocks: unlocks ?? this.unlocks,
      pickups: pickups ?? this.pickups,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayEpoch.present) {
      map['day_epoch'] = Variable<int>(dayEpoch.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (foregroundMs.present) {
      map['foreground_ms'] = Variable<int>(foregroundMs.value);
    }
    if (unlocks.present) {
      map['unlocks'] = Variable<int>(unlocks.value);
    }
    if (pickups.present) {
      map['pickups'] = Variable<int>(pickups.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HourBucketsCompanion(')
          ..write('dayEpoch: $dayEpoch, ')
          ..write('hour: $hour, ')
          ..write('foregroundMs: $foregroundMs, ')
          ..write('unlocks: $unlocks, ')
          ..write('pickups: $pickups, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyPhoneTable extends DailyPhone
    with TableInfo<$DailyPhoneTable, DailyPhoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyPhoneTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayEpochMeta = const VerificationMeta(
    'dayEpoch',
  );
  @override
  late final GeneratedColumn<int> dayEpoch = GeneratedColumn<int>(
    'day_epoch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unlocksMeta = const VerificationMeta(
    'unlocks',
  );
  @override
  late final GeneratedColumn<int> unlocks = GeneratedColumn<int>(
    'unlocks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _screenOnMsMeta = const VerificationMeta(
    'screenOnMs',
  );
  @override
  late final GeneratedColumn<int> screenOnMs = GeneratedColumn<int>(
    'screen_on_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pickupsMeta = const VerificationMeta(
    'pickups',
  );
  @override
  late final GeneratedColumn<int> pickups = GeneratedColumn<int>(
    'pickups',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shortUnlocksMeta = const VerificationMeta(
    'shortUnlocks',
  );
  @override
  late final GeneratedColumn<int> shortUnlocks = GeneratedColumn<int>(
    'short_unlocks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sleepMisuseMsMeta = const VerificationMeta(
    'sleepMisuseMs',
  );
  @override
  late final GeneratedColumn<int> sleepMisuseMs = GeneratedColumn<int>(
    'sleep_misuse_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _firstUnlockMsMeta = const VerificationMeta(
    'firstUnlockMs',
  );
  @override
  late final GeneratedColumn<int> firstUnlockMs = GeneratedColumn<int>(
    'first_unlock_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUnlockMsMeta = const VerificationMeta(
    'lastUnlockMs',
  );
  @override
  late final GeneratedColumn<int> lastUnlockMs = GeneratedColumn<int>(
    'last_unlock_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longestSessionMsMeta = const VerificationMeta(
    'longestSessionMs',
  );
  @override
  late final GeneratedColumn<int> longestSessionMs = GeneratedColumn<int>(
    'longest_session_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestScreenOffMsMeta =
      const VerificationMeta('longestScreenOffMs');
  @override
  late final GeneratedColumn<int> longestScreenOffMs = GeneratedColumn<int>(
    'longest_screen_off_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bingeCountMeta = const VerificationMeta(
    'bingeCount',
  );
  @override
  late final GeneratedColumn<int> bingeCount = GeneratedColumn<int>(
    'binge_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _firstAppPkgMeta = const VerificationMeta(
    'firstAppPkg',
  );
  @override
  late final GeneratedColumn<String> firstAppPkg = GeneratedColumn<String>(
    'first_app_pkg',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAppPkgMeta = const VerificationMeta(
    'lastAppPkg',
  );
  @override
  late final GeneratedColumn<String> lastAppPkg = GeneratedColumn<String>(
    'last_app_pkg',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    dayEpoch,
    unlocks,
    screenOnMs,
    pickups,
    shortUnlocks,
    sleepMisuseMs,
    firstUnlockMs,
    lastUnlockMs,
    longestSessionMs,
    longestScreenOffMs,
    bingeCount,
    firstAppPkg,
    lastAppPkg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_phone';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyPhoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_epoch')) {
      context.handle(
        _dayEpochMeta,
        dayEpoch.isAcceptableOrUnknown(data['day_epoch']!, _dayEpochMeta),
      );
    }
    if (data.containsKey('unlocks')) {
      context.handle(
        _unlocksMeta,
        unlocks.isAcceptableOrUnknown(data['unlocks']!, _unlocksMeta),
      );
    }
    if (data.containsKey('screen_on_ms')) {
      context.handle(
        _screenOnMsMeta,
        screenOnMs.isAcceptableOrUnknown(
          data['screen_on_ms']!,
          _screenOnMsMeta,
        ),
      );
    }
    if (data.containsKey('pickups')) {
      context.handle(
        _pickupsMeta,
        pickups.isAcceptableOrUnknown(data['pickups']!, _pickupsMeta),
      );
    }
    if (data.containsKey('short_unlocks')) {
      context.handle(
        _shortUnlocksMeta,
        shortUnlocks.isAcceptableOrUnknown(
          data['short_unlocks']!,
          _shortUnlocksMeta,
        ),
      );
    }
    if (data.containsKey('sleep_misuse_ms')) {
      context.handle(
        _sleepMisuseMsMeta,
        sleepMisuseMs.isAcceptableOrUnknown(
          data['sleep_misuse_ms']!,
          _sleepMisuseMsMeta,
        ),
      );
    }
    if (data.containsKey('first_unlock_ms')) {
      context.handle(
        _firstUnlockMsMeta,
        firstUnlockMs.isAcceptableOrUnknown(
          data['first_unlock_ms']!,
          _firstUnlockMsMeta,
        ),
      );
    }
    if (data.containsKey('last_unlock_ms')) {
      context.handle(
        _lastUnlockMsMeta,
        lastUnlockMs.isAcceptableOrUnknown(
          data['last_unlock_ms']!,
          _lastUnlockMsMeta,
        ),
      );
    }
    if (data.containsKey('longest_session_ms')) {
      context.handle(
        _longestSessionMsMeta,
        longestSessionMs.isAcceptableOrUnknown(
          data['longest_session_ms']!,
          _longestSessionMsMeta,
        ),
      );
    }
    if (data.containsKey('longest_screen_off_ms')) {
      context.handle(
        _longestScreenOffMsMeta,
        longestScreenOffMs.isAcceptableOrUnknown(
          data['longest_screen_off_ms']!,
          _longestScreenOffMsMeta,
        ),
      );
    }
    if (data.containsKey('binge_count')) {
      context.handle(
        _bingeCountMeta,
        bingeCount.isAcceptableOrUnknown(data['binge_count']!, _bingeCountMeta),
      );
    }
    if (data.containsKey('first_app_pkg')) {
      context.handle(
        _firstAppPkgMeta,
        firstAppPkg.isAcceptableOrUnknown(
          data['first_app_pkg']!,
          _firstAppPkgMeta,
        ),
      );
    }
    if (data.containsKey('last_app_pkg')) {
      context.handle(
        _lastAppPkgMeta,
        lastAppPkg.isAcceptableOrUnknown(
          data['last_app_pkg']!,
          _lastAppPkgMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayEpoch};
  @override
  DailyPhoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyPhoneRow(
      dayEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_epoch'],
      )!,
      unlocks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlocks'],
      )!,
      screenOnMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screen_on_ms'],
      )!,
      pickups: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pickups'],
      )!,
      shortUnlocks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}short_unlocks'],
      )!,
      sleepMisuseMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_misuse_ms'],
      )!,
      firstUnlockMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_unlock_ms'],
      ),
      lastUnlockMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_unlock_ms'],
      ),
      longestSessionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_session_ms'],
      )!,
      longestScreenOffMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_screen_off_ms'],
      )!,
      bingeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}binge_count'],
      )!,
      firstAppPkg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_app_pkg'],
      ),
      lastAppPkg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_app_pkg'],
      ),
    );
  }

  @override
  $DailyPhoneTable createAlias(String alias) {
    return $DailyPhoneTable(attachedDatabase, alias);
  }
}

class DailyPhoneRow extends DataClass implements Insertable<DailyPhoneRow> {
  final int dayEpoch;
  final int unlocks;
  final int screenOnMs;
  final int pickups;
  final int shortUnlocks;
  final int sleepMisuseMs;
  final int? firstUnlockMs;
  final int? lastUnlockMs;
  final int longestSessionMs;
  final int longestScreenOffMs;
  final int bingeCount;
  final String? firstAppPkg;
  final String? lastAppPkg;
  const DailyPhoneRow({
    required this.dayEpoch,
    required this.unlocks,
    required this.screenOnMs,
    required this.pickups,
    required this.shortUnlocks,
    required this.sleepMisuseMs,
    this.firstUnlockMs,
    this.lastUnlockMs,
    required this.longestSessionMs,
    required this.longestScreenOffMs,
    required this.bingeCount,
    this.firstAppPkg,
    this.lastAppPkg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_epoch'] = Variable<int>(dayEpoch);
    map['unlocks'] = Variable<int>(unlocks);
    map['screen_on_ms'] = Variable<int>(screenOnMs);
    map['pickups'] = Variable<int>(pickups);
    map['short_unlocks'] = Variable<int>(shortUnlocks);
    map['sleep_misuse_ms'] = Variable<int>(sleepMisuseMs);
    if (!nullToAbsent || firstUnlockMs != null) {
      map['first_unlock_ms'] = Variable<int>(firstUnlockMs);
    }
    if (!nullToAbsent || lastUnlockMs != null) {
      map['last_unlock_ms'] = Variable<int>(lastUnlockMs);
    }
    map['longest_session_ms'] = Variable<int>(longestSessionMs);
    map['longest_screen_off_ms'] = Variable<int>(longestScreenOffMs);
    map['binge_count'] = Variable<int>(bingeCount);
    if (!nullToAbsent || firstAppPkg != null) {
      map['first_app_pkg'] = Variable<String>(firstAppPkg);
    }
    if (!nullToAbsent || lastAppPkg != null) {
      map['last_app_pkg'] = Variable<String>(lastAppPkg);
    }
    return map;
  }

  DailyPhoneCompanion toCompanion(bool nullToAbsent) {
    return DailyPhoneCompanion(
      dayEpoch: Value(dayEpoch),
      unlocks: Value(unlocks),
      screenOnMs: Value(screenOnMs),
      pickups: Value(pickups),
      shortUnlocks: Value(shortUnlocks),
      sleepMisuseMs: Value(sleepMisuseMs),
      firstUnlockMs: firstUnlockMs == null && nullToAbsent
          ? const Value.absent()
          : Value(firstUnlockMs),
      lastUnlockMs: lastUnlockMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUnlockMs),
      longestSessionMs: Value(longestSessionMs),
      longestScreenOffMs: Value(longestScreenOffMs),
      bingeCount: Value(bingeCount),
      firstAppPkg: firstAppPkg == null && nullToAbsent
          ? const Value.absent()
          : Value(firstAppPkg),
      lastAppPkg: lastAppPkg == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAppPkg),
    );
  }

  factory DailyPhoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyPhoneRow(
      dayEpoch: serializer.fromJson<int>(json['dayEpoch']),
      unlocks: serializer.fromJson<int>(json['unlocks']),
      screenOnMs: serializer.fromJson<int>(json['screenOnMs']),
      pickups: serializer.fromJson<int>(json['pickups']),
      shortUnlocks: serializer.fromJson<int>(json['shortUnlocks']),
      sleepMisuseMs: serializer.fromJson<int>(json['sleepMisuseMs']),
      firstUnlockMs: serializer.fromJson<int?>(json['firstUnlockMs']),
      lastUnlockMs: serializer.fromJson<int?>(json['lastUnlockMs']),
      longestSessionMs: serializer.fromJson<int>(json['longestSessionMs']),
      longestScreenOffMs: serializer.fromJson<int>(json['longestScreenOffMs']),
      bingeCount: serializer.fromJson<int>(json['bingeCount']),
      firstAppPkg: serializer.fromJson<String?>(json['firstAppPkg']),
      lastAppPkg: serializer.fromJson<String?>(json['lastAppPkg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayEpoch': serializer.toJson<int>(dayEpoch),
      'unlocks': serializer.toJson<int>(unlocks),
      'screenOnMs': serializer.toJson<int>(screenOnMs),
      'pickups': serializer.toJson<int>(pickups),
      'shortUnlocks': serializer.toJson<int>(shortUnlocks),
      'sleepMisuseMs': serializer.toJson<int>(sleepMisuseMs),
      'firstUnlockMs': serializer.toJson<int?>(firstUnlockMs),
      'lastUnlockMs': serializer.toJson<int?>(lastUnlockMs),
      'longestSessionMs': serializer.toJson<int>(longestSessionMs),
      'longestScreenOffMs': serializer.toJson<int>(longestScreenOffMs),
      'bingeCount': serializer.toJson<int>(bingeCount),
      'firstAppPkg': serializer.toJson<String?>(firstAppPkg),
      'lastAppPkg': serializer.toJson<String?>(lastAppPkg),
    };
  }

  DailyPhoneRow copyWith({
    int? dayEpoch,
    int? unlocks,
    int? screenOnMs,
    int? pickups,
    int? shortUnlocks,
    int? sleepMisuseMs,
    Value<int?> firstUnlockMs = const Value.absent(),
    Value<int?> lastUnlockMs = const Value.absent(),
    int? longestSessionMs,
    int? longestScreenOffMs,
    int? bingeCount,
    Value<String?> firstAppPkg = const Value.absent(),
    Value<String?> lastAppPkg = const Value.absent(),
  }) => DailyPhoneRow(
    dayEpoch: dayEpoch ?? this.dayEpoch,
    unlocks: unlocks ?? this.unlocks,
    screenOnMs: screenOnMs ?? this.screenOnMs,
    pickups: pickups ?? this.pickups,
    shortUnlocks: shortUnlocks ?? this.shortUnlocks,
    sleepMisuseMs: sleepMisuseMs ?? this.sleepMisuseMs,
    firstUnlockMs: firstUnlockMs.present
        ? firstUnlockMs.value
        : this.firstUnlockMs,
    lastUnlockMs: lastUnlockMs.present ? lastUnlockMs.value : this.lastUnlockMs,
    longestSessionMs: longestSessionMs ?? this.longestSessionMs,
    longestScreenOffMs: longestScreenOffMs ?? this.longestScreenOffMs,
    bingeCount: bingeCount ?? this.bingeCount,
    firstAppPkg: firstAppPkg.present ? firstAppPkg.value : this.firstAppPkg,
    lastAppPkg: lastAppPkg.present ? lastAppPkg.value : this.lastAppPkg,
  );
  DailyPhoneRow copyWithCompanion(DailyPhoneCompanion data) {
    return DailyPhoneRow(
      dayEpoch: data.dayEpoch.present ? data.dayEpoch.value : this.dayEpoch,
      unlocks: data.unlocks.present ? data.unlocks.value : this.unlocks,
      screenOnMs: data.screenOnMs.present
          ? data.screenOnMs.value
          : this.screenOnMs,
      pickups: data.pickups.present ? data.pickups.value : this.pickups,
      shortUnlocks: data.shortUnlocks.present
          ? data.shortUnlocks.value
          : this.shortUnlocks,
      sleepMisuseMs: data.sleepMisuseMs.present
          ? data.sleepMisuseMs.value
          : this.sleepMisuseMs,
      firstUnlockMs: data.firstUnlockMs.present
          ? data.firstUnlockMs.value
          : this.firstUnlockMs,
      lastUnlockMs: data.lastUnlockMs.present
          ? data.lastUnlockMs.value
          : this.lastUnlockMs,
      longestSessionMs: data.longestSessionMs.present
          ? data.longestSessionMs.value
          : this.longestSessionMs,
      longestScreenOffMs: data.longestScreenOffMs.present
          ? data.longestScreenOffMs.value
          : this.longestScreenOffMs,
      bingeCount: data.bingeCount.present
          ? data.bingeCount.value
          : this.bingeCount,
      firstAppPkg: data.firstAppPkg.present
          ? data.firstAppPkg.value
          : this.firstAppPkg,
      lastAppPkg: data.lastAppPkg.present
          ? data.lastAppPkg.value
          : this.lastAppPkg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyPhoneRow(')
          ..write('dayEpoch: $dayEpoch, ')
          ..write('unlocks: $unlocks, ')
          ..write('screenOnMs: $screenOnMs, ')
          ..write('pickups: $pickups, ')
          ..write('shortUnlocks: $shortUnlocks, ')
          ..write('sleepMisuseMs: $sleepMisuseMs, ')
          ..write('firstUnlockMs: $firstUnlockMs, ')
          ..write('lastUnlockMs: $lastUnlockMs, ')
          ..write('longestSessionMs: $longestSessionMs, ')
          ..write('longestScreenOffMs: $longestScreenOffMs, ')
          ..write('bingeCount: $bingeCount, ')
          ..write('firstAppPkg: $firstAppPkg, ')
          ..write('lastAppPkg: $lastAppPkg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    dayEpoch,
    unlocks,
    screenOnMs,
    pickups,
    shortUnlocks,
    sleepMisuseMs,
    firstUnlockMs,
    lastUnlockMs,
    longestSessionMs,
    longestScreenOffMs,
    bingeCount,
    firstAppPkg,
    lastAppPkg,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyPhoneRow &&
          other.dayEpoch == this.dayEpoch &&
          other.unlocks == this.unlocks &&
          other.screenOnMs == this.screenOnMs &&
          other.pickups == this.pickups &&
          other.shortUnlocks == this.shortUnlocks &&
          other.sleepMisuseMs == this.sleepMisuseMs &&
          other.firstUnlockMs == this.firstUnlockMs &&
          other.lastUnlockMs == this.lastUnlockMs &&
          other.longestSessionMs == this.longestSessionMs &&
          other.longestScreenOffMs == this.longestScreenOffMs &&
          other.bingeCount == this.bingeCount &&
          other.firstAppPkg == this.firstAppPkg &&
          other.lastAppPkg == this.lastAppPkg);
}

class DailyPhoneCompanion extends UpdateCompanion<DailyPhoneRow> {
  final Value<int> dayEpoch;
  final Value<int> unlocks;
  final Value<int> screenOnMs;
  final Value<int> pickups;
  final Value<int> shortUnlocks;
  final Value<int> sleepMisuseMs;
  final Value<int?> firstUnlockMs;
  final Value<int?> lastUnlockMs;
  final Value<int> longestSessionMs;
  final Value<int> longestScreenOffMs;
  final Value<int> bingeCount;
  final Value<String?> firstAppPkg;
  final Value<String?> lastAppPkg;
  const DailyPhoneCompanion({
    this.dayEpoch = const Value.absent(),
    this.unlocks = const Value.absent(),
    this.screenOnMs = const Value.absent(),
    this.pickups = const Value.absent(),
    this.shortUnlocks = const Value.absent(),
    this.sleepMisuseMs = const Value.absent(),
    this.firstUnlockMs = const Value.absent(),
    this.lastUnlockMs = const Value.absent(),
    this.longestSessionMs = const Value.absent(),
    this.longestScreenOffMs = const Value.absent(),
    this.bingeCount = const Value.absent(),
    this.firstAppPkg = const Value.absent(),
    this.lastAppPkg = const Value.absent(),
  });
  DailyPhoneCompanion.insert({
    this.dayEpoch = const Value.absent(),
    this.unlocks = const Value.absent(),
    this.screenOnMs = const Value.absent(),
    this.pickups = const Value.absent(),
    this.shortUnlocks = const Value.absent(),
    this.sleepMisuseMs = const Value.absent(),
    this.firstUnlockMs = const Value.absent(),
    this.lastUnlockMs = const Value.absent(),
    this.longestSessionMs = const Value.absent(),
    this.longestScreenOffMs = const Value.absent(),
    this.bingeCount = const Value.absent(),
    this.firstAppPkg = const Value.absent(),
    this.lastAppPkg = const Value.absent(),
  });
  static Insertable<DailyPhoneRow> custom({
    Expression<int>? dayEpoch,
    Expression<int>? unlocks,
    Expression<int>? screenOnMs,
    Expression<int>? pickups,
    Expression<int>? shortUnlocks,
    Expression<int>? sleepMisuseMs,
    Expression<int>? firstUnlockMs,
    Expression<int>? lastUnlockMs,
    Expression<int>? longestSessionMs,
    Expression<int>? longestScreenOffMs,
    Expression<int>? bingeCount,
    Expression<String>? firstAppPkg,
    Expression<String>? lastAppPkg,
  }) {
    return RawValuesInsertable({
      if (dayEpoch != null) 'day_epoch': dayEpoch,
      if (unlocks != null) 'unlocks': unlocks,
      if (screenOnMs != null) 'screen_on_ms': screenOnMs,
      if (pickups != null) 'pickups': pickups,
      if (shortUnlocks != null) 'short_unlocks': shortUnlocks,
      if (sleepMisuseMs != null) 'sleep_misuse_ms': sleepMisuseMs,
      if (firstUnlockMs != null) 'first_unlock_ms': firstUnlockMs,
      if (lastUnlockMs != null) 'last_unlock_ms': lastUnlockMs,
      if (longestSessionMs != null) 'longest_session_ms': longestSessionMs,
      if (longestScreenOffMs != null)
        'longest_screen_off_ms': longestScreenOffMs,
      if (bingeCount != null) 'binge_count': bingeCount,
      if (firstAppPkg != null) 'first_app_pkg': firstAppPkg,
      if (lastAppPkg != null) 'last_app_pkg': lastAppPkg,
    });
  }

  DailyPhoneCompanion copyWith({
    Value<int>? dayEpoch,
    Value<int>? unlocks,
    Value<int>? screenOnMs,
    Value<int>? pickups,
    Value<int>? shortUnlocks,
    Value<int>? sleepMisuseMs,
    Value<int?>? firstUnlockMs,
    Value<int?>? lastUnlockMs,
    Value<int>? longestSessionMs,
    Value<int>? longestScreenOffMs,
    Value<int>? bingeCount,
    Value<String?>? firstAppPkg,
    Value<String?>? lastAppPkg,
  }) {
    return DailyPhoneCompanion(
      dayEpoch: dayEpoch ?? this.dayEpoch,
      unlocks: unlocks ?? this.unlocks,
      screenOnMs: screenOnMs ?? this.screenOnMs,
      pickups: pickups ?? this.pickups,
      shortUnlocks: shortUnlocks ?? this.shortUnlocks,
      sleepMisuseMs: sleepMisuseMs ?? this.sleepMisuseMs,
      firstUnlockMs: firstUnlockMs ?? this.firstUnlockMs,
      lastUnlockMs: lastUnlockMs ?? this.lastUnlockMs,
      longestSessionMs: longestSessionMs ?? this.longestSessionMs,
      longestScreenOffMs: longestScreenOffMs ?? this.longestScreenOffMs,
      bingeCount: bingeCount ?? this.bingeCount,
      firstAppPkg: firstAppPkg ?? this.firstAppPkg,
      lastAppPkg: lastAppPkg ?? this.lastAppPkg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayEpoch.present) {
      map['day_epoch'] = Variable<int>(dayEpoch.value);
    }
    if (unlocks.present) {
      map['unlocks'] = Variable<int>(unlocks.value);
    }
    if (screenOnMs.present) {
      map['screen_on_ms'] = Variable<int>(screenOnMs.value);
    }
    if (pickups.present) {
      map['pickups'] = Variable<int>(pickups.value);
    }
    if (shortUnlocks.present) {
      map['short_unlocks'] = Variable<int>(shortUnlocks.value);
    }
    if (sleepMisuseMs.present) {
      map['sleep_misuse_ms'] = Variable<int>(sleepMisuseMs.value);
    }
    if (firstUnlockMs.present) {
      map['first_unlock_ms'] = Variable<int>(firstUnlockMs.value);
    }
    if (lastUnlockMs.present) {
      map['last_unlock_ms'] = Variable<int>(lastUnlockMs.value);
    }
    if (longestSessionMs.present) {
      map['longest_session_ms'] = Variable<int>(longestSessionMs.value);
    }
    if (longestScreenOffMs.present) {
      map['longest_screen_off_ms'] = Variable<int>(longestScreenOffMs.value);
    }
    if (bingeCount.present) {
      map['binge_count'] = Variable<int>(bingeCount.value);
    }
    if (firstAppPkg.present) {
      map['first_app_pkg'] = Variable<String>(firstAppPkg.value);
    }
    if (lastAppPkg.present) {
      map['last_app_pkg'] = Variable<String>(lastAppPkg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyPhoneCompanion(')
          ..write('dayEpoch: $dayEpoch, ')
          ..write('unlocks: $unlocks, ')
          ..write('screenOnMs: $screenOnMs, ')
          ..write('pickups: $pickups, ')
          ..write('shortUnlocks: $shortUnlocks, ')
          ..write('sleepMisuseMs: $sleepMisuseMs, ')
          ..write('firstUnlockMs: $firstUnlockMs, ')
          ..write('lastUnlockMs: $lastUnlockMs, ')
          ..write('longestSessionMs: $longestSessionMs, ')
          ..write('longestScreenOffMs: $longestScreenOffMs, ')
          ..write('bingeCount: $bingeCount, ')
          ..write('firstAppPkg: $firstAppPkg, ')
          ..write('lastAppPkg: $lastAppPkg')
          ..write(')'))
        .toString();
  }
}

class $BehaviorEpisodesTable extends BehaviorEpisodes
    with TableInfo<$BehaviorEpisodesTable, BehaviorEpisodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BehaviorEpisodesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startedAtMsMeta = const VerificationMeta(
    'startedAtMs',
  );
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
    'started_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMsMeta = const VerificationMeta(
    'endedAtMs',
  );
  @override
  late final GeneratedColumn<int> endedAtMs = GeneratedColumn<int>(
    'ended_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appPackageMeta = const VerificationMeta(
    'appPackage',
  );
  @override
  late final GeneratedColumn<String> appPackage = GeneratedColumn<String>(
    'app_package',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interactionCountMeta = const VerificationMeta(
    'interactionCount',
  );
  @override
  late final GeneratedColumn<int> interactionCount = GeneratedColumn<int>(
    'interaction_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _unlockCountMeta = const VerificationMeta(
    'unlockCount',
  );
  @override
  late final GeneratedColumn<int> unlockCount = GeneratedColumn<int>(
    'unlock_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notificationTriggeredMeta =
      const VerificationMeta('notificationTriggered');
  @override
  late final GeneratedColumn<bool> notificationTriggered =
      GeneratedColumn<bool>(
        'notification_triggered',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notification_triggered" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _appSwitchesMeta = const VerificationMeta(
    'appSwitches',
  );
  @override
  late final GeneratedColumn<int> appSwitches = GeneratedColumn<int>(
    'app_switches',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _passiveDurationMsMeta = const VerificationMeta(
    'passiveDurationMs',
  );
  @override
  late final GeneratedColumn<int> passiveDurationMs = GeneratedColumn<int>(
    'passive_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activeDurationMsMeta = const VerificationMeta(
    'activeDurationMs',
  );
  @override
  late final GeneratedColumn<int> activeDurationMs = GeneratedColumn<int>(
    'active_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _interruptionCountMeta = const VerificationMeta(
    'interruptionCount',
  );
  @override
  late final GeneratedColumn<int> interruptionCount = GeneratedColumn<int>(
    'interruption_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _classificationMeta = const VerificationMeta(
    'classification',
  );
  @override
  late final GeneratedColumn<String> classification = GeneratedColumn<String>(
    'classification',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('neutral'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAtMs,
    endedAtMs,
    appPackage,
    interactionCount,
    unlockCount,
    notificationTriggered,
    appSwitches,
    passiveDurationMs,
    activeDurationMs,
    interruptionCount,
    classification,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'behavior_episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<BehaviorEpisodeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
        _startedAtMsMeta,
        startedAtMs.isAcceptableOrUnknown(
          data['started_at_ms']!,
          _startedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('ended_at_ms')) {
      context.handle(
        _endedAtMsMeta,
        endedAtMs.isAcceptableOrUnknown(data['ended_at_ms']!, _endedAtMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMsMeta);
    }
    if (data.containsKey('app_package')) {
      context.handle(
        _appPackageMeta,
        appPackage.isAcceptableOrUnknown(data['app_package']!, _appPackageMeta),
      );
    } else if (isInserting) {
      context.missing(_appPackageMeta);
    }
    if (data.containsKey('interaction_count')) {
      context.handle(
        _interactionCountMeta,
        interactionCount.isAcceptableOrUnknown(
          data['interaction_count']!,
          _interactionCountMeta,
        ),
      );
    }
    if (data.containsKey('unlock_count')) {
      context.handle(
        _unlockCountMeta,
        unlockCount.isAcceptableOrUnknown(
          data['unlock_count']!,
          _unlockCountMeta,
        ),
      );
    }
    if (data.containsKey('notification_triggered')) {
      context.handle(
        _notificationTriggeredMeta,
        notificationTriggered.isAcceptableOrUnknown(
          data['notification_triggered']!,
          _notificationTriggeredMeta,
        ),
      );
    }
    if (data.containsKey('app_switches')) {
      context.handle(
        _appSwitchesMeta,
        appSwitches.isAcceptableOrUnknown(
          data['app_switches']!,
          _appSwitchesMeta,
        ),
      );
    }
    if (data.containsKey('passive_duration_ms')) {
      context.handle(
        _passiveDurationMsMeta,
        passiveDurationMs.isAcceptableOrUnknown(
          data['passive_duration_ms']!,
          _passiveDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('active_duration_ms')) {
      context.handle(
        _activeDurationMsMeta,
        activeDurationMs.isAcceptableOrUnknown(
          data['active_duration_ms']!,
          _activeDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('interruption_count')) {
      context.handle(
        _interruptionCountMeta,
        interruptionCount.isAcceptableOrUnknown(
          data['interruption_count']!,
          _interruptionCountMeta,
        ),
      );
    }
    if (data.containsKey('classification')) {
      context.handle(
        _classificationMeta,
        classification.isAcceptableOrUnknown(
          data['classification']!,
          _classificationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BehaviorEpisodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BehaviorEpisodeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_ms'],
      )!,
      endedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at_ms'],
      )!,
      appPackage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_package'],
      )!,
      interactionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interaction_count'],
      )!,
      unlockCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlock_count'],
      )!,
      notificationTriggered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notification_triggered'],
      )!,
      appSwitches: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}app_switches'],
      )!,
      passiveDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passive_duration_ms'],
      )!,
      activeDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_duration_ms'],
      )!,
      interruptionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interruption_count'],
      )!,
      classification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classification'],
      )!,
    );
  }

  @override
  $BehaviorEpisodesTable createAlias(String alias) {
    return $BehaviorEpisodesTable(attachedDatabase, alias);
  }
}

class BehaviorEpisodeRow extends DataClass
    implements Insertable<BehaviorEpisodeRow> {
  final int id;
  final int startedAtMs;
  final int endedAtMs;
  final String appPackage;
  final int interactionCount;
  final int unlockCount;
  final bool notificationTriggered;
  final int appSwitches;
  final int passiveDurationMs;
  final int activeDurationMs;
  final int interruptionCount;
  final String classification;
  const BehaviorEpisodeRow({
    required this.id,
    required this.startedAtMs,
    required this.endedAtMs,
    required this.appPackage,
    required this.interactionCount,
    required this.unlockCount,
    required this.notificationTriggered,
    required this.appSwitches,
    required this.passiveDurationMs,
    required this.activeDurationMs,
    required this.interruptionCount,
    required this.classification,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at_ms'] = Variable<int>(startedAtMs);
    map['ended_at_ms'] = Variable<int>(endedAtMs);
    map['app_package'] = Variable<String>(appPackage);
    map['interaction_count'] = Variable<int>(interactionCount);
    map['unlock_count'] = Variable<int>(unlockCount);
    map['notification_triggered'] = Variable<bool>(notificationTriggered);
    map['app_switches'] = Variable<int>(appSwitches);
    map['passive_duration_ms'] = Variable<int>(passiveDurationMs);
    map['active_duration_ms'] = Variable<int>(activeDurationMs);
    map['interruption_count'] = Variable<int>(interruptionCount);
    map['classification'] = Variable<String>(classification);
    return map;
  }

  BehaviorEpisodesCompanion toCompanion(bool nullToAbsent) {
    return BehaviorEpisodesCompanion(
      id: Value(id),
      startedAtMs: Value(startedAtMs),
      endedAtMs: Value(endedAtMs),
      appPackage: Value(appPackage),
      interactionCount: Value(interactionCount),
      unlockCount: Value(unlockCount),
      notificationTriggered: Value(notificationTriggered),
      appSwitches: Value(appSwitches),
      passiveDurationMs: Value(passiveDurationMs),
      activeDurationMs: Value(activeDurationMs),
      interruptionCount: Value(interruptionCount),
      classification: Value(classification),
    );
  }

  factory BehaviorEpisodeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BehaviorEpisodeRow(
      id: serializer.fromJson<int>(json['id']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      endedAtMs: serializer.fromJson<int>(json['endedAtMs']),
      appPackage: serializer.fromJson<String>(json['appPackage']),
      interactionCount: serializer.fromJson<int>(json['interactionCount']),
      unlockCount: serializer.fromJson<int>(json['unlockCount']),
      notificationTriggered: serializer.fromJson<bool>(
        json['notificationTriggered'],
      ),
      appSwitches: serializer.fromJson<int>(json['appSwitches']),
      passiveDurationMs: serializer.fromJson<int>(json['passiveDurationMs']),
      activeDurationMs: serializer.fromJson<int>(json['activeDurationMs']),
      interruptionCount: serializer.fromJson<int>(json['interruptionCount']),
      classification: serializer.fromJson<String>(json['classification']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'endedAtMs': serializer.toJson<int>(endedAtMs),
      'appPackage': serializer.toJson<String>(appPackage),
      'interactionCount': serializer.toJson<int>(interactionCount),
      'unlockCount': serializer.toJson<int>(unlockCount),
      'notificationTriggered': serializer.toJson<bool>(notificationTriggered),
      'appSwitches': serializer.toJson<int>(appSwitches),
      'passiveDurationMs': serializer.toJson<int>(passiveDurationMs),
      'activeDurationMs': serializer.toJson<int>(activeDurationMs),
      'interruptionCount': serializer.toJson<int>(interruptionCount),
      'classification': serializer.toJson<String>(classification),
    };
  }

  BehaviorEpisodeRow copyWith({
    int? id,
    int? startedAtMs,
    int? endedAtMs,
    String? appPackage,
    int? interactionCount,
    int? unlockCount,
    bool? notificationTriggered,
    int? appSwitches,
    int? passiveDurationMs,
    int? activeDurationMs,
    int? interruptionCount,
    String? classification,
  }) => BehaviorEpisodeRow(
    id: id ?? this.id,
    startedAtMs: startedAtMs ?? this.startedAtMs,
    endedAtMs: endedAtMs ?? this.endedAtMs,
    appPackage: appPackage ?? this.appPackage,
    interactionCount: interactionCount ?? this.interactionCount,
    unlockCount: unlockCount ?? this.unlockCount,
    notificationTriggered: notificationTriggered ?? this.notificationTriggered,
    appSwitches: appSwitches ?? this.appSwitches,
    passiveDurationMs: passiveDurationMs ?? this.passiveDurationMs,
    activeDurationMs: activeDurationMs ?? this.activeDurationMs,
    interruptionCount: interruptionCount ?? this.interruptionCount,
    classification: classification ?? this.classification,
  );
  BehaviorEpisodeRow copyWithCompanion(BehaviorEpisodesCompanion data) {
    return BehaviorEpisodeRow(
      id: data.id.present ? data.id.value : this.id,
      startedAtMs: data.startedAtMs.present
          ? data.startedAtMs.value
          : this.startedAtMs,
      endedAtMs: data.endedAtMs.present ? data.endedAtMs.value : this.endedAtMs,
      appPackage: data.appPackage.present
          ? data.appPackage.value
          : this.appPackage,
      interactionCount: data.interactionCount.present
          ? data.interactionCount.value
          : this.interactionCount,
      unlockCount: data.unlockCount.present
          ? data.unlockCount.value
          : this.unlockCount,
      notificationTriggered: data.notificationTriggered.present
          ? data.notificationTriggered.value
          : this.notificationTriggered,
      appSwitches: data.appSwitches.present
          ? data.appSwitches.value
          : this.appSwitches,
      passiveDurationMs: data.passiveDurationMs.present
          ? data.passiveDurationMs.value
          : this.passiveDurationMs,
      activeDurationMs: data.activeDurationMs.present
          ? data.activeDurationMs.value
          : this.activeDurationMs,
      interruptionCount: data.interruptionCount.present
          ? data.interruptionCount.value
          : this.interruptionCount,
      classification: data.classification.present
          ? data.classification.value
          : this.classification,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BehaviorEpisodeRow(')
          ..write('id: $id, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('appPackage: $appPackage, ')
          ..write('interactionCount: $interactionCount, ')
          ..write('unlockCount: $unlockCount, ')
          ..write('notificationTriggered: $notificationTriggered, ')
          ..write('appSwitches: $appSwitches, ')
          ..write('passiveDurationMs: $passiveDurationMs, ')
          ..write('activeDurationMs: $activeDurationMs, ')
          ..write('interruptionCount: $interruptionCount, ')
          ..write('classification: $classification')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAtMs,
    endedAtMs,
    appPackage,
    interactionCount,
    unlockCount,
    notificationTriggered,
    appSwitches,
    passiveDurationMs,
    activeDurationMs,
    interruptionCount,
    classification,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BehaviorEpisodeRow &&
          other.id == this.id &&
          other.startedAtMs == this.startedAtMs &&
          other.endedAtMs == this.endedAtMs &&
          other.appPackage == this.appPackage &&
          other.interactionCount == this.interactionCount &&
          other.unlockCount == this.unlockCount &&
          other.notificationTriggered == this.notificationTriggered &&
          other.appSwitches == this.appSwitches &&
          other.passiveDurationMs == this.passiveDurationMs &&
          other.activeDurationMs == this.activeDurationMs &&
          other.interruptionCount == this.interruptionCount &&
          other.classification == this.classification);
}

class BehaviorEpisodesCompanion extends UpdateCompanion<BehaviorEpisodeRow> {
  final Value<int> id;
  final Value<int> startedAtMs;
  final Value<int> endedAtMs;
  final Value<String> appPackage;
  final Value<int> interactionCount;
  final Value<int> unlockCount;
  final Value<bool> notificationTriggered;
  final Value<int> appSwitches;
  final Value<int> passiveDurationMs;
  final Value<int> activeDurationMs;
  final Value<int> interruptionCount;
  final Value<String> classification;
  const BehaviorEpisodesCompanion({
    this.id = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.endedAtMs = const Value.absent(),
    this.appPackage = const Value.absent(),
    this.interactionCount = const Value.absent(),
    this.unlockCount = const Value.absent(),
    this.notificationTriggered = const Value.absent(),
    this.appSwitches = const Value.absent(),
    this.passiveDurationMs = const Value.absent(),
    this.activeDurationMs = const Value.absent(),
    this.interruptionCount = const Value.absent(),
    this.classification = const Value.absent(),
  });
  BehaviorEpisodesCompanion.insert({
    this.id = const Value.absent(),
    required int startedAtMs,
    required int endedAtMs,
    required String appPackage,
    this.interactionCount = const Value.absent(),
    this.unlockCount = const Value.absent(),
    this.notificationTriggered = const Value.absent(),
    this.appSwitches = const Value.absent(),
    this.passiveDurationMs = const Value.absent(),
    this.activeDurationMs = const Value.absent(),
    this.interruptionCount = const Value.absent(),
    this.classification = const Value.absent(),
  }) : startedAtMs = Value(startedAtMs),
       endedAtMs = Value(endedAtMs),
       appPackage = Value(appPackage);
  static Insertable<BehaviorEpisodeRow> custom({
    Expression<int>? id,
    Expression<int>? startedAtMs,
    Expression<int>? endedAtMs,
    Expression<String>? appPackage,
    Expression<int>? interactionCount,
    Expression<int>? unlockCount,
    Expression<bool>? notificationTriggered,
    Expression<int>? appSwitches,
    Expression<int>? passiveDurationMs,
    Expression<int>? activeDurationMs,
    Expression<int>? interruptionCount,
    Expression<String>? classification,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (endedAtMs != null) 'ended_at_ms': endedAtMs,
      if (appPackage != null) 'app_package': appPackage,
      if (interactionCount != null) 'interaction_count': interactionCount,
      if (unlockCount != null) 'unlock_count': unlockCount,
      if (notificationTriggered != null)
        'notification_triggered': notificationTriggered,
      if (appSwitches != null) 'app_switches': appSwitches,
      if (passiveDurationMs != null) 'passive_duration_ms': passiveDurationMs,
      if (activeDurationMs != null) 'active_duration_ms': activeDurationMs,
      if (interruptionCount != null) 'interruption_count': interruptionCount,
      if (classification != null) 'classification': classification,
    });
  }

  BehaviorEpisodesCompanion copyWith({
    Value<int>? id,
    Value<int>? startedAtMs,
    Value<int>? endedAtMs,
    Value<String>? appPackage,
    Value<int>? interactionCount,
    Value<int>? unlockCount,
    Value<bool>? notificationTriggered,
    Value<int>? appSwitches,
    Value<int>? passiveDurationMs,
    Value<int>? activeDurationMs,
    Value<int>? interruptionCount,
    Value<String>? classification,
  }) {
    return BehaviorEpisodesCompanion(
      id: id ?? this.id,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      endedAtMs: endedAtMs ?? this.endedAtMs,
      appPackage: appPackage ?? this.appPackage,
      interactionCount: interactionCount ?? this.interactionCount,
      unlockCount: unlockCount ?? this.unlockCount,
      notificationTriggered:
          notificationTriggered ?? this.notificationTriggered,
      appSwitches: appSwitches ?? this.appSwitches,
      passiveDurationMs: passiveDurationMs ?? this.passiveDurationMs,
      activeDurationMs: activeDurationMs ?? this.activeDurationMs,
      interruptionCount: interruptionCount ?? this.interruptionCount,
      classification: classification ?? this.classification,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (endedAtMs.present) {
      map['ended_at_ms'] = Variable<int>(endedAtMs.value);
    }
    if (appPackage.present) {
      map['app_package'] = Variable<String>(appPackage.value);
    }
    if (interactionCount.present) {
      map['interaction_count'] = Variable<int>(interactionCount.value);
    }
    if (unlockCount.present) {
      map['unlock_count'] = Variable<int>(unlockCount.value);
    }
    if (notificationTriggered.present) {
      map['notification_triggered'] = Variable<bool>(
        notificationTriggered.value,
      );
    }
    if (appSwitches.present) {
      map['app_switches'] = Variable<int>(appSwitches.value);
    }
    if (passiveDurationMs.present) {
      map['passive_duration_ms'] = Variable<int>(passiveDurationMs.value);
    }
    if (activeDurationMs.present) {
      map['active_duration_ms'] = Variable<int>(activeDurationMs.value);
    }
    if (interruptionCount.present) {
      map['interruption_count'] = Variable<int>(interruptionCount.value);
    }
    if (classification.present) {
      map['classification'] = Variable<String>(classification.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BehaviorEpisodesCompanion(')
          ..write('id: $id, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('appPackage: $appPackage, ')
          ..write('interactionCount: $interactionCount, ')
          ..write('unlockCount: $unlockCount, ')
          ..write('notificationTriggered: $notificationTriggered, ')
          ..write('appSwitches: $appSwitches, ')
          ..write('passiveDurationMs: $passiveDurationMs, ')
          ..write('activeDurationMs: $activeDurationMs, ')
          ..write('interruptionCount: $interruptionCount, ')
          ..write('classification: $classification')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startedMsMeta = const VerificationMeta(
    'startedMs',
  );
  @override
  late final GeneratedColumn<int> startedMs = GeneratedColumn<int>(
    'started_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedMsMeta = const VerificationMeta(
    'plannedMs',
  );
  @override
  late final GeneratedColumn<int> plannedMs = GeneratedColumn<int>(
    'planned_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualMsMeta = const VerificationMeta(
    'actualMs',
  );
  @override
  late final GeneratedColumn<int> actualMs = GeneratedColumn<int>(
    'actual_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pomodoro'),
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _xpAwardedMeta = const VerificationMeta(
    'xpAwarded',
  );
  @override
  late final GeneratedColumn<int> xpAwarded = GeneratedColumn<int>(
    'xp_awarded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coinsAwardedMeta = const VerificationMeta(
    'coinsAwarded',
  );
  @override
  late final GeneratedColumn<int> coinsAwarded = GeneratedColumn<int>(
    'coins_awarded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _interruptionsMeta = const VerificationMeta(
    'interruptions',
  );
  @override
  late final GeneratedColumn<int> interruptions = GeneratedColumn<int>(
    'interruptions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _productivityScoreMeta = const VerificationMeta(
    'productivityScore',
  );
  @override
  late final GeneratedColumn<int> productivityScore = GeneratedColumn<int>(
    'productivity_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedMs,
    plannedMs,
    actualMs,
    mode,
    tag,
    completed,
    xpAwarded,
    coinsAwarded,
    interruptions,
    productivityScore,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_ms')) {
      context.handle(
        _startedMsMeta,
        startedMs.isAcceptableOrUnknown(data['started_ms']!, _startedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startedMsMeta);
    }
    if (data.containsKey('planned_ms')) {
      context.handle(
        _plannedMsMeta,
        plannedMs.isAcceptableOrUnknown(data['planned_ms']!, _plannedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_plannedMsMeta);
    }
    if (data.containsKey('actual_ms')) {
      context.handle(
        _actualMsMeta,
        actualMs.isAcceptableOrUnknown(data['actual_ms']!, _actualMsMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('xp_awarded')) {
      context.handle(
        _xpAwardedMeta,
        xpAwarded.isAcceptableOrUnknown(data['xp_awarded']!, _xpAwardedMeta),
      );
    }
    if (data.containsKey('coins_awarded')) {
      context.handle(
        _coinsAwardedMeta,
        coinsAwarded.isAcceptableOrUnknown(
          data['coins_awarded']!,
          _coinsAwardedMeta,
        ),
      );
    }
    if (data.containsKey('interruptions')) {
      context.handle(
        _interruptionsMeta,
        interruptions.isAcceptableOrUnknown(
          data['interruptions']!,
          _interruptionsMeta,
        ),
      );
    }
    if (data.containsKey('productivity_score')) {
      context.handle(
        _productivityScoreMeta,
        productivityScore.isAcceptableOrUnknown(
          data['productivity_score']!,
          _productivityScoreMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_ms'],
      )!,
      plannedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_ms'],
      )!,
      actualMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_ms'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      xpAwarded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_awarded'],
      )!,
      coinsAwarded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins_awarded'],
      )!,
      interruptions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interruptions'],
      )!,
      productivityScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}productivity_score'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSessionRow extends DataClass implements Insertable<FocusSessionRow> {
  final int id;
  final int startedMs;
  final int plannedMs;
  final int actualMs;
  final String mode;
  final String? tag;
  final bool completed;
  final int xpAwarded;
  final int coinsAwarded;
  final int interruptions;
  final int productivityScore;
  final String? note;
  const FocusSessionRow({
    required this.id,
    required this.startedMs,
    required this.plannedMs,
    required this.actualMs,
    required this.mode,
    this.tag,
    required this.completed,
    required this.xpAwarded,
    required this.coinsAwarded,
    required this.interruptions,
    required this.productivityScore,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_ms'] = Variable<int>(startedMs);
    map['planned_ms'] = Variable<int>(plannedMs);
    map['actual_ms'] = Variable<int>(actualMs);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || tag != null) {
      map['tag'] = Variable<String>(tag);
    }
    map['completed'] = Variable<bool>(completed);
    map['xp_awarded'] = Variable<int>(xpAwarded);
    map['coins_awarded'] = Variable<int>(coinsAwarded);
    map['interruptions'] = Variable<int>(interruptions);
    map['productivity_score'] = Variable<int>(productivityScore);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      startedMs: Value(startedMs),
      plannedMs: Value(plannedMs),
      actualMs: Value(actualMs),
      mode: Value(mode),
      tag: tag == null && nullToAbsent ? const Value.absent() : Value(tag),
      completed: Value(completed),
      xpAwarded: Value(xpAwarded),
      coinsAwarded: Value(coinsAwarded),
      interruptions: Value(interruptions),
      productivityScore: Value(productivityScore),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory FocusSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSessionRow(
      id: serializer.fromJson<int>(json['id']),
      startedMs: serializer.fromJson<int>(json['startedMs']),
      plannedMs: serializer.fromJson<int>(json['plannedMs']),
      actualMs: serializer.fromJson<int>(json['actualMs']),
      mode: serializer.fromJson<String>(json['mode']),
      tag: serializer.fromJson<String?>(json['tag']),
      completed: serializer.fromJson<bool>(json['completed']),
      xpAwarded: serializer.fromJson<int>(json['xpAwarded']),
      coinsAwarded: serializer.fromJson<int>(json['coinsAwarded']),
      interruptions: serializer.fromJson<int>(json['interruptions']),
      productivityScore: serializer.fromJson<int>(json['productivityScore']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedMs': serializer.toJson<int>(startedMs),
      'plannedMs': serializer.toJson<int>(plannedMs),
      'actualMs': serializer.toJson<int>(actualMs),
      'mode': serializer.toJson<String>(mode),
      'tag': serializer.toJson<String?>(tag),
      'completed': serializer.toJson<bool>(completed),
      'xpAwarded': serializer.toJson<int>(xpAwarded),
      'coinsAwarded': serializer.toJson<int>(coinsAwarded),
      'interruptions': serializer.toJson<int>(interruptions),
      'productivityScore': serializer.toJson<int>(productivityScore),
      'note': serializer.toJson<String?>(note),
    };
  }

  FocusSessionRow copyWith({
    int? id,
    int? startedMs,
    int? plannedMs,
    int? actualMs,
    String? mode,
    Value<String?> tag = const Value.absent(),
    bool? completed,
    int? xpAwarded,
    int? coinsAwarded,
    int? interruptions,
    int? productivityScore,
    Value<String?> note = const Value.absent(),
  }) => FocusSessionRow(
    id: id ?? this.id,
    startedMs: startedMs ?? this.startedMs,
    plannedMs: plannedMs ?? this.plannedMs,
    actualMs: actualMs ?? this.actualMs,
    mode: mode ?? this.mode,
    tag: tag.present ? tag.value : this.tag,
    completed: completed ?? this.completed,
    xpAwarded: xpAwarded ?? this.xpAwarded,
    coinsAwarded: coinsAwarded ?? this.coinsAwarded,
    interruptions: interruptions ?? this.interruptions,
    productivityScore: productivityScore ?? this.productivityScore,
    note: note.present ? note.value : this.note,
  );
  FocusSessionRow copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSessionRow(
      id: data.id.present ? data.id.value : this.id,
      startedMs: data.startedMs.present ? data.startedMs.value : this.startedMs,
      plannedMs: data.plannedMs.present ? data.plannedMs.value : this.plannedMs,
      actualMs: data.actualMs.present ? data.actualMs.value : this.actualMs,
      mode: data.mode.present ? data.mode.value : this.mode,
      tag: data.tag.present ? data.tag.value : this.tag,
      completed: data.completed.present ? data.completed.value : this.completed,
      xpAwarded: data.xpAwarded.present ? data.xpAwarded.value : this.xpAwarded,
      coinsAwarded: data.coinsAwarded.present
          ? data.coinsAwarded.value
          : this.coinsAwarded,
      interruptions: data.interruptions.present
          ? data.interruptions.value
          : this.interruptions,
      productivityScore: data.productivityScore.present
          ? data.productivityScore.value
          : this.productivityScore,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionRow(')
          ..write('id: $id, ')
          ..write('startedMs: $startedMs, ')
          ..write('plannedMs: $plannedMs, ')
          ..write('actualMs: $actualMs, ')
          ..write('mode: $mode, ')
          ..write('tag: $tag, ')
          ..write('completed: $completed, ')
          ..write('xpAwarded: $xpAwarded, ')
          ..write('coinsAwarded: $coinsAwarded, ')
          ..write('interruptions: $interruptions, ')
          ..write('productivityScore: $productivityScore, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedMs,
    plannedMs,
    actualMs,
    mode,
    tag,
    completed,
    xpAwarded,
    coinsAwarded,
    interruptions,
    productivityScore,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSessionRow &&
          other.id == this.id &&
          other.startedMs == this.startedMs &&
          other.plannedMs == this.plannedMs &&
          other.actualMs == this.actualMs &&
          other.mode == this.mode &&
          other.tag == this.tag &&
          other.completed == this.completed &&
          other.xpAwarded == this.xpAwarded &&
          other.coinsAwarded == this.coinsAwarded &&
          other.interruptions == this.interruptions &&
          other.productivityScore == this.productivityScore &&
          other.note == this.note);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSessionRow> {
  final Value<int> id;
  final Value<int> startedMs;
  final Value<int> plannedMs;
  final Value<int> actualMs;
  final Value<String> mode;
  final Value<String?> tag;
  final Value<bool> completed;
  final Value<int> xpAwarded;
  final Value<int> coinsAwarded;
  final Value<int> interruptions;
  final Value<int> productivityScore;
  final Value<String?> note;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.startedMs = const Value.absent(),
    this.plannedMs = const Value.absent(),
    this.actualMs = const Value.absent(),
    this.mode = const Value.absent(),
    this.tag = const Value.absent(),
    this.completed = const Value.absent(),
    this.xpAwarded = const Value.absent(),
    this.coinsAwarded = const Value.absent(),
    this.interruptions = const Value.absent(),
    this.productivityScore = const Value.absent(),
    this.note = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int startedMs,
    required int plannedMs,
    this.actualMs = const Value.absent(),
    this.mode = const Value.absent(),
    this.tag = const Value.absent(),
    this.completed = const Value.absent(),
    this.xpAwarded = const Value.absent(),
    this.coinsAwarded = const Value.absent(),
    this.interruptions = const Value.absent(),
    this.productivityScore = const Value.absent(),
    this.note = const Value.absent(),
  }) : startedMs = Value(startedMs),
       plannedMs = Value(plannedMs);
  static Insertable<FocusSessionRow> custom({
    Expression<int>? id,
    Expression<int>? startedMs,
    Expression<int>? plannedMs,
    Expression<int>? actualMs,
    Expression<String>? mode,
    Expression<String>? tag,
    Expression<bool>? completed,
    Expression<int>? xpAwarded,
    Expression<int>? coinsAwarded,
    Expression<int>? interruptions,
    Expression<int>? productivityScore,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedMs != null) 'started_ms': startedMs,
      if (plannedMs != null) 'planned_ms': plannedMs,
      if (actualMs != null) 'actual_ms': actualMs,
      if (mode != null) 'mode': mode,
      if (tag != null) 'tag': tag,
      if (completed != null) 'completed': completed,
      if (xpAwarded != null) 'xp_awarded': xpAwarded,
      if (coinsAwarded != null) 'coins_awarded': coinsAwarded,
      if (interruptions != null) 'interruptions': interruptions,
      if (productivityScore != null) 'productivity_score': productivityScore,
      if (note != null) 'note': note,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? startedMs,
    Value<int>? plannedMs,
    Value<int>? actualMs,
    Value<String>? mode,
    Value<String?>? tag,
    Value<bool>? completed,
    Value<int>? xpAwarded,
    Value<int>? coinsAwarded,
    Value<int>? interruptions,
    Value<int>? productivityScore,
    Value<String?>? note,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      startedMs: startedMs ?? this.startedMs,
      plannedMs: plannedMs ?? this.plannedMs,
      actualMs: actualMs ?? this.actualMs,
      mode: mode ?? this.mode,
      tag: tag ?? this.tag,
      completed: completed ?? this.completed,
      xpAwarded: xpAwarded ?? this.xpAwarded,
      coinsAwarded: coinsAwarded ?? this.coinsAwarded,
      interruptions: interruptions ?? this.interruptions,
      productivityScore: productivityScore ?? this.productivityScore,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedMs.present) {
      map['started_ms'] = Variable<int>(startedMs.value);
    }
    if (plannedMs.present) {
      map['planned_ms'] = Variable<int>(plannedMs.value);
    }
    if (actualMs.present) {
      map['actual_ms'] = Variable<int>(actualMs.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (xpAwarded.present) {
      map['xp_awarded'] = Variable<int>(xpAwarded.value);
    }
    if (coinsAwarded.present) {
      map['coins_awarded'] = Variable<int>(coinsAwarded.value);
    }
    if (interruptions.present) {
      map['interruptions'] = Variable<int>(interruptions.value);
    }
    if (productivityScore.present) {
      map['productivity_score'] = Variable<int>(productivityScore.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedMs: $startedMs, ')
          ..write('plannedMs: $plannedMs, ')
          ..write('actualMs: $actualMs, ')
          ..write('mode: $mode, ')
          ..write('tag: $tag, ')
          ..write('completed: $completed, ')
          ..write('xpAwarded: $xpAwarded, ')
          ..write('coinsAwarded: $coinsAwarded, ')
          ..write('interruptions: $interruptions, ')
          ..write('productivityScore: $productivityScore, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $BlockRulesTable extends BlockRules
    with TableInfo<$BlockRulesTable, BlockRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlockRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _untilMsMeta = const VerificationMeta(
    'untilMs',
  );
  @override
  late final GeneratedColumn<int> untilMs = GeneratedColumn<int>(
    'until_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyLimitMsMeta = const VerificationMeta(
    'dailyLimitMs',
  );
  @override
  late final GeneratedColumn<int> dailyLimitMs = GeneratedColumn<int>(
    'daily_limit_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdMsMeta = const VerificationMeta(
    'createdMs',
  );
  @override
  late final GeneratedColumn<int> createdMs = GeneratedColumn<int>(
    'created_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    mode,
    untilMs,
    dailyLimitMs,
    enabled,
    createdMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'block_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlockRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('until_ms')) {
      context.handle(
        _untilMsMeta,
        untilMs.isAcceptableOrUnknown(data['until_ms']!, _untilMsMeta),
      );
    }
    if (data.containsKey('daily_limit_ms')) {
      context.handle(
        _dailyLimitMsMeta,
        dailyLimitMs.isAcceptableOrUnknown(
          data['daily_limit_ms']!,
          _dailyLimitMsMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('created_ms')) {
      context.handle(
        _createdMsMeta,
        createdMs.isAcceptableOrUnknown(data['created_ms']!, _createdMsMeta),
      );
    } else if (isInserting) {
      context.missing(_createdMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BlockRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlockRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      untilMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}until_ms'],
      ),
      dailyLimitMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_limit_ms'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_ms'],
      )!,
    );
  }

  @override
  $BlockRulesTable createAlias(String alias) {
    return $BlockRulesTable(attachedDatabase, alias);
  }
}

class BlockRuleRow extends DataClass implements Insertable<BlockRuleRow> {
  final int id;
  final String packageName;
  final String mode;
  final int? untilMs;
  final int? dailyLimitMs;
  final bool enabled;
  final int createdMs;
  const BlockRuleRow({
    required this.id,
    required this.packageName,
    required this.mode,
    this.untilMs,
    this.dailyLimitMs,
    required this.enabled,
    required this.createdMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || untilMs != null) {
      map['until_ms'] = Variable<int>(untilMs);
    }
    if (!nullToAbsent || dailyLimitMs != null) {
      map['daily_limit_ms'] = Variable<int>(dailyLimitMs);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['created_ms'] = Variable<int>(createdMs);
    return map;
  }

  BlockRulesCompanion toCompanion(bool nullToAbsent) {
    return BlockRulesCompanion(
      id: Value(id),
      packageName: Value(packageName),
      mode: Value(mode),
      untilMs: untilMs == null && nullToAbsent
          ? const Value.absent()
          : Value(untilMs),
      dailyLimitMs: dailyLimitMs == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyLimitMs),
      enabled: Value(enabled),
      createdMs: Value(createdMs),
    );
  }

  factory BlockRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlockRuleRow(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      mode: serializer.fromJson<String>(json['mode']),
      untilMs: serializer.fromJson<int?>(json['untilMs']),
      dailyLimitMs: serializer.fromJson<int?>(json['dailyLimitMs']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdMs: serializer.fromJson<int>(json['createdMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'mode': serializer.toJson<String>(mode),
      'untilMs': serializer.toJson<int?>(untilMs),
      'dailyLimitMs': serializer.toJson<int?>(dailyLimitMs),
      'enabled': serializer.toJson<bool>(enabled),
      'createdMs': serializer.toJson<int>(createdMs),
    };
  }

  BlockRuleRow copyWith({
    int? id,
    String? packageName,
    String? mode,
    Value<int?> untilMs = const Value.absent(),
    Value<int?> dailyLimitMs = const Value.absent(),
    bool? enabled,
    int? createdMs,
  }) => BlockRuleRow(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    mode: mode ?? this.mode,
    untilMs: untilMs.present ? untilMs.value : this.untilMs,
    dailyLimitMs: dailyLimitMs.present ? dailyLimitMs.value : this.dailyLimitMs,
    enabled: enabled ?? this.enabled,
    createdMs: createdMs ?? this.createdMs,
  );
  BlockRuleRow copyWithCompanion(BlockRulesCompanion data) {
    return BlockRuleRow(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      mode: data.mode.present ? data.mode.value : this.mode,
      untilMs: data.untilMs.present ? data.untilMs.value : this.untilMs,
      dailyLimitMs: data.dailyLimitMs.present
          ? data.dailyLimitMs.value
          : this.dailyLimitMs,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdMs: data.createdMs.present ? data.createdMs.value : this.createdMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlockRuleRow(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('mode: $mode, ')
          ..write('untilMs: $untilMs, ')
          ..write('dailyLimitMs: $dailyLimitMs, ')
          ..write('enabled: $enabled, ')
          ..write('createdMs: $createdMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    mode,
    untilMs,
    dailyLimitMs,
    enabled,
    createdMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlockRuleRow &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.mode == this.mode &&
          other.untilMs == this.untilMs &&
          other.dailyLimitMs == this.dailyLimitMs &&
          other.enabled == this.enabled &&
          other.createdMs == this.createdMs);
}

class BlockRulesCompanion extends UpdateCompanion<BlockRuleRow> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String> mode;
  final Value<int?> untilMs;
  final Value<int?> dailyLimitMs;
  final Value<bool> enabled;
  final Value<int> createdMs;
  const BlockRulesCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.mode = const Value.absent(),
    this.untilMs = const Value.absent(),
    this.dailyLimitMs = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdMs = const Value.absent(),
  });
  BlockRulesCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required String mode,
    this.untilMs = const Value.absent(),
    this.dailyLimitMs = const Value.absent(),
    this.enabled = const Value.absent(),
    required int createdMs,
  }) : packageName = Value(packageName),
       mode = Value(mode),
       createdMs = Value(createdMs);
  static Insertable<BlockRuleRow> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? mode,
    Expression<int>? untilMs,
    Expression<int>? dailyLimitMs,
    Expression<bool>? enabled,
    Expression<int>? createdMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (mode != null) 'mode': mode,
      if (untilMs != null) 'until_ms': untilMs,
      if (dailyLimitMs != null) 'daily_limit_ms': dailyLimitMs,
      if (enabled != null) 'enabled': enabled,
      if (createdMs != null) 'created_ms': createdMs,
    });
  }

  BlockRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<String>? mode,
    Value<int?>? untilMs,
    Value<int?>? dailyLimitMs,
    Value<bool>? enabled,
    Value<int>? createdMs,
  }) {
    return BlockRulesCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      mode: mode ?? this.mode,
      untilMs: untilMs ?? this.untilMs,
      dailyLimitMs: dailyLimitMs ?? this.dailyLimitMs,
      enabled: enabled ?? this.enabled,
      createdMs: createdMs ?? this.createdMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (untilMs.present) {
      map['until_ms'] = Variable<int>(untilMs.value);
    }
    if (dailyLimitMs.present) {
      map['daily_limit_ms'] = Variable<int>(dailyLimitMs.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdMs.present) {
      map['created_ms'] = Variable<int>(createdMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlockRulesCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('mode: $mode, ')
          ..write('untilMs: $untilMs, ')
          ..write('dailyLimitMs: $dailyLimitMs, ')
          ..write('enabled: $enabled, ')
          ..write('createdMs: $createdMs')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, AchievementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMsMeta = const VerificationMeta(
    'unlockedAtMs',
  );
  @override
  late final GeneratedColumn<int> unlockedAtMs = GeneratedColumn<int>(
    'unlocked_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [code, unlockedAtMs, progress];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<AchievementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('unlocked_at_ms')) {
      context.handle(
        _unlockedAtMsMeta,
        unlockedAtMs.isAcceptableOrUnknown(
          data['unlocked_at_ms']!,
          _unlockedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMsMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  AchievementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementRow(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      unlockedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlocked_at_ms'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class AchievementRow extends DataClass implements Insertable<AchievementRow> {
  final String code;
  final int unlockedAtMs;
  final int progress;
  const AchievementRow({
    required this.code,
    required this.unlockedAtMs,
    required this.progress,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['unlocked_at_ms'] = Variable<int>(unlockedAtMs);
    map['progress'] = Variable<int>(progress);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      code: Value(code),
      unlockedAtMs: Value(unlockedAtMs),
      progress: Value(progress),
    );
  }

  factory AchievementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementRow(
      code: serializer.fromJson<String>(json['code']),
      unlockedAtMs: serializer.fromJson<int>(json['unlockedAtMs']),
      progress: serializer.fromJson<int>(json['progress']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'unlockedAtMs': serializer.toJson<int>(unlockedAtMs),
      'progress': serializer.toJson<int>(progress),
    };
  }

  AchievementRow copyWith({String? code, int? unlockedAtMs, int? progress}) =>
      AchievementRow(
        code: code ?? this.code,
        unlockedAtMs: unlockedAtMs ?? this.unlockedAtMs,
        progress: progress ?? this.progress,
      );
  AchievementRow copyWithCompanion(AchievementsCompanion data) {
    return AchievementRow(
      code: data.code.present ? data.code.value : this.code,
      unlockedAtMs: data.unlockedAtMs.present
          ? data.unlockedAtMs.value
          : this.unlockedAtMs,
      progress: data.progress.present ? data.progress.value : this.progress,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementRow(')
          ..write('code: $code, ')
          ..write('unlockedAtMs: $unlockedAtMs, ')
          ..write('progress: $progress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, unlockedAtMs, progress);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementRow &&
          other.code == this.code &&
          other.unlockedAtMs == this.unlockedAtMs &&
          other.progress == this.progress);
}

class AchievementsCompanion extends UpdateCompanion<AchievementRow> {
  final Value<String> code;
  final Value<int> unlockedAtMs;
  final Value<int> progress;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.code = const Value.absent(),
    this.unlockedAtMs = const Value.absent(),
    this.progress = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String code,
    required int unlockedAtMs,
    this.progress = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       unlockedAtMs = Value(unlockedAtMs);
  static Insertable<AchievementRow> custom({
    Expression<String>? code,
    Expression<int>? unlockedAtMs,
    Expression<int>? progress,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (unlockedAtMs != null) 'unlocked_at_ms': unlockedAtMs,
      if (progress != null) 'progress': progress,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String>? code,
    Value<int>? unlockedAtMs,
    Value<int>? progress,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      code: code ?? this.code,
      unlockedAtMs: unlockedAtMs ?? this.unlockedAtMs,
      progress: progress ?? this.progress,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (unlockedAtMs.present) {
      map['unlocked_at_ms'] = Variable<int>(unlockedAtMs.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('code: $code, ')
          ..write('unlockedAtMs: $unlockedAtMs, ')
          ..write('progress: $progress, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MissionsTable extends Missions
    with TableInfo<$MissionsTable, MissionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MissionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayEpochMeta = const VerificationMeta(
    'dayEpoch',
  );
  @override
  late final GeneratedColumn<int> dayEpoch = GeneratedColumn<int>(
    'day_epoch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _xpRewardMeta = const VerificationMeta(
    'xpReward',
  );
  @override
  late final GeneratedColumn<int> xpReward = GeneratedColumn<int>(
    'xp_reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coinsRewardMeta = const VerificationMeta(
    'coinsReward',
  );
  @override
  late final GeneratedColumn<int> coinsReward = GeneratedColumn<int>(
    'coins_reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _claimedMeta = const VerificationMeta(
    'claimed',
  );
  @override
  late final GeneratedColumn<bool> claimed = GeneratedColumn<bool>(
    'claimed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("claimed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayEpoch,
    code,
    title,
    description,
    target,
    progress,
    xpReward,
    coinsReward,
    completed,
    claimed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'missions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MissionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_epoch')) {
      context.handle(
        _dayEpochMeta,
        dayEpoch.isAcceptableOrUnknown(data['day_epoch']!, _dayEpochMeta),
      );
    } else if (isInserting) {
      context.missing(_dayEpochMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
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
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('xp_reward')) {
      context.handle(
        _xpRewardMeta,
        xpReward.isAcceptableOrUnknown(data['xp_reward']!, _xpRewardMeta),
      );
    } else if (isInserting) {
      context.missing(_xpRewardMeta);
    }
    if (data.containsKey('coins_reward')) {
      context.handle(
        _coinsRewardMeta,
        coinsReward.isAcceptableOrUnknown(
          data['coins_reward']!,
          _coinsRewardMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coinsRewardMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('claimed')) {
      context.handle(
        _claimedMeta,
        claimed.isAcceptableOrUnknown(data['claimed']!, _claimedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MissionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MissionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dayEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_epoch'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      xpReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_reward'],
      )!,
      coinsReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins_reward'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      claimed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}claimed'],
      )!,
    );
  }

  @override
  $MissionsTable createAlias(String alias) {
    return $MissionsTable(attachedDatabase, alias);
  }
}

class MissionRow extends DataClass implements Insertable<MissionRow> {
  final int id;
  final int dayEpoch;
  final String code;
  final String title;
  final String description;
  final int target;
  final int progress;
  final int xpReward;
  final int coinsReward;
  final bool completed;
  final bool claimed;
  const MissionRow({
    required this.id,
    required this.dayEpoch,
    required this.code,
    required this.title,
    required this.description,
    required this.target,
    required this.progress,
    required this.xpReward,
    required this.coinsReward,
    required this.completed,
    required this.claimed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_epoch'] = Variable<int>(dayEpoch);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['target'] = Variable<int>(target);
    map['progress'] = Variable<int>(progress);
    map['xp_reward'] = Variable<int>(xpReward);
    map['coins_reward'] = Variable<int>(coinsReward);
    map['completed'] = Variable<bool>(completed);
    map['claimed'] = Variable<bool>(claimed);
    return map;
  }

  MissionsCompanion toCompanion(bool nullToAbsent) {
    return MissionsCompanion(
      id: Value(id),
      dayEpoch: Value(dayEpoch),
      code: Value(code),
      title: Value(title),
      description: Value(description),
      target: Value(target),
      progress: Value(progress),
      xpReward: Value(xpReward),
      coinsReward: Value(coinsReward),
      completed: Value(completed),
      claimed: Value(claimed),
    );
  }

  factory MissionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MissionRow(
      id: serializer.fromJson<int>(json['id']),
      dayEpoch: serializer.fromJson<int>(json['dayEpoch']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      target: serializer.fromJson<int>(json['target']),
      progress: serializer.fromJson<int>(json['progress']),
      xpReward: serializer.fromJson<int>(json['xpReward']),
      coinsReward: serializer.fromJson<int>(json['coinsReward']),
      completed: serializer.fromJson<bool>(json['completed']),
      claimed: serializer.fromJson<bool>(json['claimed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayEpoch': serializer.toJson<int>(dayEpoch),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'target': serializer.toJson<int>(target),
      'progress': serializer.toJson<int>(progress),
      'xpReward': serializer.toJson<int>(xpReward),
      'coinsReward': serializer.toJson<int>(coinsReward),
      'completed': serializer.toJson<bool>(completed),
      'claimed': serializer.toJson<bool>(claimed),
    };
  }

  MissionRow copyWith({
    int? id,
    int? dayEpoch,
    String? code,
    String? title,
    String? description,
    int? target,
    int? progress,
    int? xpReward,
    int? coinsReward,
    bool? completed,
    bool? claimed,
  }) => MissionRow(
    id: id ?? this.id,
    dayEpoch: dayEpoch ?? this.dayEpoch,
    code: code ?? this.code,
    title: title ?? this.title,
    description: description ?? this.description,
    target: target ?? this.target,
    progress: progress ?? this.progress,
    xpReward: xpReward ?? this.xpReward,
    coinsReward: coinsReward ?? this.coinsReward,
    completed: completed ?? this.completed,
    claimed: claimed ?? this.claimed,
  );
  MissionRow copyWithCompanion(MissionsCompanion data) {
    return MissionRow(
      id: data.id.present ? data.id.value : this.id,
      dayEpoch: data.dayEpoch.present ? data.dayEpoch.value : this.dayEpoch,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      target: data.target.present ? data.target.value : this.target,
      progress: data.progress.present ? data.progress.value : this.progress,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
      coinsReward: data.coinsReward.present
          ? data.coinsReward.value
          : this.coinsReward,
      completed: data.completed.present ? data.completed.value : this.completed,
      claimed: data.claimed.present ? data.claimed.value : this.claimed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MissionRow(')
          ..write('id: $id, ')
          ..write('dayEpoch: $dayEpoch, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('target: $target, ')
          ..write('progress: $progress, ')
          ..write('xpReward: $xpReward, ')
          ..write('coinsReward: $coinsReward, ')
          ..write('completed: $completed, ')
          ..write('claimed: $claimed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayEpoch,
    code,
    title,
    description,
    target,
    progress,
    xpReward,
    coinsReward,
    completed,
    claimed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MissionRow &&
          other.id == this.id &&
          other.dayEpoch == this.dayEpoch &&
          other.code == this.code &&
          other.title == this.title &&
          other.description == this.description &&
          other.target == this.target &&
          other.progress == this.progress &&
          other.xpReward == this.xpReward &&
          other.coinsReward == this.coinsReward &&
          other.completed == this.completed &&
          other.claimed == this.claimed);
}

class MissionsCompanion extends UpdateCompanion<MissionRow> {
  final Value<int> id;
  final Value<int> dayEpoch;
  final Value<String> code;
  final Value<String> title;
  final Value<String> description;
  final Value<int> target;
  final Value<int> progress;
  final Value<int> xpReward;
  final Value<int> coinsReward;
  final Value<bool> completed;
  final Value<bool> claimed;
  const MissionsCompanion({
    this.id = const Value.absent(),
    this.dayEpoch = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.target = const Value.absent(),
    this.progress = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.coinsReward = const Value.absent(),
    this.completed = const Value.absent(),
    this.claimed = const Value.absent(),
  });
  MissionsCompanion.insert({
    this.id = const Value.absent(),
    required int dayEpoch,
    required String code,
    required String title,
    required String description,
    required int target,
    this.progress = const Value.absent(),
    required int xpReward,
    required int coinsReward,
    this.completed = const Value.absent(),
    this.claimed = const Value.absent(),
  }) : dayEpoch = Value(dayEpoch),
       code = Value(code),
       title = Value(title),
       description = Value(description),
       target = Value(target),
       xpReward = Value(xpReward),
       coinsReward = Value(coinsReward);
  static Insertable<MissionRow> custom({
    Expression<int>? id,
    Expression<int>? dayEpoch,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? target,
    Expression<int>? progress,
    Expression<int>? xpReward,
    Expression<int>? coinsReward,
    Expression<bool>? completed,
    Expression<bool>? claimed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayEpoch != null) 'day_epoch': dayEpoch,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (target != null) 'target': target,
      if (progress != null) 'progress': progress,
      if (xpReward != null) 'xp_reward': xpReward,
      if (coinsReward != null) 'coins_reward': coinsReward,
      if (completed != null) 'completed': completed,
      if (claimed != null) 'claimed': claimed,
    });
  }

  MissionsCompanion copyWith({
    Value<int>? id,
    Value<int>? dayEpoch,
    Value<String>? code,
    Value<String>? title,
    Value<String>? description,
    Value<int>? target,
    Value<int>? progress,
    Value<int>? xpReward,
    Value<int>? coinsReward,
    Value<bool>? completed,
    Value<bool>? claimed,
  }) {
    return MissionsCompanion(
      id: id ?? this.id,
      dayEpoch: dayEpoch ?? this.dayEpoch,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      xpReward: xpReward ?? this.xpReward,
      coinsReward: coinsReward ?? this.coinsReward,
      completed: completed ?? this.completed,
      claimed: claimed ?? this.claimed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayEpoch.present) {
      map['day_epoch'] = Variable<int>(dayEpoch.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    if (coinsReward.present) {
      map['coins_reward'] = Variable<int>(coinsReward.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (claimed.present) {
      map['claimed'] = Variable<bool>(claimed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MissionsCompanion(')
          ..write('id: $id, ')
          ..write('dayEpoch: $dayEpoch, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('target: $target, ')
          ..write('progress: $progress, ')
          ..write('xpReward: $xpReward, ')
          ..write('coinsReward: $coinsReward, ')
          ..write('completed: $completed, ')
          ..write('claimed: $claimed')
          ..write(')'))
        .toString();
  }
}

class $PurposeUnlocksTable extends PurposeUnlocks
    with TableInfo<$PurposeUnlocksTable, PurposeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurposeUnlocksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
    'timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _followUpDurationMsMeta =
      const VerificationMeta('followUpDurationMs');
  @override
  late final GeneratedColumn<int> followUpDurationMs = GeneratedColumn<int>(
    'follow_up_duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestampMs,
    packageName,
    purpose,
    followUpDurationMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purpose_unlocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurposeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('follow_up_duration_ms')) {
      context.handle(
        _followUpDurationMsMeta,
        followUpDurationMs.isAcceptableOrUnknown(
          data['follow_up_duration_ms']!,
          _followUpDurationMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurposeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurposeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_ms'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      followUpDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}follow_up_duration_ms'],
      ),
    );
  }

  @override
  $PurposeUnlocksTable createAlias(String alias) {
    return $PurposeUnlocksTable(attachedDatabase, alias);
  }
}

class PurposeRow extends DataClass implements Insertable<PurposeRow> {
  final int id;
  final int timestampMs;
  final String packageName;
  final String purpose;
  final int? followUpDurationMs;
  const PurposeRow({
    required this.id,
    required this.timestampMs,
    required this.packageName,
    required this.purpose,
    this.followUpDurationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp_ms'] = Variable<int>(timestampMs);
    map['package_name'] = Variable<String>(packageName);
    map['purpose'] = Variable<String>(purpose);
    if (!nullToAbsent || followUpDurationMs != null) {
      map['follow_up_duration_ms'] = Variable<int>(followUpDurationMs);
    }
    return map;
  }

  PurposeUnlocksCompanion toCompanion(bool nullToAbsent) {
    return PurposeUnlocksCompanion(
      id: Value(id),
      timestampMs: Value(timestampMs),
      packageName: Value(packageName),
      purpose: Value(purpose),
      followUpDurationMs: followUpDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpDurationMs),
    );
  }

  factory PurposeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurposeRow(
      id: serializer.fromJson<int>(json['id']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
      packageName: serializer.fromJson<String>(json['packageName']),
      purpose: serializer.fromJson<String>(json['purpose']),
      followUpDurationMs: serializer.fromJson<int?>(json['followUpDurationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestampMs': serializer.toJson<int>(timestampMs),
      'packageName': serializer.toJson<String>(packageName),
      'purpose': serializer.toJson<String>(purpose),
      'followUpDurationMs': serializer.toJson<int?>(followUpDurationMs),
    };
  }

  PurposeRow copyWith({
    int? id,
    int? timestampMs,
    String? packageName,
    String? purpose,
    Value<int?> followUpDurationMs = const Value.absent(),
  }) => PurposeRow(
    id: id ?? this.id,
    timestampMs: timestampMs ?? this.timestampMs,
    packageName: packageName ?? this.packageName,
    purpose: purpose ?? this.purpose,
    followUpDurationMs: followUpDurationMs.present
        ? followUpDurationMs.value
        : this.followUpDurationMs,
  );
  PurposeRow copyWithCompanion(PurposeUnlocksCompanion data) {
    return PurposeRow(
      id: data.id.present ? data.id.value : this.id,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      followUpDurationMs: data.followUpDurationMs.present
          ? data.followUpDurationMs.value
          : this.followUpDurationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurposeRow(')
          ..write('id: $id, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('packageName: $packageName, ')
          ..write('purpose: $purpose, ')
          ..write('followUpDurationMs: $followUpDurationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, timestampMs, packageName, purpose, followUpDurationMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurposeRow &&
          other.id == this.id &&
          other.timestampMs == this.timestampMs &&
          other.packageName == this.packageName &&
          other.purpose == this.purpose &&
          other.followUpDurationMs == this.followUpDurationMs);
}

class PurposeUnlocksCompanion extends UpdateCompanion<PurposeRow> {
  final Value<int> id;
  final Value<int> timestampMs;
  final Value<String> packageName;
  final Value<String> purpose;
  final Value<int?> followUpDurationMs;
  const PurposeUnlocksCompanion({
    this.id = const Value.absent(),
    this.timestampMs = const Value.absent(),
    this.packageName = const Value.absent(),
    this.purpose = const Value.absent(),
    this.followUpDurationMs = const Value.absent(),
  });
  PurposeUnlocksCompanion.insert({
    this.id = const Value.absent(),
    required int timestampMs,
    required String packageName,
    required String purpose,
    this.followUpDurationMs = const Value.absent(),
  }) : timestampMs = Value(timestampMs),
       packageName = Value(packageName),
       purpose = Value(purpose);
  static Insertable<PurposeRow> custom({
    Expression<int>? id,
    Expression<int>? timestampMs,
    Expression<String>? packageName,
    Expression<String>? purpose,
    Expression<int>? followUpDurationMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
      if (packageName != null) 'package_name': packageName,
      if (purpose != null) 'purpose': purpose,
      if (followUpDurationMs != null)
        'follow_up_duration_ms': followUpDurationMs,
    });
  }

  PurposeUnlocksCompanion copyWith({
    Value<int>? id,
    Value<int>? timestampMs,
    Value<String>? packageName,
    Value<String>? purpose,
    Value<int?>? followUpDurationMs,
  }) {
    return PurposeUnlocksCompanion(
      id: id ?? this.id,
      timestampMs: timestampMs ?? this.timestampMs,
      packageName: packageName ?? this.packageName,
      purpose: purpose ?? this.purpose,
      followUpDurationMs: followUpDurationMs ?? this.followUpDurationMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (followUpDurationMs.present) {
      map['follow_up_duration_ms'] = Variable<int>(followUpDurationMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurposeUnlocksCompanion(')
          ..write('id: $id, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('packageName: $packageName, ')
          ..write('purpose: $purpose, ')
          ..write('followUpDurationMs: $followUpDurationMs')
          ..write(')'))
        .toString();
  }
}

class $MoodEntriesTable extends MoodEntries
    with TableInfo<$MoodEntriesTable, MoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
    'timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, timestampMs, score, tag, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_ms'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $MoodEntriesTable createAlias(String alias) {
    return $MoodEntriesTable(attachedDatabase, alias);
  }
}

class MoodRow extends DataClass implements Insertable<MoodRow> {
  final int id;
  final int timestampMs;
  final int score;
  final String? tag;
  final String? note;
  const MoodRow({
    required this.id,
    required this.timestampMs,
    required this.score,
    this.tag,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp_ms'] = Variable<int>(timestampMs);
    map['score'] = Variable<int>(score);
    if (!nullToAbsent || tag != null) {
      map['tag'] = Variable<String>(tag);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  MoodEntriesCompanion toCompanion(bool nullToAbsent) {
    return MoodEntriesCompanion(
      id: Value(id),
      timestampMs: Value(timestampMs),
      score: Value(score),
      tag: tag == null && nullToAbsent ? const Value.absent() : Value(tag),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory MoodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodRow(
      id: serializer.fromJson<int>(json['id']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
      score: serializer.fromJson<int>(json['score']),
      tag: serializer.fromJson<String?>(json['tag']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestampMs': serializer.toJson<int>(timestampMs),
      'score': serializer.toJson<int>(score),
      'tag': serializer.toJson<String?>(tag),
      'note': serializer.toJson<String?>(note),
    };
  }

  MoodRow copyWith({
    int? id,
    int? timestampMs,
    int? score,
    Value<String?> tag = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => MoodRow(
    id: id ?? this.id,
    timestampMs: timestampMs ?? this.timestampMs,
    score: score ?? this.score,
    tag: tag.present ? tag.value : this.tag,
    note: note.present ? note.value : this.note,
  );
  MoodRow copyWithCompanion(MoodEntriesCompanion data) {
    return MoodRow(
      id: data.id.present ? data.id.value : this.id,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
      score: data.score.present ? data.score.value : this.score,
      tag: data.tag.present ? data.tag.value : this.tag,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodRow(')
          ..write('id: $id, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('score: $score, ')
          ..write('tag: $tag, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timestampMs, score, tag, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodRow &&
          other.id == this.id &&
          other.timestampMs == this.timestampMs &&
          other.score == this.score &&
          other.tag == this.tag &&
          other.note == this.note);
}

class MoodEntriesCompanion extends UpdateCompanion<MoodRow> {
  final Value<int> id;
  final Value<int> timestampMs;
  final Value<int> score;
  final Value<String?> tag;
  final Value<String?> note;
  const MoodEntriesCompanion({
    this.id = const Value.absent(),
    this.timestampMs = const Value.absent(),
    this.score = const Value.absent(),
    this.tag = const Value.absent(),
    this.note = const Value.absent(),
  });
  MoodEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int timestampMs,
    required int score,
    this.tag = const Value.absent(),
    this.note = const Value.absent(),
  }) : timestampMs = Value(timestampMs),
       score = Value(score);
  static Insertable<MoodRow> custom({
    Expression<int>? id,
    Expression<int>? timestampMs,
    Expression<int>? score,
    Expression<String>? tag,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
      if (score != null) 'score': score,
      if (tag != null) 'tag': tag,
      if (note != null) 'note': note,
    });
  }

  MoodEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? timestampMs,
    Value<int>? score,
    Value<String?>? tag,
    Value<String?>? note,
  }) {
    return MoodEntriesCompanion(
      id: id ?? this.id,
      timestampMs: timestampMs ?? this.timestampMs,
      score: score ?? this.score,
      tag: tag ?? this.tag,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodEntriesCompanion(')
          ..write('id: $id, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('score: $score, ')
          ..write('tag: $tag, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $KeyValuesTable extends KeyValues with TableInfo<$KeyValuesTable, KvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValuesTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvRow> instance, {
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
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KeyValuesTable createAlias(String alias) {
    return $KeyValuesTable(attachedDatabase, alias);
  }
}

class KvRow extends DataClass implements Insertable<KvRow> {
  final String key;
  final String value;
  const KvRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KeyValuesCompanion toCompanion(bool nullToAbsent) {
    return KeyValuesCompanion(key: Value(key), value: Value(value));
  }

  factory KvRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KvRow copyWith({String? key, String? value}) =>
      KvRow(key: key ?? this.key, value: value ?? this.value);
  KvRow copyWithCompanion(KeyValuesCompanion data) {
    return KvRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvRow(')
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
      (other is KvRow && other.key == this.key && other.value == this.value);
}

class KeyValuesCompanion extends UpdateCompanion<KvRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KeyValuesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValuesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KvRow> custom({
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

  KeyValuesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KeyValuesCompanion(
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
    return (StringBuffer('KeyValuesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BlockOverridesTable extends BlockOverrides
    with TableInfo<$BlockOverridesTable, BlockOverrideRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlockOverridesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
    'timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpPenaltyMeta = const VerificationMeta(
    'xpPenalty',
  );
  @override
  late final GeneratedColumn<int> xpPenalty = GeneratedColumn<int>(
    'xp_penalty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coinPenaltyMeta = const VerificationMeta(
    'coinPenalty',
  );
  @override
  late final GeneratedColumn<int> coinPenalty = GeneratedColumn<int>(
    'coin_penalty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestampMs,
    packageName,
    mode,
    xpPenalty,
    coinPenalty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'block_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlockOverrideRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('xp_penalty')) {
      context.handle(
        _xpPenaltyMeta,
        xpPenalty.isAcceptableOrUnknown(data['xp_penalty']!, _xpPenaltyMeta),
      );
    }
    if (data.containsKey('coin_penalty')) {
      context.handle(
        _coinPenaltyMeta,
        coinPenalty.isAcceptableOrUnknown(
          data['coin_penalty']!,
          _coinPenaltyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BlockOverrideRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlockOverrideRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_ms'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      xpPenalty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_penalty'],
      )!,
      coinPenalty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coin_penalty'],
      )!,
    );
  }

  @override
  $BlockOverridesTable createAlias(String alias) {
    return $BlockOverridesTable(attachedDatabase, alias);
  }
}

class BlockOverrideRow extends DataClass
    implements Insertable<BlockOverrideRow> {
  final int id;
  final int timestampMs;
  final String packageName;
  final String mode;
  final int xpPenalty;
  final int coinPenalty;
  const BlockOverrideRow({
    required this.id,
    required this.timestampMs,
    required this.packageName,
    required this.mode,
    required this.xpPenalty,
    required this.coinPenalty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp_ms'] = Variable<int>(timestampMs);
    map['package_name'] = Variable<String>(packageName);
    map['mode'] = Variable<String>(mode);
    map['xp_penalty'] = Variable<int>(xpPenalty);
    map['coin_penalty'] = Variable<int>(coinPenalty);
    return map;
  }

  BlockOverridesCompanion toCompanion(bool nullToAbsent) {
    return BlockOverridesCompanion(
      id: Value(id),
      timestampMs: Value(timestampMs),
      packageName: Value(packageName),
      mode: Value(mode),
      xpPenalty: Value(xpPenalty),
      coinPenalty: Value(coinPenalty),
    );
  }

  factory BlockOverrideRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlockOverrideRow(
      id: serializer.fromJson<int>(json['id']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
      packageName: serializer.fromJson<String>(json['packageName']),
      mode: serializer.fromJson<String>(json['mode']),
      xpPenalty: serializer.fromJson<int>(json['xpPenalty']),
      coinPenalty: serializer.fromJson<int>(json['coinPenalty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestampMs': serializer.toJson<int>(timestampMs),
      'packageName': serializer.toJson<String>(packageName),
      'mode': serializer.toJson<String>(mode),
      'xpPenalty': serializer.toJson<int>(xpPenalty),
      'coinPenalty': serializer.toJson<int>(coinPenalty),
    };
  }

  BlockOverrideRow copyWith({
    int? id,
    int? timestampMs,
    String? packageName,
    String? mode,
    int? xpPenalty,
    int? coinPenalty,
  }) => BlockOverrideRow(
    id: id ?? this.id,
    timestampMs: timestampMs ?? this.timestampMs,
    packageName: packageName ?? this.packageName,
    mode: mode ?? this.mode,
    xpPenalty: xpPenalty ?? this.xpPenalty,
    coinPenalty: coinPenalty ?? this.coinPenalty,
  );
  BlockOverrideRow copyWithCompanion(BlockOverridesCompanion data) {
    return BlockOverrideRow(
      id: data.id.present ? data.id.value : this.id,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      mode: data.mode.present ? data.mode.value : this.mode,
      xpPenalty: data.xpPenalty.present ? data.xpPenalty.value : this.xpPenalty,
      coinPenalty: data.coinPenalty.present
          ? data.coinPenalty.value
          : this.coinPenalty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlockOverrideRow(')
          ..write('id: $id, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('packageName: $packageName, ')
          ..write('mode: $mode, ')
          ..write('xpPenalty: $xpPenalty, ')
          ..write('coinPenalty: $coinPenalty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, timestampMs, packageName, mode, xpPenalty, coinPenalty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlockOverrideRow &&
          other.id == this.id &&
          other.timestampMs == this.timestampMs &&
          other.packageName == this.packageName &&
          other.mode == this.mode &&
          other.xpPenalty == this.xpPenalty &&
          other.coinPenalty == this.coinPenalty);
}

class BlockOverridesCompanion extends UpdateCompanion<BlockOverrideRow> {
  final Value<int> id;
  final Value<int> timestampMs;
  final Value<String> packageName;
  final Value<String> mode;
  final Value<int> xpPenalty;
  final Value<int> coinPenalty;
  const BlockOverridesCompanion({
    this.id = const Value.absent(),
    this.timestampMs = const Value.absent(),
    this.packageName = const Value.absent(),
    this.mode = const Value.absent(),
    this.xpPenalty = const Value.absent(),
    this.coinPenalty = const Value.absent(),
  });
  BlockOverridesCompanion.insert({
    this.id = const Value.absent(),
    required int timestampMs,
    required String packageName,
    required String mode,
    this.xpPenalty = const Value.absent(),
    this.coinPenalty = const Value.absent(),
  }) : timestampMs = Value(timestampMs),
       packageName = Value(packageName),
       mode = Value(mode);
  static Insertable<BlockOverrideRow> custom({
    Expression<int>? id,
    Expression<int>? timestampMs,
    Expression<String>? packageName,
    Expression<String>? mode,
    Expression<int>? xpPenalty,
    Expression<int>? coinPenalty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
      if (packageName != null) 'package_name': packageName,
      if (mode != null) 'mode': mode,
      if (xpPenalty != null) 'xp_penalty': xpPenalty,
      if (coinPenalty != null) 'coin_penalty': coinPenalty,
    });
  }

  BlockOverridesCompanion copyWith({
    Value<int>? id,
    Value<int>? timestampMs,
    Value<String>? packageName,
    Value<String>? mode,
    Value<int>? xpPenalty,
    Value<int>? coinPenalty,
  }) {
    return BlockOverridesCompanion(
      id: id ?? this.id,
      timestampMs: timestampMs ?? this.timestampMs,
      packageName: packageName ?? this.packageName,
      mode: mode ?? this.mode,
      xpPenalty: xpPenalty ?? this.xpPenalty,
      coinPenalty: coinPenalty ?? this.coinPenalty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (xpPenalty.present) {
      map['xp_penalty'] = Variable<int>(xpPenalty.value);
    }
    if (coinPenalty.present) {
      map['coin_penalty'] = Variable<int>(coinPenalty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlockOverridesCompanion(')
          ..write('id: $id, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('packageName: $packageName, ')
          ..write('mode: $mode, ')
          ..write('xpPenalty: $xpPenalty, ')
          ..write('coinPenalty: $coinPenalty')
          ..write(')'))
        .toString();
  }
}

class $BlockSchedulesTable extends BlockSchedules
    with TableInfo<$BlockSchedulesTable, BlockScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlockSchedulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysMaskMeta = const VerificationMeta(
    'daysMask',
  );
  @override
  late final GeneratedColumn<int> daysMask = GeneratedColumn<int>(
    'days_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('hard'),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    startMinute,
    endMinute,
    daysMask,
    mode,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'block_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlockScheduleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('days_mask')) {
      context.handle(
        _daysMaskMeta,
        daysMask.isAcceptableOrUnknown(data['days_mask']!, _daysMaskMeta),
      );
    } else if (isInserting) {
      context.missing(_daysMaskMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BlockScheduleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlockScheduleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      )!,
      daysMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_mask'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $BlockSchedulesTable createAlias(String alias) {
    return $BlockSchedulesTable(attachedDatabase, alias);
  }
}

class BlockScheduleRow extends DataClass
    implements Insertable<BlockScheduleRow> {
  final int id;
  final String packageName;
  final int startMinute;
  final int endMinute;
  final int daysMask;
  final String mode;
  final bool enabled;
  const BlockScheduleRow({
    required this.id,
    required this.packageName,
    required this.startMinute,
    required this.endMinute,
    required this.daysMask,
    required this.mode,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_minute'] = Variable<int>(endMinute);
    map['days_mask'] = Variable<int>(daysMask);
    map['mode'] = Variable<String>(mode);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  BlockSchedulesCompanion toCompanion(bool nullToAbsent) {
    return BlockSchedulesCompanion(
      id: Value(id),
      packageName: Value(packageName),
      startMinute: Value(startMinute),
      endMinute: Value(endMinute),
      daysMask: Value(daysMask),
      mode: Value(mode),
      enabled: Value(enabled),
    );
  }

  factory BlockScheduleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlockScheduleRow(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      daysMask: serializer.fromJson<int>(json['daysMask']),
      mode: serializer.fromJson<String>(json['mode']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'startMinute': serializer.toJson<int>(startMinute),
      'endMinute': serializer.toJson<int>(endMinute),
      'daysMask': serializer.toJson<int>(daysMask),
      'mode': serializer.toJson<String>(mode),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  BlockScheduleRow copyWith({
    int? id,
    String? packageName,
    int? startMinute,
    int? endMinute,
    int? daysMask,
    String? mode,
    bool? enabled,
  }) => BlockScheduleRow(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    daysMask: daysMask ?? this.daysMask,
    mode: mode ?? this.mode,
    enabled: enabled ?? this.enabled,
  );
  BlockScheduleRow copyWithCompanion(BlockSchedulesCompanion data) {
    return BlockScheduleRow(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      daysMask: data.daysMask.present ? data.daysMask.value : this.daysMask,
      mode: data.mode.present ? data.mode.value : this.mode,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlockScheduleRow(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('daysMask: $daysMask, ')
          ..write('mode: $mode, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    startMinute,
    endMinute,
    daysMask,
    mode,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlockScheduleRow &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.daysMask == this.daysMask &&
          other.mode == this.mode &&
          other.enabled == this.enabled);
}

class BlockSchedulesCompanion extends UpdateCompanion<BlockScheduleRow> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<int> startMinute;
  final Value<int> endMinute;
  final Value<int> daysMask;
  final Value<String> mode;
  final Value<bool> enabled;
  const BlockSchedulesCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.daysMask = const Value.absent(),
    this.mode = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  BlockSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required int startMinute,
    required int endMinute,
    required int daysMask,
    this.mode = const Value.absent(),
    this.enabled = const Value.absent(),
  }) : packageName = Value(packageName),
       startMinute = Value(startMinute),
       endMinute = Value(endMinute),
       daysMask = Value(daysMask);
  static Insertable<BlockScheduleRow> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<int>? daysMask,
    Expression<String>? mode,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (daysMask != null) 'days_mask': daysMask,
      if (mode != null) 'mode': mode,
      if (enabled != null) 'enabled': enabled,
    });
  }

  BlockSchedulesCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<int>? startMinute,
    Value<int>? endMinute,
    Value<int>? daysMask,
    Value<String>? mode,
    Value<bool>? enabled,
  }) {
    return BlockSchedulesCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      daysMask: daysMask ?? this.daysMask,
      mode: mode ?? this.mode,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (daysMask.present) {
      map['days_mask'] = Variable<int>(daysMask.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlockSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('daysMask: $daysMask, ')
          ..write('mode: $mode, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$WxDatabase extends GeneratedDatabase {
  _$WxDatabase(QueryExecutor e) : super(e);
  $WxDatabaseManager get managers => $WxDatabaseManager(this);
  late final $UsageEventsTable usageEvents = $UsageEventsTable(this);
  late final $NotificationsTableTable notificationsTable =
      $NotificationsTableTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $DailyAggregatesTable dailyAggregates = $DailyAggregatesTable(
    this,
  );
  late final $HourBucketsTable hourBuckets = $HourBucketsTable(this);
  late final $DailyPhoneTable dailyPhone = $DailyPhoneTable(this);
  late final $BehaviorEpisodesTable behaviorEpisodes = $BehaviorEpisodesTable(
    this,
  );
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $BlockRulesTable blockRules = $BlockRulesTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $MissionsTable missions = $MissionsTable(this);
  late final $PurposeUnlocksTable purposeUnlocks = $PurposeUnlocksTable(this);
  late final $MoodEntriesTable moodEntries = $MoodEntriesTable(this);
  late final $KeyValuesTable keyValues = $KeyValuesTable(this);
  late final $BlockOverridesTable blockOverrides = $BlockOverridesTable(this);
  late final $BlockSchedulesTable blockSchedules = $BlockSchedulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    usageEvents,
    notificationsTable,
    appMeta,
    dailyAggregates,
    hourBuckets,
    dailyPhone,
    behaviorEpisodes,
    focusSessions,
    blockRules,
    achievements,
    missions,
    purposeUnlocks,
    moodEntries,
    keyValues,
    blockOverrides,
    blockSchedules,
  ];
}

typedef $$UsageEventsTableCreateCompanionBuilder =
    UsageEventsCompanion Function({
      Value<int> id,
      required String packageName,
      required int eventType,
      required int timestampMs,
      Value<int> durationMs,
      Value<String?> className,
    });
typedef $$UsageEventsTableUpdateCompanionBuilder =
    UsageEventsCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<int> eventType,
      Value<int> timestampMs,
      Value<int> durationMs,
      Value<String?> className,
    });

class $$UsageEventsTableFilterComposer
    extends Composer<_$WxDatabase, $UsageEventsTable> {
  $$UsageEventsTableFilterComposer({
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

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsageEventsTableOrderingComposer
    extends Composer<_$WxDatabase, $UsageEventsTable> {
  $$UsageEventsTableOrderingComposer({
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

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsageEventsTableAnnotationComposer
    extends Composer<_$WxDatabase, $UsageEventsTable> {
  $$UsageEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);
}

class $$UsageEventsTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $UsageEventsTable,
          UsageEventRow,
          $$UsageEventsTableFilterComposer,
          $$UsageEventsTableOrderingComposer,
          $$UsageEventsTableAnnotationComposer,
          $$UsageEventsTableCreateCompanionBuilder,
          $$UsageEventsTableUpdateCompanionBuilder,
          (
            UsageEventRow,
            BaseReferences<_$WxDatabase, $UsageEventsTable, UsageEventRow>,
          ),
          UsageEventRow,
          PrefetchHooks Function()
        > {
  $$UsageEventsTableTableManager(_$WxDatabase db, $UsageEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsageEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsageEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsageEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<int> eventType = const Value.absent(),
                Value<int> timestampMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String?> className = const Value.absent(),
              }) => UsageEventsCompanion(
                id: id,
                packageName: packageName,
                eventType: eventType,
                timestampMs: timestampMs,
                durationMs: durationMs,
                className: className,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required int eventType,
                required int timestampMs,
                Value<int> durationMs = const Value.absent(),
                Value<String?> className = const Value.absent(),
              }) => UsageEventsCompanion.insert(
                id: id,
                packageName: packageName,
                eventType: eventType,
                timestampMs: timestampMs,
                durationMs: durationMs,
                className: className,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsageEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $UsageEventsTable,
      UsageEventRow,
      $$UsageEventsTableFilterComposer,
      $$UsageEventsTableOrderingComposer,
      $$UsageEventsTableAnnotationComposer,
      $$UsageEventsTableCreateCompanionBuilder,
      $$UsageEventsTableUpdateCompanionBuilder,
      (
        UsageEventRow,
        BaseReferences<_$WxDatabase, $UsageEventsTable, UsageEventRow>,
      ),
      UsageEventRow,
      PrefetchHooks Function()
    >;
typedef $$NotificationsTableTableCreateCompanionBuilder =
    NotificationsTableCompanion Function({
      Value<int> id,
      required String packageName,
      required int timestampMs,
    });
typedef $$NotificationsTableTableUpdateCompanionBuilder =
    NotificationsTableCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<int> timestampMs,
    });

class $$NotificationsTableTableFilterComposer
    extends Composer<_$WxDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableFilterComposer({
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

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsTableTableOrderingComposer
    extends Composer<_$WxDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableOrderingComposer({
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

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsTableTableAnnotationComposer
    extends Composer<_$WxDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );
}

class $$NotificationsTableTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $NotificationsTableTable,
          NotificationRow,
          $$NotificationsTableTableFilterComposer,
          $$NotificationsTableTableOrderingComposer,
          $$NotificationsTableTableAnnotationComposer,
          $$NotificationsTableTableCreateCompanionBuilder,
          $$NotificationsTableTableUpdateCompanionBuilder,
          (
            NotificationRow,
            BaseReferences<
              _$WxDatabase,
              $NotificationsTableTable,
              NotificationRow
            >,
          ),
          NotificationRow,
          PrefetchHooks Function()
        > {
  $$NotificationsTableTableTableManager(
    _$WxDatabase db,
    $NotificationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<int> timestampMs = const Value.absent(),
              }) => NotificationsTableCompanion(
                id: id,
                packageName: packageName,
                timestampMs: timestampMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required int timestampMs,
              }) => NotificationsTableCompanion.insert(
                id: id,
                packageName: packageName,
                timestampMs: timestampMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $NotificationsTableTable,
      NotificationRow,
      $$NotificationsTableTableFilterComposer,
      $$NotificationsTableTableOrderingComposer,
      $$NotificationsTableTableAnnotationComposer,
      $$NotificationsTableTableCreateCompanionBuilder,
      $$NotificationsTableTableUpdateCompanionBuilder,
      (
        NotificationRow,
        BaseReferences<_$WxDatabase, $NotificationsTableTable, NotificationRow>,
      ),
      NotificationRow,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String packageName,
      required String displayName,
      Value<String> category,
      Value<bool> isUserOverride,
      Value<int> installedAtMs,
      Value<String?> iconBase64,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> packageName,
      Value<String> displayName,
      Value<String> category,
      Value<bool> isUserOverride,
      Value<int> installedAtMs,
      Value<String?> iconBase64,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$WxDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUserOverride => $composableBuilder(
    column: $table.isUserOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installedAtMs => $composableBuilder(
    column: $table.installedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconBase64 => $composableBuilder(
    column: $table.iconBase64,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$WxDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUserOverride => $composableBuilder(
    column: $table.isUserOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installedAtMs => $composableBuilder(
    column: $table.installedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconBase64 => $composableBuilder(
    column: $table.iconBase64,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$WxDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isUserOverride => $composableBuilder(
    column: $table.isUserOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installedAtMs => $composableBuilder(
    column: $table.installedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconBase64 => $composableBuilder(
    column: $table.iconBase64,
    builder: (column) => column,
  );
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $AppMetaTable,
          AppMetaRow,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (AppMetaRow, BaseReferences<_$WxDatabase, $AppMetaTable, AppMetaRow>),
          AppMetaRow,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$WxDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> packageName = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isUserOverride = const Value.absent(),
                Value<int> installedAtMs = const Value.absent(),
                Value<String?> iconBase64 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(
                packageName: packageName,
                displayName: displayName,
                category: category,
                isUserOverride: isUserOverride,
                installedAtMs: installedAtMs,
                iconBase64: iconBase64,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packageName,
                required String displayName,
                Value<String> category = const Value.absent(),
                Value<bool> isUserOverride = const Value.absent(),
                Value<int> installedAtMs = const Value.absent(),
                Value<String?> iconBase64 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion.insert(
                packageName: packageName,
                displayName: displayName,
                category: category,
                isUserOverride: isUserOverride,
                installedAtMs: installedAtMs,
                iconBase64: iconBase64,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $AppMetaTable,
      AppMetaRow,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaRow, BaseReferences<_$WxDatabase, $AppMetaTable, AppMetaRow>),
      AppMetaRow,
      PrefetchHooks Function()
    >;
typedef $$DailyAggregatesTableCreateCompanionBuilder =
    DailyAggregatesCompanion Function({
      required int dayEpoch,
      required String packageName,
      Value<int> foregroundMs,
      Value<int> opens,
      Value<int> notifications,
      Value<int> rowid,
    });
typedef $$DailyAggregatesTableUpdateCompanionBuilder =
    DailyAggregatesCompanion Function({
      Value<int> dayEpoch,
      Value<String> packageName,
      Value<int> foregroundMs,
      Value<int> opens,
      Value<int> notifications,
      Value<int> rowid,
    });

class $$DailyAggregatesTableFilterComposer
    extends Composer<_$WxDatabase, $DailyAggregatesTable> {
  $$DailyAggregatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dayEpoch => $composableBuilder(
    column: $table.dayEpoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get opens => $composableBuilder(
    column: $table.opens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyAggregatesTableOrderingComposer
    extends Composer<_$WxDatabase, $DailyAggregatesTable> {
  $$DailyAggregatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dayEpoch => $composableBuilder(
    column: $table.dayEpoch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get opens => $composableBuilder(
    column: $table.opens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyAggregatesTableAnnotationComposer
    extends Composer<_$WxDatabase, $DailyAggregatesTable> {
  $$DailyAggregatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dayEpoch =>
      $composableBuilder(column: $table.dayEpoch, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get opens =>
      $composableBuilder(column: $table.opens, builder: (column) => column);

  GeneratedColumn<int> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => column,
  );
}

class $$DailyAggregatesTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $DailyAggregatesTable,
          DailyAggRow,
          $$DailyAggregatesTableFilterComposer,
          $$DailyAggregatesTableOrderingComposer,
          $$DailyAggregatesTableAnnotationComposer,
          $$DailyAggregatesTableCreateCompanionBuilder,
          $$DailyAggregatesTableUpdateCompanionBuilder,
          (
            DailyAggRow,
            BaseReferences<_$WxDatabase, $DailyAggregatesTable, DailyAggRow>,
          ),
          DailyAggRow,
          PrefetchHooks Function()
        > {
  $$DailyAggregatesTableTableManager(
    _$WxDatabase db,
    $DailyAggregatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyAggregatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyAggregatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyAggregatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> dayEpoch = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<int> foregroundMs = const Value.absent(),
                Value<int> opens = const Value.absent(),
                Value<int> notifications = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyAggregatesCompanion(
                dayEpoch: dayEpoch,
                packageName: packageName,
                foregroundMs: foregroundMs,
                opens: opens,
                notifications: notifications,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int dayEpoch,
                required String packageName,
                Value<int> foregroundMs = const Value.absent(),
                Value<int> opens = const Value.absent(),
                Value<int> notifications = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyAggregatesCompanion.insert(
                dayEpoch: dayEpoch,
                packageName: packageName,
                foregroundMs: foregroundMs,
                opens: opens,
                notifications: notifications,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyAggregatesTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $DailyAggregatesTable,
      DailyAggRow,
      $$DailyAggregatesTableFilterComposer,
      $$DailyAggregatesTableOrderingComposer,
      $$DailyAggregatesTableAnnotationComposer,
      $$DailyAggregatesTableCreateCompanionBuilder,
      $$DailyAggregatesTableUpdateCompanionBuilder,
      (
        DailyAggRow,
        BaseReferences<_$WxDatabase, $DailyAggregatesTable, DailyAggRow>,
      ),
      DailyAggRow,
      PrefetchHooks Function()
    >;
typedef $$HourBucketsTableCreateCompanionBuilder =
    HourBucketsCompanion Function({
      required int dayEpoch,
      required int hour,
      Value<int> foregroundMs,
      Value<int> unlocks,
      Value<int> pickups,
      Value<int> rowid,
    });
typedef $$HourBucketsTableUpdateCompanionBuilder =
    HourBucketsCompanion Function({
      Value<int> dayEpoch,
      Value<int> hour,
      Value<int> foregroundMs,
      Value<int> unlocks,
      Value<int> pickups,
      Value<int> rowid,
    });

class $$HourBucketsTableFilterComposer
    extends Composer<_$WxDatabase, $HourBucketsTable> {
  $$HourBucketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dayEpoch => $composableBuilder(
    column: $table.dayEpoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlocks => $composableBuilder(
    column: $table.unlocks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pickups => $composableBuilder(
    column: $table.pickups,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HourBucketsTableOrderingComposer
    extends Composer<_$WxDatabase, $HourBucketsTable> {
  $$HourBucketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dayEpoch => $composableBuilder(
    column: $table.dayEpoch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlocks => $composableBuilder(
    column: $table.unlocks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pickups => $composableBuilder(
    column: $table.pickups,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HourBucketsTableAnnotationComposer
    extends Composer<_$WxDatabase, $HourBucketsTable> {
  $$HourBucketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dayEpoch =>
      $composableBuilder(column: $table.dayEpoch, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unlocks =>
      $composableBuilder(column: $table.unlocks, builder: (column) => column);

  GeneratedColumn<int> get pickups =>
      $composableBuilder(column: $table.pickups, builder: (column) => column);
}

class $$HourBucketsTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $HourBucketsTable,
          HourBucketRow,
          $$HourBucketsTableFilterComposer,
          $$HourBucketsTableOrderingComposer,
          $$HourBucketsTableAnnotationComposer,
          $$HourBucketsTableCreateCompanionBuilder,
          $$HourBucketsTableUpdateCompanionBuilder,
          (
            HourBucketRow,
            BaseReferences<_$WxDatabase, $HourBucketsTable, HourBucketRow>,
          ),
          HourBucketRow,
          PrefetchHooks Function()
        > {
  $$HourBucketsTableTableManager(_$WxDatabase db, $HourBucketsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HourBucketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HourBucketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HourBucketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> dayEpoch = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> foregroundMs = const Value.absent(),
                Value<int> unlocks = const Value.absent(),
                Value<int> pickups = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HourBucketsCompanion(
                dayEpoch: dayEpoch,
                hour: hour,
                foregroundMs: foregroundMs,
                unlocks: unlocks,
                pickups: pickups,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int dayEpoch,
                required int hour,
                Value<int> foregroundMs = const Value.absent(),
                Value<int> unlocks = const Value.absent(),
                Value<int> pickups = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HourBucketsCompanion.insert(
                dayEpoch: dayEpoch,
                hour: hour,
                foregroundMs: foregroundMs,
                unlocks: unlocks,
                pickups: pickups,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HourBucketsTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $HourBucketsTable,
      HourBucketRow,
      $$HourBucketsTableFilterComposer,
      $$HourBucketsTableOrderingComposer,
      $$HourBucketsTableAnnotationComposer,
      $$HourBucketsTableCreateCompanionBuilder,
      $$HourBucketsTableUpdateCompanionBuilder,
      (
        HourBucketRow,
        BaseReferences<_$WxDatabase, $HourBucketsTable, HourBucketRow>,
      ),
      HourBucketRow,
      PrefetchHooks Function()
    >;
typedef $$DailyPhoneTableCreateCompanionBuilder =
    DailyPhoneCompanion Function({
      Value<int> dayEpoch,
      Value<int> unlocks,
      Value<int> screenOnMs,
      Value<int> pickups,
      Value<int> shortUnlocks,
      Value<int> sleepMisuseMs,
      Value<int?> firstUnlockMs,
      Value<int?> lastUnlockMs,
      Value<int> longestSessionMs,
      Value<int> longestScreenOffMs,
      Value<int> bingeCount,
      Value<String?> firstAppPkg,
      Value<String?> lastAppPkg,
    });
typedef $$DailyPhoneTableUpdateCompanionBuilder =
    DailyPhoneCompanion Function({
      Value<int> dayEpoch,
      Value<int> unlocks,
      Value<int> screenOnMs,
      Value<int> pickups,
      Value<int> shortUnlocks,
      Value<int> sleepMisuseMs,
      Value<int?> firstUnlockMs,
      Value<int?> lastUnlockMs,
      Value<int> longestSessionMs,
      Value<int> longestScreenOffMs,
      Value<int> bingeCount,
      Value<String?> firstAppPkg,
      Value<String?> lastAppPkg,
    });

class $$DailyPhoneTableFilterComposer
    extends Composer<_$WxDatabase, $DailyPhoneTable> {
  $$DailyPhoneTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dayEpoch => $composableBuilder(
    column: $table.dayEpoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlocks => $composableBuilder(
    column: $table.unlocks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get screenOnMs => $composableBuilder(
    column: $table.screenOnMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pickups => $composableBuilder(
    column: $table.pickups,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shortUnlocks => $composableBuilder(
    column: $table.shortUnlocks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepMisuseMs => $composableBuilder(
    column: $table.sleepMisuseMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstUnlockMs => $composableBuilder(
    column: $table.firstUnlockMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUnlockMs => $composableBuilder(
    column: $table.lastUnlockMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestSessionMs => $composableBuilder(
    column: $table.longestSessionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestScreenOffMs => $composableBuilder(
    column: $table.longestScreenOffMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bingeCount => $composableBuilder(
    column: $table.bingeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstAppPkg => $composableBuilder(
    column: $table.firstAppPkg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastAppPkg => $composableBuilder(
    column: $table.lastAppPkg,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyPhoneTableOrderingComposer
    extends Composer<_$WxDatabase, $DailyPhoneTable> {
  $$DailyPhoneTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dayEpoch => $composableBuilder(
    column: $table.dayEpoch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlocks => $composableBuilder(
    column: $table.unlocks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get screenOnMs => $composableBuilder(
    column: $table.screenOnMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pickups => $composableBuilder(
    column: $table.pickups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shortUnlocks => $composableBuilder(
    column: $table.shortUnlocks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepMisuseMs => $composableBuilder(
    column: $table.sleepMisuseMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstUnlockMs => $composableBuilder(
    column: $table.firstUnlockMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUnlockMs => $composableBuilder(
    column: $table.lastUnlockMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestSessionMs => $composableBuilder(
    column: $table.longestSessionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestScreenOffMs => $composableBuilder(
    column: $table.longestScreenOffMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bingeCount => $composableBuilder(
    column: $table.bingeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstAppPkg => $composableBuilder(
    column: $table.firstAppPkg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastAppPkg => $composableBuilder(
    column: $table.lastAppPkg,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyPhoneTableAnnotationComposer
    extends Composer<_$WxDatabase, $DailyPhoneTable> {
  $$DailyPhoneTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dayEpoch =>
      $composableBuilder(column: $table.dayEpoch, builder: (column) => column);

  GeneratedColumn<int> get unlocks =>
      $composableBuilder(column: $table.unlocks, builder: (column) => column);

  GeneratedColumn<int> get screenOnMs => $composableBuilder(
    column: $table.screenOnMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pickups =>
      $composableBuilder(column: $table.pickups, builder: (column) => column);

  GeneratedColumn<int> get shortUnlocks => $composableBuilder(
    column: $table.shortUnlocks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepMisuseMs => $composableBuilder(
    column: $table.sleepMisuseMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstUnlockMs => $composableBuilder(
    column: $table.firstUnlockMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastUnlockMs => $composableBuilder(
    column: $table.lastUnlockMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestSessionMs => $composableBuilder(
    column: $table.longestSessionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestScreenOffMs => $composableBuilder(
    column: $table.longestScreenOffMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bingeCount => $composableBuilder(
    column: $table.bingeCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstAppPkg => $composableBuilder(
    column: $table.firstAppPkg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastAppPkg => $composableBuilder(
    column: $table.lastAppPkg,
    builder: (column) => column,
  );
}

class $$DailyPhoneTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $DailyPhoneTable,
          DailyPhoneRow,
          $$DailyPhoneTableFilterComposer,
          $$DailyPhoneTableOrderingComposer,
          $$DailyPhoneTableAnnotationComposer,
          $$DailyPhoneTableCreateCompanionBuilder,
          $$DailyPhoneTableUpdateCompanionBuilder,
          (
            DailyPhoneRow,
            BaseReferences<_$WxDatabase, $DailyPhoneTable, DailyPhoneRow>,
          ),
          DailyPhoneRow,
          PrefetchHooks Function()
        > {
  $$DailyPhoneTableTableManager(_$WxDatabase db, $DailyPhoneTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyPhoneTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyPhoneTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyPhoneTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> dayEpoch = const Value.absent(),
                Value<int> unlocks = const Value.absent(),
                Value<int> screenOnMs = const Value.absent(),
                Value<int> pickups = const Value.absent(),
                Value<int> shortUnlocks = const Value.absent(),
                Value<int> sleepMisuseMs = const Value.absent(),
                Value<int?> firstUnlockMs = const Value.absent(),
                Value<int?> lastUnlockMs = const Value.absent(),
                Value<int> longestSessionMs = const Value.absent(),
                Value<int> longestScreenOffMs = const Value.absent(),
                Value<int> bingeCount = const Value.absent(),
                Value<String?> firstAppPkg = const Value.absent(),
                Value<String?> lastAppPkg = const Value.absent(),
              }) => DailyPhoneCompanion(
                dayEpoch: dayEpoch,
                unlocks: unlocks,
                screenOnMs: screenOnMs,
                pickups: pickups,
                shortUnlocks: shortUnlocks,
                sleepMisuseMs: sleepMisuseMs,
                firstUnlockMs: firstUnlockMs,
                lastUnlockMs: lastUnlockMs,
                longestSessionMs: longestSessionMs,
                longestScreenOffMs: longestScreenOffMs,
                bingeCount: bingeCount,
                firstAppPkg: firstAppPkg,
                lastAppPkg: lastAppPkg,
              ),
          createCompanionCallback:
              ({
                Value<int> dayEpoch = const Value.absent(),
                Value<int> unlocks = const Value.absent(),
                Value<int> screenOnMs = const Value.absent(),
                Value<int> pickups = const Value.absent(),
                Value<int> shortUnlocks = const Value.absent(),
                Value<int> sleepMisuseMs = const Value.absent(),
                Value<int?> firstUnlockMs = const Value.absent(),
                Value<int?> lastUnlockMs = const Value.absent(),
                Value<int> longestSessionMs = const Value.absent(),
                Value<int> longestScreenOffMs = const Value.absent(),
                Value<int> bingeCount = const Value.absent(),
                Value<String?> firstAppPkg = const Value.absent(),
                Value<String?> lastAppPkg = const Value.absent(),
              }) => DailyPhoneCompanion.insert(
                dayEpoch: dayEpoch,
                unlocks: unlocks,
                screenOnMs: screenOnMs,
                pickups: pickups,
                shortUnlocks: shortUnlocks,
                sleepMisuseMs: sleepMisuseMs,
                firstUnlockMs: firstUnlockMs,
                lastUnlockMs: lastUnlockMs,
                longestSessionMs: longestSessionMs,
                longestScreenOffMs: longestScreenOffMs,
                bingeCount: bingeCount,
                firstAppPkg: firstAppPkg,
                lastAppPkg: lastAppPkg,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyPhoneTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $DailyPhoneTable,
      DailyPhoneRow,
      $$DailyPhoneTableFilterComposer,
      $$DailyPhoneTableOrderingComposer,
      $$DailyPhoneTableAnnotationComposer,
      $$DailyPhoneTableCreateCompanionBuilder,
      $$DailyPhoneTableUpdateCompanionBuilder,
      (
        DailyPhoneRow,
        BaseReferences<_$WxDatabase, $DailyPhoneTable, DailyPhoneRow>,
      ),
      DailyPhoneRow,
      PrefetchHooks Function()
    >;
typedef $$BehaviorEpisodesTableCreateCompanionBuilder =
    BehaviorEpisodesCompanion Function({
      Value<int> id,
      required int startedAtMs,
      required int endedAtMs,
      required String appPackage,
      Value<int> interactionCount,
      Value<int> unlockCount,
      Value<bool> notificationTriggered,
      Value<int> appSwitches,
      Value<int> passiveDurationMs,
      Value<int> activeDurationMs,
      Value<int> interruptionCount,
      Value<String> classification,
    });
typedef $$BehaviorEpisodesTableUpdateCompanionBuilder =
    BehaviorEpisodesCompanion Function({
      Value<int> id,
      Value<int> startedAtMs,
      Value<int> endedAtMs,
      Value<String> appPackage,
      Value<int> interactionCount,
      Value<int> unlockCount,
      Value<bool> notificationTriggered,
      Value<int> appSwitches,
      Value<int> passiveDurationMs,
      Value<int> activeDurationMs,
      Value<int> interruptionCount,
      Value<String> classification,
    });

class $$BehaviorEpisodesTableFilterComposer
    extends Composer<_$WxDatabase, $BehaviorEpisodesTable> {
  $$BehaviorEpisodesTableFilterComposer({
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

  ColumnFilters<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appPackage => $composableBuilder(
    column: $table.appPackage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interactionCount => $composableBuilder(
    column: $table.interactionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlockCount => $composableBuilder(
    column: $table.unlockCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationTriggered => $composableBuilder(
    column: $table.notificationTriggered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get appSwitches => $composableBuilder(
    column: $table.appSwitches,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passiveDurationMs => $composableBuilder(
    column: $table.passiveDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeDurationMs => $composableBuilder(
    column: $table.activeDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interruptionCount => $composableBuilder(
    column: $table.interruptionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BehaviorEpisodesTableOrderingComposer
    extends Composer<_$WxDatabase, $BehaviorEpisodesTable> {
  $$BehaviorEpisodesTableOrderingComposer({
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

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appPackage => $composableBuilder(
    column: $table.appPackage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interactionCount => $composableBuilder(
    column: $table.interactionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlockCount => $composableBuilder(
    column: $table.unlockCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationTriggered => $composableBuilder(
    column: $table.notificationTriggered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appSwitches => $composableBuilder(
    column: $table.appSwitches,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passiveDurationMs => $composableBuilder(
    column: $table.passiveDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeDurationMs => $composableBuilder(
    column: $table.activeDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interruptionCount => $composableBuilder(
    column: $table.interruptionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BehaviorEpisodesTableAnnotationComposer
    extends Composer<_$WxDatabase, $BehaviorEpisodesTable> {
  $$BehaviorEpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAtMs =>
      $composableBuilder(column: $table.endedAtMs, builder: (column) => column);

  GeneratedColumn<String> get appPackage => $composableBuilder(
    column: $table.appPackage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get interactionCount => $composableBuilder(
    column: $table.interactionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unlockCount => $composableBuilder(
    column: $table.unlockCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationTriggered => $composableBuilder(
    column: $table.notificationTriggered,
    builder: (column) => column,
  );

  GeneratedColumn<int> get appSwitches => $composableBuilder(
    column: $table.appSwitches,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passiveDurationMs => $composableBuilder(
    column: $table.passiveDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeDurationMs => $composableBuilder(
    column: $table.activeDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get interruptionCount => $composableBuilder(
    column: $table.interruptionCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => column,
  );
}

class $$BehaviorEpisodesTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $BehaviorEpisodesTable,
          BehaviorEpisodeRow,
          $$BehaviorEpisodesTableFilterComposer,
          $$BehaviorEpisodesTableOrderingComposer,
          $$BehaviorEpisodesTableAnnotationComposer,
          $$BehaviorEpisodesTableCreateCompanionBuilder,
          $$BehaviorEpisodesTableUpdateCompanionBuilder,
          (
            BehaviorEpisodeRow,
            BaseReferences<
              _$WxDatabase,
              $BehaviorEpisodesTable,
              BehaviorEpisodeRow
            >,
          ),
          BehaviorEpisodeRow,
          PrefetchHooks Function()
        > {
  $$BehaviorEpisodesTableTableManager(
    _$WxDatabase db,
    $BehaviorEpisodesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BehaviorEpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BehaviorEpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BehaviorEpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> startedAtMs = const Value.absent(),
                Value<int> endedAtMs = const Value.absent(),
                Value<String> appPackage = const Value.absent(),
                Value<int> interactionCount = const Value.absent(),
                Value<int> unlockCount = const Value.absent(),
                Value<bool> notificationTriggered = const Value.absent(),
                Value<int> appSwitches = const Value.absent(),
                Value<int> passiveDurationMs = const Value.absent(),
                Value<int> activeDurationMs = const Value.absent(),
                Value<int> interruptionCount = const Value.absent(),
                Value<String> classification = const Value.absent(),
              }) => BehaviorEpisodesCompanion(
                id: id,
                startedAtMs: startedAtMs,
                endedAtMs: endedAtMs,
                appPackage: appPackage,
                interactionCount: interactionCount,
                unlockCount: unlockCount,
                notificationTriggered: notificationTriggered,
                appSwitches: appSwitches,
                passiveDurationMs: passiveDurationMs,
                activeDurationMs: activeDurationMs,
                interruptionCount: interruptionCount,
                classification: classification,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int startedAtMs,
                required int endedAtMs,
                required String appPackage,
                Value<int> interactionCount = const Value.absent(),
                Value<int> unlockCount = const Value.absent(),
                Value<bool> notificationTriggered = const Value.absent(),
                Value<int> appSwitches = const Value.absent(),
                Value<int> passiveDurationMs = const Value.absent(),
                Value<int> activeDurationMs = const Value.absent(),
                Value<int> interruptionCount = const Value.absent(),
                Value<String> classification = const Value.absent(),
              }) => BehaviorEpisodesCompanion.insert(
                id: id,
                startedAtMs: startedAtMs,
                endedAtMs: endedAtMs,
                appPackage: appPackage,
                interactionCount: interactionCount,
                unlockCount: unlockCount,
                notificationTriggered: notificationTriggered,
                appSwitches: appSwitches,
                passiveDurationMs: passiveDurationMs,
                activeDurationMs: activeDurationMs,
                interruptionCount: interruptionCount,
                classification: classification,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BehaviorEpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $BehaviorEpisodesTable,
      BehaviorEpisodeRow,
      $$BehaviorEpisodesTableFilterComposer,
      $$BehaviorEpisodesTableOrderingComposer,
      $$BehaviorEpisodesTableAnnotationComposer,
      $$BehaviorEpisodesTableCreateCompanionBuilder,
      $$BehaviorEpisodesTableUpdateCompanionBuilder,
      (
        BehaviorEpisodeRow,
        BaseReferences<
          _$WxDatabase,
          $BehaviorEpisodesTable,
          BehaviorEpisodeRow
        >,
      ),
      BehaviorEpisodeRow,
      PrefetchHooks Function()
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      required int startedMs,
      required int plannedMs,
      Value<int> actualMs,
      Value<String> mode,
      Value<String?> tag,
      Value<bool> completed,
      Value<int> xpAwarded,
      Value<int> coinsAwarded,
      Value<int> interruptions,
      Value<int> productivityScore,
      Value<String?> note,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      Value<int> startedMs,
      Value<int> plannedMs,
      Value<int> actualMs,
      Value<String> mode,
      Value<String?> tag,
      Value<bool> completed,
      Value<int> xpAwarded,
      Value<int> coinsAwarded,
      Value<int> interruptions,
      Value<int> productivityScore,
      Value<String?> note,
    });

class $$FocusSessionsTableFilterComposer
    extends Composer<_$WxDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
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

  ColumnFilters<int> get startedMs => $composableBuilder(
    column: $table.startedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedMs => $composableBuilder(
    column: $table.plannedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualMs => $composableBuilder(
    column: $table.actualMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpAwarded => $composableBuilder(
    column: $table.xpAwarded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coinsAwarded => $composableBuilder(
    column: $table.coinsAwarded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interruptions => $composableBuilder(
    column: $table.interruptions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productivityScore => $composableBuilder(
    column: $table.productivityScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$WxDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
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

  ColumnOrderings<int> get startedMs => $composableBuilder(
    column: $table.startedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedMs => $composableBuilder(
    column: $table.plannedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualMs => $composableBuilder(
    column: $table.actualMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpAwarded => $composableBuilder(
    column: $table.xpAwarded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coinsAwarded => $composableBuilder(
    column: $table.coinsAwarded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interruptions => $composableBuilder(
    column: $table.interruptions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productivityScore => $composableBuilder(
    column: $table.productivityScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$WxDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedMs =>
      $composableBuilder(column: $table.startedMs, builder: (column) => column);

  GeneratedColumn<int> get plannedMs =>
      $composableBuilder(column: $table.plannedMs, builder: (column) => column);

  GeneratedColumn<int> get actualMs =>
      $composableBuilder(column: $table.actualMs, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<int> get xpAwarded =>
      $composableBuilder(column: $table.xpAwarded, builder: (column) => column);

  GeneratedColumn<int> get coinsAwarded => $composableBuilder(
    column: $table.coinsAwarded,
    builder: (column) => column,
  );

  GeneratedColumn<int> get interruptions => $composableBuilder(
    column: $table.interruptions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get productivityScore => $composableBuilder(
    column: $table.productivityScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $FocusSessionsTable,
          FocusSessionRow,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (
            FocusSessionRow,
            BaseReferences<_$WxDatabase, $FocusSessionsTable, FocusSessionRow>,
          ),
          FocusSessionRow,
          PrefetchHooks Function()
        > {
  $$FocusSessionsTableTableManager(_$WxDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> startedMs = const Value.absent(),
                Value<int> plannedMs = const Value.absent(),
                Value<int> actualMs = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String?> tag = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> xpAwarded = const Value.absent(),
                Value<int> coinsAwarded = const Value.absent(),
                Value<int> interruptions = const Value.absent(),
                Value<int> productivityScore = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                startedMs: startedMs,
                plannedMs: plannedMs,
                actualMs: actualMs,
                mode: mode,
                tag: tag,
                completed: completed,
                xpAwarded: xpAwarded,
                coinsAwarded: coinsAwarded,
                interruptions: interruptions,
                productivityScore: productivityScore,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int startedMs,
                required int plannedMs,
                Value<int> actualMs = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String?> tag = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> xpAwarded = const Value.absent(),
                Value<int> coinsAwarded = const Value.absent(),
                Value<int> interruptions = const Value.absent(),
                Value<int> productivityScore = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                startedMs: startedMs,
                plannedMs: plannedMs,
                actualMs: actualMs,
                mode: mode,
                tag: tag,
                completed: completed,
                xpAwarded: xpAwarded,
                coinsAwarded: coinsAwarded,
                interruptions: interruptions,
                productivityScore: productivityScore,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $FocusSessionsTable,
      FocusSessionRow,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (
        FocusSessionRow,
        BaseReferences<_$WxDatabase, $FocusSessionsTable, FocusSessionRow>,
      ),
      FocusSessionRow,
      PrefetchHooks Function()
    >;
typedef $$BlockRulesTableCreateCompanionBuilder =
    BlockRulesCompanion Function({
      Value<int> id,
      required String packageName,
      required String mode,
      Value<int?> untilMs,
      Value<int?> dailyLimitMs,
      Value<bool> enabled,
      required int createdMs,
    });
typedef $$BlockRulesTableUpdateCompanionBuilder =
    BlockRulesCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<String> mode,
      Value<int?> untilMs,
      Value<int?> dailyLimitMs,
      Value<bool> enabled,
      Value<int> createdMs,
    });

class $$BlockRulesTableFilterComposer
    extends Composer<_$WxDatabase, $BlockRulesTable> {
  $$BlockRulesTableFilterComposer({
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

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get untilMs => $composableBuilder(
    column: $table.untilMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyLimitMs => $composableBuilder(
    column: $table.dailyLimitMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdMs => $composableBuilder(
    column: $table.createdMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BlockRulesTableOrderingComposer
    extends Composer<_$WxDatabase, $BlockRulesTable> {
  $$BlockRulesTableOrderingComposer({
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

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get untilMs => $composableBuilder(
    column: $table.untilMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyLimitMs => $composableBuilder(
    column: $table.dailyLimitMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdMs => $composableBuilder(
    column: $table.createdMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BlockRulesTableAnnotationComposer
    extends Composer<_$WxDatabase, $BlockRulesTable> {
  $$BlockRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get untilMs =>
      $composableBuilder(column: $table.untilMs, builder: (column) => column);

  GeneratedColumn<int> get dailyLimitMs => $composableBuilder(
    column: $table.dailyLimitMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get createdMs =>
      $composableBuilder(column: $table.createdMs, builder: (column) => column);
}

class $$BlockRulesTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $BlockRulesTable,
          BlockRuleRow,
          $$BlockRulesTableFilterComposer,
          $$BlockRulesTableOrderingComposer,
          $$BlockRulesTableAnnotationComposer,
          $$BlockRulesTableCreateCompanionBuilder,
          $$BlockRulesTableUpdateCompanionBuilder,
          (
            BlockRuleRow,
            BaseReferences<_$WxDatabase, $BlockRulesTable, BlockRuleRow>,
          ),
          BlockRuleRow,
          PrefetchHooks Function()
        > {
  $$BlockRulesTableTableManager(_$WxDatabase db, $BlockRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlockRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlockRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlockRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int?> untilMs = const Value.absent(),
                Value<int?> dailyLimitMs = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> createdMs = const Value.absent(),
              }) => BlockRulesCompanion(
                id: id,
                packageName: packageName,
                mode: mode,
                untilMs: untilMs,
                dailyLimitMs: dailyLimitMs,
                enabled: enabled,
                createdMs: createdMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required String mode,
                Value<int?> untilMs = const Value.absent(),
                Value<int?> dailyLimitMs = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                required int createdMs,
              }) => BlockRulesCompanion.insert(
                id: id,
                packageName: packageName,
                mode: mode,
                untilMs: untilMs,
                dailyLimitMs: dailyLimitMs,
                enabled: enabled,
                createdMs: createdMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BlockRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $BlockRulesTable,
      BlockRuleRow,
      $$BlockRulesTableFilterComposer,
      $$BlockRulesTableOrderingComposer,
      $$BlockRulesTableAnnotationComposer,
      $$BlockRulesTableCreateCompanionBuilder,
      $$BlockRulesTableUpdateCompanionBuilder,
      (
        BlockRuleRow,
        BaseReferences<_$WxDatabase, $BlockRulesTable, BlockRuleRow>,
      ),
      BlockRuleRow,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      required String code,
      required int unlockedAtMs,
      Value<int> progress,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String> code,
      Value<int> unlockedAtMs,
      Value<int> progress,
      Value<int> rowid,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$WxDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlockedAtMs => $composableBuilder(
    column: $table.unlockedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$WxDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlockedAtMs => $composableBuilder(
    column: $table.unlockedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$WxDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get unlockedAtMs => $composableBuilder(
    column: $table.unlockedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $AchievementsTable,
          AchievementRow,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            AchievementRow,
            BaseReferences<_$WxDatabase, $AchievementsTable, AchievementRow>,
          ),
          AchievementRow,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$WxDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<int> unlockedAtMs = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                code: code,
                unlockedAtMs: unlockedAtMs,
                progress: progress,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required int unlockedAtMs,
                Value<int> progress = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                code: code,
                unlockedAtMs: unlockedAtMs,
                progress: progress,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $AchievementsTable,
      AchievementRow,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        AchievementRow,
        BaseReferences<_$WxDatabase, $AchievementsTable, AchievementRow>,
      ),
      AchievementRow,
      PrefetchHooks Function()
    >;
typedef $$MissionsTableCreateCompanionBuilder =
    MissionsCompanion Function({
      Value<int> id,
      required int dayEpoch,
      required String code,
      required String title,
      required String description,
      required int target,
      Value<int> progress,
      required int xpReward,
      required int coinsReward,
      Value<bool> completed,
      Value<bool> claimed,
    });
typedef $$MissionsTableUpdateCompanionBuilder =
    MissionsCompanion Function({
      Value<int> id,
      Value<int> dayEpoch,
      Value<String> code,
      Value<String> title,
      Value<String> description,
      Value<int> target,
      Value<int> progress,
      Value<int> xpReward,
      Value<int> coinsReward,
      Value<bool> completed,
      Value<bool> claimed,
    });

class $$MissionsTableFilterComposer
    extends Composer<_$WxDatabase, $MissionsTable> {
  $$MissionsTableFilterComposer({
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

  ColumnFilters<int> get dayEpoch => $composableBuilder(
    column: $table.dayEpoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
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

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coinsReward => $composableBuilder(
    column: $table.coinsReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get claimed => $composableBuilder(
    column: $table.claimed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MissionsTableOrderingComposer
    extends Composer<_$WxDatabase, $MissionsTable> {
  $$MissionsTableOrderingComposer({
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

  ColumnOrderings<int> get dayEpoch => $composableBuilder(
    column: $table.dayEpoch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
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

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coinsReward => $composableBuilder(
    column: $table.coinsReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get claimed => $composableBuilder(
    column: $table.claimed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MissionsTableAnnotationComposer
    extends Composer<_$WxDatabase, $MissionsTable> {
  $$MissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayEpoch =>
      $composableBuilder(column: $table.dayEpoch, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  GeneratedColumn<int> get coinsReward => $composableBuilder(
    column: $table.coinsReward,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get claimed =>
      $composableBuilder(column: $table.claimed, builder: (column) => column);
}

class $$MissionsTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $MissionsTable,
          MissionRow,
          $$MissionsTableFilterComposer,
          $$MissionsTableOrderingComposer,
          $$MissionsTableAnnotationComposer,
          $$MissionsTableCreateCompanionBuilder,
          $$MissionsTableUpdateCompanionBuilder,
          (
            MissionRow,
            BaseReferences<_$WxDatabase, $MissionsTable, MissionRow>,
          ),
          MissionRow,
          PrefetchHooks Function()
        > {
  $$MissionsTableTableManager(_$WxDatabase db, $MissionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayEpoch = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<int> coinsReward = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> claimed = const Value.absent(),
              }) => MissionsCompanion(
                id: id,
                dayEpoch: dayEpoch,
                code: code,
                title: title,
                description: description,
                target: target,
                progress: progress,
                xpReward: xpReward,
                coinsReward: coinsReward,
                completed: completed,
                claimed: claimed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dayEpoch,
                required String code,
                required String title,
                required String description,
                required int target,
                Value<int> progress = const Value.absent(),
                required int xpReward,
                required int coinsReward,
                Value<bool> completed = const Value.absent(),
                Value<bool> claimed = const Value.absent(),
              }) => MissionsCompanion.insert(
                id: id,
                dayEpoch: dayEpoch,
                code: code,
                title: title,
                description: description,
                target: target,
                progress: progress,
                xpReward: xpReward,
                coinsReward: coinsReward,
                completed: completed,
                claimed: claimed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $MissionsTable,
      MissionRow,
      $$MissionsTableFilterComposer,
      $$MissionsTableOrderingComposer,
      $$MissionsTableAnnotationComposer,
      $$MissionsTableCreateCompanionBuilder,
      $$MissionsTableUpdateCompanionBuilder,
      (MissionRow, BaseReferences<_$WxDatabase, $MissionsTable, MissionRow>),
      MissionRow,
      PrefetchHooks Function()
    >;
typedef $$PurposeUnlocksTableCreateCompanionBuilder =
    PurposeUnlocksCompanion Function({
      Value<int> id,
      required int timestampMs,
      required String packageName,
      required String purpose,
      Value<int?> followUpDurationMs,
    });
typedef $$PurposeUnlocksTableUpdateCompanionBuilder =
    PurposeUnlocksCompanion Function({
      Value<int> id,
      Value<int> timestampMs,
      Value<String> packageName,
      Value<String> purpose,
      Value<int?> followUpDurationMs,
    });

class $$PurposeUnlocksTableFilterComposer
    extends Composer<_$WxDatabase, $PurposeUnlocksTable> {
  $$PurposeUnlocksTableFilterComposer({
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

  ColumnFilters<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get followUpDurationMs => $composableBuilder(
    column: $table.followUpDurationMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PurposeUnlocksTableOrderingComposer
    extends Composer<_$WxDatabase, $PurposeUnlocksTable> {
  $$PurposeUnlocksTableOrderingComposer({
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

  ColumnOrderings<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get followUpDurationMs => $composableBuilder(
    column: $table.followUpDurationMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurposeUnlocksTableAnnotationComposer
    extends Composer<_$WxDatabase, $PurposeUnlocksTable> {
  $$PurposeUnlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<int> get followUpDurationMs => $composableBuilder(
    column: $table.followUpDurationMs,
    builder: (column) => column,
  );
}

class $$PurposeUnlocksTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $PurposeUnlocksTable,
          PurposeRow,
          $$PurposeUnlocksTableFilterComposer,
          $$PurposeUnlocksTableOrderingComposer,
          $$PurposeUnlocksTableAnnotationComposer,
          $$PurposeUnlocksTableCreateCompanionBuilder,
          $$PurposeUnlocksTableUpdateCompanionBuilder,
          (
            PurposeRow,
            BaseReferences<_$WxDatabase, $PurposeUnlocksTable, PurposeRow>,
          ),
          PurposeRow,
          PrefetchHooks Function()
        > {
  $$PurposeUnlocksTableTableManager(_$WxDatabase db, $PurposeUnlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurposeUnlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurposeUnlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurposeUnlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> timestampMs = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<int?> followUpDurationMs = const Value.absent(),
              }) => PurposeUnlocksCompanion(
                id: id,
                timestampMs: timestampMs,
                packageName: packageName,
                purpose: purpose,
                followUpDurationMs: followUpDurationMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int timestampMs,
                required String packageName,
                required String purpose,
                Value<int?> followUpDurationMs = const Value.absent(),
              }) => PurposeUnlocksCompanion.insert(
                id: id,
                timestampMs: timestampMs,
                packageName: packageName,
                purpose: purpose,
                followUpDurationMs: followUpDurationMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurposeUnlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $PurposeUnlocksTable,
      PurposeRow,
      $$PurposeUnlocksTableFilterComposer,
      $$PurposeUnlocksTableOrderingComposer,
      $$PurposeUnlocksTableAnnotationComposer,
      $$PurposeUnlocksTableCreateCompanionBuilder,
      $$PurposeUnlocksTableUpdateCompanionBuilder,
      (
        PurposeRow,
        BaseReferences<_$WxDatabase, $PurposeUnlocksTable, PurposeRow>,
      ),
      PurposeRow,
      PrefetchHooks Function()
    >;
typedef $$MoodEntriesTableCreateCompanionBuilder =
    MoodEntriesCompanion Function({
      Value<int> id,
      required int timestampMs,
      required int score,
      Value<String?> tag,
      Value<String?> note,
    });
typedef $$MoodEntriesTableUpdateCompanionBuilder =
    MoodEntriesCompanion Function({
      Value<int> id,
      Value<int> timestampMs,
      Value<int> score,
      Value<String?> tag,
      Value<String?> note,
    });

class $$MoodEntriesTableFilterComposer
    extends Composer<_$WxDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableFilterComposer({
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

  ColumnFilters<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoodEntriesTableOrderingComposer
    extends Composer<_$WxDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoodEntriesTableAnnotationComposer
    extends Composer<_$WxDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$MoodEntriesTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $MoodEntriesTable,
          MoodRow,
          $$MoodEntriesTableFilterComposer,
          $$MoodEntriesTableOrderingComposer,
          $$MoodEntriesTableAnnotationComposer,
          $$MoodEntriesTableCreateCompanionBuilder,
          $$MoodEntriesTableUpdateCompanionBuilder,
          (MoodRow, BaseReferences<_$WxDatabase, $MoodEntriesTable, MoodRow>),
          MoodRow,
          PrefetchHooks Function()
        > {
  $$MoodEntriesTableTableManager(_$WxDatabase db, $MoodEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> timestampMs = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String?> tag = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => MoodEntriesCompanion(
                id: id,
                timestampMs: timestampMs,
                score: score,
                tag: tag,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int timestampMs,
                required int score,
                Value<String?> tag = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => MoodEntriesCompanion.insert(
                id: id,
                timestampMs: timestampMs,
                score: score,
                tag: tag,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoodEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $MoodEntriesTable,
      MoodRow,
      $$MoodEntriesTableFilterComposer,
      $$MoodEntriesTableOrderingComposer,
      $$MoodEntriesTableAnnotationComposer,
      $$MoodEntriesTableCreateCompanionBuilder,
      $$MoodEntriesTableUpdateCompanionBuilder,
      (MoodRow, BaseReferences<_$WxDatabase, $MoodEntriesTable, MoodRow>),
      MoodRow,
      PrefetchHooks Function()
    >;
typedef $$KeyValuesTableCreateCompanionBuilder =
    KeyValuesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$KeyValuesTableUpdateCompanionBuilder =
    KeyValuesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$KeyValuesTableFilterComposer
    extends Composer<_$WxDatabase, $KeyValuesTable> {
  $$KeyValuesTableFilterComposer({
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

class $$KeyValuesTableOrderingComposer
    extends Composer<_$WxDatabase, $KeyValuesTable> {
  $$KeyValuesTableOrderingComposer({
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

class $$KeyValuesTableAnnotationComposer
    extends Composer<_$WxDatabase, $KeyValuesTable> {
  $$KeyValuesTableAnnotationComposer({
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

class $$KeyValuesTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $KeyValuesTable,
          KvRow,
          $$KeyValuesTableFilterComposer,
          $$KeyValuesTableOrderingComposer,
          $$KeyValuesTableAnnotationComposer,
          $$KeyValuesTableCreateCompanionBuilder,
          $$KeyValuesTableUpdateCompanionBuilder,
          (KvRow, BaseReferences<_$WxDatabase, $KeyValuesTable, KvRow>),
          KvRow,
          PrefetchHooks Function()
        > {
  $$KeyValuesTableTableManager(_$WxDatabase db, $KeyValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $KeyValuesTable,
      KvRow,
      $$KeyValuesTableFilterComposer,
      $$KeyValuesTableOrderingComposer,
      $$KeyValuesTableAnnotationComposer,
      $$KeyValuesTableCreateCompanionBuilder,
      $$KeyValuesTableUpdateCompanionBuilder,
      (KvRow, BaseReferences<_$WxDatabase, $KeyValuesTable, KvRow>),
      KvRow,
      PrefetchHooks Function()
    >;
typedef $$BlockOverridesTableCreateCompanionBuilder =
    BlockOverridesCompanion Function({
      Value<int> id,
      required int timestampMs,
      required String packageName,
      required String mode,
      Value<int> xpPenalty,
      Value<int> coinPenalty,
    });
typedef $$BlockOverridesTableUpdateCompanionBuilder =
    BlockOverridesCompanion Function({
      Value<int> id,
      Value<int> timestampMs,
      Value<String> packageName,
      Value<String> mode,
      Value<int> xpPenalty,
      Value<int> coinPenalty,
    });

class $$BlockOverridesTableFilterComposer
    extends Composer<_$WxDatabase, $BlockOverridesTable> {
  $$BlockOverridesTableFilterComposer({
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

  ColumnFilters<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpPenalty => $composableBuilder(
    column: $table.xpPenalty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coinPenalty => $composableBuilder(
    column: $table.coinPenalty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BlockOverridesTableOrderingComposer
    extends Composer<_$WxDatabase, $BlockOverridesTable> {
  $$BlockOverridesTableOrderingComposer({
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

  ColumnOrderings<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpPenalty => $composableBuilder(
    column: $table.xpPenalty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coinPenalty => $composableBuilder(
    column: $table.coinPenalty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BlockOverridesTableAnnotationComposer
    extends Composer<_$WxDatabase, $BlockOverridesTable> {
  $$BlockOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get xpPenalty =>
      $composableBuilder(column: $table.xpPenalty, builder: (column) => column);

  GeneratedColumn<int> get coinPenalty => $composableBuilder(
    column: $table.coinPenalty,
    builder: (column) => column,
  );
}

class $$BlockOverridesTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $BlockOverridesTable,
          BlockOverrideRow,
          $$BlockOverridesTableFilterComposer,
          $$BlockOverridesTableOrderingComposer,
          $$BlockOverridesTableAnnotationComposer,
          $$BlockOverridesTableCreateCompanionBuilder,
          $$BlockOverridesTableUpdateCompanionBuilder,
          (
            BlockOverrideRow,
            BaseReferences<
              _$WxDatabase,
              $BlockOverridesTable,
              BlockOverrideRow
            >,
          ),
          BlockOverrideRow,
          PrefetchHooks Function()
        > {
  $$BlockOverridesTableTableManager(_$WxDatabase db, $BlockOverridesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlockOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlockOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlockOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> timestampMs = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> xpPenalty = const Value.absent(),
                Value<int> coinPenalty = const Value.absent(),
              }) => BlockOverridesCompanion(
                id: id,
                timestampMs: timestampMs,
                packageName: packageName,
                mode: mode,
                xpPenalty: xpPenalty,
                coinPenalty: coinPenalty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int timestampMs,
                required String packageName,
                required String mode,
                Value<int> xpPenalty = const Value.absent(),
                Value<int> coinPenalty = const Value.absent(),
              }) => BlockOverridesCompanion.insert(
                id: id,
                timestampMs: timestampMs,
                packageName: packageName,
                mode: mode,
                xpPenalty: xpPenalty,
                coinPenalty: coinPenalty,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BlockOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $BlockOverridesTable,
      BlockOverrideRow,
      $$BlockOverridesTableFilterComposer,
      $$BlockOverridesTableOrderingComposer,
      $$BlockOverridesTableAnnotationComposer,
      $$BlockOverridesTableCreateCompanionBuilder,
      $$BlockOverridesTableUpdateCompanionBuilder,
      (
        BlockOverrideRow,
        BaseReferences<_$WxDatabase, $BlockOverridesTable, BlockOverrideRow>,
      ),
      BlockOverrideRow,
      PrefetchHooks Function()
    >;
typedef $$BlockSchedulesTableCreateCompanionBuilder =
    BlockSchedulesCompanion Function({
      Value<int> id,
      required String packageName,
      required int startMinute,
      required int endMinute,
      required int daysMask,
      Value<String> mode,
      Value<bool> enabled,
    });
typedef $$BlockSchedulesTableUpdateCompanionBuilder =
    BlockSchedulesCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<int> startMinute,
      Value<int> endMinute,
      Value<int> daysMask,
      Value<String> mode,
      Value<bool> enabled,
    });

class $$BlockSchedulesTableFilterComposer
    extends Composer<_$WxDatabase, $BlockSchedulesTable> {
  $$BlockSchedulesTableFilterComposer({
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

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysMask => $composableBuilder(
    column: $table.daysMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BlockSchedulesTableOrderingComposer
    extends Composer<_$WxDatabase, $BlockSchedulesTable> {
  $$BlockSchedulesTableOrderingComposer({
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

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysMask => $composableBuilder(
    column: $table.daysMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BlockSchedulesTableAnnotationComposer
    extends Composer<_$WxDatabase, $BlockSchedulesTable> {
  $$BlockSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<int> get daysMask =>
      $composableBuilder(column: $table.daysMask, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$BlockSchedulesTableTableManager
    extends
        RootTableManager<
          _$WxDatabase,
          $BlockSchedulesTable,
          BlockScheduleRow,
          $$BlockSchedulesTableFilterComposer,
          $$BlockSchedulesTableOrderingComposer,
          $$BlockSchedulesTableAnnotationComposer,
          $$BlockSchedulesTableCreateCompanionBuilder,
          $$BlockSchedulesTableUpdateCompanionBuilder,
          (
            BlockScheduleRow,
            BaseReferences<
              _$WxDatabase,
              $BlockSchedulesTable,
              BlockScheduleRow
            >,
          ),
          BlockScheduleRow,
          PrefetchHooks Function()
        > {
  $$BlockSchedulesTableTableManager(_$WxDatabase db, $BlockSchedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlockSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlockSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlockSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> endMinute = const Value.absent(),
                Value<int> daysMask = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => BlockSchedulesCompanion(
                id: id,
                packageName: packageName,
                startMinute: startMinute,
                endMinute: endMinute,
                daysMask: daysMask,
                mode: mode,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required int startMinute,
                required int endMinute,
                required int daysMask,
                Value<String> mode = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => BlockSchedulesCompanion.insert(
                id: id,
                packageName: packageName,
                startMinute: startMinute,
                endMinute: endMinute,
                daysMask: daysMask,
                mode: mode,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BlockSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$WxDatabase,
      $BlockSchedulesTable,
      BlockScheduleRow,
      $$BlockSchedulesTableFilterComposer,
      $$BlockSchedulesTableOrderingComposer,
      $$BlockSchedulesTableAnnotationComposer,
      $$BlockSchedulesTableCreateCompanionBuilder,
      $$BlockSchedulesTableUpdateCompanionBuilder,
      (
        BlockScheduleRow,
        BaseReferences<_$WxDatabase, $BlockSchedulesTable, BlockScheduleRow>,
      ),
      BlockScheduleRow,
      PrefetchHooks Function()
    >;

class $WxDatabaseManager {
  final _$WxDatabase _db;
  $WxDatabaseManager(this._db);
  $$UsageEventsTableTableManager get usageEvents =>
      $$UsageEventsTableTableManager(_db, _db.usageEvents);
  $$NotificationsTableTableTableManager get notificationsTable =>
      $$NotificationsTableTableTableManager(_db, _db.notificationsTable);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$DailyAggregatesTableTableManager get dailyAggregates =>
      $$DailyAggregatesTableTableManager(_db, _db.dailyAggregates);
  $$HourBucketsTableTableManager get hourBuckets =>
      $$HourBucketsTableTableManager(_db, _db.hourBuckets);
  $$DailyPhoneTableTableManager get dailyPhone =>
      $$DailyPhoneTableTableManager(_db, _db.dailyPhone);
  $$BehaviorEpisodesTableTableManager get behaviorEpisodes =>
      $$BehaviorEpisodesTableTableManager(_db, _db.behaviorEpisodes);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$BlockRulesTableTableManager get blockRules =>
      $$BlockRulesTableTableManager(_db, _db.blockRules);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$MissionsTableTableManager get missions =>
      $$MissionsTableTableManager(_db, _db.missions);
  $$PurposeUnlocksTableTableManager get purposeUnlocks =>
      $$PurposeUnlocksTableTableManager(_db, _db.purposeUnlocks);
  $$MoodEntriesTableTableManager get moodEntries =>
      $$MoodEntriesTableTableManager(_db, _db.moodEntries);
  $$KeyValuesTableTableManager get keyValues =>
      $$KeyValuesTableTableManager(_db, _db.keyValues);
  $$BlockOverridesTableTableManager get blockOverrides =>
      $$BlockOverridesTableTableManager(_db, _db.blockOverrides);
  $$BlockSchedulesTableTableManager get blockSchedules =>
      $$BlockSchedulesTableTableManager(_db, _db.blockSchedules);
}
