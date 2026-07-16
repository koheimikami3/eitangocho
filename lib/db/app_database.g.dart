// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ipaMeta = const VerificationMeta('ipa');
  @override
  late final GeneratedColumn<String> ipa = GeneratedColumn<String>(
    'ipa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _japaneseMeta = const VerificationMeta(
    'japanese',
  );
  @override
  late final GeneratedColumn<String> japanese = GeneratedColumn<String>(
    'japanese',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<PartOfSpeech>, String>
  partsOfSpeech = GeneratedColumn<String>(
    'parts_of_speech',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  ).withConverter<List<PartOfSpeech>>($WordsTable.$converterpartsOfSpeech);
  static const VerificationMeta _exampleEnMeta = const VerificationMeta(
    'exampleEn',
  );
  @override
  late final GeneratedColumn<String> exampleEn = GeneratedColumn<String>(
    'example_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _exampleJaMeta = const VerificationMeta(
    'exampleJa',
  );
  @override
  late final GeneratedColumn<String> exampleJa = GeneratedColumn<String>(
    'example_ja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isLearnedMeta = const VerificationMeta(
    'isLearned',
  );
  @override
  late final GeneratedColumn<bool> isLearned = GeneratedColumn<bool>(
    'is_learned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_learned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
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
    id,
    word,
    ipa,
    japanese,
    partsOfSpeech,
    exampleEn,
    exampleJa,
    audioUrl,
    isLearned,
    lastReviewedAt,
    correctCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('ipa')) {
      context.handle(
        _ipaMeta,
        ipa.isAcceptableOrUnknown(data['ipa']!, _ipaMeta),
      );
    }
    if (data.containsKey('japanese')) {
      context.handle(
        _japaneseMeta,
        japanese.isAcceptableOrUnknown(data['japanese']!, _japaneseMeta),
      );
    } else if (isInserting) {
      context.missing(_japaneseMeta);
    }
    if (data.containsKey('example_en')) {
      context.handle(
        _exampleEnMeta,
        exampleEn.isAcceptableOrUnknown(data['example_en']!, _exampleEnMeta),
      );
    }
    if (data.containsKey('example_ja')) {
      context.handle(
        _exampleJaMeta,
        exampleJa.isAcceptableOrUnknown(data['example_ja']!, _exampleJaMeta),
      );
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    }
    if (data.containsKey('is_learned')) {
      context.handle(
        _isLearnedMeta,
        isLearned.isAcceptableOrUnknown(data['is_learned']!, _isLearnedMeta),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
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
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      ipa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ipa'],
      )!,
      japanese: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}japanese'],
      )!,
      partsOfSpeech: $WordsTable.$converterpartsOfSpeech.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}parts_of_speech'],
        )!,
      ),
      exampleEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_en'],
      )!,
      exampleJa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_ja'],
      )!,
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      isLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_learned'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
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
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<PartOfSpeech>, String> $converterpartsOfSpeech =
      const PartOfSpeechListConverter();
}

class Word extends DataClass implements Insertable<Word> {
  final int id;
  final String word;
  final String ipa;

  /// 日本語訳(必須)
  final String japanese;
  final List<PartOfSpeech> partsOfSpeech;
  final String exampleEn;
  final String exampleJa;

  /// 辞書 API の発音 mp3 URL。空なら Google 翻訳リンクにフォールバック(Phase 3)
  final String audioUrl;
  final bool isLearned;

