import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'rift_database.g.dart';

class Words extends Table {
  IntColumn get id => integer()();
  TextColumn get word => text()();

  @override
  Set<Column>? get primaryKey => {id};
}

@DriftDatabase(tables: [Words])
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
