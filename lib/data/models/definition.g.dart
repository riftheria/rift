// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Definition _$DefinitionFromJson(Map<String, dynamic> json) => Definition(
      id: json['id'] as int,
      meaningId: json['meaningId'] as int,
      definition: json['definition'] as String?,
      example: json['example'] as String?,
    );

Map<String, dynamic> _$DefinitionToJson(Definition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'meaningId': instance.meaningId,
      'definition': instance.definition,
      'example': instance.example,
    };
