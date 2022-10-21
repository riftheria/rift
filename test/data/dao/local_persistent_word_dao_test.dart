import 'package:flutter_test/flutter_test.dart';
import 'package:rift/data/dao/local_persistent_sql_word_dao.dart';
import 'package:rift/data/dao/meaning_dao.dart';
import 'package:rift/data/dao/definition_dao.dart';
import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/models/definition.dart';
import 'package:rift/data/models/meaning.dart';
import 'package:rift/data/models/word.dart';
import 'package:rift/data/rift_database.dart';

void main() {
  test('Words can saved and retrieved in database', () async {
    final database = RiftDatabase.testDatabase();
    final wordDao = LocalPersistentWordDao(database);
    await wordDao.insertAll([
      Word(word: 'Rift'),
      Word(word: 'Help'),
      Word(word: 'Nothing'),
    ]);
    final allWords = wordDao.getAll();
    expect((await allWords).length, 3);
  });

  test('Check if a word is saved to local', () async {
    final word = Word(word: 'Word');
    final database = RiftDatabase.testDatabase();
    final wordDao = LocalPersistentWordDao(database);
    await wordDao.insert(word);
    expect((await wordDao.getAll()).length, 1);
  });

  test('Word could be retrieved from local source', () async {
    final database = RiftDatabase.testDatabase();
    final wordDao = LocalPersistentWordDao(database);
    final word = Word(word: 'Word');
    await wordDao.insert(word);
    final retrievedWord = wordDao.find(word.word);
    expect((await retrievedWord)?.word, word.word);
  });

  test('Find all the words inside a list', () async {
    final database = RiftDatabase.testDatabase();
    final wordDao = LocalPersistentWordDao(database);
    final words = ['First', 'Second', 'Third'];
    final wordsToInsert = words.map((e) => Word(word: e));
    final queryWords = ['First', 'Second', 'Third'];
    for (Word word in wordsToInsert) {
      await wordDao.insert(word);
    }
    final foundWords = await wordDao.findAll(queryWords);
    expect(foundWords.length, 3);
  });

  test('Get words, meanings, and definitions', () async {
    final database = RiftDatabase.testDatabase();
    final wordsDao = LocalPersistentWordDao(database);
    final meaningDao = MeaningDao(database);
    final definitionDao = DefinitionDao(database);
    await wordsDao.insert(Word(word: 'word', phonetic: 'phon'));
    await meaningDao
        .insertAll([Meaning(id: 1, partOfSpeech: 'verb', wordId: 'word')]);
    await definitionDao.insertAll([Definition(id: 1, meaningId: 1)]);
    final completeWords = await wordsDao.findThreeCompleteWords();
    expect(completeWords[0].word.phonetic, 'phon');
    expect(completeWords[0].meaning.id, 1);
  });

  Future populateDatabase(RiftDatabase database, LocalWordDao wordsDao,
      MeaningDao meaningDao, DefinitionDao definitionDao) async {
    await wordsDao.insertAll(
      [
        Word(word: 'word', phonetic: 'phon'),
        Word(word: 'take', phonetic: 'phon'),
        Word(word: 'get', phonetic: 'phon'),
        Word(word: 'no', phonetic: 'phon'),
        Word(word: 'yes', phonetic: 'phon'),
      ],
    );
    await meaningDao.insertAll(
      [
        Meaning(id: 1, partOfSpeech: 'verb', wordId: 'word'),
        Meaning(id: 2, partOfSpeech: 'verb', wordId: 'take'),
        Meaning(id: 3, partOfSpeech: 'verb', wordId: 'take'),
        Meaning(id: 4, partOfSpeech: 'verb', wordId: 'no'),
        Meaning(id: 5, partOfSpeech: 'verb', wordId: 'yes'),
        Meaning(id: 6, partOfSpeech: 'verb', wordId: 'take'),
      ],
    );
    await definitionDao.insertAll(
      [
        Definition(id: 1, meaningId: 1),
        Definition(id: 2, meaningId: 2),
        Definition(id: 3, meaningId: 3),
        Definition(id: 4, meaningId: 4),
        Definition(id: 5, meaningId: 5),
        Definition(id: 6, meaningId: 6),
        Definition(id: 7, meaningId: 3),
      ],
    );
  }

  test('Get complete words returns only three words', () async {
    final database = RiftDatabase.testDatabase();
    final wordsDao = LocalPersistentWordDao(database);
    final meaningDao = MeaningDao(database);
    final definitionDao = DefinitionDao(database);
    await populateDatabase(database, wordsDao, meaningDao, definitionDao);
    final completeWords = await wordsDao.findThreeCompleteWords();
    expect(completeWords.length, 3);
  });

  test('Get complete words returns definitions from different words', () async {
    final database = RiftDatabase.testDatabase();
    final wordsDao = LocalPersistentWordDao(database);
    final meaningDao = MeaningDao(database);
    final definitionDao = DefinitionDao(database);
    await populateDatabase(database, wordsDao, meaningDao, definitionDao);
    final completeWords = await wordsDao.findThreeCompleteWords();
    expect(
      completeWords[0].word.word,
      isNot(equals(completeWords[1].word.word)),
    );
    expect(
      completeWords[0].word.word,
      isNot(equals(completeWords[2].word.word)),
    );
    expect(
      completeWords[1].word.word,
      isNot(equals(completeWords[2].word.word)),
    );
  });
}
