import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rift/data/models/definition.dart';
import 'package:rift/data/rift_database.dart';
part 'meaning.g.dart';

@JsonSerializable()
class Meaning extends Insertable<Meaning> {
  int id;
  String partOfSpeech;
  String wordId;
  List<Definition>? definitions;

  Meaning({
    required this.id,
    required this.partOfSpeech,
    required this.wordId,
    this.definitions,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) =>
      _$MeaningFromJson(json);
  Map<String, dynamic> toJson() => _$MeaningToJson(this);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return MeaningsCompanion(
      id: Value(id),
      partOfSpeech: Value(partOfSpeech),
      wordId: Value(wordId),
    ).toColumns(nullToAbsent);
  }

  @override
  String toString() {
    return 'id: $id, partOfSpeech: $partOfSpeech, wordId:$wordId';
  }
}
