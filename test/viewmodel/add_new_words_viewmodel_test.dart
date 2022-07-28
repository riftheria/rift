import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rift/data/repository/word_repository.dart';
import 'package:rift/data/rift_database.dart';
import 'package:rift/viewmodel/word_viewmodel.dart';

void main() {
  test('User enters a new word and it is notified', () async {
    const wordValue = 'Word';
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.find(any()))
        .thenAnswer((_) => Future(() => getWord(wordValue)));
    when(() => mockWordRepository.addToKnownWords(wordValue))
        .thenAnswer((_) => Future.value());
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    addTearDown(container.dispose);
    await container.read(wordViewModelProvider).addToKnownWords(wordValue);
    expect(container.read(addedWordsMessageProvider), '1 new word added');
  });

  test('User enters a new word but notify the user that it is already added',
      () async {
    const wordValue = 'Word';
    final mockWordRepository = MockWordRepository();

    when(() => mockWordRepository.addToKnownWords(wordValue))
        .thenThrow(WordAlreadyAddedException(message: ''));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    addTearDown(container.dispose);
    await container.read(wordViewModelProvider).addToKnownWords(wordValue);
    expect(container.read(addedWordsMessageProvider),
        'You have already added this word');
  });

  test('User enters an invalid word and receives a notification', () async {
    const wordValue = 'Word';
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.addToKnownWords(wordValue))
        .thenThrow(InvalidWordException(message: ''));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    addTearDown(container.dispose);
    await container.read(wordViewModelProvider).addToKnownWords(wordValue);
    expect(container.read(addedWordsMessageProvider),
        'The word you\'re trying to add is invalid');
  });
}

int timesGetWordHaveBeenCalled = 0;

Word? getWord(String wordValue) {
  return timesGetWordHaveBeenCalled++ == 0
      ? null
      : Word(id: 0, word: wordValue);
}

class MockTextEditingController extends Mock implements TextEditingController {}

class MockWordRepository extends Mock implements WordRepository {}
