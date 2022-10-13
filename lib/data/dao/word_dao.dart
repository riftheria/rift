import 'package:rift/data/models/word.dart';

abstract class LocalWordDao {
  void insert(Word word);
  Future<Word?> find(String word);
  Future<List<Word>> findAll(List<String> queryWords);
  Future<void> insertAll(List<Word> newWords);
}

abstract class RemoteWordDao {
  Word? find(String word);
  Future<List<Word>> findAll(List<String> queryWords);
}
