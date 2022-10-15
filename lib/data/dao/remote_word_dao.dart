import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:rift/data/models/word.dart';
part 'remote_word_dao.g.dart';

@RestApi()
abstract class RiftRemoteWordDao {
  factory RiftRemoteWordDao(Dio dio, {required String baseUrl}) =
      _RiftRemoteWordDao;

  @GET('/dictionary')
  Future<List<Word>> findWithWordNames(@Queries() Map<String, dynamic> queries);
}
