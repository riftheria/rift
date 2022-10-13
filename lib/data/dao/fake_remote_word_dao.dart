import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/models/word.dart';
import 'package:rift/data/rift_database.dart';

class FakeRemoteWordDao extends RemoteWordDao {
  final _dummyDatabase = ['It', 'Is', 'A', 'Nice', 'Rift', 'Own'].map(
    (e) => Word(
      word: e,
    ),
  );
  @override
  Word? find(String word) {
    return word == 'Invalid' ? null : Word(word: word);
  }

  @override
  Future<List<Word>> findAll(List<String> queryWords) async {
    final lowCaseQueryWords = queryWords.map((e) => e.toLowerCase());
    final found = _dummyDatabase
        .where(
            (element) => lowCaseQueryWords.contains(element.word.toLowerCase()))
        .toList();
    return found;
  }
}
