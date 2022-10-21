import 'dart:io';
import 'package:rift/data/dao/local_persistent_sql_word_dao.dart';
import 'package:rift/data/dao/meaning_dao.dart';
import 'package:rift/data/dao/definition_dao.dart';
import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/dataclasses/complete_word.dart';
import 'package:rift/data/models/definition.dart';
import 'package:rift/data/models/meaning.dart';
import 'package:rift/data/models/word.dart';

class WordRepository {
  final LocalPersistentWordDao _localWordDao;
  final RemoteWordDao _remoteWordDao;
  final MeaningDao _meaningDao;
  final DefinitionDao _definitionDao;

  WordRepository({
    required LocalPersistentWordDao localWordDao,
    required RemoteWordDao remoteWordDao,
    required MeaningDao meaningDao,
    required DefinitionDao definitionDao,
  })  : _localWordDao = localWordDao,
        _remoteWordDao = remoteWordDao,
        _meaningDao = meaningDao,
        _definitionDao = definitionDao;

  Future<void> addToKnownWords(String newWord) async {
    Word? newWordData = await _localWordDao.find(newWord);
    if (newWordData == null) {
      newWordData = await _remoteWordDao.find(newWord);
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
        await _localWordDao.find(word) ?? await _remoteWordDao.find(word);
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
        wordsInRemote.map((e) => e.word.toLowerCase());
    newImportedWords.addAll(wordsInRemote);
    await _localWordDao.insertAll(newImportedWords);
    final meanings = <Meaning>[];
    final definitions = <Definition>[];
    for (Word wordInRemote in wordsInRemote) {
      meanings.addAll(wordInRemote.meanings ?? []);
    }
    for (Meaning meaning in meanings) {
      definitions.addAll(meaning.definitions ?? []);
    }
    await _meaningDao.insertAll(meanings);
    await _definitionDao.insertAll(definitions);
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

  Future<Word?> getRandomWords() async {
    return await _localWordDao.find('word');
  }

  Future<List<CompleteWord>> retrieveCompleteWords() async {
    return await _localWordDao.findThreeCompleteWords();
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
