import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rift/data/dataclasses/complete_word.dart';
import 'package:rift/data/models/definition.dart';
import 'package:rift/data/models/meaning.dart';
import 'package:rift/data/models/word.dart';
import 'package:rift/viewmodel/guess_the_definition_game_viewmodel.dart';
import 'package:rift/viewmodel/word_viewmodel.dart';

import 'add_new_words_viewmodel_test.dart';

void main() {
  final retrievedWords = [
    CompleteWord(
      word: Word(word: 'word'),
      meaning: Meaning(id: 0, wordId: 'word', partOfSpeech: 'verb'),
      definition: Definition(id: 0, meaningId: 0),
    ),
    CompleteWord(
      word: Word(word: 'kind'),
      meaning: Meaning(id: 1, wordId: 'kind', partOfSpeech: 'verb'),
      definition: Definition(id: 1, meaningId: 1),
    ),
    CompleteWord(
      word: Word(word: 'another'),
      meaning: Meaning(id: 2, wordId: 'another', partOfSpeech: 'verb'),
      definition: Definition(id: 1, meaningId: 2),
    ),
  ];
  test('Retrieve three complete words', () async {
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.retrieveCompleteWords())
        .thenAnswer((_) => Future(() => Future(() => retrievedWords)));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    await container.read(guessTheDefinitionViewmodelProvider).refreshQuiz();
    verify(() => mockWordRepository.retrieveCompleteWords()).called(1);
  });

  test('Correct word is the first from the list', () async {
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.retrieveCompleteWords())
        .thenAnswer((_) => Future(() => Future(
              () => retrievedWords,
            )));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    await container.read(guessTheDefinitionViewmodelProvider).refreshQuiz();
    final correctWord = container.read(correctCompleteWordProvider);
    expect(correctWord, retrievedWords[0]);
  });

  test('Verify if the current game is in progress', () async {
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.retrieveCompleteWords())
        .thenAnswer((_) => Future(() => Future(
              () => retrievedWords,
            )));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    expect(container.read(gameStateProvider), GameState.iddle);
    await container.read(guessTheDefinitionViewmodelProvider).refreshQuiz();
    expect(container.read(gameStateProvider), GameState.onGoing);
  });

  test('Verify if the current game got a correct answer', () async {
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.retrieveCompleteWords())
        .thenAnswer((_) => Future(() => Future(
              () => retrievedWords,
            )));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    await container.read(guessTheDefinitionViewmodelProvider).refreshQuiz();
    await container
        .read(guessTheDefinitionViewmodelProvider)
        .verifyDefinitionSelection(0);
    expect(container.read(gameStateProvider), GameState.gotCorrectAnswer);
  });

  test('Verify if the current game time out', () async {
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.retrieveCompleteWords())
        .thenAnswer((_) => Future(() => Future(
              () => retrievedWords,
            )));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository),
    ]);
    container.read(guessTheDefinitionViewmodelProvider).refreshQuiz();
    await Future.delayed(const Duration(seconds: 15, milliseconds: 100));
    expect(container.read(gameStateProvider), GameState.timeOut);
  });

  test('Verify if the current game got an incorrect answer', () async {
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.retrieveCompleteWords())
        .thenAnswer((_) => Future(() => Future(
              () => retrievedWords,
            )));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    await container.read(guessTheDefinitionViewmodelProvider).refreshQuiz();
    await container
        .read(guessTheDefinitionViewmodelProvider)
        .verifyDefinitionSelection(26);
    expect(container.read(gameStateProvider), GameState.gotIncorrectAnswer);
  });

  test('Verify remaing time after the refresh is 100.0', () async {
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.retrieveCompleteWords())
        .thenAnswer((_) => Future(() => Future(
              () => retrievedWords,
            )));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    await container.read(guessTheDefinitionViewmodelProvider).refreshQuiz();
    expect(container.read(remainingTimePercentageProvider), 100.0);
  });

  test('Test time remains for answer in percentage', () async {
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.retrieveCompleteWords())
        .thenAnswer((_) => Future(() => Future(
              () => retrievedWords,
            )));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    await container.read(guessTheDefinitionViewmodelProvider).refreshQuiz();
    await Future.delayed(const Duration(milliseconds: 400));
    expect(container.read(remainingTimePercentageProvider), lessThan(100.0));
  });

  test('Test answer cancels the timer', () async {
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.retrieveCompleteWords())
        .thenAnswer((_) => Future(() => Future(
              () => retrievedWords,
            )));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    await container.read(guessTheDefinitionViewmodelProvider).refreshQuiz();
    await Future.delayed(const Duration(milliseconds: 400));
    await container
        .read(guessTheDefinitionViewmodelProvider)
        .verifyDefinitionSelection(46);
    final firstPercentage = container.read(remainingTimePercentageProvider);
    await Future.delayed(const Duration(milliseconds: 400));
    final secondPercentage = container.read(remainingTimePercentageProvider);
    expect(firstPercentage, secondPercentage);
  });
}
