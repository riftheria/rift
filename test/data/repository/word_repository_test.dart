import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rift/data/dao/definition_dao.dart';
import 'package:rift/data/dao/local_persistent_sql_word_dao.dart';
import 'package:rift/data/dao/meaning_dao.dart';
import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/models/definition.dart';
import 'package:rift/data/models/meaning.dart';
import 'package:rift/data/models/word.dart';
import 'package:rift/data/repository/word_repository.dart';

WordRepository _setupWordRepository(
  LocalPersistentWordDao localWordDao,
  RemoteWordDao remoteWordDao,
  MeaningDao? meaningDao, {
  DefinitionDao? definitionDao,
}) {
  definitionDao = definitionDao ?? MockDefinitionDao();
  when(() => definitionDao?.insertAll(any())).thenAnswer((_) => Future.value());
  meaningDao = meaningDao ?? MockMeaningDao();
  when(() => meaningDao?.insertAll(any())).thenAnswer((_) => Future.value());
  return WordRepository(
    localWordDao: localWordDao,
    remoteWordDao: remoteWordDao,
    meaningDao: meaningDao,
    definitionDao: definitionDao,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(Word(word: 'Word'));
  });
  test('Retrieve word in remote if local dao doesn\'t have the word', () async {
    const word = 'Word';
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.find(any()))
        .thenAnswer((_) => Future(() => null));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.find(any()))
        .thenAnswer((_) => Future(() => Word(word: word)));
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    final retrievedWord = await wordRepository.find(word);
    verify(() => mockLocalWordDao.find(any())).called(1);
    verify(() => mockRemoteWordDao.find(any())).called(1);
    expect(retrievedWord, isNotNull);
  });

  test('Returns null if word have not be founded in local or remote', () async {
    const word = 'Word';
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.find(any()))
        .thenAnswer((_) => Future(() => null));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.find(any()))
        .thenAnswer((_) => Future((() => null)));
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    final retrievedWord = await wordRepository.find(word);
    expect(retrievedWord, isNull);
  });

  test(
    'Verify repository didn\'t used remote if the word was found in local',
    () async {
      const word = 'Word';
      final mockLocalWordDao = MockLocalWordDao();
      when(() => mockLocalWordDao.find(any()))
          .thenAnswer((_) => Future(() => Word(word: word)));
      final mockRemoteWordDao = MockRemoteWordDao();
      when(() => mockRemoteWordDao.find(any()))
          .thenAnswer((_) => Future((() => null)));
      final mockMeaningDao = MockMeaningDao();
      final wordRepository = _setupWordRepository(
        mockLocalWordDao,
        mockRemoteWordDao,
        mockMeaningDao,
      );
      try {
        await wordRepository.addToKnownWords(word);
      } catch (_) {}
      verifyNever(() => mockRemoteWordDao.find(any()));
      verify(() => mockLocalWordDao.find(any())).called(1);
    },
  );

  test('Insert in local database after retrieve the word info from remote',
      () async {
    const word = 'Word';
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.find(any()))
        .thenAnswer((_) => Future(() => null));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.find(any()))
        .thenAnswer((_) => Future((() => Word(word: word))));
    when(() => mockLocalWordDao.insert(any()))
        .thenAnswer((_) => Future.value());
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    await wordRepository.addToKnownWords(word);
    verify(() => mockLocalWordDao.find(any())).called(1);
    verify(() => mockRemoteWordDao.find(any())).called(1);
    verify(() => mockLocalWordDao.insert(any())).called(1);
  });

  test('Throw and exception when adding an invalid word', () async {
    const word = 'Word';
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.find(any()))
        .thenAnswer((_) => Future(() => null));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.find(any()))
        .thenAnswer((_) => Future((() => null)));
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    expect(() => wordRepository.addToKnownWords(word),
        throwsA(isA<InvalidWordException>()));
  });

  test('Throw and exception when the word already exists', () async {
    const word = 'Word';
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.find(any()))
        .thenAnswer((_) => Future(() => Word(word: word)));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.find(any()))
        .thenAnswer((_) => Future((() => null)));
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    expect(() => wordRepository.addToKnownWords(word),
        throwsA(isA<WordAlreadyAddedException>()));
  });

  test('New words are not in local and they have been found in remote',
      () async {
    const fileContentLines = '''
First line
Second line
''';
    final mockFile = MockFile();
    when(() => mockFile.readAsString())
        .thenAnswer((invocation) => Future(() => fileContentLines));
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.findAll(any()))
        .thenAnswer((_) => Future(() => []));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [
          Word(word: 'First'),
          Word(word: 'Second'),
          Word(word: 'Line'),
        ],
      ),
    );
    when(() => mockLocalWordDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    final validWords =
        (await wordRepository.importWordsFromFile(mockFile)).addedWords;
    expect(validWords.length, 3);
  });

  test('Import words from file returns 5 valid words', () async {
    const fileContentLines = 'Good is a nice rift';
    final mockFile = MockFile();
    when(() => mockFile.readAsString())
        .thenAnswer((invocation) => Future(() => fileContentLines));
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.findAll(any()))
        .thenAnswer((_) => Future(() => []));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [
          Word(word: 'Good'),
          Word(word: 'Is'),
          Word(word: 'A'),
          Word(word: 'Nice'),
          Word(word: 'Rift'),
        ],
      ),
    );
    when(() => mockLocalWordDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    final validWords =
        (await wordRepository.importWordsFromFile(mockFile)).addedWords;
    expect(validWords.length, 5);
  });

  test('Import words from file and save them in local', () async {
    const fileContentLines = 'Good is a nice rift';
    final mockFile = MockFile();
    when(() => mockFile.readAsString())
        .thenAnswer((invocation) => Future(() => fileContentLines));
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.findAll(any()))
        .thenAnswer((_) => Future(() => []));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [
          Word(word: 'Good'),
          Word(word: 'Is'),
          Word(word: 'A'),
          Word(word: 'Nice'),
          Word(word: 'Rift'),
        ],
      ),
    );
    when(() => mockLocalWordDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    await wordRepository.importWordsFromFile(mockFile);
    verify(() => mockLocalWordDao.insertAll(any())).called(1);
  });

  test('Import words from file returns 5 valid words and 1 invalid word',
      () async {
    const fileContentLines = 'Good is a nice rift InvalidWord';
    final mockFile = MockFile();
    when(() => mockFile.readAsString())
        .thenAnswer((invocation) => Future(() => fileContentLines));
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.findAll(any()))
        .thenAnswer((_) => Future(() => []));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [
          Word(word: 'Good'),
          Word(word: 'Is'),
          Word(word: 'A'),
          Word(word: 'Nice'),
          Word(word: 'Rift'),
        ],
      ),
    );
    when(() => mockLocalWordDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    final importedWords = await wordRepository.importWordsFromFile(mockFile);

    expect(importedWords.addedWords.length, 5);
    expect(importedWords.invalidWords.length, 1);
  });

  test('Add to new words returns 5 valid and 1 invalid word', () async {
    const text = 'Good is a nice rift InvalidWord';
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.findAll(any()))
        .thenAnswer((_) => Future(() => []));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [
          Word(word: 'Good'),
          Word(word: 'Is'),
          Word(word: 'A'),
          Word(word: 'Nice'),
          Word(word: 'Rift'),
        ],
      ),
    );
    when(() => mockLocalWordDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    final importedWords = await wordRepository.importWordsFromText(text);
    expect(importedWords.addedWords.length, 5);
    expect(importedWords.invalidWords.length, 1);
  });

  test('Add to new words returns 5 already added word and 1 invalid word',
      () async {
    const text = 'Good is a nice rift InvalidWord';
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [
          Word(word: 'Good'),
          Word(word: 'Is'),
          Word(word: 'A'),
          Word(word: 'Nice'),
          Word(word: 'Rift'),
        ],
      ),
    );
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [],
      ),
    );
    when(() => mockLocalWordDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    final importedWords = await wordRepository.importWordsFromText(text);
    expect(importedWords.addedWords.length, 0);
    expect(importedWords.invalidWords.length, 1);
    expect(importedWords.alreadyAddedWords.length, 5);
  });

  test('Import words from subtitle file gets 13 added words, 1 invalid words',
      () async {
    const subtitleFileContent = '''
1
00:00:24,028 --> 00:00:26,118
(FIRST LINE)

2
00:00:43,123 --> 00:00:47,147
(SOMETHING IS HAPPENING)

3
00:01:05,603 --> 00:01:07,669
(SOMEONE SCREAMING)

4
00:01:09,239 --> 00:01:11,307
(DRAMATIC MUSIC)

5
00:01:13,243 --> 00:01:15,578
(PANTING)

6
00:01:15,679 --> 00:01:17,747
DIALOG

7
00:02:15,679 --> 00:02:17,747
My name is Aleva
''';
    final mockLocalWordDao = MockLocalWordDao();
    final mockRemoteWordDao = MockRemoteWordDao();
    final mockMeaningDao = MockMeaningDao();
    final wordRepository = _setupWordRepository(
      mockLocalWordDao,
      mockRemoteWordDao,
      mockMeaningDao,
    );
    const wordsInRemote = [
      'First',
      'Line',
      'Something',
      'Is',
      'Happening',
      'Someone',
      'Screaming',
      'Dramatic',
      'Music',
      'Panting',
      'Dialog',
      'My',
      'Name',
    ];
    final mockFile = MockFile();
    when(() => mockFile.readAsString())
        .thenAnswer((_) => Future(() => subtitleFileContent));
    final wordsInRemoteResponse =
        wordsInRemote.map((e) => Word(word: e)).toList();
    when(() => mockLocalWordDao.findAll(any()))
        .thenAnswer((_) => Future(() => []));
    when(() => mockRemoteWordDao.findAll(any()))
        .thenAnswer((invocation) => Future(() => wordsInRemoteResponse));
    when(() => mockLocalWordDao.insertAll(any()))
        .thenAnswer((_) => Future(() => Future.value()));
    final importedWords = await wordRepository.importWordsFromFile(mockFile);
    expect(importedWords.addedWords.length, 13);
    expect(importedWords.invalidWords.length, 1);
  });

  test('Add meanings and  to database', () async {
    final localWordDao = MockLocalWordDao();
    const text = 'Test';
    final remoteWordDao = MockRemoteWordDao();
    final meaningDao = MockMeaningDao();
    final definitionDao = MockDefinitionDao();
    final answer = [
      Word(word: 'test', meanings: [
        Meaning(id: 0, partOfSpeech: 'verb', wordId: 'test', definitions: [
          Definition(id: 0, definition: 'Def', example: 'Example', meaningId: 0)
        ])
      ])
    ];
    final wordRepository = WordRepository(
        localWordDao: localWordDao,
        remoteWordDao: remoteWordDao,
        meaningDao: meaningDao,
        definitionDao: definitionDao);
    when(() => remoteWordDao.findAll(any()))
        .thenAnswer((_) => Future(() => answer));
    when(() => localWordDao.findAll(any())).thenAnswer((_) => Future(() => []));
    when(() => localWordDao.insertAll(any())).thenAnswer((_) => Future.value());
    when(() => meaningDao.insertAll(any())).thenAnswer((_) => Future.value());
    when(() => definitionDao.insertAll(any()))
        .thenAnswer((_) => Future.value());
    await wordRepository.importWordsFromText(text);
    verify(() => localWordDao.insertAll(any())).called(1);
    verify(() => meaningDao.insertAll(any())).called(1);
    verify(() => definitionDao.insertAll(any())).called(1);
  });
}

class MockLocalWordDao extends Mock implements LocalPersistentWordDao {}

class MockRemoteWordDao extends Mock implements RemoteWordDao {}

class MockFile extends Mock implements File {}

class MockDefinitionDao extends Mock implements DefinitionDao {}

class MockMeaningDao extends Mock implements MeaningDao {}
