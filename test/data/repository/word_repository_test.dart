import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/models/word.dart';
import 'package:rift/data/repository/word_repository.dart';
import 'package:rift/data/rift_database.dart';

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
    when(() => mockRemoteWordDao.find(any())).thenReturn(Word(word: word));
    final wordRepository = WordRepository(
      localWordDao: mockLocalWordDao,
      remoteWordDao: mockRemoteWordDao,
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
    when(() => mockRemoteWordDao.find(any())).thenReturn(null);
    final wordRepository = WordRepository(
      localWordDao: mockLocalWordDao,
      remoteWordDao: mockRemoteWordDao,
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
      when(() => mockRemoteWordDao.find(any())).thenReturn(null);
      final wordRepository = WordRepository(
          localWordDao: mockLocalWordDao, remoteWordDao: mockRemoteWordDao);
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
    when(() => mockRemoteWordDao.find(any())).thenReturn(Word(word: word));
    final wordRepository = WordRepository(
        localWordDao: mockLocalWordDao, remoteWordDao: mockRemoteWordDao);
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
    when(() => mockRemoteWordDao.find(any())).thenReturn(null);
    final wordRepository = WordRepository(
        localWordDao: mockLocalWordDao, remoteWordDao: mockRemoteWordDao);
    expect(() => wordRepository.addToKnownWords(word),
        throwsA(isA<InvalidWordException>()));
  });

  test('Throw and exception when the word already exists', () async {
    const word = 'Word';
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.find(any()))
        .thenAnswer((_) => Future(() => Word(word: word)));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.find(any())).thenReturn(null);
    final wordRepository = WordRepository(
        localWordDao: mockLocalWordDao, remoteWordDao: mockRemoteWordDao);
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
    final localDao = MockLocalWordDao();
    when(() => localDao.findAll(any())).thenAnswer((_) => Future(() => []));
    final remoteDao = MockRemoteWordDao();
    when(() => remoteDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [
          Word(word: 'First'),
          Word(word: 'Second'),
          Word(word: 'Line'),
        ],
      ),
    );
    when(() => localDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final wordRepository =
        WordRepository(localWordDao: localDao, remoteWordDao: remoteDao);
    final validWords =
        (await wordRepository.importWordsFromFile(mockFile)).addedWords;
    expect(validWords.length, 3);
  });

  test('Import words from file returns 5 valid words', () async {
    const fileContentLines = 'Good is a nice rift';
    final mockFile = MockFile();
    when(() => mockFile.readAsString())
        .thenAnswer((invocation) => Future(() => fileContentLines));
    final localDao = MockLocalWordDao();
    when(() => localDao.findAll(any())).thenAnswer((_) => Future(() => []));
    final remoteDao = MockRemoteWordDao();
    when(() => remoteDao.findAll(any())).thenAnswer(
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
    when(() => localDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final wordRepository =
        WordRepository(localWordDao: localDao, remoteWordDao: remoteDao);
    final validWords =
        (await wordRepository.importWordsFromFile(mockFile)).addedWords;
    expect(validWords.length, 5);
  });

  test('Import words from file and save them in local', () async {
    const fileContentLines = 'Good is a nice rift';
    final mockFile = MockFile();
    when(() => mockFile.readAsString())
        .thenAnswer((invocation) => Future(() => fileContentLines));
    final localDao = MockLocalWordDao();
    when(() => localDao.findAll(any())).thenAnswer((_) => Future(() => []));
    final remoteDao = MockRemoteWordDao();
    when(() => remoteDao.findAll(any())).thenAnswer(
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
    when(() => localDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final wordRepository =
        WordRepository(localWordDao: localDao, remoteWordDao: remoteDao);
    await wordRepository.importWordsFromFile(mockFile);
    verify(() => localDao.insertAll(any())).called(1);
  });

  test('Import words from file returns 5 valid words and 1 invalid word',
      () async {
    const fileContentLines = 'Good is a nice rift InvalidWord';
    final mockFile = MockFile();
    when(() => mockFile.readAsString())
        .thenAnswer((invocation) => Future(() => fileContentLines));
    final localDao = MockLocalWordDao();
    when(() => localDao.findAll(any())).thenAnswer((_) => Future(() => []));
    final remoteDao = MockRemoteWordDao();
    when(() => remoteDao.findAll(any())).thenAnswer(
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
    when(() => localDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final wordRepository =
        WordRepository(localWordDao: localDao, remoteWordDao: remoteDao);
    final importedWords = await wordRepository.importWordsFromFile(mockFile);

    expect(importedWords.addedWords.length, 5);
    expect(importedWords.invalidWords.length, 1);
  });

  test('Add to new words returns 5 valid and 1 invalid word', () async {
    const text = 'Good is a nice rift InvalidWord';
    final localDao = MockLocalWordDao();
    when(() => localDao.findAll(any())).thenAnswer((_) => Future(() => []));
    final remoteDao = MockRemoteWordDao();
    when(() => remoteDao.findAll(any())).thenAnswer(
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
    when(() => localDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final wordRepository =
        WordRepository(localWordDao: localDao, remoteWordDao: remoteDao);
    final importedWords = await wordRepository.importWordsFromText(text);
    expect(importedWords.addedWords.length, 5);
    expect(importedWords.invalidWords.length, 1);
  });

  test('Add to new words returns 5 already added word and 1 invalid word',
      () async {
    const text = 'Good is a nice rift InvalidWord';
    final localDao = MockLocalWordDao();
    when(() => localDao.findAll(any())).thenAnswer(
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
    final remoteDao = MockRemoteWordDao();
    when(() => remoteDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [],
      ),
    );
    when(() => localDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final wordRepository =
        WordRepository(localWordDao: localDao, remoteWordDao: remoteDao);
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
    final localDao = MockLocalWordDao();
    final remoteDao = MockRemoteWordDao();
    final wordRepository =
        WordRepository(localWordDao: localDao, remoteWordDao: remoteDao);
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
    when(() => localDao.findAll(any())).thenAnswer((_) => Future(() => []));
    when(() => remoteDao.findAll(any()))
        .thenAnswer((invocation) => Future(() => wordsInRemoteResponse));
    when(() => localDao.insertAll(any()))
        .thenAnswer((_) => Future(() => Future.value()));
    final importedWords = await wordRepository.importWordsFromFile(mockFile);
    expect(importedWords.addedWords.length, 13);
    expect(importedWords.invalidWords.length, 1);
  });
}

class MockLocalWordDao extends Mock implements LocalWordDao {}

class MockRemoteWordDao extends Mock implements RemoteWordDao {}

class MockFile extends Mock implements File {}
