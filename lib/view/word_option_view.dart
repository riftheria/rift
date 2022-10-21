import 'package:flutter/material.dart';
import 'package:rift/data/dataclasses/complete_word.dart';
import 'package:rift/viewmodel/guess_the_definition_game_viewmodel.dart';
import 'package:rift/viewmodel/word_viewmodel.dart';

class WordOptionView extends StatelessWidget {
  final Function(int selectedDefinition) callback;
  final CompleteWord completeWord;
  final int selectedDefinitionId;
  final int correctDefinitionId;

  final GameState gameState;

  const WordOptionView({
    super.key,
    required this.callback,
    required this.completeWord,
    required this.selectedDefinitionId,
    required this.gameState,
    required this.correctDefinitionId,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedDefinitionId == completeWord.definition.id;
    Color backgroundColor = Colors.grey;
    if (gameState == GameState.onGoing && isSelected) {
      backgroundColor = Colors.green;
    }
    if (gameState == GameState.gotCorrectAnswer && isSelected) {
      backgroundColor = Colors.green;
    }
    if (gameState == GameState.gotIncorrectAnswer && isSelected) {
      backgroundColor = Colors.red;
    }
    if (gameState == GameState.gotIncorrectAnswer &&
        completeWord.definition.id == correctDefinitionId) {
      backgroundColor = Colors.green;
    }

    return Expanded(
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          child: ElevatedButton(
            onPressed: () => callback(completeWord.definition.id),
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                backgroundColor: backgroundColor),
            child: Text(
              completeWord.definition.definition ?? "",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
