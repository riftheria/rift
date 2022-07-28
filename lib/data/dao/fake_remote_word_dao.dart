import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/rift_database.dart';

class FakeRemoteWordDao extends RemoteWordDao {
  @override
  Word? find(String word) {
    return word == 'Invalid' ? null : Word(id: 0, word: word);
  }
}
