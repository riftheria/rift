import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:rift/data/dao/remote_word_dao.dart';
import 'package:dio/dio.dart';

Dio setupDioResponse() {
  Dio dio = Dio(BaseOptions());
  final dioAdapter = DioAdapter(dio: dio);
  dio.httpClientAdapter = dioAdapter;
  dioAdapter.onGet(
      '/dictionary',
      data: {},
      queryParameters: {'words[0]': 'word'},
      (server) =>
          server.reply(200, [ServerWord(word: 'word', phonetic: '/wɜːd/')]));
  return dio;
}

void main() {
  test("Get returns a list", () async {
    final dio = setupDioResponse();
    RiftRemoteWordDao remoteWordDao =
        RiftRemoteWordDao(dio, baseUrl: '127.0.0.1:8000');
    Map<String, String> wordQueryNames = <String, String>{};
    wordQueryNames['words[0]'] = 'word';
    expect(remoteWordDao.findWithWordNames(wordQueryNames),
        isA<Future<List<ServerWord>>>());
  });

  test("Get a list with one item from remote", () async {
    final dio = setupDioResponse();
    RiftRemoteWordDao remoteWordDao =
        RiftRemoteWordDao(dio, baseUrl: '127.0.0.1:8000');
    Map<String, String> queryWordNames = {'words[0]': 'word'};
    final response = await remoteWordDao.findWithWordNames(queryWordNames);
    expect(response.length, 1);
  });
}
