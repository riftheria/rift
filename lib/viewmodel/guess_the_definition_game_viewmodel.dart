import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rift/data/dataclasses/complete_word.dart';
import 'package:rift/viewmodel/word_viewmodel.dart';

final completeWordsListProvider = StateProvider((ref) => <CompleteWord>[]);
final correctCompleteWordProvider = StateProvider<CompleteWord?>((ref) => null);
final gameStateProvider = StateProvider((ref) => GameState.iddle);
final remainingTimePercentageProvider = StateProvider((ref) => -1.0);
final guessTheDefinitionViewmodelProvider =
    Provider((ref) => GuessTheDefinitionGameViewmodel(ref));

final wordsCountProvider = StreamProvider(
  (ref) => ref.read(wordRepositoryProvider).getWordCountStream(),
);

class GuessTheDefinitionGameViewmodel extends ChangeNotifier {
  Timer? answerCountdownTimer;
  final int waitingTime;
  final Ref _ref;
  GuessTheDefinitionGameViewmodel(this._ref, {this.waitingTime = 15});

  Future refreshQuiz({int correctDefinitionPosition = 0}) async {
    final completeWords =
        await _ref.read(wordRepositoryProvider).retrieveCompleteWords();
    completeWords.shuffle();
    _ref.read(completeWordsListProvider.state).state = completeWords;
    _ref.read(correctCompleteWordProvider.state).state =
        completeWords[correctDefinitionPosition];
    _ref.read(gameStateProvider.state).state = GameState.onGoing;
    _ref.read(remainingTimePercentageProvider.state).state = 100.0;
    if (answerCountdownTimer != null) {
      answerCountdownTimer!.cancel();
    }
    answerCountdownTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _ref.read(remainingTimePercentageProvider.state).state =
          (((waitingTime * 1000) - timer.tick * 100) / (waitingTime * 1000));
      if (timer.tick * 100 == waitingTime * 1000) {
        _ref.read(gameStateProvider.state).state = GameState.timeOut;
        timer.cancel();
      }
    });
    answerCountdownTimer;
  }

  Future verifyDefinitionSelection(int definitionId) async {
    final correctCompleteWord = _ref.read(correctCompleteWordProvider);
    if (correctCompleteWord != null &&
        correctCompleteWord.definition.id == definitionId) {
      _ref.read(gameStateProvider.state).state = GameState.gotCorrectAnswer;
    } else {
      _ref.read(gameStateProvider.state).state = GameState.gotIncorrectAnswer;
    }
    answerCountdownTimer!.cancel();
  }
}

enum GameState { iddle, onGoing, gotCorrectAnswer, timeOut, gotIncorrectAnswer }
