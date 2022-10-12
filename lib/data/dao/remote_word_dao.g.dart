// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_word_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerMeaning _$ServerMeaningFromJson(Map<String, dynamic> json) =>
    ServerMeaning(
      partOfSpeech: json['partOfSpeech'] as String?,
      definitions: (json['definitions'] as List<dynamic>?)
          ?.map((e) => ServerDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ServerMeaningToJson(ServerMeaning instance) =>
    <String, dynamic>{
      'partOfSpeech': instance.partOfSpeech,
      'definitions': instance.definitions,
    };

ServerWord _$ServerWordFromJson(Map<String, dynamic> json) => ServerWord(
      word: json['word'] as String?,
      phonetic: json['phonetic'] as String?,
      meanings: (json['meanings'] as List<dynamic>?)
          ?.map((e) => ServerMeaning.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ServerWordToJson(ServerWord instance) =>
    <String, dynamic>{
      'word': instance.word,
      'phonetic': instance.phonetic,
      'meanings': instance.meanings,
    };

ServerDefinition _$ServerDefinitionFromJson(Map<String, dynamic> json) =>
    ServerDefinition(
      definition: json['definition'] as String?,
      example: json['example'] as String?,
    );

Map<String, dynamic> _$ServerDefinitionToJson(ServerDefinition instance) =>
    <String, dynamic>{
      'definition': instance.definition,
      'example': instance.example,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _RiftRemoteWordDao implements RiftRemoteWordDao {
  _RiftRemoteWordDao(
    this._dio, {
    this.baseUrl,
  });

  final Dio _dio;

  String? baseUrl;

  @override
  Future<List<ServerWord>> findWithWordNames(queries) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.addAll(queries);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio
        .fetch<List<dynamic>>(_setStreamType<List<ServerWord>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/dictionary',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    var value = _result.data!
        .map((dynamic i) => ServerWord.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
