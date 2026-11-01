// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pawlum_database.dart';

// ignore_for_file: type=lint
class $OnboardingDraftsTable extends OnboardingDrafts
    with TableInfo<$OnboardingDraftsTable, OnboardingDraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OnboardingDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentStepMeta = const VerificationMeta(
    'currentStep',
  );
  @override
  late final GeneratedColumn<int> currentStep = GeneratedColumn<int>(
    'current_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _remoteRevisionMeta = const VerificationMeta(
    'remoteRevision',
  );
  @override
  late final GeneratedColumn<String> remoteRevision = GeneratedColumn<String>(
    'remote_revision',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    id,
    currentStep,
    payloadJson,
    remoteRevision,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'onboarding_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<OnboardingDraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('current_step')) {
      context.handle(
        _currentStepMeta,
        currentStep.isAcceptableOrUnknown(
          data['current_step']!,
          _currentStepMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('remote_revision')) {
      context.handle(
        _remoteRevisionMeta,
        remoteRevision.isAcceptableOrUnknown(
          data['remote_revision']!,
          _remoteRevisionMeta,
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
  Set<GeneratedColumn> get $primaryKey => {accountId, id};
  @override
  OnboardingDraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OnboardingDraftRow(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      currentStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_step'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      remoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_revision'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OnboardingDraftsTable createAlias(String alias) {
    return $OnboardingDraftsTable(attachedDatabase, alias);
  }
}

class OnboardingDraftRow extends DataClass
    implements Insertable<OnboardingDraftRow> {
  final String accountId;
  final String id;
  final int currentStep;
  final String payloadJson;
  final String? remoteRevision;
  final DateTime createdAt;
  final DateTime updatedAt;
  const OnboardingDraftRow({
    required this.accountId,
    required this.id,
    required this.currentStep,
    required this.payloadJson,
    this.remoteRevision,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['id'] = Variable<String>(id);
    map['current_step'] = Variable<int>(currentStep);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || remoteRevision != null) {
      map['remote_revision'] = Variable<String>(remoteRevision);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OnboardingDraftsCompanion toCompanion(bool nullToAbsent) {
    return OnboardingDraftsCompanion(
      accountId: Value(accountId),
      id: Value(id),
      currentStep: Value(currentStep),
      payloadJson: Value(payloadJson),
      remoteRevision: remoteRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteRevision),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OnboardingDraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OnboardingDraftRow(
      accountId: serializer.fromJson<String>(json['accountId']),
      id: serializer.fromJson<String>(json['id']),
      currentStep: serializer.fromJson<int>(json['currentStep']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      remoteRevision: serializer.fromJson<String?>(json['remoteRevision']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'id': serializer.toJson<String>(id),
      'currentStep': serializer.toJson<int>(currentStep),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'remoteRevision': serializer.toJson<String?>(remoteRevision),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OnboardingDraftRow copyWith({
    String? accountId,
    String? id,
    int? currentStep,
    String? payloadJson,
    Value<String?> remoteRevision = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => OnboardingDraftRow(
    accountId: accountId ?? this.accountId,
    id: id ?? this.id,
    currentStep: currentStep ?? this.currentStep,
    payloadJson: payloadJson ?? this.payloadJson,
    remoteRevision: remoteRevision.present
        ? remoteRevision.value
        : this.remoteRevision,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OnboardingDraftRow copyWithCompanion(OnboardingDraftsCompanion data) {
    return OnboardingDraftRow(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      id: data.id.present ? data.id.value : this.id,
      currentStep: data.currentStep.present
          ? data.currentStep.value
          : this.currentStep,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      remoteRevision: data.remoteRevision.present
          ? data.remoteRevision.value
          : this.remoteRevision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingDraftRow(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('currentStep: $currentStep, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    id,
    currentStep,
    payloadJson,
    remoteRevision,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OnboardingDraftRow &&
          other.accountId == this.accountId &&
          other.id == this.id &&
          other.currentStep == this.currentStep &&
          other.payloadJson == this.payloadJson &&
          other.remoteRevision == this.remoteRevision &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OnboardingDraftsCompanion extends UpdateCompanion<OnboardingDraftRow> {
  final Value<String> accountId;
  final Value<String> id;
  final Value<int> currentStep;
  final Value<String> payloadJson;
  final Value<String?> remoteRevision;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OnboardingDraftsCompanion({
    this.accountId = const Value.absent(),
    this.id = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OnboardingDraftsCompanion.insert({
    required String accountId,
    required String id,
    this.currentStep = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OnboardingDraftRow> custom({
    Expression<String>? accountId,
    Expression<String>? id,
    Expression<int>? currentStep,
    Expression<String>? payloadJson,
    Expression<String>? remoteRevision,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (id != null) 'id': id,
      if (currentStep != null) 'current_step': currentStep,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (remoteRevision != null) 'remote_revision': remoteRevision,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OnboardingDraftsCompanion copyWith({
    Value<String>? accountId,
    Value<String>? id,
    Value<int>? currentStep,
    Value<String>? payloadJson,
    Value<String?>? remoteRevision,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OnboardingDraftsCompanion(
      accountId: accountId ?? this.accountId,
      id: id ?? this.id,
      currentStep: currentStep ?? this.currentStep,
      payloadJson: payloadJson ?? this.payloadJson,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (currentStep.present) {
      map['current_step'] = Variable<int>(currentStep.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (remoteRevision.present) {
      map['remote_revision'] = Variable<String>(remoteRevision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingDraftsCompanion(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('currentStep: $currentStep, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryDraftsTable extends MemoryDrafts
    with TableInfo<$MemoryDraftsTable, MemoryDraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _draftKindMeta = const VerificationMeta(
    'draftKind',
  );
  @override
  late final GeneratedColumn<String> draftKind = GeneratedColumn<String>(
    'draft_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basePublishedVersionIdMeta =
      const VerificationMeta('basePublishedVersionId');
  @override
  late final GeneratedColumn<String> basePublishedVersionId =
      GeneratedColumn<String>(
        'base_published_version_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _baseRemoteRevisionMeta =
      const VerificationMeta('baseRemoteRevision');
  @override
  late final GeneratedColumn<String> baseRemoteRevision =
      GeneratedColumn<String>(
        'base_remote_revision',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currentStepMeta = const VerificationMeta(
    'currentStep',
  );
  @override
  late final GeneratedColumn<int> currentStep = GeneratedColumn<int>(
    'current_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    id,
    memoryId,
    draftKind,
    basePublishedVersionId,
    baseRemoteRevision,
    currentStep,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryDraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('draft_kind')) {
      context.handle(
        _draftKindMeta,
        draftKind.isAcceptableOrUnknown(data['draft_kind']!, _draftKindMeta),
      );
    } else if (isInserting) {
      context.missing(_draftKindMeta);
    }
    if (data.containsKey('base_published_version_id')) {
      context.handle(
        _basePublishedVersionIdMeta,
        basePublishedVersionId.isAcceptableOrUnknown(
          data['base_published_version_id']!,
          _basePublishedVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('base_remote_revision')) {
      context.handle(
        _baseRemoteRevisionMeta,
        baseRemoteRevision.isAcceptableOrUnknown(
          data['base_remote_revision']!,
          _baseRemoteRevisionMeta,
        ),
      );
    }
    if (data.containsKey('current_step')) {
      context.handle(
        _currentStepMeta,
        currentStep.isAcceptableOrUnknown(
          data['current_step']!,
          _currentStepMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
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
  Set<GeneratedColumn> get $primaryKey => {accountId, id};
  @override
  MemoryDraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryDraftRow(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id'],
      )!,
      draftKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draft_kind'],
      )!,
      basePublishedVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_published_version_id'],
      ),
      baseRemoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_remote_revision'],
      ),
      currentStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_step'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MemoryDraftsTable createAlias(String alias) {
    return $MemoryDraftsTable(attachedDatabase, alias);
  }
}

class MemoryDraftRow extends DataClass implements Insertable<MemoryDraftRow> {
  final String accountId;
  final String id;
  final String memoryId;
  final String draftKind;
  final String? basePublishedVersionId;
  final String? baseRemoteRevision;
  final int currentStep;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MemoryDraftRow({
    required this.accountId,
    required this.id,
    required this.memoryId,
    required this.draftKind,
    this.basePublishedVersionId,
    this.baseRemoteRevision,
    required this.currentStep,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['id'] = Variable<String>(id);
    map['memory_id'] = Variable<String>(memoryId);
    map['draft_kind'] = Variable<String>(draftKind);
    if (!nullToAbsent || basePublishedVersionId != null) {
      map['base_published_version_id'] = Variable<String>(
        basePublishedVersionId,
      );
    }
    if (!nullToAbsent || baseRemoteRevision != null) {
      map['base_remote_revision'] = Variable<String>(baseRemoteRevision);
    }
    map['current_step'] = Variable<int>(currentStep);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MemoryDraftsCompanion toCompanion(bool nullToAbsent) {
    return MemoryDraftsCompanion(
      accountId: Value(accountId),
      id: Value(id),
      memoryId: Value(memoryId),
      draftKind: Value(draftKind),
      basePublishedVersionId: basePublishedVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(basePublishedVersionId),
      baseRemoteRevision: baseRemoteRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(baseRemoteRevision),
      currentStep: Value(currentStep),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MemoryDraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryDraftRow(
      accountId: serializer.fromJson<String>(json['accountId']),
      id: serializer.fromJson<String>(json['id']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      draftKind: serializer.fromJson<String>(json['draftKind']),
      basePublishedVersionId: serializer.fromJson<String?>(
        json['basePublishedVersionId'],
      ),
      baseRemoteRevision: serializer.fromJson<String?>(
        json['baseRemoteRevision'],
      ),
      currentStep: serializer.fromJson<int>(json['currentStep']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'id': serializer.toJson<String>(id),
      'memoryId': serializer.toJson<String>(memoryId),
      'draftKind': serializer.toJson<String>(draftKind),
      'basePublishedVersionId': serializer.toJson<String?>(
        basePublishedVersionId,
      ),
      'baseRemoteRevision': serializer.toJson<String?>(baseRemoteRevision),
      'currentStep': serializer.toJson<int>(currentStep),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MemoryDraftRow copyWith({
    String? accountId,
    String? id,
    String? memoryId,
    String? draftKind,
    Value<String?> basePublishedVersionId = const Value.absent(),
    Value<String?> baseRemoteRevision = const Value.absent(),
    int? currentStep,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MemoryDraftRow(
    accountId: accountId ?? this.accountId,
    id: id ?? this.id,
    memoryId: memoryId ?? this.memoryId,
    draftKind: draftKind ?? this.draftKind,
    basePublishedVersionId: basePublishedVersionId.present
        ? basePublishedVersionId.value
        : this.basePublishedVersionId,
    baseRemoteRevision: baseRemoteRevision.present
        ? baseRemoteRevision.value
        : this.baseRemoteRevision,
    currentStep: currentStep ?? this.currentStep,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MemoryDraftRow copyWithCompanion(MemoryDraftsCompanion data) {
    return MemoryDraftRow(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      id: data.id.present ? data.id.value : this.id,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      draftKind: data.draftKind.present ? data.draftKind.value : this.draftKind,
      basePublishedVersionId: data.basePublishedVersionId.present
          ? data.basePublishedVersionId.value
          : this.basePublishedVersionId,
      baseRemoteRevision: data.baseRemoteRevision.present
          ? data.baseRemoteRevision.value
          : this.baseRemoteRevision,
      currentStep: data.currentStep.present
          ? data.currentStep.value
          : this.currentStep,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryDraftRow(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('draftKind: $draftKind, ')
          ..write('basePublishedVersionId: $basePublishedVersionId, ')
          ..write('baseRemoteRevision: $baseRemoteRevision, ')
          ..write('currentStep: $currentStep, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    id,
    memoryId,
    draftKind,
    basePublishedVersionId,
    baseRemoteRevision,
    currentStep,
    payloadJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryDraftRow &&
          other.accountId == this.accountId &&
          other.id == this.id &&
          other.memoryId == this.memoryId &&
          other.draftKind == this.draftKind &&
          other.basePublishedVersionId == this.basePublishedVersionId &&
          other.baseRemoteRevision == this.baseRemoteRevision &&
          other.currentStep == this.currentStep &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MemoryDraftsCompanion extends UpdateCompanion<MemoryDraftRow> {
  final Value<String> accountId;
  final Value<String> id;
  final Value<String> memoryId;
  final Value<String> draftKind;
  final Value<String?> basePublishedVersionId;
  final Value<String?> baseRemoteRevision;
  final Value<int> currentStep;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MemoryDraftsCompanion({
    this.accountId = const Value.absent(),
    this.id = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.draftKind = const Value.absent(),
    this.basePublishedVersionId = const Value.absent(),
    this.baseRemoteRevision = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryDraftsCompanion.insert({
    required String accountId,
    required String id,
    required String memoryId,
    required String draftKind,
    this.basePublishedVersionId = const Value.absent(),
    this.baseRemoteRevision = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.payloadJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       id = Value(id),
       memoryId = Value(memoryId),
       draftKind = Value(draftKind),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MemoryDraftRow> custom({
    Expression<String>? accountId,
    Expression<String>? id,
    Expression<String>? memoryId,
    Expression<String>? draftKind,
    Expression<String>? basePublishedVersionId,
    Expression<String>? baseRemoteRevision,
    Expression<int>? currentStep,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (id != null) 'id': id,
      if (memoryId != null) 'memory_id': memoryId,
      if (draftKind != null) 'draft_kind': draftKind,
      if (basePublishedVersionId != null)
        'base_published_version_id': basePublishedVersionId,
      if (baseRemoteRevision != null)
        'base_remote_revision': baseRemoteRevision,
      if (currentStep != null) 'current_step': currentStep,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryDraftsCompanion copyWith({
    Value<String>? accountId,
    Value<String>? id,
    Value<String>? memoryId,
    Value<String>? draftKind,
    Value<String?>? basePublishedVersionId,
    Value<String?>? baseRemoteRevision,
    Value<int>? currentStep,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MemoryDraftsCompanion(
      accountId: accountId ?? this.accountId,
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      draftKind: draftKind ?? this.draftKind,
      basePublishedVersionId:
          basePublishedVersionId ?? this.basePublishedVersionId,
      baseRemoteRevision: baseRemoteRevision ?? this.baseRemoteRevision,
      currentStep: currentStep ?? this.currentStep,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (draftKind.present) {
      map['draft_kind'] = Variable<String>(draftKind.value);
    }
    if (basePublishedVersionId.present) {
      map['base_published_version_id'] = Variable<String>(
        basePublishedVersionId.value,
      );
    }
    if (baseRemoteRevision.present) {
      map['base_remote_revision'] = Variable<String>(baseRemoteRevision.value);
    }
    if (currentStep.present) {
      map['current_step'] = Variable<int>(currentStep.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryDraftsCompanion(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('draftKind: $draftKind, ')
          ..write('basePublishedVersionId: $basePublishedVersionId, ')
          ..write('baseRemoteRevision: $baseRemoteRevision, ')
          ..write('currentStep: $currentStep, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMediaReferencesTable extends LocalMediaReferences
    with TableInfo<$LocalMediaReferencesTable, LocalMediaReferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMediaReferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerDraftTypeMeta = const VerificationMeta(
    'ownerDraftType',
  );
  @override
  late final GeneratedColumn<String> ownerDraftType = GeneratedColumn<String>(
    'owner_draft_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerDraftIdMeta = const VerificationMeta(
    'ownerDraftId',
  );
  @override
  late final GeneratedColumn<String> ownerDraftId = GeneratedColumn<String>(
    'owner_draft_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadStateMeta = const VerificationMeta(
    'uploadState',
  );
  @override
  late final GeneratedColumn<String> uploadState = GeneratedColumn<String>(
    'upload_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_selected'),
  );
  static const VerificationMeta _remoteObjectPathMeta = const VerificationMeta(
    'remoteObjectPath',
  );
  @override
  late final GeneratedColumn<String> remoteObjectPath = GeneratedColumn<String>(
    'remote_object_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    id,
    ownerDraftType,
    ownerDraftId,
    localPath,
    mediaType,
    sortOrder,
    checksum,
    uploadState,
    remoteObjectPath,
    metadataJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_media_references';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMediaReferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_draft_type')) {
      context.handle(
        _ownerDraftTypeMeta,
        ownerDraftType.isAcceptableOrUnknown(
          data['owner_draft_type']!,
          _ownerDraftTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerDraftTypeMeta);
    }
    if (data.containsKey('owner_draft_id')) {
      context.handle(
        _ownerDraftIdMeta,
        ownerDraftId.isAcceptableOrUnknown(
          data['owner_draft_id']!,
          _ownerDraftIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerDraftIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    }
    if (data.containsKey('upload_state')) {
      context.handle(
        _uploadStateMeta,
        uploadState.isAcceptableOrUnknown(
          data['upload_state']!,
          _uploadStateMeta,
        ),
      );
    }
    if (data.containsKey('remote_object_path')) {
      context.handle(
        _remoteObjectPathMeta,
        remoteObjectPath.isAcceptableOrUnknown(
          data['remote_object_path']!,
          _remoteObjectPathMeta,
        ),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
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
  Set<GeneratedColumn> get $primaryKey => {accountId, id};
  @override
  LocalMediaReferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMediaReferenceRow(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerDraftType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_draft_type'],
      )!,
      ownerDraftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_draft_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      ),
      uploadState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_state'],
      )!,
      remoteObjectPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_object_path'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalMediaReferencesTable createAlias(String alias) {
    return $LocalMediaReferencesTable(attachedDatabase, alias);
  }
}

class LocalMediaReferenceRow extends DataClass
    implements Insertable<LocalMediaReferenceRow> {
  final String accountId;
  final String id;
  final String ownerDraftType;
  final String ownerDraftId;
  final String localPath;
  final String mediaType;
  final int sortOrder;
  final String? checksum;
  final String uploadState;
  final String? remoteObjectPath;
  final String metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalMediaReferenceRow({
    required this.accountId,
    required this.id,
    required this.ownerDraftType,
    required this.ownerDraftId,
    required this.localPath,
    required this.mediaType,
    required this.sortOrder,
    this.checksum,
    required this.uploadState,
    this.remoteObjectPath,
    required this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['id'] = Variable<String>(id);
    map['owner_draft_type'] = Variable<String>(ownerDraftType);
    map['owner_draft_id'] = Variable<String>(ownerDraftId);
    map['local_path'] = Variable<String>(localPath);
    map['media_type'] = Variable<String>(mediaType);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    map['upload_state'] = Variable<String>(uploadState);
    if (!nullToAbsent || remoteObjectPath != null) {
      map['remote_object_path'] = Variable<String>(remoteObjectPath);
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalMediaReferencesCompanion toCompanion(bool nullToAbsent) {
    return LocalMediaReferencesCompanion(
      accountId: Value(accountId),
      id: Value(id),
      ownerDraftType: Value(ownerDraftType),
      ownerDraftId: Value(ownerDraftId),
      localPath: Value(localPath),
      mediaType: Value(mediaType),
      sortOrder: Value(sortOrder),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      uploadState: Value(uploadState),
      remoteObjectPath: remoteObjectPath == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteObjectPath),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalMediaReferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMediaReferenceRow(
      accountId: serializer.fromJson<String>(json['accountId']),
      id: serializer.fromJson<String>(json['id']),
      ownerDraftType: serializer.fromJson<String>(json['ownerDraftType']),
      ownerDraftId: serializer.fromJson<String>(json['ownerDraftId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      uploadState: serializer.fromJson<String>(json['uploadState']),
      remoteObjectPath: serializer.fromJson<String?>(json['remoteObjectPath']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'id': serializer.toJson<String>(id),
      'ownerDraftType': serializer.toJson<String>(ownerDraftType),
      'ownerDraftId': serializer.toJson<String>(ownerDraftId),
      'localPath': serializer.toJson<String>(localPath),
      'mediaType': serializer.toJson<String>(mediaType),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'checksum': serializer.toJson<String?>(checksum),
      'uploadState': serializer.toJson<String>(uploadState),
      'remoteObjectPath': serializer.toJson<String?>(remoteObjectPath),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalMediaReferenceRow copyWith({
    String? accountId,
    String? id,
    String? ownerDraftType,
    String? ownerDraftId,
    String? localPath,
    String? mediaType,
    int? sortOrder,
    Value<String?> checksum = const Value.absent(),
    String? uploadState,
    Value<String?> remoteObjectPath = const Value.absent(),
    String? metadataJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalMediaReferenceRow(
    accountId: accountId ?? this.accountId,
    id: id ?? this.id,
    ownerDraftType: ownerDraftType ?? this.ownerDraftType,
    ownerDraftId: ownerDraftId ?? this.ownerDraftId,
    localPath: localPath ?? this.localPath,
    mediaType: mediaType ?? this.mediaType,
    sortOrder: sortOrder ?? this.sortOrder,
    checksum: checksum.present ? checksum.value : this.checksum,
    uploadState: uploadState ?? this.uploadState,
    remoteObjectPath: remoteObjectPath.present
        ? remoteObjectPath.value
        : this.remoteObjectPath,
    metadataJson: metadataJson ?? this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalMediaReferenceRow copyWithCompanion(LocalMediaReferencesCompanion data) {
    return LocalMediaReferenceRow(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      id: data.id.present ? data.id.value : this.id,
      ownerDraftType: data.ownerDraftType.present
          ? data.ownerDraftType.value
          : this.ownerDraftType,
      ownerDraftId: data.ownerDraftId.present
          ? data.ownerDraftId.value
          : this.ownerDraftId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      uploadState: data.uploadState.present
          ? data.uploadState.value
          : this.uploadState,
      remoteObjectPath: data.remoteObjectPath.present
          ? data.remoteObjectPath.value
          : this.remoteObjectPath,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMediaReferenceRow(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('ownerDraftType: $ownerDraftType, ')
          ..write('ownerDraftId: $ownerDraftId, ')
          ..write('localPath: $localPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('checksum: $checksum, ')
          ..write('uploadState: $uploadState, ')
          ..write('remoteObjectPath: $remoteObjectPath, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    id,
    ownerDraftType,
    ownerDraftId,
    localPath,
    mediaType,
    sortOrder,
    checksum,
    uploadState,
    remoteObjectPath,
    metadataJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMediaReferenceRow &&
          other.accountId == this.accountId &&
          other.id == this.id &&
          other.ownerDraftType == this.ownerDraftType &&
          other.ownerDraftId == this.ownerDraftId &&
          other.localPath == this.localPath &&
          other.mediaType == this.mediaType &&
          other.sortOrder == this.sortOrder &&
          other.checksum == this.checksum &&
          other.uploadState == this.uploadState &&
          other.remoteObjectPath == this.remoteObjectPath &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalMediaReferencesCompanion
    extends UpdateCompanion<LocalMediaReferenceRow> {
  final Value<String> accountId;
  final Value<String> id;
  final Value<String> ownerDraftType;
  final Value<String> ownerDraftId;
  final Value<String> localPath;
  final Value<String> mediaType;
  final Value<int> sortOrder;
  final Value<String?> checksum;
  final Value<String> uploadState;
  final Value<String?> remoteObjectPath;
  final Value<String> metadataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalMediaReferencesCompanion({
    this.accountId = const Value.absent(),
    this.id = const Value.absent(),
    this.ownerDraftType = const Value.absent(),
    this.ownerDraftId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.checksum = const Value.absent(),
    this.uploadState = const Value.absent(),
    this.remoteObjectPath = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMediaReferencesCompanion.insert({
    required String accountId,
    required String id,
    required String ownerDraftType,
    required String ownerDraftId,
    required String localPath,
    required String mediaType,
    this.sortOrder = const Value.absent(),
    this.checksum = const Value.absent(),
    this.uploadState = const Value.absent(),
    this.remoteObjectPath = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       id = Value(id),
       ownerDraftType = Value(ownerDraftType),
       ownerDraftId = Value(ownerDraftId),
       localPath = Value(localPath),
       mediaType = Value(mediaType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalMediaReferenceRow> custom({
    Expression<String>? accountId,
    Expression<String>? id,
    Expression<String>? ownerDraftType,
    Expression<String>? ownerDraftId,
    Expression<String>? localPath,
    Expression<String>? mediaType,
    Expression<int>? sortOrder,
    Expression<String>? checksum,
    Expression<String>? uploadState,
    Expression<String>? remoteObjectPath,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (id != null) 'id': id,
      if (ownerDraftType != null) 'owner_draft_type': ownerDraftType,
      if (ownerDraftId != null) 'owner_draft_id': ownerDraftId,
      if (localPath != null) 'local_path': localPath,
      if (mediaType != null) 'media_type': mediaType,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (checksum != null) 'checksum': checksum,
      if (uploadState != null) 'upload_state': uploadState,
      if (remoteObjectPath != null) 'remote_object_path': remoteObjectPath,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMediaReferencesCompanion copyWith({
    Value<String>? accountId,
    Value<String>? id,
    Value<String>? ownerDraftType,
    Value<String>? ownerDraftId,
    Value<String>? localPath,
    Value<String>? mediaType,
    Value<int>? sortOrder,
    Value<String?>? checksum,
    Value<String>? uploadState,
    Value<String?>? remoteObjectPath,
    Value<String>? metadataJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalMediaReferencesCompanion(
      accountId: accountId ?? this.accountId,
      id: id ?? this.id,
      ownerDraftType: ownerDraftType ?? this.ownerDraftType,
      ownerDraftId: ownerDraftId ?? this.ownerDraftId,
      localPath: localPath ?? this.localPath,
      mediaType: mediaType ?? this.mediaType,
      sortOrder: sortOrder ?? this.sortOrder,
      checksum: checksum ?? this.checksum,
      uploadState: uploadState ?? this.uploadState,
      remoteObjectPath: remoteObjectPath ?? this.remoteObjectPath,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerDraftType.present) {
      map['owner_draft_type'] = Variable<String>(ownerDraftType.value);
    }
    if (ownerDraftId.present) {
      map['owner_draft_id'] = Variable<String>(ownerDraftId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (uploadState.present) {
      map['upload_state'] = Variable<String>(uploadState.value);
    }
    if (remoteObjectPath.present) {
      map['remote_object_path'] = Variable<String>(remoteObjectPath.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMediaReferencesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('ownerDraftType: $ownerDraftType, ')
          ..write('ownerDraftId: $ownerDraftId, ')
          ..write('localPath: $localPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('checksum: $checksum, ')
          ..write('uploadState: $uploadState, ')
          ..write('remoteObjectPath: $remoteObjectPath, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedPublishedSummariesTable extends CachedPublishedSummaries
    with TableInfo<$CachedPublishedSummariesTable, CachedPublishedSummaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPublishedSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishedVersionIdMeta =
      const VerificationMeta('publishedVersionId');
  @override
  late final GeneratedColumn<String> publishedVersionId =
      GeneratedColumn<String>(
        'published_version_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _petIdsJsonMeta = const VerificationMeta(
    'petIdsJson',
  );
  @override
  late final GeneratedColumn<String> petIdsJson = GeneratedColumn<String>(
    'pet_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
  static const VerificationMeta _captionSnippetMeta = const VerificationMeta(
    'captionSnippet',
  );
  @override
  late final GeneratedColumn<String> captionSnippet = GeneratedColumn<String>(
    'caption_snippet',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoryDateMeta = const VerificationMeta(
    'memoryDate',
  );
  @override
  late final GeneratedColumn<DateTime> memoryDate = GeneratedColumn<DateTime>(
    'memory_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverMediaPathMeta = const VerificationMeta(
    'coverMediaPath',
  );
  @override
  late final GeneratedColumn<String> coverMediaPath = GeneratedColumn<String>(
    'cover_media_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _presentationJsonMeta = const VerificationMeta(
    'presentationJson',
  );
  @override
  late final GeneratedColumn<String> presentationJson = GeneratedColumn<String>(
    'presentation_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _remoteRevisionMeta = const VerificationMeta(
    'remoteRevision',
  );
  @override
  late final GeneratedColumn<String> remoteRevision = GeneratedColumn<String>(
    'remote_revision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    memoryId,
    publishedVersionId,
    petIdsJson,
    title,
    captionSnippet,
    memoryDate,
    coverMediaPath,
    presentationJson,
    remoteRevision,
    cachedAt,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_published_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPublishedSummaryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('published_version_id')) {
      context.handle(
        _publishedVersionIdMeta,
        publishedVersionId.isAcceptableOrUnknown(
          data['published_version_id']!,
          _publishedVersionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedVersionIdMeta);
    }
    if (data.containsKey('pet_ids_json')) {
      context.handle(
        _petIdsJsonMeta,
        petIdsJson.isAcceptableOrUnknown(
          data['pet_ids_json']!,
          _petIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('caption_snippet')) {
      context.handle(
        _captionSnippetMeta,
        captionSnippet.isAcceptableOrUnknown(
          data['caption_snippet']!,
          _captionSnippetMeta,
        ),
      );
    }
    if (data.containsKey('memory_date')) {
      context.handle(
        _memoryDateMeta,
        memoryDate.isAcceptableOrUnknown(data['memory_date']!, _memoryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryDateMeta);
    }
    if (data.containsKey('cover_media_path')) {
      context.handle(
        _coverMediaPathMeta,
        coverMediaPath.isAcceptableOrUnknown(
          data['cover_media_path']!,
          _coverMediaPathMeta,
        ),
      );
    }
    if (data.containsKey('presentation_json')) {
      context.handle(
        _presentationJsonMeta,
        presentationJson.isAcceptableOrUnknown(
          data['presentation_json']!,
          _presentationJsonMeta,
        ),
      );
    }
    if (data.containsKey('remote_revision')) {
      context.handle(
        _remoteRevisionMeta,
        remoteRevision.isAcceptableOrUnknown(
          data['remote_revision']!,
          _remoteRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteRevisionMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, memoryId};
  @override
  CachedPublishedSummaryRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPublishedSummaryRow(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id'],
      )!,
      publishedVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}published_version_id'],
      )!,
      petIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_ids_json'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      captionSnippet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption_snippet'],
      ),
      memoryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}memory_date'],
      )!,
      coverMediaPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_media_path'],
      ),
      presentationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presentation_json'],
      )!,
      remoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_revision'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      )!,
    );
  }

  @override
  $CachedPublishedSummariesTable createAlias(String alias) {
    return $CachedPublishedSummariesTable(attachedDatabase, alias);
  }
}

class CachedPublishedSummaryRow extends DataClass
    implements Insertable<CachedPublishedSummaryRow> {
  final String accountId;
  final String memoryId;
  final String publishedVersionId;
  final String petIdsJson;
  final String title;
  final String? captionSnippet;
  final DateTime memoryDate;
  final String? coverMediaPath;
  final String presentationJson;
  final String remoteRevision;
  final DateTime cachedAt;
  final DateTime lastAccessedAt;
  const CachedPublishedSummaryRow({
    required this.accountId,
    required this.memoryId,
    required this.publishedVersionId,
    required this.petIdsJson,
    required this.title,
    this.captionSnippet,
    required this.memoryDate,
    this.coverMediaPath,
    required this.presentationJson,
    required this.remoteRevision,
    required this.cachedAt,
    required this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['memory_id'] = Variable<String>(memoryId);
    map['published_version_id'] = Variable<String>(publishedVersionId);
    map['pet_ids_json'] = Variable<String>(petIdsJson);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || captionSnippet != null) {
      map['caption_snippet'] = Variable<String>(captionSnippet);
    }
    map['memory_date'] = Variable<DateTime>(memoryDate);
    if (!nullToAbsent || coverMediaPath != null) {
      map['cover_media_path'] = Variable<String>(coverMediaPath);
    }
    map['presentation_json'] = Variable<String>(presentationJson);
    map['remote_revision'] = Variable<String>(remoteRevision);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    return map;
  }

  CachedPublishedSummariesCompanion toCompanion(bool nullToAbsent) {
    return CachedPublishedSummariesCompanion(
      accountId: Value(accountId),
      memoryId: Value(memoryId),
      publishedVersionId: Value(publishedVersionId),
      petIdsJson: Value(petIdsJson),
      title: Value(title),
      captionSnippet: captionSnippet == null && nullToAbsent
          ? const Value.absent()
          : Value(captionSnippet),
      memoryDate: Value(memoryDate),
      coverMediaPath: coverMediaPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverMediaPath),
      presentationJson: Value(presentationJson),
      remoteRevision: Value(remoteRevision),
      cachedAt: Value(cachedAt),
      lastAccessedAt: Value(lastAccessedAt),
    );
  }

  factory CachedPublishedSummaryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPublishedSummaryRow(
      accountId: serializer.fromJson<String>(json['accountId']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      publishedVersionId: serializer.fromJson<String>(
        json['publishedVersionId'],
      ),
      petIdsJson: serializer.fromJson<String>(json['petIdsJson']),
      title: serializer.fromJson<String>(json['title']),
      captionSnippet: serializer.fromJson<String?>(json['captionSnippet']),
      memoryDate: serializer.fromJson<DateTime>(json['memoryDate']),
      coverMediaPath: serializer.fromJson<String?>(json['coverMediaPath']),
      presentationJson: serializer.fromJson<String>(json['presentationJson']),
      remoteRevision: serializer.fromJson<String>(json['remoteRevision']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'memoryId': serializer.toJson<String>(memoryId),
      'publishedVersionId': serializer.toJson<String>(publishedVersionId),
      'petIdsJson': serializer.toJson<String>(petIdsJson),
      'title': serializer.toJson<String>(title),
      'captionSnippet': serializer.toJson<String?>(captionSnippet),
      'memoryDate': serializer.toJson<DateTime>(memoryDate),
      'coverMediaPath': serializer.toJson<String?>(coverMediaPath),
      'presentationJson': serializer.toJson<String>(presentationJson),
      'remoteRevision': serializer.toJson<String>(remoteRevision),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
    };
  }

  CachedPublishedSummaryRow copyWith({
    String? accountId,
    String? memoryId,
    String? publishedVersionId,
    String? petIdsJson,
    String? title,
    Value<String?> captionSnippet = const Value.absent(),
    DateTime? memoryDate,
    Value<String?> coverMediaPath = const Value.absent(),
    String? presentationJson,
    String? remoteRevision,
    DateTime? cachedAt,
    DateTime? lastAccessedAt,
  }) => CachedPublishedSummaryRow(
    accountId: accountId ?? this.accountId,
    memoryId: memoryId ?? this.memoryId,
    publishedVersionId: publishedVersionId ?? this.publishedVersionId,
    petIdsJson: petIdsJson ?? this.petIdsJson,
    title: title ?? this.title,
    captionSnippet: captionSnippet.present
        ? captionSnippet.value
        : this.captionSnippet,
    memoryDate: memoryDate ?? this.memoryDate,
    coverMediaPath: coverMediaPath.present
        ? coverMediaPath.value
        : this.coverMediaPath,
    presentationJson: presentationJson ?? this.presentationJson,
    remoteRevision: remoteRevision ?? this.remoteRevision,
    cachedAt: cachedAt ?? this.cachedAt,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
  );
  CachedPublishedSummaryRow copyWithCompanion(
    CachedPublishedSummariesCompanion data,
  ) {
    return CachedPublishedSummaryRow(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      publishedVersionId: data.publishedVersionId.present
          ? data.publishedVersionId.value
          : this.publishedVersionId,
      petIdsJson: data.petIdsJson.present
          ? data.petIdsJson.value
          : this.petIdsJson,
      title: data.title.present ? data.title.value : this.title,
      captionSnippet: data.captionSnippet.present
          ? data.captionSnippet.value
          : this.captionSnippet,
      memoryDate: data.memoryDate.present
          ? data.memoryDate.value
          : this.memoryDate,
      coverMediaPath: data.coverMediaPath.present
          ? data.coverMediaPath.value
          : this.coverMediaPath,
      presentationJson: data.presentationJson.present
          ? data.presentationJson.value
          : this.presentationJson,
      remoteRevision: data.remoteRevision.present
          ? data.remoteRevision.value
          : this.remoteRevision,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPublishedSummaryRow(')
          ..write('accountId: $accountId, ')
          ..write('memoryId: $memoryId, ')
          ..write('publishedVersionId: $publishedVersionId, ')
          ..write('petIdsJson: $petIdsJson, ')
          ..write('title: $title, ')
          ..write('captionSnippet: $captionSnippet, ')
          ..write('memoryDate: $memoryDate, ')
          ..write('coverMediaPath: $coverMediaPath, ')
          ..write('presentationJson: $presentationJson, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    memoryId,
    publishedVersionId,
    petIdsJson,
    title,
    captionSnippet,
    memoryDate,
    coverMediaPath,
    presentationJson,
    remoteRevision,
    cachedAt,
    lastAccessedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPublishedSummaryRow &&
          other.accountId == this.accountId &&
          other.memoryId == this.memoryId &&
          other.publishedVersionId == this.publishedVersionId &&
          other.petIdsJson == this.petIdsJson &&
          other.title == this.title &&
          other.captionSnippet == this.captionSnippet &&
          other.memoryDate == this.memoryDate &&
          other.coverMediaPath == this.coverMediaPath &&
          other.presentationJson == this.presentationJson &&
          other.remoteRevision == this.remoteRevision &&
          other.cachedAt == this.cachedAt &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class CachedPublishedSummariesCompanion
    extends UpdateCompanion<CachedPublishedSummaryRow> {
  final Value<String> accountId;
  final Value<String> memoryId;
  final Value<String> publishedVersionId;
  final Value<String> petIdsJson;
  final Value<String> title;
  final Value<String?> captionSnippet;
  final Value<DateTime> memoryDate;
  final Value<String?> coverMediaPath;
  final Value<String> presentationJson;
  final Value<String> remoteRevision;
  final Value<DateTime> cachedAt;
  final Value<DateTime> lastAccessedAt;
  final Value<int> rowid;
  const CachedPublishedSummariesCompanion({
    this.accountId = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.publishedVersionId = const Value.absent(),
    this.petIdsJson = const Value.absent(),
    this.title = const Value.absent(),
    this.captionSnippet = const Value.absent(),
    this.memoryDate = const Value.absent(),
    this.coverMediaPath = const Value.absent(),
    this.presentationJson = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPublishedSummariesCompanion.insert({
    required String accountId,
    required String memoryId,
    required String publishedVersionId,
    this.petIdsJson = const Value.absent(),
    required String title,
    this.captionSnippet = const Value.absent(),
    required DateTime memoryDate,
    this.coverMediaPath = const Value.absent(),
    this.presentationJson = const Value.absent(),
    required String remoteRevision,
    required DateTime cachedAt,
    required DateTime lastAccessedAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       memoryId = Value(memoryId),
       publishedVersionId = Value(publishedVersionId),
       title = Value(title),
       memoryDate = Value(memoryDate),
       remoteRevision = Value(remoteRevision),
       cachedAt = Value(cachedAt),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<CachedPublishedSummaryRow> custom({
    Expression<String>? accountId,
    Expression<String>? memoryId,
    Expression<String>? publishedVersionId,
    Expression<String>? petIdsJson,
    Expression<String>? title,
    Expression<String>? captionSnippet,
    Expression<DateTime>? memoryDate,
    Expression<String>? coverMediaPath,
    Expression<String>? presentationJson,
    Expression<String>? remoteRevision,
    Expression<DateTime>? cachedAt,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (memoryId != null) 'memory_id': memoryId,
      if (publishedVersionId != null)
        'published_version_id': publishedVersionId,
      if (petIdsJson != null) 'pet_ids_json': petIdsJson,
      if (title != null) 'title': title,
      if (captionSnippet != null) 'caption_snippet': captionSnippet,
      if (memoryDate != null) 'memory_date': memoryDate,
      if (coverMediaPath != null) 'cover_media_path': coverMediaPath,
      if (presentationJson != null) 'presentation_json': presentationJson,
      if (remoteRevision != null) 'remote_revision': remoteRevision,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPublishedSummariesCompanion copyWith({
    Value<String>? accountId,
    Value<String>? memoryId,
    Value<String>? publishedVersionId,
    Value<String>? petIdsJson,
    Value<String>? title,
    Value<String?>? captionSnippet,
    Value<DateTime>? memoryDate,
    Value<String?>? coverMediaPath,
    Value<String>? presentationJson,
    Value<String>? remoteRevision,
    Value<DateTime>? cachedAt,
    Value<DateTime>? lastAccessedAt,
    Value<int>? rowid,
  }) {
    return CachedPublishedSummariesCompanion(
      accountId: accountId ?? this.accountId,
      memoryId: memoryId ?? this.memoryId,
      publishedVersionId: publishedVersionId ?? this.publishedVersionId,
      petIdsJson: petIdsJson ?? this.petIdsJson,
      title: title ?? this.title,
      captionSnippet: captionSnippet ?? this.captionSnippet,
      memoryDate: memoryDate ?? this.memoryDate,
      coverMediaPath: coverMediaPath ?? this.coverMediaPath,
      presentationJson: presentationJson ?? this.presentationJson,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      cachedAt: cachedAt ?? this.cachedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (publishedVersionId.present) {
      map['published_version_id'] = Variable<String>(publishedVersionId.value);
    }
    if (petIdsJson.present) {
      map['pet_ids_json'] = Variable<String>(petIdsJson.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (captionSnippet.present) {
      map['caption_snippet'] = Variable<String>(captionSnippet.value);
    }
    if (memoryDate.present) {
      map['memory_date'] = Variable<DateTime>(memoryDate.value);
    }
    if (coverMediaPath.present) {
      map['cover_media_path'] = Variable<String>(coverMediaPath.value);
    }
    if (presentationJson.present) {
      map['presentation_json'] = Variable<String>(presentationJson.value);
    }
    if (remoteRevision.present) {
      map['remote_revision'] = Variable<String>(remoteRevision.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPublishedSummariesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('memoryId: $memoryId, ')
          ..write('publishedVersionId: $publishedVersionId, ')
          ..write('petIdsJson: $petIdsJson, ')
          ..write('title: $title, ')
          ..write('captionSnippet: $captionSnippet, ')
          ..write('memoryDate: $memoryDate, ')
          ..write('coverMediaPath: $coverMediaPath, ')
          ..write('presentationJson: $presentationJson, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOperationsTable extends SyncOperations
    with TableInfo<$SyncOperationsTable, SyncOperationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateTypeMeta = const VerificationMeta(
    'aggregateType',
  );
  @override
  late final GeneratedColumn<String> aggregateType = GeneratedColumn<String>(
    'aggregate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateIdMeta = const VerificationMeta(
    'aggregateId',
  );
  @override
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
    'aggregate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _dependencyIdsJsonMeta = const VerificationMeta(
    'dependencyIdsJson',
  );
  @override
  late final GeneratedColumn<String> dependencyIdsJson =
      GeneratedColumn<String>(
        'dependency_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
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
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteRevisionMeta = const VerificationMeta(
    'remoteRevision',
  );
  @override
  late final GeneratedColumn<String> remoteRevision = GeneratedColumn<String>(
    'remote_revision',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    id,
    aggregateType,
    aggregateId,
    operationType,
    idempotencyKey,
    payloadJson,
    dependencyIdsJson,
    status,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
    remoteRevision,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOperationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('aggregate_type')) {
      context.handle(
        _aggregateTypeMeta,
        aggregateType.isAcceptableOrUnknown(
          data['aggregate_type']!,
          _aggregateTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateTypeMeta);
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
        _aggregateIdMeta,
        aggregateId.isAcceptableOrUnknown(
          data['aggregate_id']!,
          _aggregateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('dependency_ids_json')) {
      context.handle(
        _dependencyIdsJsonMeta,
        dependencyIdsJson.isAcceptableOrUnknown(
          data['dependency_ids_json']!,
          _dependencyIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('remote_revision')) {
      context.handle(
        _remoteRevisionMeta,
        remoteRevision.isAcceptableOrUnknown(
          data['remote_revision']!,
          _remoteRevisionMeta,
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
  Set<GeneratedColumn> get $primaryKey => {accountId, id};
  @override
  SyncOperationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOperationRow(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      aggregateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_type'],
      )!,
      aggregateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      dependencyIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dependency_ids_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      remoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_revision'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncOperationsTable createAlias(String alias) {
    return $SyncOperationsTable(attachedDatabase, alias);
  }
}

class SyncOperationRow extends DataClass
    implements Insertable<SyncOperationRow> {
  final String accountId;
  final String id;
  final String aggregateType;
  final String aggregateId;
  final String operationType;
  final String idempotencyKey;
  final String payloadJson;
  final String dependencyIdsJson;
  final String status;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final String? lastErrorCode;
  final String? remoteRevision;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncOperationRow({
    required this.accountId,
    required this.id,
    required this.aggregateType,
    required this.aggregateId,
    required this.operationType,
    required this.idempotencyKey,
    required this.payloadJson,
    required this.dependencyIdsJson,
    required this.status,
    required this.attemptCount,
    this.nextAttemptAt,
    this.lastErrorCode,
    this.remoteRevision,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['id'] = Variable<String>(id);
    map['aggregate_type'] = Variable<String>(aggregateType);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['operation_type'] = Variable<String>(operationType);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['payload_json'] = Variable<String>(payloadJson);
    map['dependency_ids_json'] = Variable<String>(dependencyIdsJson);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || remoteRevision != null) {
      map['remote_revision'] = Variable<String>(remoteRevision);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return SyncOperationsCompanion(
      accountId: Value(accountId),
      id: Value(id),
      aggregateType: Value(aggregateType),
      aggregateId: Value(aggregateId),
      operationType: Value(operationType),
      idempotencyKey: Value(idempotencyKey),
      payloadJson: Value(payloadJson),
      dependencyIdsJson: Value(dependencyIdsJson),
      status: Value(status),
      attemptCount: Value(attemptCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      remoteRevision: remoteRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteRevision),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncOperationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOperationRow(
      accountId: serializer.fromJson<String>(json['accountId']),
      id: serializer.fromJson<String>(json['id']),
      aggregateType: serializer.fromJson<String>(json['aggregateType']),
      aggregateId: serializer.fromJson<String>(json['aggregateId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      dependencyIdsJson: serializer.fromJson<String>(json['dependencyIdsJson']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      remoteRevision: serializer.fromJson<String?>(json['remoteRevision']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'id': serializer.toJson<String>(id),
      'aggregateType': serializer.toJson<String>(aggregateType),
      'aggregateId': serializer.toJson<String>(aggregateId),
      'operationType': serializer.toJson<String>(operationType),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'dependencyIdsJson': serializer.toJson<String>(dependencyIdsJson),
      'status': serializer.toJson<String>(status),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'remoteRevision': serializer.toJson<String?>(remoteRevision),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncOperationRow copyWith({
    String? accountId,
    String? id,
    String? aggregateType,
    String? aggregateId,
    String? operationType,
    String? idempotencyKey,
    String? payloadJson,
    String? dependencyIdsJson,
    String? status,
    int? attemptCount,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
    Value<String?> remoteRevision = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SyncOperationRow(
    accountId: accountId ?? this.accountId,
    id: id ?? this.id,
    aggregateType: aggregateType ?? this.aggregateType,
    aggregateId: aggregateId ?? this.aggregateId,
    operationType: operationType ?? this.operationType,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    payloadJson: payloadJson ?? this.payloadJson,
    dependencyIdsJson: dependencyIdsJson ?? this.dependencyIdsJson,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    remoteRevision: remoteRevision.present
        ? remoteRevision.value
        : this.remoteRevision,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncOperationRow copyWithCompanion(SyncOperationsCompanion data) {
    return SyncOperationRow(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      id: data.id.present ? data.id.value : this.id,
      aggregateType: data.aggregateType.present
          ? data.aggregateType.value
          : this.aggregateType,
      aggregateId: data.aggregateId.present
          ? data.aggregateId.value
          : this.aggregateId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      dependencyIdsJson: data.dependencyIdsJson.present
          ? data.dependencyIdsJson.value
          : this.dependencyIdsJson,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      remoteRevision: data.remoteRevision.present
          ? data.remoteRevision.value
          : this.remoteRevision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationRow(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('operationType: $operationType, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependencyIdsJson: $dependencyIdsJson, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    id,
    aggregateType,
    aggregateId,
    operationType,
    idempotencyKey,
    payloadJson,
    dependencyIdsJson,
    status,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
    remoteRevision,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOperationRow &&
          other.accountId == this.accountId &&
          other.id == this.id &&
          other.aggregateType == this.aggregateType &&
          other.aggregateId == this.aggregateId &&
          other.operationType == this.operationType &&
          other.idempotencyKey == this.idempotencyKey &&
          other.payloadJson == this.payloadJson &&
          other.dependencyIdsJson == this.dependencyIdsJson &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastErrorCode == this.lastErrorCode &&
          other.remoteRevision == this.remoteRevision &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncOperationsCompanion extends UpdateCompanion<SyncOperationRow> {
  final Value<String> accountId;
  final Value<String> id;
  final Value<String> aggregateType;
  final Value<String> aggregateId;
  final Value<String> operationType;
  final Value<String> idempotencyKey;
  final Value<String> payloadJson;
  final Value<String> dependencyIdsJson;
  final Value<String> status;
  final Value<int> attemptCount;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastErrorCode;
  final Value<String?> remoteRevision;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncOperationsCompanion({
    this.accountId = const Value.absent(),
    this.id = const Value.absent(),
    this.aggregateType = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.dependencyIdsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOperationsCompanion.insert({
    required String accountId,
    required String id,
    required String aggregateType,
    required String aggregateId,
    required String operationType,
    required String idempotencyKey,
    this.payloadJson = const Value.absent(),
    this.dependencyIdsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       id = Value(id),
       aggregateType = Value(aggregateType),
       aggregateId = Value(aggregateId),
       operationType = Value(operationType),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SyncOperationRow> custom({
    Expression<String>? accountId,
    Expression<String>? id,
    Expression<String>? aggregateType,
    Expression<String>? aggregateId,
    Expression<String>? operationType,
    Expression<String>? idempotencyKey,
    Expression<String>? payloadJson,
    Expression<String>? dependencyIdsJson,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastErrorCode,
    Expression<String>? remoteRevision,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (id != null) 'id': id,
      if (aggregateType != null) 'aggregate_type': aggregateType,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (operationType != null) 'operation_type': operationType,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (dependencyIdsJson != null) 'dependency_ids_json': dependencyIdsJson,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (remoteRevision != null) 'remote_revision': remoteRevision,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOperationsCompanion copyWith({
    Value<String>? accountId,
    Value<String>? id,
    Value<String>? aggregateType,
    Value<String>? aggregateId,
    Value<String>? operationType,
    Value<String>? idempotencyKey,
    Value<String>? payloadJson,
    Value<String>? dependencyIdsJson,
    Value<String>? status,
    Value<int>? attemptCount,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastErrorCode,
    Value<String?>? remoteRevision,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncOperationsCompanion(
      accountId: accountId ?? this.accountId,
      id: id ?? this.id,
      aggregateType: aggregateType ?? this.aggregateType,
      aggregateId: aggregateId ?? this.aggregateId,
      operationType: operationType ?? this.operationType,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      payloadJson: payloadJson ?? this.payloadJson,
      dependencyIdsJson: dependencyIdsJson ?? this.dependencyIdsJson,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (aggregateType.present) {
      map['aggregate_type'] = Variable<String>(aggregateType.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (dependencyIdsJson.present) {
      map['dependency_ids_json'] = Variable<String>(dependencyIdsJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (remoteRevision.present) {
      map['remote_revision'] = Variable<String>(remoteRevision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationsCompanion(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('operationType: $operationType, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependencyIdsJson: $dependencyIdsJson, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreferenceRow> instance, {
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
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreferenceRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreferenceRow extends DataClass
    implements Insertable<AppPreferenceRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppPreferenceRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppPreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreferenceRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppPreferenceRow copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => AppPreferenceRow(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppPreferenceRow copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreferenceRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferenceRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreferenceRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreferenceRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppPreferenceRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PawlumDatabase extends GeneratedDatabase {
  _$PawlumDatabase(QueryExecutor e) : super(e);
  $PawlumDatabaseManager get managers => $PawlumDatabaseManager(this);
  late final $OnboardingDraftsTable onboardingDrafts = $OnboardingDraftsTable(
    this,
  );
  late final $MemoryDraftsTable memoryDrafts = $MemoryDraftsTable(this);
  late final $LocalMediaReferencesTable localMediaReferences =
      $LocalMediaReferencesTable(this);
  late final $CachedPublishedSummariesTable cachedPublishedSummaries =
      $CachedPublishedSummariesTable(this);
  late final $SyncOperationsTable syncOperations = $SyncOperationsTable(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final Index onboardingDraftsAccount = Index(
    'onboarding_drafts_account',
    'CREATE INDEX onboarding_drafts_account ON onboarding_drafts (account_id)',
  );
  late final Index memoryDraftsAccountUpdated = Index(
    'memory_drafts_account_updated',
    'CREATE INDEX memory_drafts_account_updated ON memory_drafts (account_id, updated_at)',
  );
  late final Index memoryDraftsAccountMemoryKind = Index(
    'memory_drafts_account_memory_kind',
    'CREATE UNIQUE INDEX memory_drafts_account_memory_kind ON memory_drafts (account_id, memory_id, draft_kind)',
  );
  late final Index localMediaAccountOwner = Index(
    'local_media_account_owner',
    'CREATE INDEX local_media_account_owner ON local_media_references (account_id, owner_draft_id)',
  );
  late final Index localMediaAccountUploadState = Index(
    'local_media_account_upload_state',
    'CREATE INDEX local_media_account_upload_state ON local_media_references (account_id, upload_state)',
  );
  late final Index publishedSummariesAccountMemoryDate = Index(
    'published_summaries_account_memory_date',
    'CREATE INDEX published_summaries_account_memory_date ON cached_published_summaries (account_id, memory_date)',
  );
  late final Index publishedSummariesAccountAccessed = Index(
    'published_summaries_account_accessed',
    'CREATE INDEX published_summaries_account_accessed ON cached_published_summaries (account_id, last_accessed_at)',
  );
  late final Index syncOperationsAccountReady = Index(
    'sync_operations_account_ready',
    'CREATE INDEX sync_operations_account_ready ON sync_operations (account_id, status, next_attempt_at)',
  );
  late final Index syncOperationsAccountIdempotency = Index(
    'sync_operations_account_idempotency',
    'CREATE UNIQUE INDEX sync_operations_account_idempotency ON sync_operations (account_id, idempotency_key)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    onboardingDrafts,
    memoryDrafts,
    localMediaReferences,
    cachedPublishedSummaries,
    syncOperations,
    appPreferences,
    onboardingDraftsAccount,
    memoryDraftsAccountUpdated,
    memoryDraftsAccountMemoryKind,
    localMediaAccountOwner,
    localMediaAccountUploadState,
    publishedSummariesAccountMemoryDate,
    publishedSummariesAccountAccessed,
    syncOperationsAccountReady,
    syncOperationsAccountIdempotency,
  ];
}

typedef $$OnboardingDraftsTableCreateCompanionBuilder =
    OnboardingDraftsCompanion Function({
      required String accountId,
      required String id,
      Value<int> currentStep,
      Value<String> payloadJson,
      Value<String?> remoteRevision,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$OnboardingDraftsTableUpdateCompanionBuilder =
    OnboardingDraftsCompanion Function({
      Value<String> accountId,
      Value<String> id,
      Value<int> currentStep,
      Value<String> payloadJson,
      Value<String?> remoteRevision,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$OnboardingDraftsTableFilterComposer
    extends Composer<_$PawlumDatabase, $OnboardingDraftsTable> {
  $$OnboardingDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OnboardingDraftsTableOrderingComposer
    extends Composer<_$PawlumDatabase, $OnboardingDraftsTable> {
  $$OnboardingDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OnboardingDraftsTableAnnotationComposer
    extends Composer<_$PawlumDatabase, $OnboardingDraftsTable> {
  $$OnboardingDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OnboardingDraftsTableTableManager
    extends
        RootTableManager<
          _$PawlumDatabase,
          $OnboardingDraftsTable,
          OnboardingDraftRow,
          $$OnboardingDraftsTableFilterComposer,
          $$OnboardingDraftsTableOrderingComposer,
          $$OnboardingDraftsTableAnnotationComposer,
          $$OnboardingDraftsTableCreateCompanionBuilder,
          $$OnboardingDraftsTableUpdateCompanionBuilder,
          (
            OnboardingDraftRow,
            BaseReferences<
              _$PawlumDatabase,
              $OnboardingDraftsTable,
              OnboardingDraftRow
            >,
          ),
          OnboardingDraftRow,
          PrefetchHooks Function()
        > {
  $$OnboardingDraftsTableTableManager(
    _$PawlumDatabase db,
    $OnboardingDraftsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OnboardingDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OnboardingDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OnboardingDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> currentStep = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> remoteRevision = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OnboardingDraftsCompanion(
                accountId: accountId,
                id: id,
                currentStep: currentStep,
                payloadJson: payloadJson,
                remoteRevision: remoteRevision,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String id,
                Value<int> currentStep = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> remoteRevision = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OnboardingDraftsCompanion.insert(
                accountId: accountId,
                id: id,
                currentStep: currentStep,
                payloadJson: payloadJson,
                remoteRevision: remoteRevision,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OnboardingDraftsTable, OnboardingDraftRow>(
                    table,
                  ),
                  BaseReferences<
                    _$PawlumDatabase,
                    $OnboardingDraftsTable,
                    OnboardingDraftRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OnboardingDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$PawlumDatabase,
      $OnboardingDraftsTable,
      OnboardingDraftRow,
      $$OnboardingDraftsTableFilterComposer,
      $$OnboardingDraftsTableOrderingComposer,
      $$OnboardingDraftsTableAnnotationComposer,
      $$OnboardingDraftsTableCreateCompanionBuilder,
      $$OnboardingDraftsTableUpdateCompanionBuilder,
      (
        OnboardingDraftRow,
        BaseReferences<
          _$PawlumDatabase,
          $OnboardingDraftsTable,
          OnboardingDraftRow
        >,
      ),
      OnboardingDraftRow,
      PrefetchHooks Function()
    >;
typedef $$MemoryDraftsTableCreateCompanionBuilder =
    MemoryDraftsCompanion Function({
      required String accountId,
      required String id,
      required String memoryId,
      required String draftKind,
      Value<String?> basePublishedVersionId,
      Value<String?> baseRemoteRevision,
      Value<int> currentStep,
      Value<String> payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MemoryDraftsTableUpdateCompanionBuilder =
    MemoryDraftsCompanion Function({
      Value<String> accountId,
      Value<String> id,
      Value<String> memoryId,
      Value<String> draftKind,
      Value<String?> basePublishedVersionId,
      Value<String?> baseRemoteRevision,
      Value<int> currentStep,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MemoryDraftsTableFilterComposer
    extends Composer<_$PawlumDatabase, $MemoryDraftsTable> {
  $$MemoryDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get draftKind => $composableBuilder(
    column: $table.draftKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basePublishedVersionId => $composableBuilder(
    column: $table.basePublishedVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseRemoteRevision => $composableBuilder(
    column: $table.baseRemoteRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemoryDraftsTableOrderingComposer
    extends Composer<_$PawlumDatabase, $MemoryDraftsTable> {
  $$MemoryDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get draftKind => $composableBuilder(
    column: $table.draftKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basePublishedVersionId => $composableBuilder(
    column: $table.basePublishedVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseRemoteRevision => $composableBuilder(
    column: $table.baseRemoteRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoryDraftsTableAnnotationComposer
    extends Composer<_$PawlumDatabase, $MemoryDraftsTable> {
  $$MemoryDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memoryId =>
      $composableBuilder(column: $table.memoryId, builder: (column) => column);

  GeneratedColumn<String> get draftKind =>
      $composableBuilder(column: $table.draftKind, builder: (column) => column);

  GeneratedColumn<String> get basePublishedVersionId => $composableBuilder(
    column: $table.basePublishedVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseRemoteRevision => $composableBuilder(
    column: $table.baseRemoteRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MemoryDraftsTableTableManager
    extends
        RootTableManager<
          _$PawlumDatabase,
          $MemoryDraftsTable,
          MemoryDraftRow,
          $$MemoryDraftsTableFilterComposer,
          $$MemoryDraftsTableOrderingComposer,
          $$MemoryDraftsTableAnnotationComposer,
          $$MemoryDraftsTableCreateCompanionBuilder,
          $$MemoryDraftsTableUpdateCompanionBuilder,
          (
            MemoryDraftRow,
            BaseReferences<
              _$PawlumDatabase,
              $MemoryDraftsTable,
              MemoryDraftRow
            >,
          ),
          MemoryDraftRow,
          PrefetchHooks Function()
        > {
  $$MemoryDraftsTableTableManager(_$PawlumDatabase db, $MemoryDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> memoryId = const Value.absent(),
                Value<String> draftKind = const Value.absent(),
                Value<String?> basePublishedVersionId = const Value.absent(),
                Value<String?> baseRemoteRevision = const Value.absent(),
                Value<int> currentStep = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryDraftsCompanion(
                accountId: accountId,
                id: id,
                memoryId: memoryId,
                draftKind: draftKind,
                basePublishedVersionId: basePublishedVersionId,
                baseRemoteRevision: baseRemoteRevision,
                currentStep: currentStep,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String id,
                required String memoryId,
                required String draftKind,
                Value<String?> basePublishedVersionId = const Value.absent(),
                Value<String?> baseRemoteRevision = const Value.absent(),
                Value<int> currentStep = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MemoryDraftsCompanion.insert(
                accountId: accountId,
                id: id,
                memoryId: memoryId,
                draftKind: draftKind,
                basePublishedVersionId: basePublishedVersionId,
                baseRemoteRevision: baseRemoteRevision,
                currentStep: currentStep,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemoryDraftsTable, MemoryDraftRow>(table),
                  BaseReferences<
                    _$PawlumDatabase,
                    $MemoryDraftsTable,
                    MemoryDraftRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemoryDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$PawlumDatabase,
      $MemoryDraftsTable,
      MemoryDraftRow,
      $$MemoryDraftsTableFilterComposer,
      $$MemoryDraftsTableOrderingComposer,
      $$MemoryDraftsTableAnnotationComposer,
      $$MemoryDraftsTableCreateCompanionBuilder,
      $$MemoryDraftsTableUpdateCompanionBuilder,
      (
        MemoryDraftRow,
        BaseReferences<_$PawlumDatabase, $MemoryDraftsTable, MemoryDraftRow>,
      ),
      MemoryDraftRow,
      PrefetchHooks Function()
    >;
typedef $$LocalMediaReferencesTableCreateCompanionBuilder =
    LocalMediaReferencesCompanion Function({
      required String accountId,
      required String id,
      required String ownerDraftType,
      required String ownerDraftId,
      required String localPath,
      required String mediaType,
      Value<int> sortOrder,
      Value<String?> checksum,
      Value<String> uploadState,
      Value<String?> remoteObjectPath,
      Value<String> metadataJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalMediaReferencesTableUpdateCompanionBuilder =
    LocalMediaReferencesCompanion Function({
      Value<String> accountId,
      Value<String> id,
      Value<String> ownerDraftType,
      Value<String> ownerDraftId,
      Value<String> localPath,
      Value<String> mediaType,
      Value<int> sortOrder,
      Value<String?> checksum,
      Value<String> uploadState,
      Value<String?> remoteObjectPath,
      Value<String> metadataJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalMediaReferencesTableFilterComposer
    extends Composer<_$PawlumDatabase, $LocalMediaReferencesTable> {
  $$LocalMediaReferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerDraftType => $composableBuilder(
    column: $table.ownerDraftType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerDraftId => $composableBuilder(
    column: $table.ownerDraftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteObjectPath => $composableBuilder(
    column: $table.remoteObjectPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMediaReferencesTableOrderingComposer
    extends Composer<_$PawlumDatabase, $LocalMediaReferencesTable> {
  $$LocalMediaReferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerDraftType => $composableBuilder(
    column: $table.ownerDraftType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerDraftId => $composableBuilder(
    column: $table.ownerDraftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteObjectPath => $composableBuilder(
    column: $table.remoteObjectPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMediaReferencesTableAnnotationComposer
    extends Composer<_$PawlumDatabase, $LocalMediaReferencesTable> {
  $$LocalMediaReferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerDraftType => $composableBuilder(
    column: $table.ownerDraftType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerDraftId => $composableBuilder(
    column: $table.ownerDraftId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteObjectPath => $composableBuilder(
    column: $table.remoteObjectPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalMediaReferencesTableTableManager
    extends
        RootTableManager<
          _$PawlumDatabase,
          $LocalMediaReferencesTable,
          LocalMediaReferenceRow,
          $$LocalMediaReferencesTableFilterComposer,
          $$LocalMediaReferencesTableOrderingComposer,
          $$LocalMediaReferencesTableAnnotationComposer,
          $$LocalMediaReferencesTableCreateCompanionBuilder,
          $$LocalMediaReferencesTableUpdateCompanionBuilder,
          (
            LocalMediaReferenceRow,
            BaseReferences<
              _$PawlumDatabase,
              $LocalMediaReferencesTable,
              LocalMediaReferenceRow
            >,
          ),
          LocalMediaReferenceRow,
          PrefetchHooks Function()
        > {
  $$LocalMediaReferencesTableTableManager(
    _$PawlumDatabase db,
    $LocalMediaReferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMediaReferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMediaReferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalMediaReferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> ownerDraftType = const Value.absent(),
                Value<String> ownerDraftId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<String> uploadState = const Value.absent(),
                Value<String?> remoteObjectPath = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMediaReferencesCompanion(
                accountId: accountId,
                id: id,
                ownerDraftType: ownerDraftType,
                ownerDraftId: ownerDraftId,
                localPath: localPath,
                mediaType: mediaType,
                sortOrder: sortOrder,
                checksum: checksum,
                uploadState: uploadState,
                remoteObjectPath: remoteObjectPath,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String id,
                required String ownerDraftType,
                required String ownerDraftId,
                required String localPath,
                required String mediaType,
                Value<int> sortOrder = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<String> uploadState = const Value.absent(),
                Value<String?> remoteObjectPath = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalMediaReferencesCompanion.insert(
                accountId: accountId,
                id: id,
                ownerDraftType: ownerDraftType,
                ownerDraftId: ownerDraftId,
                localPath: localPath,
                mediaType: mediaType,
                sortOrder: sortOrder,
                checksum: checksum,
                uploadState: uploadState,
                remoteObjectPath: remoteObjectPath,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LocalMediaReferencesTable,
                    LocalMediaReferenceRow
                  >(table),
                  BaseReferences<
                    _$PawlumDatabase,
                    $LocalMediaReferencesTable,
                    LocalMediaReferenceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMediaReferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$PawlumDatabase,
      $LocalMediaReferencesTable,
      LocalMediaReferenceRow,
      $$LocalMediaReferencesTableFilterComposer,
      $$LocalMediaReferencesTableOrderingComposer,
      $$LocalMediaReferencesTableAnnotationComposer,
      $$LocalMediaReferencesTableCreateCompanionBuilder,
      $$LocalMediaReferencesTableUpdateCompanionBuilder,
      (
        LocalMediaReferenceRow,
        BaseReferences<
          _$PawlumDatabase,
          $LocalMediaReferencesTable,
          LocalMediaReferenceRow
        >,
      ),
      LocalMediaReferenceRow,
      PrefetchHooks Function()
    >;
typedef $$CachedPublishedSummariesTableCreateCompanionBuilder =
    CachedPublishedSummariesCompanion Function({
      required String accountId,
      required String memoryId,
      required String publishedVersionId,
      Value<String> petIdsJson,
      required String title,
      Value<String?> captionSnippet,
      required DateTime memoryDate,
      Value<String?> coverMediaPath,
      Value<String> presentationJson,
      required String remoteRevision,
      required DateTime cachedAt,
      required DateTime lastAccessedAt,
      Value<int> rowid,
    });
typedef $$CachedPublishedSummariesTableUpdateCompanionBuilder =
    CachedPublishedSummariesCompanion Function({
      Value<String> accountId,
      Value<String> memoryId,
      Value<String> publishedVersionId,
      Value<String> petIdsJson,
      Value<String> title,
      Value<String?> captionSnippet,
      Value<DateTime> memoryDate,
      Value<String?> coverMediaPath,
      Value<String> presentationJson,
      Value<String> remoteRevision,
      Value<DateTime> cachedAt,
      Value<DateTime> lastAccessedAt,
      Value<int> rowid,
    });

class $$CachedPublishedSummariesTableFilterComposer
    extends Composer<_$PawlumDatabase, $CachedPublishedSummariesTable> {
  $$CachedPublishedSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publishedVersionId => $composableBuilder(
    column: $table.publishedVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get petIdsJson => $composableBuilder(
    column: $table.petIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get captionSnippet => $composableBuilder(
    column: $table.captionSnippet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get memoryDate => $composableBuilder(
    column: $table.memoryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverMediaPath => $composableBuilder(
    column: $table.coverMediaPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presentationJson => $composableBuilder(
    column: $table.presentationJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPublishedSummariesTableOrderingComposer
    extends Composer<_$PawlumDatabase, $CachedPublishedSummariesTable> {
  $$CachedPublishedSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publishedVersionId => $composableBuilder(
    column: $table.publishedVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get petIdsJson => $composableBuilder(
    column: $table.petIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get captionSnippet => $composableBuilder(
    column: $table.captionSnippet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get memoryDate => $composableBuilder(
    column: $table.memoryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverMediaPath => $composableBuilder(
    column: $table.coverMediaPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presentationJson => $composableBuilder(
    column: $table.presentationJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPublishedSummariesTableAnnotationComposer
    extends Composer<_$PawlumDatabase, $CachedPublishedSummariesTable> {
  $$CachedPublishedSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get memoryId =>
      $composableBuilder(column: $table.memoryId, builder: (column) => column);

  GeneratedColumn<String> get publishedVersionId => $composableBuilder(
    column: $table.publishedVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get petIdsJson => $composableBuilder(
    column: $table.petIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get captionSnippet => $composableBuilder(
    column: $table.captionSnippet,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get memoryDate => $composableBuilder(
    column: $table.memoryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverMediaPath => $composableBuilder(
    column: $table.coverMediaPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get presentationJson => $composableBuilder(
    column: $table.presentationJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );
}

class $$CachedPublishedSummariesTableTableManager
    extends
        RootTableManager<
          _$PawlumDatabase,
          $CachedPublishedSummariesTable,
          CachedPublishedSummaryRow,
          $$CachedPublishedSummariesTableFilterComposer,
          $$CachedPublishedSummariesTableOrderingComposer,
          $$CachedPublishedSummariesTableAnnotationComposer,
          $$CachedPublishedSummariesTableCreateCompanionBuilder,
          $$CachedPublishedSummariesTableUpdateCompanionBuilder,
          (
            CachedPublishedSummaryRow,
            BaseReferences<
              _$PawlumDatabase,
              $CachedPublishedSummariesTable,
              CachedPublishedSummaryRow
            >,
          ),
          CachedPublishedSummaryRow,
          PrefetchHooks Function()
        > {
  $$CachedPublishedSummariesTableTableManager(
    _$PawlumDatabase db,
    $CachedPublishedSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPublishedSummariesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CachedPublishedSummariesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedPublishedSummariesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> memoryId = const Value.absent(),
                Value<String> publishedVersionId = const Value.absent(),
                Value<String> petIdsJson = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> captionSnippet = const Value.absent(),
                Value<DateTime> memoryDate = const Value.absent(),
                Value<String?> coverMediaPath = const Value.absent(),
                Value<String> presentationJson = const Value.absent(),
                Value<String> remoteRevision = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<DateTime> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPublishedSummariesCompanion(
                accountId: accountId,
                memoryId: memoryId,
                publishedVersionId: publishedVersionId,
                petIdsJson: petIdsJson,
                title: title,
                captionSnippet: captionSnippet,
                memoryDate: memoryDate,
                coverMediaPath: coverMediaPath,
                presentationJson: presentationJson,
                remoteRevision: remoteRevision,
                cachedAt: cachedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String memoryId,
                required String publishedVersionId,
                Value<String> petIdsJson = const Value.absent(),
                required String title,
                Value<String?> captionSnippet = const Value.absent(),
                required DateTime memoryDate,
                Value<String?> coverMediaPath = const Value.absent(),
                Value<String> presentationJson = const Value.absent(),
                required String remoteRevision,
                required DateTime cachedAt,
                required DateTime lastAccessedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedPublishedSummariesCompanion.insert(
                accountId: accountId,
                memoryId: memoryId,
                publishedVersionId: publishedVersionId,
                petIdsJson: petIdsJson,
                title: title,
                captionSnippet: captionSnippet,
                memoryDate: memoryDate,
                coverMediaPath: coverMediaPath,
                presentationJson: presentationJson,
                remoteRevision: remoteRevision,
                cachedAt: cachedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CachedPublishedSummariesTable,
                    CachedPublishedSummaryRow
                  >(table),
                  BaseReferences<
                    _$PawlumDatabase,
                    $CachedPublishedSummariesTable,
                    CachedPublishedSummaryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPublishedSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$PawlumDatabase,
      $CachedPublishedSummariesTable,
      CachedPublishedSummaryRow,
      $$CachedPublishedSummariesTableFilterComposer,
      $$CachedPublishedSummariesTableOrderingComposer,
      $$CachedPublishedSummariesTableAnnotationComposer,
      $$CachedPublishedSummariesTableCreateCompanionBuilder,
      $$CachedPublishedSummariesTableUpdateCompanionBuilder,
      (
        CachedPublishedSummaryRow,
        BaseReferences<
          _$PawlumDatabase,
          $CachedPublishedSummariesTable,
          CachedPublishedSummaryRow
        >,
      ),
      CachedPublishedSummaryRow,
      PrefetchHooks Function()
    >;
typedef $$SyncOperationsTableCreateCompanionBuilder =
    SyncOperationsCompanion Function({
      required String accountId,
      required String id,
      required String aggregateType,
      required String aggregateId,
      required String operationType,
      required String idempotencyKey,
      Value<String> payloadJson,
      Value<String> dependencyIdsJson,
      Value<String> status,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastErrorCode,
      Value<String?> remoteRevision,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncOperationsTableUpdateCompanionBuilder =
    SyncOperationsCompanion Function({
      Value<String> accountId,
      Value<String> id,
      Value<String> aggregateType,
      Value<String> aggregateId,
      Value<String> operationType,
      Value<String> idempotencyKey,
      Value<String> payloadJson,
      Value<String> dependencyIdsJson,
      Value<String> status,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastErrorCode,
      Value<String?> remoteRevision,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncOperationsTableFilterComposer
    extends Composer<_$PawlumDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependencyIdsJson => $composableBuilder(
    column: $table.dependencyIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOperationsTableOrderingComposer
    extends Composer<_$PawlumDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependencyIdsJson => $composableBuilder(
    column: $table.dependencyIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOperationsTableAnnotationComposer
    extends Composer<_$PawlumDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependencyIdsJson => $composableBuilder(
    column: $table.dependencyIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncOperationsTableTableManager
    extends
        RootTableManager<
          _$PawlumDatabase,
          $SyncOperationsTable,
          SyncOperationRow,
          $$SyncOperationsTableFilterComposer,
          $$SyncOperationsTableOrderingComposer,
          $$SyncOperationsTableAnnotationComposer,
          $$SyncOperationsTableCreateCompanionBuilder,
          $$SyncOperationsTableUpdateCompanionBuilder,
          (
            SyncOperationRow,
            BaseReferences<
              _$PawlumDatabase,
              $SyncOperationsTable,
              SyncOperationRow
            >,
          ),
          SyncOperationRow,
          PrefetchHooks Function()
        > {
  $$SyncOperationsTableTableManager(
    _$PawlumDatabase db,
    $SyncOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> aggregateType = const Value.absent(),
                Value<String> aggregateId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> dependencyIdsJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> remoteRevision = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion(
                accountId: accountId,
                id: id,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                operationType: operationType,
                idempotencyKey: idempotencyKey,
                payloadJson: payloadJson,
                dependencyIdsJson: dependencyIdsJson,
                status: status,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                remoteRevision: remoteRevision,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String id,
                required String aggregateType,
                required String aggregateId,
                required String operationType,
                required String idempotencyKey,
                Value<String> payloadJson = const Value.absent(),
                Value<String> dependencyIdsJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> remoteRevision = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion.insert(
                accountId: accountId,
                id: id,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                operationType: operationType,
                idempotencyKey: idempotencyKey,
                payloadJson: payloadJson,
                dependencyIdsJson: dependencyIdsJson,
                status: status,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                remoteRevision: remoteRevision,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOperationsTable, SyncOperationRow>(table),
                  BaseReferences<
                    _$PawlumDatabase,
                    $SyncOperationsTable,
                    SyncOperationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$PawlumDatabase,
      $SyncOperationsTable,
      SyncOperationRow,
      $$SyncOperationsTableFilterComposer,
      $$SyncOperationsTableOrderingComposer,
      $$SyncOperationsTableAnnotationComposer,
      $$SyncOperationsTableCreateCompanionBuilder,
      $$SyncOperationsTableUpdateCompanionBuilder,
      (
        SyncOperationRow,
        BaseReferences<
          _$PawlumDatabase,
          $SyncOperationsTable,
          SyncOperationRow
        >,
      ),
      SyncOperationRow,
      PrefetchHooks Function()
    >;
typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$PawlumDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$PawlumDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$PawlumDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$PawlumDatabase,
          $AppPreferencesTable,
          AppPreferenceRow,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreferenceRow,
            BaseReferences<
              _$PawlumDatabase,
              $AppPreferencesTable,
              AppPreferenceRow
            >,
          ),
          AppPreferenceRow,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$PawlumDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppPreferencesTable, AppPreferenceRow>(table),
                  BaseReferences<
                    _$PawlumDatabase,
                    $AppPreferencesTable,
                    AppPreferenceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$PawlumDatabase,
      $AppPreferencesTable,
      AppPreferenceRow,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreferenceRow,
        BaseReferences<
          _$PawlumDatabase,
          $AppPreferencesTable,
          AppPreferenceRow
        >,
      ),
      AppPreferenceRow,
      PrefetchHooks Function()
    >;

class $PawlumDatabaseManager {
  final _$PawlumDatabase _db;
  $PawlumDatabaseManager(this._db);
  $$OnboardingDraftsTableTableManager get onboardingDrafts =>
      $$OnboardingDraftsTableTableManager(_db, _db.onboardingDrafts);
  $$MemoryDraftsTableTableManager get memoryDrafts =>
      $$MemoryDraftsTableTableManager(_db, _db.memoryDrafts);
  $$LocalMediaReferencesTableTableManager get localMediaReferences =>
      $$LocalMediaReferencesTableTableManager(_db, _db.localMediaReferences);
  $$CachedPublishedSummariesTableTableManager get cachedPublishedSummaries =>
      $$CachedPublishedSummariesTableTableManager(
        _db,
        _db.cachedPublishedSummaries,
      );
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(_db, _db.syncOperations);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
}
