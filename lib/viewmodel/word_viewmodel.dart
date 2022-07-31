import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rift/data/dao/fake_remote_word_dao.dart';
import 'package:rift/data/dao/local_persistent_sql_word_dao.dart';
import 'package:rift/data/repository/word_repository.dart';
import 'package:rift/data/rift_database.dart';

final remoteWordDaoProvider = Provider((ref) => FakeRemoteWordDao());
final riftDatabase = Provider((ref) => RiftDatabase());
final localWordDaoProvider =
    Provider((ref) => LocalPersistentWordDao(ref.watch(riftDatabase)));

final wordRepositoryProvider = Provider((ref) => WordRepository(
    localWordDao: ref.watch(localWordDaoProvider),
    remoteWordDao: ref.watch(remoteWordDaoProvider)));

final wordViewModelProvider =
    Provider.autoDispose((ref) => WordViewModelProvider(ref));

final addedWordsMessageProvider = StateProvider<String?>((ref) => null);
final newWordControllerProvider = Provider((ref) => TextEditingController());

class WordViewModelProvider extends ChangeNotifier {
  final Ref _ref;
  WordViewModelProvider(this._ref);
  Future<void> addToKnownWords(String text) async {
    ImportedWords importedWords =
        await _ref.read(wordRepositoryProvider).importWordsFromText(text);
    String message = _buildAddedWordsMessage(importedWords);

    _ref.read(addedWordsMessageProvider.state).state = message;
  }

  String _buildAddedWordsMessage(ImportedWords importedWords) {
    String message = '';
    final validWordsCount = importedWords.addedWords.length;
    final invalidWordsCount = importedWords.invalidWords.length;
    final wordsAlreadyAddedCount = importedWords.alreadyAddedWords.length;
    if (validWordsCount == 0 &&
        invalidWordsCount == 0 &&
        wordsAlreadyAddedCount == 1) {
      message = 'You have already added this word';
    } else if (validWordsCount == 0 &&
        invalidWordsCount == 1 &&
        wordsAlreadyAddedCount == 0) {
      message = 'The word you\'re trying to add is invalid';
    } else if (validWordsCount == 1 &&
        invalidWordsCount == 0 &&
        wordsAlreadyAddedCount == 0) {
      message = '1 word added';
    } else {
      message = '';
      if (validWordsCount > 0) {
        message +=
            '$validWordsCount word${validWordsCount > 1 ? 's' : ''} added';
        if (invalidWordsCount > 0) {
          message += ', ';
        }
      }
      if (invalidWordsCount > 0) {
        message +=
            '$invalidWordsCount invalid word${invalidWordsCount > 1 ? 's' : ''} not added';
        if (wordsAlreadyAddedCount > 0) {
          message += ', ';
        }
      }
      if (wordsAlreadyAddedCount > 0) {
        message +=
            '$wordsAlreadyAddedCount word${wordsAlreadyAddedCount > 1 ? 's' : ''} already added';
      }
    }
    return message;
  }

  Future<void> addToKnownWordsFromFile(File file) async {
    final importedWords =
        await _ref.read(wordRepositoryProvider).importWordsFromFile(file);
    _ref.read(addedWordsMessageProvider.state).state =
        _buildAddedWordsMessage(importedWords);
  }
}
