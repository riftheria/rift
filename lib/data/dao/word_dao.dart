import 'package:rift/data/rift_database.dart';

abstract class LocalWordDao {
  void insert(Word word);
  Future<Word?> find(String word);
}

abstract class RemoteWordDao {
  Word? find(String word);
}
