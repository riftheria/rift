import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rift/data/repository/word_repository.dart';
import 'package:rift/data/rift_database.dart';
import 'package:rift/viewmodel/word_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  registerFallbackValue(MockFile());
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  test('User enters a new word and it is notified', () async {
    const wordValue = 'Word';
    final mockWordRepository = MockWordRepository();
    when(() => mockWordRepository.find(any()))
        .thenAnswer((_) => Future(() => getWord(wordValue)));
    when(() => mockWordRepository.importWordsFromText(wordValue))
        .thenAnswer((_) => Future(() => ImportedWords(
              addedWords: ['Word'],
              invalidWords: [],
              alreadyAddedWords: [],
            )));
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    addTearDown(container.dispose);
    await container.read(wordViewModelProvider).addToKnownWords(wordValue);
    expect(container.read(addedWordsMessageProvider), '1 word added');
  });

  test('User enters a new word but notify the user that it is already added',
      () async {
    const wordValue = 'Word';
    final mockWordRepository = MockWordRepository();

    when(() => mockWordRepository.importWordsFromText(wordValue))
        .thenAnswer((_) => Future(() => ImportedWords(
              addedWords: [],
              invalidWords: [],
              alreadyAddedWords: ['Added'],
            )));
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
    when(() => mockWordRepository.importWordsFromText(wordValue)).thenAnswer(
      (_) => Future(
        () => ImportedWords(
          addedWords: [],
          invalidWords: ['Invalid'],
          alreadyAddedWords: [],
        ),
      ),
    );
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    addTearDown(container.dispose);
    await container.read(wordViewModelProvider).addToKnownWords(wordValue);
    expect(container.read(addedWordsMessageProvider),
        'The word you\'re trying to add is invalid');
  });

  test('Add words by file and show valid and invalid words count', () async {
    final mockWordRepository = MockWordRepository();
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);

    when(() => mockWordRepository.importWordsFromFile(any()))
        .thenAnswer((invocation) => Future(() => ImportedWords(
              addedWords: ['First', 'Second', 'Line'],
              invalidWords: ['iftgfs'],
              alreadyAddedWords: [],
            )));
    await container
        .read(wordViewModelProvider)
        .addToKnownWordsFromFile(MockFile());
    expect(container.read(addedWordsMessageProvider),
        '3 words added, 1 invalid word not added');
  });

  test('User enters a text and gets the valid and invalid words count',
      () async {
    final mockWordRepository = MockWordRepository();
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    when(() => mockWordRepository.importWordsFromText(any())).thenAnswer(
      (invocation) => Future(
        () => ImportedWords(
          addedWords: ['Some', 'Nice', 'Text'],
          invalidWords: ['Keb'],
          alreadyAddedWords: [],
        ),
      ),
    );
    await container
        .read(wordViewModelProvider)
        .addToKnownWords('Some nice text Keb');
    expect(container.read(addedWordsMessageProvider),
        '3 words added, 1 invalid word not added');
  });

  test('User enters a text and gets the invalid and already words count',
      () async {
    final mockWordRepository = MockWordRepository();
    final container = ProviderContainer(overrides: [
      wordRepositoryProvider.overrideWithValue(mockWordRepository)
    ]);
    when(() => mockWordRepository.importWordsFromText(any())).thenAnswer(
      (invocation) => Future(
        () => ImportedWords(
          addedWords: [],
          invalidWords: ['Keb'],
          alreadyAddedWords: ['Some', 'Nice', 'Text'],
        ),
      ),
    );
    await container
        .read(wordViewModelProvider)
        .addToKnownWords('Some nice text Keb');
    expect(container.read(addedWordsMessageProvider),
        '1 invalid word not added, 3 words already added');
  });

  test('Import words from text file doesn\'t show a dialog the second time',
      () async {
    final container = ProviderContainer();
    bool isFirstImportTextFile =
        await container.read(wordViewModelProvider).isFirstImportTextFile();
    expect(isFirstImportTextFile, isTrue);
    isFirstImportTextFile =
        await container.read(wordViewModelProvider).isFirstImportTextFile();
    expect(isFirstImportTextFile, isFalse);
  });
}

int timesGetWordHaveBeenCalled = 0;

Word? getWord(String wordValue) {
  return timesGetWordHaveBeenCalled++ == 0 ? null : Word(word: wordValue);
}

class MockTextEditingController extends Mock implements TextEditingController {}

class MockWordRepository extends Mock implements WordRepository {}

class MockFile extends Mock implements File {}
