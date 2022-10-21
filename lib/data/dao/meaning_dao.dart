import 'package:drift/drift.dart';
import 'package:rift/data/models/meaning.dart';
import 'package:rift/data/rift_database.dart';
part 'meaning_dao.g.dart';

@DriftAccessor(tables: [Meanings])
class MeaningDao extends DatabaseAccessor<RiftDatabase> with _$MeaningDaoMixin {
  MeaningDao(RiftDatabase database) : super(database);

  Future<void> insertAll(List<Meaning> newMeanings) async {
    batch(
      (batch) => batch.insertAllOnConflictUpdate(meanings, newMeanings),
    );
  }
}
