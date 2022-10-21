import 'package:rift/data/models/definition.dart';
import 'package:rift/data/models/meaning.dart';
import 'package:rift/data/models/word.dart';

class CompleteWord {
  final Word word;
  final Meaning meaning;
  final Definition definition;

  CompleteWord({
    required this.word,
    required this.meaning,
    required this.definition,
  });
}
