import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rift/data/rift_database.dart';
part 'definition.g.dart';

@JsonSerializable()
class Definition implements Insertable<Definition> {
  int id;
  int meaningId;
  String? definition;
  String? example;

  Definition(
      {required this.id,
      required this.meaningId,
      this.definition,
      this.example});
  factory Definition.fromJson(Map<String, dynamic> json) =>
      _$DefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$DefinitionToJson(this);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return DefinitionsCompanion(
      id: Value(id),
      definition: Value(definition),
      example: Value(example),
      meaningId: Value(meaningId),
    ).toColumns(nullToAbsent);
  }

  @override
  String toString() {
    return 'id: $id, meaningId: $meaningId';
  }
}
