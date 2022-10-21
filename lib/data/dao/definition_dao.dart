import 'package:drift/drift.dart';
import 'package:rift/data/models/definition.dart';
import 'package:rift/data/rift_database.dart';
part 'definition_dao.g.dart';

@DriftAccessor(tables: [Definitions])
class DefinitionDao extends DatabaseAccessor<RiftDatabase>
    with _$DefinitionDaoMixin {
  DefinitionDao(RiftDatabase database) : super(database);

  Future<void> insertAll(List<Definition> newDefinitions) async {
    batch((batch) => batch.insertAll(definitions, newDefinitions));
  }
}
