import 'dart:io';

import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/models/word.dart';
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
    final words = <String>[];
    final content = await file.readAsString();
    final wordsRegex = RegExp(r'([a-zA-Z])+');
    final allMatches = wordsRegex.allMatches(content);
    for (RegExpMatch match in allMatches) {
      final word = match.group(0);
      if (word != null) {
        words.add(word);
      }
    }
    return _importWords(words);
  }

  Future<ImportedWords> _importWords(List<String> newWords) async {
    final newImportedWords = <Word>[];
    final alreadyImportedWords = <String>[];
    final invalidWords = <String>[];
    final wordsInLocal = await _localWordDao.findAll(newWords);
    final wordsInLocalLowerCase = wordsInLocal.map((e) => e.word.toLowerCase());
    var newWordsLowerCase = newWords.map((e) => e.toLowerCase());
    final wordsNotFoundInLocal = newWordsLowerCase
        .where((element) => !wordsInLocalLowerCase.contains(element))
        .toList();
    final wordsInRemote = await _remoteWordDao.findAll(wordsNotFoundInLocal);
    final wordsInRemoteLowerCase =
        wordsInRemote.map((e) => e.word?.toLowerCase());
    newImportedWords.addAll(wordsInRemote);
    await _localWordDao.insertAll(newImportedWords);
    invalidWords.addAll(newWordsLowerCase.where((e) =>
        !wordsInLocalLowerCase.contains(e) &&
        !wordsInRemoteLowerCase.contains(e)));
    alreadyImportedWords.addAll(
        newWordsLowerCase.where((e) => wordsInLocalLowerCase.contains(e)));
    ImportedWords importedWords = ImportedWords(
        addedWords: newImportedWords.map((e) => e.word).toList(),
        invalidWords: invalidWords,
        alreadyAddedWords: alreadyImportedWords);
    return importedWords;
  }

  Future<ImportedWords> importWordsFromText(String text) async {
    final words = text.split(' ');
    return _importWords(words);
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
  final List<String> addedWords;
  final List<String> invalidWords;
  final List<String> alreadyAddedWords;
  ImportedWords({
    required this.addedWords,
    required this.invalidWords,
    required this.alreadyAddedWords,
  });
}
