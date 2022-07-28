import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rift/viewmodel/word_viewmodel.dart';

class AddNewWordsPage extends ConsumerWidget {
  const AddNewWordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(addedWordsMessageProvider, (previous, next) {
      if (next != null) {
        final snackbarMessage = SnackBar(
          content: Text(next),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbarMessage);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rift'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          TextField(
            controller: ref.read(newWordControllerProvider),
            decoration: const InputDecoration(hintText: 'Enter a new word'),
            minLines: 10,
            maxLines: 10,
          ),
          ElevatedButton(
            onPressed: () {
              final newWord = ref.read(newWordControllerProvider).text;
              ref.read(wordViewModelProvider).addToKnownWords(newWord);
            },
            child: const Text('Add to new words'),
          ),
        ]),
      ),
    );
  }
}
