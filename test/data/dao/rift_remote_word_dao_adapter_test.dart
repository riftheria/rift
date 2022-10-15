import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rift/data/dao/remote_word_dao.dart';
import 'package:rift/data/dao/rift_remote_word_dao_adapter.dart';
import 'package:rift/data/dao/word_dao.dart';
import 'package:rift/data/models/word.dart';

void main() {
  test('Adapter is a RemoteWordDao', () async {
    RiftRemoteWordDao riftRemoteWordDao = MockRiftRemoteWordDao();
    RiftRemoteWordADaoAdapter adapter =
        RiftRemoteWordADaoAdapter(dao: riftRemoteWordDao);
    expect(adapter, isA<RemoteWordDao>());
  });

  test('Adapter got an item when is querying for a word', () async {
    RiftRemoteWordDao riftRemoteWordDao = MockRiftRemoteWordDao();
    RiftRemoteWordADaoAdapter adapter =
        RiftRemoteWordADaoAdapter(dao: riftRemoteWordDao);
    when(() => riftRemoteWordDao.findWithWordNames(any()))
        .thenAnswer((_) => Future(() => [Word(word: 'word')]));
    final words = await adapter.findAll(['word']);
    expect(words, hasLength(1));
  });

  test('Adapter got an item when is querying a single word', () async {
    RiftRemoteWordDao riftRemoteWordDao = MockRiftRemoteWordDao();
    RiftRemoteWordADaoAdapter adapter =
        RiftRemoteWordADaoAdapter(dao: riftRemoteWordDao);
    when(() => riftRemoteWordDao.findWithWordNames(any()))
        .thenAnswer((_) => Future(() => [Word(word: 'word')]));
    final words = await adapter.find('word');
    expect(words, isNotNull);
  });
}

class MockRiftRemoteWordDao extends Mock implements RiftRemoteWordDao {}
