import 'package:rift/data/dao/remote_word_dao.dart';
import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/models/word.dart';

class RiftRemoteWordADaoAdapter implements RemoteWordDao {
  final RiftRemoteWordDao dao;
  RiftRemoteWordADaoAdapter({required this.dao});

  @override
  Future<Word?> find(String word) async {
    final queryWords = await findAll([word]);
    return queryWords.isNotEmpty ? queryWords[0] : null;
  }

  @override
  Future<List<Word>> findAll(List<String> queryWords) async {
    final queryWordsMap = <String, String>{};
    for (int i = 0; i < queryWords.length; i++) {
      queryWordsMap['words[$i]'] = queryWords[i];
    }
    return dao.findWithWordNames(queryWordsMap);
  }
}
