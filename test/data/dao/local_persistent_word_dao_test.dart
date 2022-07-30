import 'package:flutter_test/flutter_test.dart';
import 'package:rift/data/dao/local_persistent_sql_word_dao.dart';
import 'package:rift/data/rift_database.dart';

void main() {
  test('Words can saved and retrieved in database', () async {
    final database = RiftDatabase.testDatabase();
    final wordDao = LocalPersistentWordDao(database);
    await wordDao.insertAll([
      Word(id: 'Rift'.hashCode, word: 'Rift'),
      Word(id: 'Help'.hashCode, word: 'Help'),
      Word(id: 'Nothing'.hashCode, word: 'Nothing'),
    ]);
    final allWords = wordDao.getAll();
    expect((await allWords).length, 3);
  });

  test('Check if a word is saved to local', () async {
    final word = Word(id: 0, word: 'Word');
    final database = RiftDatabase.testDatabase();
    final wordDao = LocalPersistentWordDao(database);
    await wordDao.insert(word);
    expect((await wordDao.getAll()).length, 1);
  });

  test('Word could be retrieved from local source', () async {
    final database = RiftDatabase.testDatabase();
    final wordDao = LocalPersistentWordDao(database);
    final word = Word(id: 0, word: 'Word');
    await wordDao.insert(word);
    final retrievedWord = wordDao.find(word.word);
    expect((await retrievedWord)?.word, word.word);
  });

  test('Find all the words inside a list', () async {
    final database = RiftDatabase.testDatabase();
    final wordDao = LocalPersistentWordDao(database);
    final wordsInsideDatabase = [
      Word(id: 0, word: 'First'),
      Word(id: 1, word: 'Second'),
      Word(id: 2, word: 'Third'),
    ];
    final queryWords = ['First', 'Second', 'Third'];
    for (Word word in wordsInsideDatabase) {
      await wordDao.insert(word);
    }
    final foundWords = await wordDao.findAll(queryWords);
    expect(foundWords.length, 3);
  });
}
