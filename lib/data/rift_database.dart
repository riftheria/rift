import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rift/data/models/definition.dart';
import 'package:rift/data/models/meaning.dart';
import 'package:rift/data/models/word.dart';

part 'rift_database.g.dart';

@UseRowClass(Word)
class Words extends Table {
  TextColumn get word => text()();
  TextColumn get phonetic => text().nullable()();

  @override
  Set<Column>? get primaryKey => {word};
}

@UseRowClass(Meaning)
class Meanings extends Table {
  IntColumn get id => integer()();
  TextColumn get partOfSpeech => text()();
  TextColumn get wordId => text().references(Words, #word)();

  @override
  Set<Column>? get primaryKey => {id};
}

@UseRowClass(Definition)
class Definitions extends Table {
  IntColumn get id => integer()();
  TextColumn get definition => text().nullable()();
  TextColumn get example => text().nullable()();
  IntColumn get meaningId => integer().references(Meanings, #id)();

  @override
  Set<Column>? get primaryKey => {id};
}

@DriftDatabase(tables: [Words, Meanings, Definitions])
class RiftDatabase extends _$RiftDatabase {
  RiftDatabase() : super(_openDatabase());

  RiftDatabase.testDatabase() : super(NativeDatabase.memory());
  @override
  int get schemaVersion => 1;
}

LazyDatabase _openDatabase() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(join(dbFolder.path, 'rift_database.sqlite'));

    return NativeDatabase(file);
  });
}
