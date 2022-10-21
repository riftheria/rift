// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rift_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: type=lint
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
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      word: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}word'])!,
      phonetic: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}phonetic']),
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class MeaningsCompanion extends UpdateCompanion<Meaning> {
  final Value<int> id;
  final Value<String> partOfSpeech;
  final Value<String> wordId;
  const MeaningsCompanion({
    this.id = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.wordId = const Value.absent(),
  });
  MeaningsCompanion.insert({
    this.id = const Value.absent(),
    required String partOfSpeech,
    required String wordId,
  })  : partOfSpeech = Value(partOfSpeech),
        wordId = Value(wordId);
  static Insertable<Meaning> custom({
    Expression<int>? id,
    Expression<String>? partOfSpeech,
    Expression<String>? wordId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (wordId != null) 'word_id': wordId,
    });
  }

  MeaningsCompanion copyWith(
      {Value<int>? id, Value<String>? partOfSpeech, Value<String>? wordId}) {
    return MeaningsCompanion(
      id: id ?? this.id,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      wordId: wordId ?? this.wordId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeaningsCompanion(')
          ..write('id: $id, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('wordId: $wordId')
          ..write(')'))
        .toString();
  }
}

class $MeaningsTable extends Meanings with TableInfo<$MeaningsTable, Meaning> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeaningsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _partOfSpeechMeta =
      const VerificationMeta('partOfSpeech');
  @override
  late final GeneratedColumn<String?> partOfSpeech = GeneratedColumn<String?>(
      'part_of_speech', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String?> wordId = GeneratedColumn<String?>(
      'word_id', aliasedName, false,
      type: const StringType(),
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES words (word)');
  @override
  List<GeneratedColumn> get $columns => [id, partOfSpeech, wordId];
  @override
  String get aliasedName => _alias ?? 'meanings';
  @override
  String get actualTableName => 'meanings';
  @override
  VerificationContext validateIntegrity(Insertable<Meaning> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
          _partOfSpeechMeta,
          partOfSpeech.isAcceptableOrUnknown(
              data['part_of_speech']!, _partOfSpeechMeta));
    } else if (isInserting) {
      context.missing(_partOfSpeechMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meaning map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meaning(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      partOfSpeech: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}part_of_speech'])!,
      wordId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}word_id'])!,
    );
  }

  @override
  $MeaningsTable createAlias(String alias) {
    return $MeaningsTable(attachedDatabase, alias);
  }
}

class DefinitionsCompanion extends UpdateCompanion<Definition> {
  final Value<int> id;
  final Value<String?> definition;
  final Value<String?> example;
  final Value<int> meaningId;
  const DefinitionsCompanion({
    this.id = const Value.absent(),
    this.definition = const Value.absent(),
    this.example = const Value.absent(),
    this.meaningId = const Value.absent(),
  });
  DefinitionsCompanion.insert({
    this.id = const Value.absent(),
    this.definition = const Value.absent(),
    this.example = const Value.absent(),
    required int meaningId,
  }) : meaningId = Value(meaningId);
  static Insertable<Definition> custom({
    Expression<int>? id,
    Expression<String?>? definition,
    Expression<String?>? example,
    Expression<int>? meaningId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (definition != null) 'definition': definition,
      if (example != null) 'example': example,
      if (meaningId != null) 'meaning_id': meaningId,
    });
  }

  DefinitionsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? definition,
      Value<String?>? example,
      Value<int>? meaningId}) {
    return DefinitionsCompanion(
      id: id ?? this.id,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      meaningId: meaningId ?? this.meaningId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String?>(definition.value);
    }
    if (example.present) {
      map['example'] = Variable<String?>(example.value);
    }
    if (meaningId.present) {
      map['meaning_id'] = Variable<int>(meaningId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('definition: $definition, ')
          ..write('example: $example, ')
          ..write('meaningId: $meaningId')
          ..write(')'))
        .toString();
  }
}

class $DefinitionsTable extends Definitions
    with TableInfo<$DefinitionsTable, Definition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DefinitionsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _definitionMeta = const VerificationMeta('definition');
  @override
  late final GeneratedColumn<String?> definition = GeneratedColumn<String?>(
      'definition', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _exampleMeta = const VerificationMeta('example');
  @override
  late final GeneratedColumn<String?> example = GeneratedColumn<String?>(
      'example', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _meaningIdMeta = const VerificationMeta('meaningId');
  @override
  late final GeneratedColumn<int?> meaningId = GeneratedColumn<int?>(
      'meaning_id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES meanings (id)');
  @override
  List<GeneratedColumn> get $columns => [id, definition, example, meaningId];
  @override
  String get aliasedName => _alias ?? 'definitions';
  @override
  String get actualTableName => 'definitions';
  @override
  VerificationContext validateIntegrity(Insertable<Definition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('definition')) {
      context.handle(
          _definitionMeta,
          definition.isAcceptableOrUnknown(
              data['definition']!, _definitionMeta));
    }
    if (data.containsKey('example')) {
      context.handle(_exampleMeta,
          example.isAcceptableOrUnknown(data['example']!, _exampleMeta));
    }
    if (data.containsKey('meaning_id')) {
      context.handle(_meaningIdMeta,
          meaningId.isAcceptableOrUnknown(data['meaning_id']!, _meaningIdMeta));
    } else if (isInserting) {
      context.missing(_meaningIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Definition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Definition(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      meaningId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}meaning_id'])!,
      definition: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}definition']),
      example: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}example']),
    );
  }

  @override
  $DefinitionsTable createAlias(String alias) {
    return $DefinitionsTable(attachedDatabase, alias);
  }
}

abstract class _$RiftDatabase extends GeneratedDatabase {
  _$RiftDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $WordsTable words = $WordsTable(this);
  late final $MeaningsTable meanings = $MeaningsTable(this);
  late final $DefinitionsTable definitions = $DefinitionsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [words, meanings, definitions];
}
