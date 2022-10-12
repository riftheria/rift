import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';
part 'remote_word_dao.g.dart';

@RestApi()
abstract class RiftRemoteWordDao {
  factory RiftRemoteWordDao(Dio dio, {required String baseUrl}) =
      _RiftRemoteWordDao;

  @GET('/dictionary')
  Future<List<ServerWord>> findWithWordNames(
      @Queries() Map<String, dynamic> queries);
}

@JsonSerializable()
class ServerMeaning {
  String? partOfSpeech;
  List<ServerDefinition>? definitions;

  ServerMeaning({this.partOfSpeech, this.definitions});

  factory ServerMeaning.fromJson(Map<String, dynamic> json) =>
      _$ServerMeaningFromJson(json);
  Map<String, dynamic> toJson() => _$ServerMeaningToJson(this);
}

@JsonSerializable()
class ServerWord {
  String? word;
  String? phonetic;
  List<ServerMeaning>? meanings;

  ServerWord({this.word, this.phonetic, this.meanings});
  factory ServerWord.fromJson(Map<String, dynamic> json) =>
      _$ServerWordFromJson(json);
  Map<String, dynamic> toJson() => _$ServerWordToJson(this);
}

@JsonSerializable()
class ServerDefinition {
  String? definition;
  String? example;

  ServerDefinition({this.definition, this.example});
  factory ServerDefinition.fromJson(Map<String, dynamic> json) =>
      _$ServerDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$ServerDefinitionToJson(this);
}
