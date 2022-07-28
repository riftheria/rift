import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/rift_database.dart';

class WordRepository {
  final LocalWordDao _localWordDao;
  final RemoteWordDao _remoteWordDao;

  WordRepository({
    required LocalWordDao localWordDao,
    required RemoteWordDao remoteWordsDao,
  })  : _localWordDao = localWordDao,
        _remoteWordDao = remoteWordsDao;

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
