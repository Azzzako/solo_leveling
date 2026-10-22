// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(500),
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    xpReward,
    deadline,
    isArchived,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('xp_reward')) {
      context.handle(
        _xpRewardMeta,
        xpReward.isAcceptableOrUnknown(data['xp_reward']!, _xpRewardMeta),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
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
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      xpReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_reward'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final DateTime? deadline;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? completedAt;
  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    this.deadline,
    required this.isArchived,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['xp_reward'] = Variable<int>(xpReward);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      xpReward: Value(xpReward),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      xpReward: serializer.fromJson<int>(json['xpReward']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'xpReward': serializer.toJson<int>(xpReward),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    int? xpReward,
    Value<DateTime?> deadline = const Value.absent(),
    bool? isArchived,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => Goal(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    xpReward: xpReward ?? this.xpReward,
    deadline: deadline.present ? deadline.value : this.deadline,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('xpReward: $xpReward, ')
          ..write('deadline: $deadline, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    xpReward,
    deadline,
    isArchived,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.xpReward == this.xpReward &&
          other.deadline == this.deadline &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> xpReward;
  final Value<DateTime?> deadline;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.deadline = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.deadline = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<Goal> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? xpReward,
    Expression<DateTime>? deadline,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (xpReward != null) 'xp_reward': xpReward,
      if (deadline != null) 'deadline': deadline,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<int>? xpReward,
    Value<DateTime?>? deadline,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      deadline: deadline ?? this.deadline,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('xpReward: $xpReward, ')
          ..write('deadline: $deadline, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MissionsTable extends Missions with TableInfo<$MissionsTable, Mission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MissionDifficulty, int>
  difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<MissionDifficulty>($MissionsTable.$converterdifficulty);
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
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDailyMeta = const VerificationMeta(
    'isDaily',
  );
  @override
  late final GeneratedColumn<bool> isDaily = GeneratedColumn<bool>(
    'is_daily',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_daily" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    goalId,
    difficulty,
    xpReward,
    progress,
    target,
    isDaily,
    dueDate,
    isActive,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'missions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
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
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('is_daily')) {
      context.handle(
        _isDailyMeta,
        isDaily.isAcceptableOrUnknown(data['is_daily']!, _isDailyMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
  Mission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      ),
      difficulty: $MissionsTable.$converterdifficulty.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}difficulty'],
        )!,
      ),
      xpReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_reward'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      )!,
      isDaily: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_daily'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MissionsTable createAlias(String alias) {
    return $MissionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MissionDifficulty, int, int> $converterdifficulty =
      const EnumIndexConverter<MissionDifficulty>(MissionDifficulty.values);
}

class Mission extends DataClass implements Insertable<Mission> {
  final String id;
  final String title;
  final String description;
  final String? goalId;
  final MissionDifficulty difficulty;
  final int xpReward;
  final int progress;
  final int target;
  final bool isDaily;
  final DateTime? dueDate;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    this.goalId,
    required this.difficulty,
    required this.xpReward,
    required this.progress,
    required this.target,
    required this.isDaily,
    this.dueDate,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || goalId != null) {
      map['goal_id'] = Variable<String>(goalId);
    }
    {
      map['difficulty'] = Variable<int>(
        $MissionsTable.$converterdifficulty.toSql(difficulty),
      );
    }
    map['xp_reward'] = Variable<int>(xpReward);
    map['progress'] = Variable<int>(progress);
    map['target'] = Variable<int>(target);
    map['is_daily'] = Variable<bool>(isDaily);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MissionsCompanion toCompanion(bool nullToAbsent) {
    return MissionsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      goalId: goalId == null && nullToAbsent
          ? const Value.absent()
          : Value(goalId),
      difficulty: Value(difficulty),
      xpReward: Value(xpReward),
      progress: Value(progress),
      target: Value(target),
      isDaily: Value(isDaily),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Mission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mission(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      goalId: serializer.fromJson<String?>(json['goalId']),
      difficulty: $MissionsTable.$converterdifficulty.fromJson(
        serializer.fromJson<int>(json['difficulty']),
      ),
      xpReward: serializer.fromJson<int>(json['xpReward']),
      progress: serializer.fromJson<int>(json['progress']),
      target: serializer.fromJson<int>(json['target']),
      isDaily: serializer.fromJson<bool>(json['isDaily']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'goalId': serializer.toJson<String?>(goalId),
      'difficulty': serializer.toJson<int>(
        $MissionsTable.$converterdifficulty.toJson(difficulty),
      ),
      'xpReward': serializer.toJson<int>(xpReward),
      'progress': serializer.toJson<int>(progress),
      'target': serializer.toJson<int>(target),
      'isDaily': serializer.toJson<bool>(isDaily),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    Value<String?> goalId = const Value.absent(),
    MissionDifficulty? difficulty,
    int? xpReward,
    int? progress,
    int? target,
    bool? isDaily,
    Value<DateTime?> dueDate = const Value.absent(),
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
  }) => Mission(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    goalId: goalId.present ? goalId.value : this.goalId,
    difficulty: difficulty ?? this.difficulty,
    xpReward: xpReward ?? this.xpReward,
    progress: progress ?? this.progress,
    target: target ?? this.target,
    isDaily: isDaily ?? this.isDaily,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Mission copyWithCompanion(MissionsCompanion data) {
    return Mission(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
      progress: data.progress.present ? data.progress.value : this.progress,
      target: data.target.present ? data.target.value : this.target,
      isDaily: data.isDaily.present ? data.isDaily.value : this.isDaily,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mission(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('goalId: $goalId, ')
          ..write('difficulty: $difficulty, ')
          ..write('xpReward: $xpReward, ')
          ..write('progress: $progress, ')
          ..write('target: $target, ')
          ..write('isDaily: $isDaily, ')
          ..write('dueDate: $dueDate, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    goalId,
    difficulty,
    xpReward,
    progress,
    target,
    isDaily,
    dueDate,
    isActive,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mission &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.goalId == this.goalId &&
          other.difficulty == this.difficulty &&
          other.xpReward == this.xpReward &&
          other.progress == this.progress &&
          other.target == this.target &&
          other.isDaily == this.isDaily &&
          other.dueDate == this.dueDate &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class MissionsCompanion extends UpdateCompanion<Mission> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String?> goalId;
  final Value<MissionDifficulty> difficulty;
  final Value<int> xpReward;
  final Value<int> progress;
  final Value<int> target;
  final Value<bool> isDaily;
  final Value<DateTime?> dueDate;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MissionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.goalId = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.progress = const Value.absent(),
    this.target = const Value.absent(),
    this.isDaily = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MissionsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.goalId = const Value.absent(),
    required MissionDifficulty difficulty,
    required int xpReward,
    this.progress = const Value.absent(),
    this.target = const Value.absent(),
    this.isDaily = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       difficulty = Value(difficulty),
       xpReward = Value(xpReward),
       createdAt = Value(createdAt);
  static Insertable<Mission> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? goalId,
    Expression<int>? difficulty,
    Expression<int>? xpReward,
    Expression<int>? progress,
    Expression<int>? target,
    Expression<bool>? isDaily,
    Expression<DateTime>? dueDate,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (goalId != null) 'goal_id': goalId,
      if (difficulty != null) 'difficulty': difficulty,
      if (xpReward != null) 'xp_reward': xpReward,
      if (progress != null) 'progress': progress,
      if (target != null) 'target': target,
      if (isDaily != null) 'is_daily': isDaily,
      if (dueDate != null) 'due_date': dueDate,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MissionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String?>? goalId,
    Value<MissionDifficulty>? difficulty,
    Value<int>? xpReward,
    Value<int>? progress,
    Value<int>? target,
    Value<bool>? isDaily,
    Value<DateTime?>? dueDate,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MissionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      goalId: goalId ?? this.goalId,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      isDaily: isDaily ?? this.isDaily,
      dueDate: dueDate ?? this.dueDate,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(
        $MissionsTable.$converterdifficulty.toSql(difficulty.value),
      );
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (isDaily.present) {
      map['is_daily'] = Variable<bool>(isDaily.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MissionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('goalId: $goalId, ')
          ..write('difficulty: $difficulty, ')
          ..write('xpReward: $xpReward, ')
          ..write('progress: $progress, ')
          ..write('target: $target, ')
          ..write('isDaily: $isDaily, ')
          ..write('dueDate: $dueDate, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MissionCompletionsTable extends MissionCompletions
    with TableInfo<$MissionCompletionsTable, MissionCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MissionCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _missionIdMeta = const VerificationMeta(
    'missionId',
  );
  @override
  late final GeneratedColumn<String> missionId = GeneratedColumn<String>(
    'mission_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpEarnedMeta = const VerificationMeta(
    'xpEarned',
  );
  @override
  late final GeneratedColumn<int> xpEarned = GeneratedColumn<int>(
    'xp_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelUpMeta = const VerificationMeta(
    'levelUp',
  );
  @override
  late final GeneratedColumn<bool> levelUp = GeneratedColumn<bool>(
    'level_up',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("level_up" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    missionId,
    completedAt,
    xpEarned,
    levelUp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mission_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MissionCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mission_id')) {
      context.handle(
        _missionIdMeta,
        missionId.isAcceptableOrUnknown(data['mission_id']!, _missionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_missionIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('xp_earned')) {
      context.handle(
        _xpEarnedMeta,
        xpEarned.isAcceptableOrUnknown(data['xp_earned']!, _xpEarnedMeta),
      );
    } else if (isInserting) {
      context.missing(_xpEarnedMeta);
    }
    if (data.containsKey('level_up')) {
      context.handle(
        _levelUpMeta,
        levelUp.isAcceptableOrUnknown(data['level_up']!, _levelUpMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MissionCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MissionCompletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      missionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mission_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      xpEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_earned'],
      )!,
      levelUp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}level_up'],
      )!,
    );
  }

  @override
  $MissionCompletionsTable createAlias(String alias) {
    return $MissionCompletionsTable(attachedDatabase, alias);
  }
}

class MissionCompletion extends DataClass
    implements Insertable<MissionCompletion> {
  final String id;
  final String missionId;
  final DateTime completedAt;
  final int xpEarned;
  final bool levelUp;
  const MissionCompletion({
    required this.id,
    required this.missionId,
    required this.completedAt,
    required this.xpEarned,
    required this.levelUp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mission_id'] = Variable<String>(missionId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['xp_earned'] = Variable<int>(xpEarned);
    map['level_up'] = Variable<bool>(levelUp);
    return map;
  }

  MissionCompletionsCompanion toCompanion(bool nullToAbsent) {
    return MissionCompletionsCompanion(
      id: Value(id),
      missionId: Value(missionId),
      completedAt: Value(completedAt),
      xpEarned: Value(xpEarned),
      levelUp: Value(levelUp),
    );
  }

  factory MissionCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MissionCompletion(
      id: serializer.fromJson<String>(json['id']),
      missionId: serializer.fromJson<String>(json['missionId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      xpEarned: serializer.fromJson<int>(json['xpEarned']),
      levelUp: serializer.fromJson<bool>(json['levelUp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'missionId': serializer.toJson<String>(missionId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'xpEarned': serializer.toJson<int>(xpEarned),
      'levelUp': serializer.toJson<bool>(levelUp),
    };
  }

  MissionCompletion copyWith({
    String? id,
    String? missionId,
    DateTime? completedAt,
    int? xpEarned,
    bool? levelUp,
  }) => MissionCompletion(
    id: id ?? this.id,
    missionId: missionId ?? this.missionId,
    completedAt: completedAt ?? this.completedAt,
    xpEarned: xpEarned ?? this.xpEarned,
    levelUp: levelUp ?? this.levelUp,
  );
  MissionCompletion copyWithCompanion(MissionCompletionsCompanion data) {
    return MissionCompletion(
      id: data.id.present ? data.id.value : this.id,
      missionId: data.missionId.present ? data.missionId.value : this.missionId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      xpEarned: data.xpEarned.present ? data.xpEarned.value : this.xpEarned,
      levelUp: data.levelUp.present ? data.levelUp.value : this.levelUp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MissionCompletion(')
          ..write('id: $id, ')
          ..write('missionId: $missionId, ')
          ..write('completedAt: $completedAt, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('levelUp: $levelUp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, missionId, completedAt, xpEarned, levelUp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MissionCompletion &&
          other.id == this.id &&
          other.missionId == this.missionId &&
          other.completedAt == this.completedAt &&
          other.xpEarned == this.xpEarned &&
          other.levelUp == this.levelUp);
}

class MissionCompletionsCompanion extends UpdateCompanion<MissionCompletion> {
  final Value<String> id;
  final Value<String> missionId;
  final Value<DateTime> completedAt;
  final Value<int> xpEarned;
  final Value<bool> levelUp;
  final Value<int> rowid;
  const MissionCompletionsCompanion({
    this.id = const Value.absent(),
    this.missionId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.levelUp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MissionCompletionsCompanion.insert({
    required String id,
    required String missionId,
    required DateTime completedAt,
    required int xpEarned,
    this.levelUp = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       missionId = Value(missionId),
       completedAt = Value(completedAt),
       xpEarned = Value(xpEarned);
  static Insertable<MissionCompletion> custom({
    Expression<String>? id,
    Expression<String>? missionId,
    Expression<DateTime>? completedAt,
    Expression<int>? xpEarned,
    Expression<bool>? levelUp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (missionId != null) 'mission_id': missionId,
      if (completedAt != null) 'completed_at': completedAt,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (levelUp != null) 'level_up': levelUp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MissionCompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? missionId,
    Value<DateTime>? completedAt,
    Value<int>? xpEarned,
    Value<bool>? levelUp,
    Value<int>? rowid,
  }) {
    return MissionCompletionsCompanion(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      completedAt: completedAt ?? this.completedAt,
      xpEarned: xpEarned ?? this.xpEarned,
      levelUp: levelUp ?? this.levelUp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (missionId.present) {
      map['mission_id'] = Variable<String>(missionId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (xpEarned.present) {
      map['xp_earned'] = Variable<int>(xpEarned.value);
    }
    if (levelUp.present) {
      map['level_up'] = Variable<bool>(levelUp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MissionCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('missionId: $missionId, ')
          ..write('completedAt: $completedAt, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('levelUp: $levelUp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MissionSubtasksTable extends MissionSubtasks
    with TableInfo<$MissionSubtasksTable, MissionSubtask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MissionSubtasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _missionIdMeta = const VerificationMeta(
    'missionId',
  );
  @override
  late final GeneratedColumn<String> missionId = GeneratedColumn<String>(
    'mission_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES missions (id) ON DELETE CASCADE',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    missionId,
    title,
    target,
    progress,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mission_subtasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<MissionSubtask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mission_id')) {
      context.handle(
        _missionIdMeta,
        missionId.isAcceptableOrUnknown(data['mission_id']!, _missionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_missionIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
  MissionSubtask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MissionSubtask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      missionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mission_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MissionSubtasksTable createAlias(String alias) {
    return $MissionSubtasksTable(attachedDatabase, alias);
  }
}

class MissionSubtask extends DataClass implements Insertable<MissionSubtask> {
  final String id;
  final String missionId;
  final String title;
  final int target;
  final int progress;
  final int sortOrder;
  final DateTime createdAt;
  const MissionSubtask({
    required this.id,
    required this.missionId,
    required this.title,
    required this.target,
    required this.progress,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mission_id'] = Variable<String>(missionId);
    map['title'] = Variable<String>(title);
    map['target'] = Variable<int>(target);
    map['progress'] = Variable<int>(progress);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MissionSubtasksCompanion toCompanion(bool nullToAbsent) {
    return MissionSubtasksCompanion(
      id: Value(id),
      missionId: Value(missionId),
      title: Value(title),
      target: Value(target),
      progress: Value(progress),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory MissionSubtask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MissionSubtask(
      id: serializer.fromJson<String>(json['id']),
      missionId: serializer.fromJson<String>(json['missionId']),
      title: serializer.fromJson<String>(json['title']),
      target: serializer.fromJson<int>(json['target']),
      progress: serializer.fromJson<int>(json['progress']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'missionId': serializer.toJson<String>(missionId),
      'title': serializer.toJson<String>(title),
      'target': serializer.toJson<int>(target),
      'progress': serializer.toJson<int>(progress),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MissionSubtask copyWith({
    String? id,
    String? missionId,
    String? title,
    int? target,
    int? progress,
    int? sortOrder,
    DateTime? createdAt,
  }) => MissionSubtask(
    id: id ?? this.id,
    missionId: missionId ?? this.missionId,
    title: title ?? this.title,
    target: target ?? this.target,
    progress: progress ?? this.progress,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  MissionSubtask copyWithCompanion(MissionSubtasksCompanion data) {
    return MissionSubtask(
      id: data.id.present ? data.id.value : this.id,
      missionId: data.missionId.present ? data.missionId.value : this.missionId,
      title: data.title.present ? data.title.value : this.title,
      target: data.target.present ? data.target.value : this.target,
      progress: data.progress.present ? data.progress.value : this.progress,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MissionSubtask(')
          ..write('id: $id, ')
          ..write('missionId: $missionId, ')
          ..write('title: $title, ')
          ..write('target: $target, ')
          ..write('progress: $progress, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, missionId, title, target, progress, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MissionSubtask &&
          other.id == this.id &&
          other.missionId == this.missionId &&
          other.title == this.title &&
          other.target == this.target &&
          other.progress == this.progress &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class MissionSubtasksCompanion extends UpdateCompanion<MissionSubtask> {
  final Value<String> id;
  final Value<String> missionId;
  final Value<String> title;
  final Value<int> target;
  final Value<int> progress;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MissionSubtasksCompanion({
    this.id = const Value.absent(),
    this.missionId = const Value.absent(),
    this.title = const Value.absent(),
    this.target = const Value.absent(),
    this.progress = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MissionSubtasksCompanion.insert({
    required String id,
    required String missionId,
    required String title,
    required int target,
    this.progress = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       missionId = Value(missionId),
       title = Value(title),
       target = Value(target),
       createdAt = Value(createdAt);
  static Insertable<MissionSubtask> custom({
    Expression<String>? id,
    Expression<String>? missionId,
    Expression<String>? title,
    Expression<int>? target,
    Expression<int>? progress,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (missionId != null) 'mission_id': missionId,
      if (title != null) 'title': title,
      if (target != null) 'target': target,
      if (progress != null) 'progress': progress,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MissionSubtasksCompanion copyWith({
    Value<String>? id,
    Value<String>? missionId,
    Value<String>? title,
    Value<int>? target,
    Value<int>? progress,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MissionSubtasksCompanion(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      title: title ?? this.title,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (missionId.present) {
      map['mission_id'] = Variable<String>(missionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MissionSubtasksCompanion(')
          ..write('id: $id, ')
          ..write('missionId: $missionId, ')
          ..write('title: $title, ')
          ..write('target: $target, ')
          ..write('progress: $progress, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StackTemplatesTable extends StackTemplates
    with TableInfo<$StackTemplatesTable, StackTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StackTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DailyGoal, String> goal =
      GeneratedColumn<String>(
        'goal',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DailyGoal>($StackTemplatesTable.$convertergoal);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MissionDifficulty, int>
  difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<MissionDifficulty>($StackTemplatesTable.$converterdifficulty);
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
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _stackVersionMeta = const VerificationMeta(
    'stackVersion',
  );
  @override
  late final GeneratedColumn<int> stackVersion = GeneratedColumn<int>(
    'stack_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goal,
    slot,
    title,
    description,
    difficulty,
    xpReward,
    target,
    stackVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stack_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<StackTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
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
    if (data.containsKey('xp_reward')) {
      context.handle(
        _xpRewardMeta,
        xpReward.isAcceptableOrUnknown(data['xp_reward']!, _xpRewardMeta),
      );
    } else if (isInserting) {
      context.missing(_xpRewardMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('stack_version')) {
      context.handle(
        _stackVersionMeta,
        stackVersion.isAcceptableOrUnknown(
          data['stack_version']!,
          _stackVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StackTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StackTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      goal: $StackTemplatesTable.$convertergoal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal'],
        )!,
      ),
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      difficulty: $StackTemplatesTable.$converterdifficulty.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}difficulty'],
        )!,
      ),
      xpReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_reward'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      )!,
      stackVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stack_version'],
      )!,
    );
  }

  @override
  $StackTemplatesTable createAlias(String alias) {
    return $StackTemplatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DailyGoal, String, String> $convertergoal =
      const EnumNameConverter<DailyGoal>(DailyGoal.values);
  static JsonTypeConverter2<MissionDifficulty, int, int> $converterdifficulty =
      const EnumIndexConverter<MissionDifficulty>(MissionDifficulty.values);
}

class StackTemplate extends DataClass implements Insertable<StackTemplate> {
  final String id;
  final DailyGoal goal;
  final int slot;
  final String title;
  final String description;
  final MissionDifficulty difficulty;
  final int xpReward;
  final int target;
  final int stackVersion;
  const StackTemplate({
    required this.id,
    required this.goal,
    required this.slot,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.xpReward,
    required this.target,
    required this.stackVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['goal'] = Variable<String>(
        $StackTemplatesTable.$convertergoal.toSql(goal),
      );
    }
    map['slot'] = Variable<int>(slot);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    {
      map['difficulty'] = Variable<int>(
        $StackTemplatesTable.$converterdifficulty.toSql(difficulty),
      );
    }
    map['xp_reward'] = Variable<int>(xpReward);
    map['target'] = Variable<int>(target);
    map['stack_version'] = Variable<int>(stackVersion);
    return map;
  }

  StackTemplatesCompanion toCompanion(bool nullToAbsent) {
    return StackTemplatesCompanion(
      id: Value(id),
      goal: Value(goal),
      slot: Value(slot),
      title: Value(title),
      description: Value(description),
      difficulty: Value(difficulty),
      xpReward: Value(xpReward),
      target: Value(target),
      stackVersion: Value(stackVersion),
    );
  }

  factory StackTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StackTemplate(
      id: serializer.fromJson<String>(json['id']),
      goal: $StackTemplatesTable.$convertergoal.fromJson(
        serializer.fromJson<String>(json['goal']),
      ),
      slot: serializer.fromJson<int>(json['slot']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      difficulty: $StackTemplatesTable.$converterdifficulty.fromJson(
        serializer.fromJson<int>(json['difficulty']),
      ),
      xpReward: serializer.fromJson<int>(json['xpReward']),
      target: serializer.fromJson<int>(json['target']),
      stackVersion: serializer.fromJson<int>(json['stackVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'goal': serializer.toJson<String>(
        $StackTemplatesTable.$convertergoal.toJson(goal),
      ),
      'slot': serializer.toJson<int>(slot),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'difficulty': serializer.toJson<int>(
        $StackTemplatesTable.$converterdifficulty.toJson(difficulty),
      ),
      'xpReward': serializer.toJson<int>(xpReward),
      'target': serializer.toJson<int>(target),
      'stackVersion': serializer.toJson<int>(stackVersion),
    };
  }

  StackTemplate copyWith({
    String? id,
    DailyGoal? goal,
    int? slot,
    String? title,
    String? description,
    MissionDifficulty? difficulty,
    int? xpReward,
    int? target,
    int? stackVersion,
  }) => StackTemplate(
    id: id ?? this.id,
    goal: goal ?? this.goal,
    slot: slot ?? this.slot,
    title: title ?? this.title,
    description: description ?? this.description,
    difficulty: difficulty ?? this.difficulty,
    xpReward: xpReward ?? this.xpReward,
    target: target ?? this.target,
    stackVersion: stackVersion ?? this.stackVersion,
  );
  StackTemplate copyWithCompanion(StackTemplatesCompanion data) {
    return StackTemplate(
      id: data.id.present ? data.id.value : this.id,
      goal: data.goal.present ? data.goal.value : this.goal,
      slot: data.slot.present ? data.slot.value : this.slot,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
      target: data.target.present ? data.target.value : this.target,
      stackVersion: data.stackVersion.present
          ? data.stackVersion.value
          : this.stackVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StackTemplate(')
          ..write('id: $id, ')
          ..write('goal: $goal, ')
          ..write('slot: $slot, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('difficulty: $difficulty, ')
          ..write('xpReward: $xpReward, ')
          ..write('target: $target, ')
          ..write('stackVersion: $stackVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    goal,
    slot,
    title,
    description,
    difficulty,
    xpReward,
    target,
    stackVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StackTemplate &&
          other.id == this.id &&
          other.goal == this.goal &&
          other.slot == this.slot &&
          other.title == this.title &&
          other.description == this.description &&
          other.difficulty == this.difficulty &&
          other.xpReward == this.xpReward &&
          other.target == this.target &&
          other.stackVersion == this.stackVersion);
}

class StackTemplatesCompanion extends UpdateCompanion<StackTemplate> {
  final Value<String> id;
  final Value<DailyGoal> goal;
  final Value<int> slot;
  final Value<String> title;
  final Value<String> description;
  final Value<MissionDifficulty> difficulty;
  final Value<int> xpReward;
  final Value<int> target;
  final Value<int> stackVersion;
  final Value<int> rowid;
  const StackTemplatesCompanion({
    this.id = const Value.absent(),
    this.goal = const Value.absent(),
    this.slot = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.target = const Value.absent(),
    this.stackVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StackTemplatesCompanion.insert({
    required String id,
    required DailyGoal goal,
    required int slot,
    required String title,
    this.description = const Value.absent(),
    required MissionDifficulty difficulty,
    required int xpReward,
    this.target = const Value.absent(),
    this.stackVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       goal = Value(goal),
       slot = Value(slot),
       title = Value(title),
       difficulty = Value(difficulty),
       xpReward = Value(xpReward);
  static Insertable<StackTemplate> custom({
    Expression<String>? id,
    Expression<String>? goal,
    Expression<int>? slot,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? difficulty,
    Expression<int>? xpReward,
    Expression<int>? target,
    Expression<int>? stackVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goal != null) 'goal': goal,
      if (slot != null) 'slot': slot,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (difficulty != null) 'difficulty': difficulty,
      if (xpReward != null) 'xp_reward': xpReward,
      if (target != null) 'target': target,
      if (stackVersion != null) 'stack_version': stackVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StackTemplatesCompanion copyWith({
    Value<String>? id,
    Value<DailyGoal>? goal,
    Value<int>? slot,
    Value<String>? title,
    Value<String>? description,
    Value<MissionDifficulty>? difficulty,
    Value<int>? xpReward,
    Value<int>? target,
    Value<int>? stackVersion,
    Value<int>? rowid,
  }) {
    return StackTemplatesCompanion(
      id: id ?? this.id,
      goal: goal ?? this.goal,
      slot: slot ?? this.slot,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      target: target ?? this.target,
      stackVersion: stackVersion ?? this.stackVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(
        $StackTemplatesTable.$convertergoal.toSql(goal.value),
      );
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(
        $StackTemplatesTable.$converterdifficulty.toSql(difficulty.value),
      );
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (stackVersion.present) {
      map['stack_version'] = Variable<int>(stackVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StackTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('goal: $goal, ')
          ..write('slot: $slot, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('difficulty: $difficulty, ')
          ..write('xpReward: $xpReward, ')
          ..write('target: $target, ')
          ..write('stackVersion: $stackVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StackSubtasksTable extends StackSubtasks
    with TableInfo<$StackSubtasksTable, StackSubtask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StackSubtasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stack_templates (id) ON DELETE CASCADE',
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
  static const VerificationMeta _baseMeta = const VerificationMeta('base');
  @override
  late final GeneratedColumn<int> base = GeneratedColumn<int>(
    'base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _perLevelMeta = const VerificationMeta(
    'perLevel',
  );
  @override
  late final GeneratedColumn<int> perLevel = GeneratedColumn<int>(
    'per_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxLevelMeta = const VerificationMeta(
    'maxLevel',
  );
  @override
  late final GeneratedColumn<int> maxLevel = GeneratedColumn<int>(
    'max_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    title,
    base,
    perLevel,
    maxLevel,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stack_subtasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StackSubtask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('base')) {
      context.handle(
        _baseMeta,
        base.isAcceptableOrUnknown(data['base']!, _baseMeta),
      );
    } else if (isInserting) {
      context.missing(_baseMeta);
    }
    if (data.containsKey('per_level')) {
      context.handle(
        _perLevelMeta,
        perLevel.isAcceptableOrUnknown(data['per_level']!, _perLevelMeta),
      );
    }
    if (data.containsKey('max_level')) {
      context.handle(
        _maxLevelMeta,
        maxLevel.isAcceptableOrUnknown(data['max_level']!, _maxLevelMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StackSubtask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StackSubtask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      base: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base'],
      )!,
      perLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}per_level'],
      )!,
      maxLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_level'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $StackSubtasksTable createAlias(String alias) {
    return $StackSubtasksTable(attachedDatabase, alias);
  }
}

class StackSubtask extends DataClass implements Insertable<StackSubtask> {
  final String id;
  final String templateId;
  final String title;
  final int base;
  final int perLevel;
  final int maxLevel;
  final int sortOrder;
  const StackSubtask({
    required this.id,
    required this.templateId,
    required this.title,
    required this.base,
    required this.perLevel,
    required this.maxLevel,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['title'] = Variable<String>(title);
    map['base'] = Variable<int>(base);
    map['per_level'] = Variable<int>(perLevel);
    map['max_level'] = Variable<int>(maxLevel);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  StackSubtasksCompanion toCompanion(bool nullToAbsent) {
    return StackSubtasksCompanion(
      id: Value(id),
      templateId: Value(templateId),
      title: Value(title),
      base: Value(base),
      perLevel: Value(perLevel),
      maxLevel: Value(maxLevel),
      sortOrder: Value(sortOrder),
    );
  }

  factory StackSubtask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StackSubtask(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      title: serializer.fromJson<String>(json['title']),
      base: serializer.fromJson<int>(json['base']),
      perLevel: serializer.fromJson<int>(json['perLevel']),
      maxLevel: serializer.fromJson<int>(json['maxLevel']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'title': serializer.toJson<String>(title),
      'base': serializer.toJson<int>(base),
      'perLevel': serializer.toJson<int>(perLevel),
      'maxLevel': serializer.toJson<int>(maxLevel),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  StackSubtask copyWith({
    String? id,
    String? templateId,
    String? title,
    int? base,
    int? perLevel,
    int? maxLevel,
    int? sortOrder,
  }) => StackSubtask(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    title: title ?? this.title,
    base: base ?? this.base,
    perLevel: perLevel ?? this.perLevel,
    maxLevel: maxLevel ?? this.maxLevel,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  StackSubtask copyWithCompanion(StackSubtasksCompanion data) {
    return StackSubtask(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      title: data.title.present ? data.title.value : this.title,
      base: data.base.present ? data.base.value : this.base,
      perLevel: data.perLevel.present ? data.perLevel.value : this.perLevel,
      maxLevel: data.maxLevel.present ? data.maxLevel.value : this.maxLevel,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StackSubtask(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('title: $title, ')
          ..write('base: $base, ')
          ..write('perLevel: $perLevel, ')
          ..write('maxLevel: $maxLevel, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, templateId, title, base, perLevel, maxLevel, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StackSubtask &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.title == this.title &&
          other.base == this.base &&
          other.perLevel == this.perLevel &&
          other.maxLevel == this.maxLevel &&
          other.sortOrder == this.sortOrder);
}

class StackSubtasksCompanion extends UpdateCompanion<StackSubtask> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> title;
  final Value<int> base;
  final Value<int> perLevel;
  final Value<int> maxLevel;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const StackSubtasksCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.title = const Value.absent(),
    this.base = const Value.absent(),
    this.perLevel = const Value.absent(),
    this.maxLevel = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StackSubtasksCompanion.insert({
    required String id,
    required String templateId,
    required String title,
    required int base,
    this.perLevel = const Value.absent(),
    this.maxLevel = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       title = Value(title),
       base = Value(base);
  static Insertable<StackSubtask> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? title,
    Expression<int>? base,
    Expression<int>? perLevel,
    Expression<int>? maxLevel,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (title != null) 'title': title,
      if (base != null) 'base': base,
      if (perLevel != null) 'per_level': perLevel,
      if (maxLevel != null) 'max_level': maxLevel,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StackSubtasksCompanion copyWith({
    Value<String>? id,
    Value<String>? templateId,
    Value<String>? title,
    Value<int>? base,
    Value<int>? perLevel,
    Value<int>? maxLevel,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return StackSubtasksCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      title: title ?? this.title,
      base: base ?? this.base,
      perLevel: perLevel ?? this.perLevel,
      maxLevel: maxLevel ?? this.maxLevel,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (base.present) {
      map['base'] = Variable<int>(base.value);
    }
    if (perLevel.present) {
      map['per_level'] = Variable<int>(perLevel.value);
    }
    if (maxLevel.present) {
      map['max_level'] = Variable<int>(maxLevel.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StackSubtasksCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('title: $title, ')
          ..write('base: $base, ')
          ..write('perLevel: $perLevel, ')
          ..write('maxLevel: $maxLevel, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DailyGoal, String> goal =
      GeneratedColumn<String>(
        'goal',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DailyGoal>($UserPreferencesTable.$convertergoal);
  static const VerificationMeta _answersMeta = const VerificationMeta(
    'answers',
  );
  @override
  late final GeneratedColumn<String> answers = GeneratedColumn<String>(
    'answers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('interview'),
  );
  static const VerificationMeta _stackVersionMeta = const VerificationMeta(
    'stackVersion',
  );
  @override
  late final GeneratedColumn<int> stackVersion = GeneratedColumn<int>(
    'stack_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _configuredAtMeta = const VerificationMeta(
    'configuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> configuredAt = GeneratedColumn<DateTime>(
    'configured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goal,
    answers,
    source,
    stackVersion,
    configuredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('answers')) {
      context.handle(
        _answersMeta,
        answers.isAcceptableOrUnknown(data['answers']!, _answersMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('stack_version')) {
      context.handle(
        _stackVersionMeta,
        stackVersion.isAcceptableOrUnknown(
          data['stack_version']!,
          _stackVersionMeta,
        ),
      );
    }
    if (data.containsKey('configured_at')) {
      context.handle(
        _configuredAtMeta,
        configuredAt.isAcceptableOrUnknown(
          data['configured_at']!,
          _configuredAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_configuredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      goal: $UserPreferencesTable.$convertergoal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal'],
        )!,
      ),
      answers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      stackVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stack_version'],
      )!,
      configuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}configured_at'],
      )!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DailyGoal, String, String> $convertergoal =
      const EnumNameConverter<DailyGoal>(DailyGoal.values);
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  final int id;
  final DailyGoal goal;
  final String answers;
  final String source;
  final int stackVersion;
  final DateTime configuredAt;
  const UserPreference({
    required this.id,
    required this.goal,
    required this.answers,
    required this.source,
    required this.stackVersion,
    required this.configuredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['goal'] = Variable<String>(
        $UserPreferencesTable.$convertergoal.toSql(goal),
      );
    }
    map['answers'] = Variable<String>(answers);
    map['source'] = Variable<String>(source);
    map['stack_version'] = Variable<int>(stackVersion);
    map['configured_at'] = Variable<DateTime>(configuredAt);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      id: Value(id),
      goal: Value(goal),
      answers: Value(answers),
      source: Value(source),
      stackVersion: Value(stackVersion),
      configuredAt: Value(configuredAt),
    );
  }

  factory UserPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      id: serializer.fromJson<int>(json['id']),
      goal: $UserPreferencesTable.$convertergoal.fromJson(
        serializer.fromJson<String>(json['goal']),
      ),
      answers: serializer.fromJson<String>(json['answers']),
      source: serializer.fromJson<String>(json['source']),
      stackVersion: serializer.fromJson<int>(json['stackVersion']),
      configuredAt: serializer.fromJson<DateTime>(json['configuredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goal': serializer.toJson<String>(
        $UserPreferencesTable.$convertergoal.toJson(goal),
      ),
      'answers': serializer.toJson<String>(answers),
      'source': serializer.toJson<String>(source),
      'stackVersion': serializer.toJson<int>(stackVersion),
      'configuredAt': serializer.toJson<DateTime>(configuredAt),
    };
  }

  UserPreference copyWith({
    int? id,
    DailyGoal? goal,
    String? answers,
    String? source,
    int? stackVersion,
    DateTime? configuredAt,
  }) => UserPreference(
    id: id ?? this.id,
    goal: goal ?? this.goal,
    answers: answers ?? this.answers,
    source: source ?? this.source,
    stackVersion: stackVersion ?? this.stackVersion,
    configuredAt: configuredAt ?? this.configuredAt,
  );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      id: data.id.present ? data.id.value : this.id,
      goal: data.goal.present ? data.goal.value : this.goal,
      answers: data.answers.present ? data.answers.value : this.answers,
      source: data.source.present ? data.source.value : this.source,
      stackVersion: data.stackVersion.present
          ? data.stackVersion.value
          : this.stackVersion,
      configuredAt: data.configuredAt.present
          ? data.configuredAt.value
          : this.configuredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('id: $id, ')
          ..write('goal: $goal, ')
          ..write('answers: $answers, ')
          ..write('source: $source, ')
          ..write('stackVersion: $stackVersion, ')
          ..write('configuredAt: $configuredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, goal, answers, source, stackVersion, configuredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.id == this.id &&
          other.goal == this.goal &&
          other.answers == this.answers &&
          other.source == this.source &&
          other.stackVersion == this.stackVersion &&
          other.configuredAt == this.configuredAt);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<int> id;
  final Value<DailyGoal> goal;
  final Value<String> answers;
  final Value<String> source;
  final Value<int> stackVersion;
  final Value<DateTime> configuredAt;
  const UserPreferencesCompanion({
    this.id = const Value.absent(),
    this.goal = const Value.absent(),
    this.answers = const Value.absent(),
    this.source = const Value.absent(),
    this.stackVersion = const Value.absent(),
    this.configuredAt = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    this.id = const Value.absent(),
    required DailyGoal goal,
    this.answers = const Value.absent(),
    this.source = const Value.absent(),
    this.stackVersion = const Value.absent(),
    required DateTime configuredAt,
  }) : goal = Value(goal),
       configuredAt = Value(configuredAt);
  static Insertable<UserPreference> custom({
    Expression<int>? id,
    Expression<String>? goal,
    Expression<String>? answers,
    Expression<String>? source,
    Expression<int>? stackVersion,
    Expression<DateTime>? configuredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goal != null) 'goal': goal,
      if (answers != null) 'answers': answers,
      if (source != null) 'source': source,
      if (stackVersion != null) 'stack_version': stackVersion,
      if (configuredAt != null) 'configured_at': configuredAt,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<int>? id,
    Value<DailyGoal>? goal,
    Value<String>? answers,
    Value<String>? source,
    Value<int>? stackVersion,
    Value<DateTime>? configuredAt,
  }) {
    return UserPreferencesCompanion(
      id: id ?? this.id,
      goal: goal ?? this.goal,
      answers: answers ?? this.answers,
      source: source ?? this.source,
      stackVersion: stackVersion ?? this.stackVersion,
      configuredAt: configuredAt ?? this.configuredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(
        $UserPreferencesTable.$convertergoal.toSql(goal.value),
      );
    }
    if (answers.present) {
      map['answers'] = Variable<String>(answers.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (stackVersion.present) {
      map['stack_version'] = Variable<int>(stackVersion.value);
    }
    if (configuredAt.present) {
      map['configured_at'] = Variable<DateTime>(configuredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('goal: $goal, ')
          ..write('answers: $answers, ')
          ..write('source: $source, ')
          ..write('stackVersion: $stackVersion, ')
          ..write('configuredAt: $configuredAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $MissionsTable missions = $MissionsTable(this);
  late final $MissionCompletionsTable missionCompletions =
      $MissionCompletionsTable(this);
  late final $MissionSubtasksTable missionSubtasks = $MissionSubtasksTable(
    this,
  );
  late final $StackTemplatesTable stackTemplates = $StackTemplatesTable(this);
  late final $StackSubtasksTable stackSubtasks = $StackSubtasksTable(this);
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    goals,
    missions,
    missionCompletions,
    missionSubtasks,
    stackTemplates,
    stackSubtasks,
    userPreferences,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'goals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('missions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'missions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('mission_subtasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'stack_templates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('stack_subtasks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  required String id,
  required String title,
  Value<String> description,
  Value<int> xpReward,
  Value<DateTime?> deadline,
  Value<bool> isArchived,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<int> xpReward,
  Value<DateTime?> deadline,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

final class $$GoalsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalsTable, Goal> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MissionsTable, List<Mission>> _missionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.missions,
    aliasName: 'goals__id__missions__goal_id',
  );

  $$MissionsTableProcessedTableManager get missionsRefs {
    final manager = $$MissionsTableTableManager(
      $_db,
      $_db.missions,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_missionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
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

  ColumnFilters<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> missionsRefs(
    Expression<bool> Function($$MissionsTableFilterComposer f) f,
  ) {
    final $$MissionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.missions,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionsTableFilterComposer(
            $db: $db,
            $table: $db.missions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
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

  ColumnOrderings<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  Expression<T> missionsRefs<T extends Object>(
    Expression<T> Function($$MissionsTableAnnotationComposer a) f,
  ) {
    final $$MissionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.missions,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionsTableAnnotationComposer(
            $db: $db,
            $table: $db.missions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, $$GoalsTableReferences),
          Goal,
          PrefetchHooks Function({bool missionsRefs})
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                title: title,
                description: description,
                xpReward: xpReward,
                deadline: deadline,
                isArchived: isArchived,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                title: title,
                description: description,
                xpReward: xpReward,
                deadline: deadline,
                isArchived: isArchived,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalsTable, Goal>(table),
                  $$GoalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({missionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (missionsRefs) db.missions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (missionsRefs)
                    await $_getPrefetchedData<Goal, $GoalsTable, Mission>(
                      currentTable: table,
                      referencedTable: $$GoalsTableReferences
                          ._missionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GoalsTableReferences(db, table, p0).missionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.goalId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, $$GoalsTableReferences),
      Goal,
      PrefetchHooks Function({bool missionsRefs})
    >;
typedef $$MissionsTableCreateCompanionBuilder = MissionsCompanion Function({
  required String id,
  required String title,
  Value<String> description,
  Value<String?> goalId,
  required MissionDifficulty difficulty,
  required int xpReward,
  Value<int> progress,
  Value<int> target,
  Value<bool> isDaily,
  Value<DateTime?> dueDate,
  Value<bool> isActive,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MissionsTableUpdateCompanionBuilder = MissionsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<String?> goalId,
  Value<MissionDifficulty> difficulty,
  Value<int> xpReward,
  Value<int> progress,
  Value<int> target,
  Value<bool> isDaily,
  Value<DateTime?> dueDate,
  Value<bool> isActive,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$MissionsTableReferences
    extends BaseReferences<_$AppDatabase, $MissionsTable, Mission> {
  $$MissionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalsTable _goalIdTable(_$AppDatabase db) =>
      db.goals.createAlias('missions__goal_id__goals__id');

  $$GoalsTableProcessedTableManager? get goalId {
    final $_column = $_itemColumn<String>('goal_id');
    if ($_column == null) return null;
    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MissionSubtasksTable, List<MissionSubtask>>
  _missionSubtasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.missionSubtasks,
    aliasName: 'missions__id__mission_subtasks__mission_id',
  );

  $$MissionSubtasksTableProcessedTableManager get missionSubtasksRefs {
    final manager = $$MissionSubtasksTableTableManager(
      $_db,
      $_db.missionSubtasks,
    ).filter((f) => f.missionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _missionSubtasksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MissionsTableFilterComposer
    extends Composer<_$AppDatabase, $MissionsTable> {
  $$MissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
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

  ColumnWithTypeConverterFilters<MissionDifficulty, MissionDifficulty, int>
  get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDaily => $composableBuilder(
    column: $table.isDaily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> missionSubtasksRefs(
    Expression<bool> Function($$MissionSubtasksTableFilterComposer f) f,
  ) {
    final $$MissionSubtasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.missionSubtasks,
      getReferencedColumn: (t) => t.missionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionSubtasksTableFilterComposer(
            $db: $db,
            $table: $db.missionSubtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MissionsTable> {
  $$MissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
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

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDaily => $composableBuilder(
    column: $table.isDaily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MissionsTable> {
  $$MissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MissionDifficulty, int> get difficulty =>
      $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<bool> get isDaily =>
      $composableBuilder(column: $table.isDaily, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> missionSubtasksRefs<T extends Object>(
    Expression<T> Function($$MissionSubtasksTableAnnotationComposer a) f,
  ) {
    final $$MissionSubtasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.missionSubtasks,
      getReferencedColumn: (t) => t.missionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionSubtasksTableAnnotationComposer(
            $db: $db,
            $table: $db.missionSubtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MissionsTable,
          Mission,
          $$MissionsTableFilterComposer,
          $$MissionsTableOrderingComposer,
          $$MissionsTableAnnotationComposer,
          $$MissionsTableCreateCompanionBuilder,
          $$MissionsTableUpdateCompanionBuilder,
          (Mission, $$MissionsTableReferences),
          Mission,
          PrefetchHooks Function({bool goalId, bool missionSubtasksRefs})
        > {
  $$MissionsTableTableManager(_$AppDatabase db, $MissionsTable table)
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
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> goalId = const Value.absent(),
                Value<MissionDifficulty> difficulty = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<bool> isDaily = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionsCompanion(
                id: id,
                title: title,
                description: description,
                goalId: goalId,
                difficulty: difficulty,
                xpReward: xpReward,
                progress: progress,
                target: target,
                isDaily: isDaily,
                dueDate: dueDate,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                Value<String?> goalId = const Value.absent(),
                required MissionDifficulty difficulty,
                required int xpReward,
                Value<int> progress = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<bool> isDaily = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MissionsCompanion.insert(
                id: id,
                title: title,
                description: description,
                goalId: goalId,
                difficulty: difficulty,
                xpReward: xpReward,
                progress: progress,
                target: target,
                isDaily: isDaily,
                dueDate: dueDate,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MissionsTable, Mission>(table),
                  $$MissionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({goalId = false, missionSubtasksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (missionSubtasksRefs) db.missionSubtasks,
                  ],
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
                        if (goalId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.goalId,
                            referencedTable: $$MissionsTableReferences
                                ._goalIdTable(db),
                            referencedColumn: $$MissionsTableReferences
                                ._goalIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (missionSubtasksRefs)
                        await $_getPrefetchedData<
                          Mission,
                          $MissionsTable,
                          MissionSubtask
                        >(
                          currentTable: table,
                          referencedTable: $$MissionsTableReferences
                              ._missionSubtasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MissionsTableReferences(
                                db,
                                table,
                                p0,
                              ).missionSubtasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.missionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MissionsTable,
      Mission,
      $$MissionsTableFilterComposer,
      $$MissionsTableOrderingComposer,
      $$MissionsTableAnnotationComposer,
      $$MissionsTableCreateCompanionBuilder,
      $$MissionsTableUpdateCompanionBuilder,
      (Mission, $$MissionsTableReferences),
      Mission,
      PrefetchHooks Function({bool goalId, bool missionSubtasksRefs})
    >;
typedef $$MissionCompletionsTableCreateCompanionBuilder =
    MissionCompletionsCompanion Function({
      required String id,
      required String missionId,
      required DateTime completedAt,
      required int xpEarned,
      Value<bool> levelUp,
      Value<int> rowid,
    });
typedef $$MissionCompletionsTableUpdateCompanionBuilder =
    MissionCompletionsCompanion Function({
      Value<String> id,
      Value<String> missionId,
      Value<DateTime> completedAt,
      Value<int> xpEarned,
      Value<bool> levelUp,
      Value<int> rowid,
    });

class $$MissionCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $MissionCompletionsTable> {
  $$MissionCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get missionId => $composableBuilder(
    column: $table.missionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get levelUp => $composableBuilder(
    column: $table.levelUp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MissionCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MissionCompletionsTable> {
  $$MissionCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get missionId => $composableBuilder(
    column: $table.missionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get levelUp => $composableBuilder(
    column: $table.levelUp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MissionCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MissionCompletionsTable> {
  $$MissionCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get missionId =>
      $composableBuilder(column: $table.missionId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpEarned =>
      $composableBuilder(column: $table.xpEarned, builder: (column) => column);

  GeneratedColumn<bool> get levelUp =>
      $composableBuilder(column: $table.levelUp, builder: (column) => column);
}

class $$MissionCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MissionCompletionsTable,
          MissionCompletion,
          $$MissionCompletionsTableFilterComposer,
          $$MissionCompletionsTableOrderingComposer,
          $$MissionCompletionsTableAnnotationComposer,
          $$MissionCompletionsTableCreateCompanionBuilder,
          $$MissionCompletionsTableUpdateCompanionBuilder,
          (
            MissionCompletion,
            BaseReferences<
              _$AppDatabase,
              $MissionCompletionsTable,
              MissionCompletion
            >,
          ),
          MissionCompletion,
          PrefetchHooks Function()
        > {
  $$MissionCompletionsTableTableManager(
    _$AppDatabase db,
    $MissionCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MissionCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MissionCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MissionCompletionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> missionId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<bool> levelUp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionCompletionsCompanion(
                id: id,
                missionId: missionId,
                completedAt: completedAt,
                xpEarned: xpEarned,
                levelUp: levelUp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String missionId,
                required DateTime completedAt,
                required int xpEarned,
                Value<bool> levelUp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionCompletionsCompanion.insert(
                id: id,
                missionId: missionId,
                completedAt: completedAt,
                xpEarned: xpEarned,
                levelUp: levelUp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MissionCompletionsTable, MissionCompletion>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $MissionCompletionsTable,
                    MissionCompletion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MissionCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MissionCompletionsTable,
      MissionCompletion,
      $$MissionCompletionsTableFilterComposer,
      $$MissionCompletionsTableOrderingComposer,
      $$MissionCompletionsTableAnnotationComposer,
      $$MissionCompletionsTableCreateCompanionBuilder,
      $$MissionCompletionsTableUpdateCompanionBuilder,
      (
        MissionCompletion,
        BaseReferences<
          _$AppDatabase,
          $MissionCompletionsTable,
          MissionCompletion
        >,
      ),
      MissionCompletion,
      PrefetchHooks Function()
    >;
typedef $$MissionSubtasksTableCreateCompanionBuilder =
    MissionSubtasksCompanion Function({
      required String id,
      required String missionId,
      required String title,
      required int target,
      Value<int> progress,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MissionSubtasksTableUpdateCompanionBuilder =
    MissionSubtasksCompanion Function({
      Value<String> id,
      Value<String> missionId,
      Value<String> title,
      Value<int> target,
      Value<int> progress,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MissionSubtasksTableReferences
    extends
        BaseReferences<_$AppDatabase, $MissionSubtasksTable, MissionSubtask> {
  $$MissionSubtasksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MissionsTable _missionIdTable(_$AppDatabase db) =>
      db.missions.createAlias('mission_subtasks__mission_id__missions__id');

  $$MissionsTableProcessedTableManager get missionId {
    final $_column = $_itemColumn<String>('mission_id')!;

    final manager = $$MissionsTableTableManager(
      $_db,
      $_db.missions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_missionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MissionSubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $MissionSubtasksTable> {
  $$MissionSubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MissionsTableFilterComposer get missionId {
    final $$MissionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.missionId,
      referencedTable: $db.missions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionsTableFilterComposer(
            $db: $db,
            $table: $db.missions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MissionSubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $MissionSubtasksTable> {
  $$MissionSubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MissionsTableOrderingComposer get missionId {
    final $$MissionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.missionId,
      referencedTable: $db.missions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionsTableOrderingComposer(
            $db: $db,
            $table: $db.missions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MissionSubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $MissionSubtasksTable> {
  $$MissionSubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MissionsTableAnnotationComposer get missionId {
    final $$MissionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.missionId,
      referencedTable: $db.missions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionsTableAnnotationComposer(
            $db: $db,
            $table: $db.missions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MissionSubtasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MissionSubtasksTable,
          MissionSubtask,
          $$MissionSubtasksTableFilterComposer,
          $$MissionSubtasksTableOrderingComposer,
          $$MissionSubtasksTableAnnotationComposer,
          $$MissionSubtasksTableCreateCompanionBuilder,
          $$MissionSubtasksTableUpdateCompanionBuilder,
          (MissionSubtask, $$MissionSubtasksTableReferences),
          MissionSubtask,
          PrefetchHooks Function({bool missionId})
        > {
  $$MissionSubtasksTableTableManager(
    _$AppDatabase db,
    $MissionSubtasksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MissionSubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MissionSubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MissionSubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> missionId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionSubtasksCompanion(
                id: id,
                missionId: missionId,
                title: title,
                target: target,
                progress: progress,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String missionId,
                required String title,
                required int target,
                Value<int> progress = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MissionSubtasksCompanion.insert(
                id: id,
                missionId: missionId,
                title: title,
                target: target,
                progress: progress,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MissionSubtasksTable, MissionSubtask>(table),
                  $$MissionSubtasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({missionId = false}) {
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
                    if (missionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.missionId,
                        referencedTable: $$MissionSubtasksTableReferences
                            ._missionIdTable(db),
                        referencedColumn: $$MissionSubtasksTableReferences
                            ._missionIdTable(db)
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

typedef $$MissionSubtasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MissionSubtasksTable,
      MissionSubtask,
      $$MissionSubtasksTableFilterComposer,
      $$MissionSubtasksTableOrderingComposer,
      $$MissionSubtasksTableAnnotationComposer,
      $$MissionSubtasksTableCreateCompanionBuilder,
      $$MissionSubtasksTableUpdateCompanionBuilder,
      (MissionSubtask, $$MissionSubtasksTableReferences),
      MissionSubtask,
      PrefetchHooks Function({bool missionId})
    >;
typedef $$StackTemplatesTableCreateCompanionBuilder =
    StackTemplatesCompanion Function({
      required String id,
      required DailyGoal goal,
      required int slot,
      required String title,
      Value<String> description,
      required MissionDifficulty difficulty,
      required int xpReward,
      Value<int> target,
      Value<int> stackVersion,
      Value<int> rowid,
    });
typedef $$StackTemplatesTableUpdateCompanionBuilder =
    StackTemplatesCompanion Function({
      Value<String> id,
      Value<DailyGoal> goal,
      Value<int> slot,
      Value<String> title,
      Value<String> description,
      Value<MissionDifficulty> difficulty,
      Value<int> xpReward,
      Value<int> target,
      Value<int> stackVersion,
      Value<int> rowid,
    });

final class $$StackTemplatesTableReferences
    extends BaseReferences<_$AppDatabase, $StackTemplatesTable, StackTemplate> {
  $$StackTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$StackSubtasksTable, List<StackSubtask>>
  _stackSubtasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stackSubtasks,
    aliasName: 'stack_templates__id__stack_subtasks__template_id',
  );

  $$StackSubtasksTableProcessedTableManager get stackSubtasksRefs {
    final manager = $$StackSubtasksTableTableManager(
      $_db,
      $_db.stackSubtasks,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stackSubtasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StackTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $StackTemplatesTable> {
  $$StackTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DailyGoal, DailyGoal, String> get goal =>
      $composableBuilder(
        column: $table.goal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
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

  ColumnWithTypeConverterFilters<MissionDifficulty, MissionDifficulty, int>
  get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stackVersion => $composableBuilder(
    column: $table.stackVersion,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stackSubtasksRefs(
    Expression<bool> Function($$StackSubtasksTableFilterComposer f) f,
  ) {
    final $$StackSubtasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stackSubtasks,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StackSubtasksTableFilterComposer(
            $db: $db,
            $table: $db.stackSubtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StackTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $StackTemplatesTable> {
  $$StackTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
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

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stackVersion => $composableBuilder(
    column: $table.stackVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StackTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StackTemplatesTable> {
  $$StackTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DailyGoal, String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MissionDifficulty, int> get difficulty =>
      $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get stackVersion => $composableBuilder(
    column: $table.stackVersion,
    builder: (column) => column,
  );

  Expression<T> stackSubtasksRefs<T extends Object>(
    Expression<T> Function($$StackSubtasksTableAnnotationComposer a) f,
  ) {
    final $$StackSubtasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stackSubtasks,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StackSubtasksTableAnnotationComposer(
            $db: $db,
            $table: $db.stackSubtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StackTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StackTemplatesTable,
          StackTemplate,
          $$StackTemplatesTableFilterComposer,
          $$StackTemplatesTableOrderingComposer,
          $$StackTemplatesTableAnnotationComposer,
          $$StackTemplatesTableCreateCompanionBuilder,
          $$StackTemplatesTableUpdateCompanionBuilder,
          (StackTemplate, $$StackTemplatesTableReferences),
          StackTemplate,
          PrefetchHooks Function({bool stackSubtasksRefs})
        > {
  $$StackTemplatesTableTableManager(
    _$AppDatabase db,
    $StackTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StackTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StackTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StackTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DailyGoal> goal = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<MissionDifficulty> difficulty = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<int> stackVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StackTemplatesCompanion(
                id: id,
                goal: goal,
                slot: slot,
                title: title,
                description: description,
                difficulty: difficulty,
                xpReward: xpReward,
                target: target,
                stackVersion: stackVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DailyGoal goal,
                required int slot,
                required String title,
                Value<String> description = const Value.absent(),
                required MissionDifficulty difficulty,
                required int xpReward,
                Value<int> target = const Value.absent(),
                Value<int> stackVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StackTemplatesCompanion.insert(
                id: id,
                goal: goal,
                slot: slot,
                title: title,
                description: description,
                difficulty: difficulty,
                xpReward: xpReward,
                target: target,
                stackVersion: stackVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StackTemplatesTable, StackTemplate>(table),
                  $$StackTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stackSubtasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (stackSubtasksRefs) db.stackSubtasks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stackSubtasksRefs)
                    await $_getPrefetchedData<
                      StackTemplate,
                      $StackTemplatesTable,
                      StackSubtask
                    >(
                      currentTable: table,
                      referencedTable: $$StackTemplatesTableReferences
                          ._stackSubtasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StackTemplatesTableReferences(
                            db,
                            table,
                            p0,
                          ).stackSubtasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.templateId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StackTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StackTemplatesTable,
      StackTemplate,
      $$StackTemplatesTableFilterComposer,
      $$StackTemplatesTableOrderingComposer,
      $$StackTemplatesTableAnnotationComposer,
      $$StackTemplatesTableCreateCompanionBuilder,
      $$StackTemplatesTableUpdateCompanionBuilder,
      (StackTemplate, $$StackTemplatesTableReferences),
      StackTemplate,
      PrefetchHooks Function({bool stackSubtasksRefs})
    >;
typedef $$StackSubtasksTableCreateCompanionBuilder =
    StackSubtasksCompanion Function({
      required String id,
      required String templateId,
      required String title,
      required int base,
      Value<int> perLevel,
      Value<int> maxLevel,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$StackSubtasksTableUpdateCompanionBuilder =
    StackSubtasksCompanion Function({
      Value<String> id,
      Value<String> templateId,
      Value<String> title,
      Value<int> base,
      Value<int> perLevel,
      Value<int> maxLevel,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$StackSubtasksTableReferences
    extends BaseReferences<_$AppDatabase, $StackSubtasksTable, StackSubtask> {
  $$StackSubtasksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StackTemplatesTable _templateIdTable(_$AppDatabase db) => db
      .stackTemplates
      .createAlias('stack_subtasks__template_id__stack_templates__id');

  $$StackTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager = $$StackTemplatesTableTableManager(
      $_db,
      $_db.stackTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StackSubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $StackSubtasksTable> {
  $$StackSubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get base => $composableBuilder(
    column: $table.base,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get perLevel => $composableBuilder(
    column: $table.perLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxLevel => $composableBuilder(
    column: $table.maxLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$StackTemplatesTableFilterComposer get templateId {
    final $$StackTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.stackTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StackTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.stackTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StackSubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $StackSubtasksTable> {
  $$StackSubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get base => $composableBuilder(
    column: $table.base,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get perLevel => $composableBuilder(
    column: $table.perLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxLevel => $composableBuilder(
    column: $table.maxLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$StackTemplatesTableOrderingComposer get templateId {
    final $$StackTemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.stackTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StackTemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.stackTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StackSubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $StackSubtasksTable> {
  $$StackSubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get base =>
      $composableBuilder(column: $table.base, builder: (column) => column);

  GeneratedColumn<int> get perLevel =>
      $composableBuilder(column: $table.perLevel, builder: (column) => column);

  GeneratedColumn<int> get maxLevel =>
      $composableBuilder(column: $table.maxLevel, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$StackTemplatesTableAnnotationComposer get templateId {
    final $$StackTemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.stackTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StackTemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.stackTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StackSubtasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StackSubtasksTable,
          StackSubtask,
          $$StackSubtasksTableFilterComposer,
          $$StackSubtasksTableOrderingComposer,
          $$StackSubtasksTableAnnotationComposer,
          $$StackSubtasksTableCreateCompanionBuilder,
          $$StackSubtasksTableUpdateCompanionBuilder,
          (StackSubtask, $$StackSubtasksTableReferences),
          StackSubtask,
          PrefetchHooks Function({bool templateId})
        > {
  $$StackSubtasksTableTableManager(_$AppDatabase db, $StackSubtasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StackSubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StackSubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StackSubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> base = const Value.absent(),
                Value<int> perLevel = const Value.absent(),
                Value<int> maxLevel = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StackSubtasksCompanion(
                id: id,
                templateId: templateId,
                title: title,
                base: base,
                perLevel: perLevel,
                maxLevel: maxLevel,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateId,
                required String title,
                required int base,
                Value<int> perLevel = const Value.absent(),
                Value<int> maxLevel = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StackSubtasksCompanion.insert(
                id: id,
                templateId: templateId,
                title: title,
                base: base,
                perLevel: perLevel,
                maxLevel: maxLevel,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StackSubtasksTable, StackSubtask>(table),
                  $$StackSubtasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({templateId = false}) {
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
                    if (templateId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.templateId,
                        referencedTable: $$StackSubtasksTableReferences
                            ._templateIdTable(db),
                        referencedColumn: $$StackSubtasksTableReferences
                            ._templateIdTable(db)
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

typedef $$StackSubtasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StackSubtasksTable,
      StackSubtask,
      $$StackSubtasksTableFilterComposer,
      $$StackSubtasksTableOrderingComposer,
      $$StackSubtasksTableAnnotationComposer,
      $$StackSubtasksTableCreateCompanionBuilder,
      $$StackSubtasksTableUpdateCompanionBuilder,
      (StackSubtask, $$StackSubtasksTableReferences),
      StackSubtask,
      PrefetchHooks Function({bool templateId})
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      required DailyGoal goal,
      Value<String> answers,
      Value<String> source,
      Value<int> stackVersion,
      required DateTime configuredAt,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<DailyGoal> goal,
      Value<String> answers,
      Value<String> source,
      Value<int> stackVersion,
      Value<DateTime> configuredAt,
    });

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<DailyGoal, DailyGoal, String> get goal =>
      $composableBuilder(
        column: $table.goal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stackVersion => $composableBuilder(
    column: $table.stackVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get configuredAt => $composableBuilder(
    column: $table.configuredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
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

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stackVersion => $composableBuilder(
    column: $table.stackVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get configuredAt => $composableBuilder(
    column: $table.configuredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DailyGoal, String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get answers =>
      $composableBuilder(column: $table.answers, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get stackVersion => $composableBuilder(
    column: $table.stackVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get configuredAt => $composableBuilder(
    column: $table.configuredAt,
    builder: (column) => column,
  );
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreference,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (
            UserPreference,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTable,
              UserPreference
            >,
          ),
          UserPreference,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DailyGoal> goal = const Value.absent(),
                Value<String> answers = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> stackVersion = const Value.absent(),
                Value<DateTime> configuredAt = const Value.absent(),
              }) => UserPreferencesCompanion(
                id: id,
                goal: goal,
                answers: answers,
                source: source,
                stackVersion: stackVersion,
                configuredAt: configuredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DailyGoal goal,
                Value<String> answers = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> stackVersion = const Value.absent(),
                required DateTime configuredAt,
              }) => UserPreferencesCompanion.insert(
                id: id,
                goal: goal,
                answers: answers,
                source: source,
                stackVersion: stackVersion,
                configuredAt: configuredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserPreferencesTable, UserPreference>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserPreferencesTable,
                    UserPreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreference,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (
        UserPreference,
        BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference>,
      ),
      UserPreference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$MissionsTableTableManager get missions =>
      $$MissionsTableTableManager(_db, _db.missions);
  $$MissionCompletionsTableTableManager get missionCompletions =>
      $$MissionCompletionsTableTableManager(_db, _db.missionCompletions);
  $$MissionSubtasksTableTableManager get missionSubtasks =>
      $$MissionSubtasksTableTableManager(_db, _db.missionSubtasks);
  $$StackTemplatesTableTableManager get stackTemplates =>
      $$StackTemplatesTableTableManager(_db, _db.stackTemplates);
  $$StackSubtasksTableTableManager get stackSubtasks =>
      $$StackSubtasksTableTableManager(_db, _db.stackSubtasks);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
}
