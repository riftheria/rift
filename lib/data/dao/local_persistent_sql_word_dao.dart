import 'package:drift/drift.dart';
import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/rift_database.dart';

part 'local_persistent_sql_word_dao.g.dart';

@DriftAccessor(tables: [Words])
class LocalPersistentWordDao extends DatabaseAccessor<RiftDatabase>
    with _$LocalPersistentWordDaoMixin, LocalWordDao {
  LocalPersistentWordDao(RiftDatabase database) : super(database);

  Future<List<Word>> getAll() {
    return select(words).get();
  }

  @override
  Future<void> insertAll(List<Word> newWords) async {
    await batch(
      (batch) => {
        batch.insertAll(words, newWords),
      },
    );
  }

  @override
  Future<void> insert(Word word) async {
    into(words).insert(word);
  }

  @override
  Future<Word?> find(String word) async {
    final queryWord = await (select(words)
          ..where((tbl) => tbl.word.equals(word)))
        .getSingleOrNull();
    return queryWord;
  }

  @override
  Future<List<Word>> findAll(List<String> queryWords) async {
    final queryWordsHashes = queryWords.map((e) => e.toLowerCase().hashCode);
    final foundWords = await (select(words)
          ..where((table) => table.id.isIn(queryWordsHashes)))
        .get();
    return foundWords;
  }
}
