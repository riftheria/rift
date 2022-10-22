import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rift/data/dataclasses/complete_word.dart';
import 'package:rift/view/add_new_words_page.dart';
import 'package:rift/view/word_option_view.dart';
import 'package:rift/viewmodel/guess_the_definition_game_viewmodel.dart';

final selectedDefinitionIdProvider = StateProvider((ref) => -1);

class GuessTheDefinitionGame extends ConsumerWidget {
  const GuessTheDefinitionGame({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == GameState.iddle) {
      _refreshGame(ref);
    }
    final completeWords = ref.watch(completeWordsListProvider);
    final correctWord = ref.watch(correctCompleteWordProvider);
    final selectedDefinitionId = ref.watch(selectedDefinitionIdProvider);
    final wordCount = ref.watch(wordsCountProvider).value ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess the definition'),
        actions: [
          IconButton(
              onPressed: (() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (buildContext) => const AddNewWordsPage(),
                  ),
                );
              }),
              icon: const Icon(Icons.add))
        ],
      ),
      body: wordCount < 3
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/images/cat_empty_view.svg'),
                  const Text(
                    'Not enough words to play, please add more.',
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (buildContext) => const AddNewWordsPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Add new words',
                    ),
                  ),
                ],
              ),
            )
          : _buildGuessTheDefinitionGameView(
              ref,
              completeWords,
              correctWord,
              selectedDefinitionId,
              gameState,
            ),
    );
  }

  void selectedDefinitionCallback(WidgetRef ref, int selectedDefinitionId) {
    ref.read(selectedDefinitionIdProvider.state).state = selectedDefinitionId;
  }

  void verifyAnswer(WidgetRef ref) {
    final selectedDefinitionId = ref.read(selectedDefinitionIdProvider);
    ref
        .read(guessTheDefinitionViewmodelProvider)
        .verifyDefinitionSelection(selectedDefinitionId);
  }

  void _refreshGame(WidgetRef ref) {
    ref
        .read(guessTheDefinitionViewmodelProvider)
        .refreshQuiz(correctDefinitionPosition: Random().nextInt(3));
    ref.read(selectedDefinitionIdProvider.state).state = -1;
  }

  Widget buildBottomButton(GameState gameState, WidgetRef ref) {
    Widget button = ElevatedButton(
      onPressed: () => verifyAnswer(ref),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
      child: const Text('Check answer', style: TextStyle(color: Colors.white)),
    );

    if (gameState == GameState.gotCorrectAnswer) {
      button = ElevatedButton(
        onPressed: () {
          _refreshGame(ref);
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text(
          'Correct, Next question!',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    if (gameState == GameState.gotIncorrectAnswer) {
      button = ElevatedButton(
        onPressed: () {
          _refreshGame(ref);
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text('Good luck next time',
            style: TextStyle(color: Colors.white)),
      );
    }
    return button;
  }

  Widget _buildGuessTheDefinitionGameView(
      WidgetRef ref,
      List<CompleteWord> completeWords,
      CompleteWord? correctWord,
      int selectedDefinitionId,
      GameState gameState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Column(children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'What is a correct definition of ${correctWord?.word.word ?? ''}?',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            LinearProgressIndicator(
              value: ref.watch(remainingTimePercentageProvider),
            ),
            ...completeWords.map(
              (completeWord) => WordOptionView(
                completeWord: completeWord,
                callback: (int selectedDefinition) =>
                    selectedDefinitionCallback(ref, selectedDefinition),
                selectedDefinitionId: selectedDefinitionId,
                gameState: gameState,
                correctDefinitionId: correctWord?.definition.id ?? 0,
              ),
            )
          ]),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          child: buildBottomButton(gameState, ref),
        )
      ],
    );
  }
}
