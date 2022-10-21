import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rift/constants.dart';
import 'package:rift/data/dao/local_persistent_sql_word_dao.dart';
import 'package:rift/data/dao/meaning_dao.dart';
import 'package:rift/data/dao/definition_dao.dart';
import 'package:rift/data/dao/remote_word_dao.dart';
import 'package:rift/data/dao/rift_remote_word_dao_adapter.dart';
import 'package:rift/data/repository/word_repository.dart';
import 'package:rift/data/rift_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dioProvider = Provider((ref) => Dio());
final riftRemoteWordDao = Provider((ref) =>
    RiftRemoteWordDao(ref.watch(dioProvider), baseUrl: riftServerBaseUrl));
final remoteWordDaoProvider = Provider(
    (ref) => RiftRemoteWordADaoAdapter(dao: ref.watch(riftRemoteWordDao)));
final riftDatabase = Provider((ref) => RiftDatabase());
final localWordDaoProvider =
    Provider((ref) => LocalPersistentWordDao(ref.watch(riftDatabase)));
final meaningDaoProvider =
    Provider((ref) => MeaningDao(ref.watch(riftDatabase)));
final definitionDaoProvider =
    Provider((ref) => DefinitionDao(ref.watch(riftDatabase)));
final wordRepositoryProvider = Provider(
  (ref) => WordRepository(
    localWordDao: ref.watch(localWordDaoProvider),
    remoteWordDao: ref.watch(remoteWordDaoProvider),
    meaningDao: ref.watch(meaningDaoProvider),
    definitionDao: ref.watch(definitionDaoProvider),
  ),
);

final wordViewModelProvider = Provider((ref) => WordViewModelProvider(ref));

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

  Future<bool> isFirstImportTextFile() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    bool firstTime = true;
    firstTime = sharedPreferences.getBool('first_text_import') ?? true;
    if (firstTime) {
      sharedPreferences.setBool('first_text_import', false);
    }
    return firstTime;
  }
}

enum DialogShowed { importTextFile }
