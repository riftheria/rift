import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/repository/word_repository.dart';
import 'package:rift/data/rift_database.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(Word(id: 0, word: 'Word'));
  });
  test('Retrieve word in remote if local dao doesn\'t have the word', () async {
    const word = 'Word';
    final mockLocalWordDao = MockLocalWordDao();
    when(() => mockLocalWordDao.find(any()))
        .thenAnswer((_) => Future(() => null));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.find(any()))
        .thenReturn(Word(id: 0, word: word));
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
          .thenAnswer((_) => Future(() => Word(id: 0, word: word)));
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
    when(() => mockRemoteWordDao.find(any()))
        .thenReturn(Word(id: 0, word: word));
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
        .thenAnswer((_) => Future(() => Word(id: 0, word: word)));
    final mockRemoteWordDao = MockRemoteWordDao();
    when(() => mockRemoteWordDao.find(any())).thenReturn(null);
    final wordRepository = WordRepository(
        localWordDao: mockLocalWordDao, remoteWordDao: mockRemoteWordDao);
    expect(() => wordRepository.addToKnownWords(word),
        throwsA(isA<WordAlreadyAddedException>()));
  });

  test('New words are not in local and they have been found in remote',
      () async {
    const fileContentLines = <String>['First line', 'Second line iftgfs'];
    final mockFile = MockFile();
    when(() => mockFile.readAsLines())
        .thenAnswer((invocation) => Future(() => fileContentLines));
    final localDao = MockLocalWordDao();
    when(() => localDao.findAll(any())).thenAnswer((_) => Future(() => []));
    final remoteDao = MockRemoteWordDao();
    when(() => remoteDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [
          Word(id: 0, word: 'First'),
          Word(id: 1, word: 'Second'),
          Word(id: 2, word: 'Line'),
        ],
      ),
    );
    when(() => localDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final wordRepository =
        WordRepository(localWordDao: localDao, remoteWordDao: remoteDao);
    final validWords =
        (await wordRepository.importWordsFromFile(mockFile)).validWords;
    expect(validWords.length, 3);
  });

  test('Import words from file returns 5 valid words', () async {
    const fileContentLines = <String>['Good is a nice rift'];
    final mockFile = MockFile();
    when(() => mockFile.readAsLines())
        .thenAnswer((invocation) => Future(() => fileContentLines));
    final localDao = MockLocalWordDao();
    when(() => localDao.findAll(any())).thenAnswer((_) => Future(() => []));
    final remoteDao = MockRemoteWordDao();
    when(() => remoteDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [
          Word(id: 0, word: 'Good'),
          Word(id: 1, word: 'Is'),
          Word(id: 2, word: 'A'),
          Word(id: 3, word: 'Nice'),
          Word(id: 4, word: 'Rift'),
        ],
      ),
    );
    when(() => localDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final wordRepository =
        WordRepository(localWordDao: localDao, remoteWordDao: remoteDao);
    final validWords =
        (await wordRepository.importWordsFromFile(mockFile)).validWords;
    expect(validWords.length, 5);
  });

  test('Import words from file and save them in local', () async {
    const fileContentLines = <String>['Good is a nice rift'];
    final mockFile = MockFile();
    when(() => mockFile.readAsLines())
        .thenAnswer((invocation) => Future(() => fileContentLines));
    final localDao = MockLocalWordDao();
    when(() => localDao.findAll(any())).thenAnswer((_) => Future(() => []));
    final remoteDao = MockRemoteWordDao();
    when(() => remoteDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [
          Word(id: 0, word: 'Good'),
          Word(id: 1, word: 'Is'),
          Word(id: 2, word: 'A'),
          Word(id: 3, word: 'Nice'),
          Word(id: 4, word: 'Rift'),
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
    const fileContentLines = <String>['Good is a nice rift InvalidWord'];
    final mockFile = MockFile();
    when(() => mockFile.readAsLines())
        .thenAnswer((invocation) => Future(() => fileContentLines));
    final localDao = MockLocalWordDao();
    when(() => localDao.findAll(any())).thenAnswer((_) => Future(() => []));
    final remoteDao = MockRemoteWordDao();
    when(() => remoteDao.findAll(any())).thenAnswer(
      (_) => Future(
        () => [
          Word(id: 0, word: 'Good'),
          Word(id: 1, word: 'Is'),
          Word(id: 2, word: 'A'),
          Word(id: 3, word: 'Nice'),
          Word(id: 4, word: 'Rift'),
        ],
      ),
    );
    when(() => localDao.insertAll(any()))
        .thenAnswer((invocation) => Future.value());
    final wordRepository =
        WordRepository(localWordDao: localDao, remoteWordDao: remoteDao);
    final importedWords = await wordRepository.importWordsFromFile(mockFile);

    expect(importedWords.validWords.length, 5);
    expect(importedWords.invalidWords.length, 1);
  });
}

class MockLocalWordDao extends Mock implements LocalWordDao {}

class MockRemoteWordDao extends Mock implements RemoteWordDao {}

class MockFile extends Mock implements File {}
