import 'package:json_annotation/json_annotation.dart';
import 'package:rift/data/models/definition.dart';
part 'meaning.g.dart';

@JsonSerializable()
class Meaning {
  String partOfSpeech;
  List<Definition>? definitions;

  Meaning({required this.partOfSpeech, this.definitions});

  factory Meaning.fromJson(Map<String, dynamic> json) =>
      _$MeaningFromJson(json);
  Map<String, dynamic> toJson() => _$MeaningToJson(this);
}
