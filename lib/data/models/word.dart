import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rift/data/models/meaning.dart';
import 'package:rift/data/rift_database.dart';
part 'word.g.dart';

@JsonSerializable()
class Word implements Insertable<Word> {
  String word;
  String? phonetic;
  List<Meaning>? meanings;

  Word({required this.word, this.phonetic, this.meanings});
  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return WordsCompanion(word: Value(word), phonetic: Value(phonetic))
        .toColumns(nullToAbsent);
  }

  @override
  String toString() {
    return 'word: $word, phonetic: $phonetic';
  }
}
