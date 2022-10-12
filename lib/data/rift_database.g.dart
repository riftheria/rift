// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rift_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Word extends DataClass implements Insertable<Word> {
  final String word;
  final String? phonetic;
  Word({required this.word, this.phonetic});
  factory Word.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Word(
      word: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}word'])!,
      phonetic: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}phonetic']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || phonetic != null) {
      map['phonetic'] = Variable<String?>(phonetic);
    }
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      word: Value(word),
      phonetic: phonetic == null && nullToAbsent
          ? const Value.absent()
          : Value(phonetic),
    );
  }

  factory Word.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      word: serializer.fromJson<String>(json['word']),
      phonetic: serializer.fromJson<String?>(json['phonetic']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'word': serializer.toJson<String>(word),
      'phonetic': serializer.toJson<String?>(phonetic),
    };
  }

  Word copyWith({String? word, String? phonetic}) => Word(
        word: word ?? this.word,
        phonetic: phonetic ?? this.phonetic,
      );
  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('word: $word, ')
          ..write('phonetic: $phonetic')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(word, phonetic);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.word == this.word &&
          other.phonetic == this.phonetic);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<String> word;
  final Value<String?> phonetic;
  const WordsCompanion({
    this.word = const Value.absent(),
    this.phonetic = const Value.absent(),
  });
  WordsCompanion.insert({
    required String word,
    this.phonetic = const Value.absent(),
  }) : word = Value(word);
  static Insertable<Word> custom({
    Expression<String>? word,
    Expression<String?>? phonetic,
  }) {
    return RawValuesInsertable({
      if (word != null) 'word': word,
      if (phonetic != null) 'phonetic': phonetic,
    });
  }

  WordsCompanion copyWith({Value<String>? word, Value<String?>? phonetic}) {
    return WordsCompanion(
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (phonetic.present) {
      map['phonetic'] = Variable<String?>(phonetic.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('word: $word, ')
          ..write('phonetic: $phonetic')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String?> word = GeneratedColumn<String?>(
      'word', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _phoneticMeta = const VerificationMeta('phonetic');
  @override
  late final GeneratedColumn<String?> phonetic = GeneratedColumn<String?>(
      'phonetic', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [word, phonetic];
  @override
  String get aliasedName => _alias ?? 'words';
  @override
  String get actualTableName => 'words';
  @override
  VerificationContext validateIntegrity(Insertable<Word> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('phonetic')) {
      context.handle(_phoneticMeta,
          phonetic.isAcceptableOrUnknown(data['phonetic']!, _phoneticMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {word};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Word.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

abstract class _$RiftDatabase extends GeneratedDatabase {
  _$RiftDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $WordsTable words = $WordsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [words];
}
