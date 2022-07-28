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
    remoteWordsDao: ref.watch(remoteWordDaoProvider)));

final wordViewModelProvider =
    Provider.autoDispose((ref) => WordViewModelProvider(ref));

final addedWordsMessageProvider = StateProvider<String?>((ref) => null);
final newWordControllerProvider = Provider((ref) => TextEditingController());

class WordViewModelProvider extends ChangeNotifier {
  final Ref _ref;
  WordViewModelProvider(this._ref);
  Future<void> addToKnownWords(String word) async {
    String message = '';
    try {
      await _ref.read(wordRepositoryProvider).addToKnownWords(word);
      message = '1 new word added';
    } on InvalidWordException catch (_) {
      message = 'The word you\'re trying to add is invalid';
    } on WordAlreadyAddedException catch (_) {
      message = 'You have already added this word';
    }
    _ref.read(addedWordsMessageProvider.state).state = message;
  }
}