  /// クイズ実績(Phase 2 で更新開始。UI には出さない)
  final DateTime? lastReviewedAt;
  final int correctCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Word({
    required this.id,
    required this.word,
    required this.ipa,
    required this.japanese,
    required this.partsOfSpeech,
    required this.exampleEn,
    required this.exampleJa,
    required this.audioUrl,
    required this.isLearned,
    this.lastReviewedAt,
    required this.correctCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    map['ipa'] = Variable<String>(ipa);
    map['japanese'] = Variable<String>(japanese);
    {
      map['parts_of_speech'] = Variable<String>(
        $WordsTable.$converterpartsOfSpeech.toSql(partsOfSpeech),
      );
    }
    map['example_en'] = Variable<String>(exampleEn);
    map['example_ja'] = Variable<String>(exampleJa);
    map['audio_url'] = Variable<String>(audioUrl);
    map['is_learned'] = Variable<bool>(isLearned);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['correct_count'] = Variable<int>(correctCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      word: Value(word),
      ipa: Value(ipa),
      japanese: Value(japanese),
      partsOfSpeech: Value(partsOfSpeech),
      exampleEn: Value(exampleEn),
      exampleJa: Value(exampleJa),
      audioUrl: Value(audioUrl),
      isLearned: Value(isLearned),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      correctCount: Value(correctCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      ipa: serializer.fromJson<String>(json['ipa']),
      japanese: serializer.fromJson<String>(json['japanese']),
      partsOfSpeech: serializer.fromJson<List<PartOfSpeech>>(
        json['partsOfSpeech'],
      ),
      exampleEn: serializer.fromJson<String>(json['exampleEn']),
      exampleJa: serializer.fromJson<String>(json['exampleJa']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      isLearned: serializer.fromJson<bool>(json['isLearned']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
      'ipa': serializer.toJson<String>(ipa),
      'japanese': serializer.toJson<String>(japanese),
      'partsOfSpeech': serializer.toJson<List<PartOfSpeech>>(partsOfSpeech),
      'exampleEn': serializer.toJson<String>(exampleEn),
      'exampleJa': serializer.toJson<String>(exampleJa),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'isLearned': serializer.toJson<bool>(isLearned),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'correctCount': serializer.toJson<int>(correctCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Word copyWith({
    int? id,
    String? word,
    String? ipa,
    String? japanese,
    List<PartOfSpeech>? partsOfSpeech,
    String? exampleEn,
    String? exampleJa,
    String? audioUrl,
    bool? isLearned,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    int? correctCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Word(
    id: id ?? this.id,
    word: word ?? this.word,
    ipa: ipa ?? this.ipa,
    japanese: japanese ?? this.japanese,
    partsOfSpeech: partsOfSpeech ?? this.partsOfSpeech,
    exampleEn: exampleEn ?? this.exampleEn,
    exampleJa: exampleJa ?? this.exampleJa,
    audioUrl: audioUrl ?? this.audioUrl,
    isLearned: isLearned ?? this.isLearned,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    correctCount: correctCount ?? this.correctCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      ipa: data.ipa.present ? data.ipa.value : this.ipa,
      japanese: data.japanese.present ? data.japanese.value : this.japanese,
      partsOfSpeech: data.partsOfSpeech.present
          ? data.partsOfSpeech.value
          : this.partsOfSpeech,
      exampleEn: data.exampleEn.present ? data.exampleEn.value : this.exampleEn,
      exampleJa: data.exampleJa.present ? data.exampleJa.value : this.exampleJa,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      isLearned: data.isLearned.present ? data.isLearned.value : this.isLearned,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('ipa: $ipa, ')
          ..write('japanese: $japanese, ')
          ..write('partsOfSpeech: $partsOfSpeech, ')
          ..write('exampleEn: $exampleEn, ')
          ..write('exampleJa: $exampleJa, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('isLearned: $isLearned, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('correctCount: $correctCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    word,
    ipa,
    japanese,
    partsOfSpeech,
    exampleEn,
    exampleJa,
    audioUrl,
    isLearned,
    lastReviewedAt,
    correctCount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.word == this.word &&
          other.ipa == this.ipa &&
          other.japanese == this.japanese &&
          other.partsOfSpeech == this.partsOfSpeech &&
          other.exampleEn == this.exampleEn &&
          other.exampleJa == this.exampleJa &&
          other.audioUrl == this.audioUrl &&
          other.isLearned == this.isLearned &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.correctCount == this.correctCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> word;
  final Value<String> ipa;
  final Value<String> japanese;
  final Value<List<PartOfSpeech>> partsOfSpeech;
  final Value<String> exampleEn;
  final Value<String> exampleJa;
  final Value<String> audioUrl;
  final Value<bool> isLearned;
  final Value<DateTime?> lastReviewedAt;
  final Value<int> correctCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.ipa = const Value.absent(),
    this.japanese = const Value.absent(),
    this.partsOfSpeech = const Value.absent(),
    this.exampleEn = const Value.absent(),
    this.exampleJa = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    this.ipa = const Value.absent(),
    required String japanese,
    this.partsOfSpeech = const Value.absent(),
    this.exampleEn = const Value.absent(),
    this.exampleJa = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.correctCount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : word = Value(word),
       japanese = Value(japanese),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? word,
    Expression<String>? ipa,
    Expression<String>? japanese,
    Expression<String>? partsOfSpeech,
    Expression<String>? exampleEn,
    Expression<String>? exampleJa,
    Expression<String>? audioUrl,
    Expression<bool>? isLearned,
    Expression<DateTime>? lastReviewedAt,
    Expression<int>? correctCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (ipa != null) 'ipa': ipa,
      if (japanese != null) 'japanese': japanese,
      if (partsOfSpeech != null) 'parts_of_speech': partsOfSpeech,
      if (exampleEn != null) 'example_en': exampleEn,
      if (exampleJa != null) 'example_ja': exampleJa,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (isLearned != null) 'is_learned': isLearned,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (correctCount != null) 'correct_count': correctCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? word,
    Value<String>? ipa,
    Value<String>? japanese,
    Value<List<PartOfSpeech>>? partsOfSpeech,
    Value<String>? exampleEn,
    Value<String>? exampleJa,
    Value<String>? audioUrl,
    Value<bool>? isLearned,
    Value<DateTime?>? lastReviewedAt,
    Value<int>? correctCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      ipa: ipa ?? this.ipa,
      japanese: japanese ?? this.japanese,
      partsOfSpeech: partsOfSpeech ?? this.partsOfSpeech,
      exampleEn: exampleEn ?? this.exampleEn,
      exampleJa: exampleJa ?? this.exampleJa,
      audioUrl: audioUrl ?? this.audioUrl,
      isLearned: isLearned ?? this.isLearned,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      correctCount: correctCount ?? this.correctCount,
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
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (ipa.present) {
      map['ipa'] = Variable<String>(ipa.value);
    }
    if (japanese.present) {
      map['japanese'] = Variable<String>(japanese.value);
    }
    if (partsOfSpeech.present) {
      map['parts_of_speech'] = Variable<String>(
        $WordsTable.$converterpartsOfSpeech.toSql(partsOfSpeech.value),
      );
    }
    if (exampleEn.present) {
      map['example_en'] = Variable<String>(exampleEn.value);
    }
    if (exampleJa.present) {
      map['example_ja'] = Variable<String>(exampleJa.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (isLearned.present) {
      map['is_learned'] = Variable<bool>(isLearned.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('ipa: $ipa, ')
          ..write('japanese: $japanese, ')
          ..write('partsOfSpeech: $partsOfSpeech, ')
          ..write('exampleEn: $exampleEn, ')
          ..write('exampleJa: $exampleJa, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('isLearned: $isLearned, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('correctCount: $correctCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EjdictEntriesTable extends EjdictEntries
    with TableInfo<$EjdictEntriesTable, EjdictEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EjdictEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningsMeta = const VerificationMeta(
    'meanings',
  );
  @override
  late final GeneratedColumn<String> meanings = GeneratedColumn<String>(
    'meanings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [word, meanings];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ejdict_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<EjdictEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('meanings')) {
      context.handle(
        _meaningsMeta,
        meanings.isAcceptableOrUnknown(data['meanings']!, _meaningsMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {word};
  @override
  EjdictEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EjdictEntry(
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      meanings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meanings'],
      )!,
    );
  }

  @override
  $EjdictEntriesTable createAlias(String alias) {
    return $EjdictEntriesTable(attachedDatabase, alias);
  }
}

class EjdictEntry extends DataClass implements Insertable<EjdictEntry> {
  final String word;

  /// EJDict の訳文字列(複数語義は原文のまま保持)
  final String meanings;
  const EjdictEntry({required this.word, required this.meanings});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word'] = Variable<String>(word);
    map['meanings'] = Variable<String>(meanings);
    return map;
  }

  EjdictEntriesCompanion toCompanion(bool nullToAbsent) {
    return EjdictEntriesCompanion(word: Value(word), meanings: Value(meanings));
  }

  factory EjdictEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EjdictEntry(
      word: serializer.fromJson<String>(json['word']),
      meanings: serializer.fromJson<String>(json['meanings']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'word': serializer.toJson<String>(word),
      'meanings': serializer.toJson<String>(meanings),
    };
  }

  EjdictEntry copyWith({String? word, String? meanings}) =>
      EjdictEntry(word: word ?? this.word, meanings: meanings ?? this.meanings);
  EjdictEntry copyWithCompanion(EjdictEntriesCompanion data) {
    return EjdictEntry(
      word: data.word.present ? data.word.value : this.word,
      meanings: data.meanings.present ? data.meanings.value : this.meanings,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EjdictEntry(')
          ..write('word: $word, ')
          ..write('meanings: $meanings')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(word, meanings);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EjdictEntry &&
          other.word == this.word &&
          other.meanings == this.meanings);
}

class EjdictEntriesCompanion extends UpdateCompanion<EjdictEntry> {
  final Value<String> word;
  final Value<String> meanings;
  final Value<int> rowid;
  const EjdictEntriesCompanion({
    this.word = const Value.absent(),
    this.meanings = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EjdictEntriesCompanion.insert({
    required String word,
    required String meanings,
    this.rowid = const Value.absent(),
  }) : word = Value(word),
       meanings = Value(meanings);
  static Insertable<EjdictEntry> custom({
    Expression<String>? word,
    Expression<String>? meanings,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (word != null) 'word': word,
      if (meanings != null) 'meanings': meanings,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EjdictEntriesCompanion copyWith({
    Value<String>? word,
    Value<String>? meanings,
    Value<int>? rowid,
  }) {
    return EjdictEntriesCompanion(
      word: word ?? this.word,
      meanings: meanings ?? this.meanings,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (meanings.present) {
      map['meanings'] = Variable<String>(meanings.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EjdictEntriesCompanion(')
          ..write('word: $word, ')
          ..write('meanings: $meanings, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DictionaryCacheEntriesTable extends DictionaryCacheEntries
    with TableInfo<$DictionaryCacheEntriesTable, DictionaryCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DictionaryCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseJsonMeta = const VerificationMeta(
    'responseJson',
  );
  @override
  late final GeneratedColumn<String> responseJson = GeneratedColumn<String>(
    'response_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [word, responseJson, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dictionary_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DictionaryCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('response_json')) {
      context.handle(
        _responseJsonMeta,
        responseJson.isAcceptableOrUnknown(
          data['response_json']!,
          _responseJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseJsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {word};
  @override
  DictionaryCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DictionaryCacheEntry(
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      responseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $DictionaryCacheEntriesTable createAlias(String alias) {
    return $DictionaryCacheEntriesTable(attachedDatabase, alias);
  }
}

class DictionaryCacheEntry extends DataClass
    implements Insertable<DictionaryCacheEntry> {
  final String word;
  final String responseJson;
  final DateTime fetchedAt;
  const DictionaryCacheEntry({
    required this.word,
    required this.responseJson,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word'] = Variable<String>(word);
    map['response_json'] = Variable<String>(responseJson);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  DictionaryCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return DictionaryCacheEntriesCompanion(
      word: Value(word),
      responseJson: Value(responseJson),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory DictionaryCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DictionaryCacheEntry(
      word: serializer.fromJson<String>(json['word']),
      responseJson: serializer.fromJson<String>(json['responseJson']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'word': serializer.toJson<String>(word),
      'responseJson': serializer.toJson<String>(responseJson),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  DictionaryCacheEntry copyWith({
    String? word,
    String? responseJson,
    DateTime? fetchedAt,
  }) => DictionaryCacheEntry(
    word: word ?? this.word,
    responseJson: responseJson ?? this.responseJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  DictionaryCacheEntry copyWithCompanion(DictionaryCacheEntriesCompanion data) {
    return DictionaryCacheEntry(
      word: data.word.present ? data.word.value : this.word,
      responseJson: data.responseJson.present
          ? data.responseJson.value
          : this.responseJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryCacheEntry(')
          ..write('word: $word, ')
          ..write('responseJson: $responseJson, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(word, responseJson, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DictionaryCacheEntry &&
          other.word == this.word &&
          other.responseJson == this.responseJson &&
          other.fetchedAt == this.fetchedAt);
}

class DictionaryCacheEntriesCompanion
    extends UpdateCompanion<DictionaryCacheEntry> {
  final Value<String> word;
  final Value<String> responseJson;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const DictionaryCacheEntriesCompanion({
    this.word = const Value.absent(),
    this.responseJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DictionaryCacheEntriesCompanion.insert({
    required String word,
    required String responseJson,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : word = Value(word),
       responseJson = Value(responseJson),
       fetchedAt = Value(fetchedAt);
  static Insertable<DictionaryCacheEntry> custom({
    Expression<String>? word,
    Expression<String>? responseJson,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (word != null) 'word': word,
      if (responseJson != null) 'response_json': responseJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DictionaryCacheEntriesCompanion copyWith({
    Value<String>? word,
    Value<String>? responseJson,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return DictionaryCacheEntriesCompanion(
      word: word ?? this.word,
      responseJson: responseJson ?? this.responseJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (responseJson.present) {
      map['response_json'] = Variable<String>(responseJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryCacheEntriesCompanion(')
          ..write('word: $word, ')
          ..write('responseJson: $responseJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordsTable words = $WordsTable(this);
  late final $EjdictEntriesTable ejdictEntries = $EjdictEntriesTable(this);
  late final $DictionaryCacheEntriesTable dictionaryCacheEntries =
      $DictionaryCacheEntriesTable(this);
  late final WordDao wordDao = WordDao(this as AppDatabase);
  late final EjdictDao ejdictDao = EjdictDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    words,
    ejdictEntries,
    dictionaryCacheEntries,
  ];
}

typedef $$WordsTableCreateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      required String word,
      Value<String> ipa,
      required String japanese,
      Value<List<PartOfSpeech>> partsOfSpeech,
      Value<String> exampleEn,
      Value<String> exampleJa,
      Value<String> audioUrl,
      Value<bool> isLearned,
      Value<DateTime?> lastReviewedAt,
      Value<int> correctCount,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$WordsTableUpdateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      Value<String> word,
      Value<String> ipa,
      Value<String> japanese,
      Value<List<PartOfSpeech>> partsOfSpeech,
      Value<String> exampleEn,
      Value<String> exampleJa,
      Value<String> audioUrl,
      Value<bool> isLearned,
      Value<DateTime?> lastReviewedAt,
      Value<int> correctCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
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

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipa => $composableBuilder(
    column: $table.ipa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get japanese => $composableBuilder(
    column: $table.japanese,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<PartOfSpeech>, List<PartOfSpeech>, String>
  get partsOfSpeech => $composableBuilder(
    column: $table.partsOfSpeech,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get exampleEn => $composableBuilder(
    column: $table.exampleEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleJa => $composableBuilder(
    column: $table.exampleJa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLearned => $composableBuilder(
    column: $table.isLearned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
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

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
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

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipa => $composableBuilder(
    column: $table.ipa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get japanese => $composableBuilder(
    column: $table.japanese,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partsOfSpeech => $composableBuilder(
    column: $table.partsOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleEn => $composableBuilder(
    column: $table.exampleEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleJa => $composableBuilder(
    column: $table.exampleJa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLearned => $composableBuilder(
    column: $table.isLearned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
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

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get ipa =>
      $composableBuilder(column: $table.ipa, builder: (column) => column);

  GeneratedColumn<String> get japanese =>
      $composableBuilder(column: $table.japanese, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<PartOfSpeech>, String>
  get partsOfSpeech => $composableBuilder(
    column: $table.partsOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exampleEn =>
      $composableBuilder(column: $table.exampleEn, builder: (column) => column);

  GeneratedColumn<String> get exampleJa =>
      $composableBuilder(column: $table.exampleJa, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<bool> get isLearned =>
      $composableBuilder(column: $table.isLearned, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, BaseReferences<_$AppDatabase, $WordsTable, Word>),
          Word,
          PrefetchHooks Function()
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> ipa = const Value.absent(),
                Value<String> japanese = const Value.absent(),
                Value<List<PartOfSpeech>> partsOfSpeech = const Value.absent(),
                Value<String> exampleEn = const Value.absent(),
                Value<String> exampleJa = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<bool> isLearned = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                word: word,
                ipa: ipa,
                japanese: japanese,
                partsOfSpeech: partsOfSpeech,
                exampleEn: exampleEn,
                exampleJa: exampleJa,
                audioUrl: audioUrl,
                isLearned: isLearned,
                lastReviewedAt: lastReviewedAt,
                correctCount: correctCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String word,
                Value<String> ipa = const Value.absent(),
                required String japanese,
                Value<List<PartOfSpeech>> partsOfSpeech = const Value.absent(),
                Value<String> exampleEn = const Value.absent(),
                Value<String> exampleJa = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<bool> isLearned = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => WordsCompanion.insert(
                id: id,
                word: word,
                ipa: ipa,
                japanese: japanese,
                partsOfSpeech: partsOfSpeech,
                exampleEn: exampleEn,
                exampleJa: exampleJa,
                audioUrl: audioUrl,
                isLearned: isLearned,
                lastReviewedAt: lastReviewedAt,
                correctCount: correctCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, BaseReferences<_$AppDatabase, $WordsTable, Word>),
      Word,
      PrefetchHooks Function()
    >;
typedef $$EjdictEntriesTableCreateCompanionBuilder =
    EjdictEntriesCompanion Function({
      required String word,
      required String meanings,
      Value<int> rowid,
    });
typedef $$EjdictEntriesTableUpdateCompanionBuilder =
    EjdictEntriesCompanion Function({
      Value<String> word,
      Value<String> meanings,
      Value<int> rowid,
    });

class $$EjdictEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EjdictEntriesTable> {
  $$EjdictEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EjdictEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EjdictEntriesTable> {
  $$EjdictEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EjdictEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EjdictEntriesTable> {
  $$EjdictEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get meanings =>
      $composableBuilder(column: $table.meanings, builder: (column) => column);
}

class $$EjdictEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EjdictEntriesTable,
          EjdictEntry,
          $$EjdictEntriesTableFilterComposer,
          $$EjdictEntriesTableOrderingComposer,
          $$EjdictEntriesTableAnnotationComposer,
          $$EjdictEntriesTableCreateCompanionBuilder,
          $$EjdictEntriesTableUpdateCompanionBuilder,
          (
            EjdictEntry,
            BaseReferences<_$AppDatabase, $EjdictEntriesTable, EjdictEntry>,
          ),
          EjdictEntry,
          PrefetchHooks Function()
        > {
  $$EjdictEntriesTableTableManager(_$AppDatabase db, $EjdictEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EjdictEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EjdictEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EjdictEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> word = const Value.absent(),
                Value<String> meanings = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EjdictEntriesCompanion(
                word: word,
                meanings: meanings,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String word,
                required String meanings,
                Value<int> rowid = const Value.absent(),
              }) => EjdictEntriesCompanion.insert(
                word: word,
                meanings: meanings,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EjdictEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EjdictEntriesTable,
      EjdictEntry,
      $$EjdictEntriesTableFilterComposer,
      $$EjdictEntriesTableOrderingComposer,
      $$EjdictEntriesTableAnnotationComposer,
      $$EjdictEntriesTableCreateCompanionBuilder,
      $$EjdictEntriesTableUpdateCompanionBuilder,
      (
        EjdictEntry,
        BaseReferences<_$AppDatabase, $EjdictEntriesTable, EjdictEntry>,
      ),
      EjdictEntry,
      PrefetchHooks Function()
    >;
typedef $$DictionaryCacheEntriesTableCreateCompanionBuilder =
    DictionaryCacheEntriesCompanion Function({
      required String word,
      required String responseJson,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$DictionaryCacheEntriesTableUpdateCompanionBuilder =
    DictionaryCacheEntriesCompanion Function({
      Value<String> word,
      Value<String> responseJson,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$DictionaryCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DictionaryCacheEntriesTable> {
  $$DictionaryCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DictionaryCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DictionaryCacheEntriesTable> {
  $$DictionaryCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DictionaryCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DictionaryCacheEntriesTable> {
  $$DictionaryCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$DictionaryCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DictionaryCacheEntriesTable,
          DictionaryCacheEntry,
          $$DictionaryCacheEntriesTableFilterComposer,
          $$DictionaryCacheEntriesTableOrderingComposer,
          $$DictionaryCacheEntriesTableAnnotationComposer,
          $$DictionaryCacheEntriesTableCreateCompanionBuilder,
          $$DictionaryCacheEntriesTableUpdateCompanionBuilder,
          (
            DictionaryCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $DictionaryCacheEntriesTable,
              DictionaryCacheEntry
            >,
          ),
          DictionaryCacheEntry,
          PrefetchHooks Function()
        > {
  $$DictionaryCacheEntriesTableTableManager(
    _$AppDatabase db,
    $DictionaryCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DictionaryCacheEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DictionaryCacheEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DictionaryCacheEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> word = const Value.absent(),
                Value<String> responseJson = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DictionaryCacheEntriesCompanion(
                word: word,
                responseJson: responseJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String word,
                required String responseJson,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => DictionaryCacheEntriesCompanion.insert(
                word: word,
                responseJson: responseJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DictionaryCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DictionaryCacheEntriesTable,
      DictionaryCacheEntry,
      $$DictionaryCacheEntriesTableFilterComposer,
      $$DictionaryCacheEntriesTableOrderingComposer,
      $$DictionaryCacheEntriesTableAnnotationComposer,
      $$DictionaryCacheEntriesTableCreateCompanionBuilder,
      $$DictionaryCacheEntriesTableUpdateCompanionBuilder,
      (
        DictionaryCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $DictionaryCacheEntriesTable,
          DictionaryCacheEntry
        >,
      ),
      DictionaryCacheEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$EjdictEntriesTableTableManager get ejdictEntries =>
      $$EjdictEntriesTableTableManager(_db, _db.ejdictEntries);
  $$DictionaryCacheEntriesTableTableManager get dictionaryCacheEntries =>
      $$DictionaryCacheEntriesTableTableManager(
        _db,
        _db.dictionaryCacheEntries,
      );
}
