import 'dart:io';

import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/rift_database.dart';

class WordRepository {
  final LocalWordDao _localWordDao;
  final RemoteWordDao _remoteWordDao;

  WordRepository({
    required LocalWordDao localWordDao,
    required RemoteWordDao remoteWordDao,
  })  : _localWordDao = localWordDao,
        _remoteWordDao = remoteWordDao;

  Future<void> addToKnownWords(String newWord) async {
    Word? newWordData = await _localWordDao.find(newWord);
    if (newWordData == null) {
      newWordData = _remoteWordDao.find(newWord);
      if (newWordData != null) {
        _localWordDao.insert(newWordData);
      } else {
        throw InvalidWordException(message: 'Not a valid English word');
      }
    } else {
      throw WordAlreadyAddedException(message: 'Word $newWord already exists');
    }
  }

  Future<Word?> find(String word) async {
    Word? retrievedWord =
        await _localWordDao.find(word) ?? _remoteWordDao.find(word);
    return retrievedWord;
  }

  Future<ImportedWords> importWordsFromFile(File file) async {
    final lines = await file.readAsLines();
    final words = <String>[];
    for (String line in lines) {
      words.addAll(line.trim().split(' '));
    }
    final validWords = <Word>[];
    final invalidWords = <String>[];
    final wordsInLocal = await _localWordDao.findAll(words);
    final wordsInLocalStringList = wordsInLocal.map((e) => e.word);
    final wordsNotFoundInLocal = words
        .where((element) => !wordsInLocalStringList.contains(element))
        .toList();
    final wordsInRemote = await _remoteWordDao.findAll(wordsNotFoundInLocal);
    final wordsInRemoteString = wordsInRemote.map((e) => e.word);
    validWords.addAll(wordsInLocal);
    validWords.addAll(wordsInRemote);
    invalidWords.addAll(wordsInRemoteString
        .where((element) => wordsNotFoundInLocal.contains(element)));
    await _localWordDao.insertAll(validWords);
    ImportedWords importedWords = ImportedWords(
        validWords: validWords.map((e) => e.word).toList(),
        invalidWords: invalidWords);
    return importedWords;
  }
}

class InvalidWordException implements Exception {
  final String _message;
  InvalidWordException({required String message}) : _message = message;
  @override
  String toString() {
    return _message;
  }
}

class WordAlreadyAddedException implements Exception {
  final String _message;
  WordAlreadyAddedException({required String message}) : _message = message;
  @override
  String toString() {
    return _message;
  }
}

class ImportedWords {
  final List<String> validWords;
  final List<String> invalidWords;
  ImportedWords({required this.validWords, required this.invalidWords});
}
