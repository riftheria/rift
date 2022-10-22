import 'package:drift/drift.dart';
import 'package:rift/data/dataclasses/complete_word.dart';
import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/models/word.dart';
import 'package:rift/data/rift_database.dart';

part 'local_persistent_sql_word_dao.g.dart';

@DriftAccessor(
    tables: [Words, Definitions, Meanings],
    queries: {'wordCount': 'SELECT COUNT(*) FROM words'})
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
        batch.insertAllOnConflictUpdate(words, newWords),
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
    final foundWords = await (select(words)
          ..where((table) => table.word.isIn(queryWords)))
        .get();
    return foundWords;
  }

  Future<List<CompleteWord>> findThreeCompleteWords() async {
    final query = select(definitions).join(
      [
        leftOuterJoin(meanings, meanings.id.equalsExp(definitions.meaningId)),
        leftOuterJoin(words, words.word.equalsExp(meanings.wordId)),
      ],
    )
      ..groupBy([words.word])
      ..orderBy([OrderingTerm.random()])
      ..limit(3);
    final result = await query
        .map(
          (row) => CompleteWord(
              word: row.readTable(words),
              meaning: row.readTable(meanings),
              definition: row.readTable(definitions)),
        )
        .get();
    return result;
  }

  Stream<int> getWordCountStream() {
    return wordCount().watchSingle();
  }
}
