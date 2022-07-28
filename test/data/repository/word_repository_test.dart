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
      remoteWordsDao: mockRemoteWordDao,
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
      remoteWordsDao: mockRemoteWordDao,
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
          localWordDao: mockLocalWordDao, remoteWordsDao: mockRemoteWordDao);
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
        localWordDao: mockLocalWordDao, remoteWordsDao: mockRemoteWordDao);
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
        localWordDao: mockLocalWordDao, remoteWordsDao: mockRemoteWordDao);
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
        localWordDao: mockLocalWordDao, remoteWordsDao: mockRemoteWordDao);
    expect(() => wordRepository.addToKnownWords(word),
        throwsA(isA<WordAlreadyAddedException>()));
  });
}

class MockLocalWordDao extends Mock implements LocalWordDao {}

class MockRemoteWordDao extends Mock implements RemoteWordDao {}
