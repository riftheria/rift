// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meaning.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meaning _$MeaningFromJson(Map<String, dynamic> json) => Meaning(
      id: json['id'] as int,
      partOfSpeech: json['partOfSpeech'] as String,
      wordId: json['wordId'] as String,
      definitions: (json['definitions'] as List<dynamic>?)
          ?.map((e) => Definition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MeaningToJson(Meaning instance) => <String, dynamic>{
      'id': instance.id,
      'partOfSpeech': instance.partOfSpeech,
      'wordId': instance.wordId,
      'definitions': instance.definitions,
    };
