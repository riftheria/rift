import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rift/viewmodel/word_viewmodel.dart';

class AddNewWordsPage extends ConsumerWidget {
  const AddNewWordsPage({super.key});

  void _addWordsFromFile(WidgetRef ref) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    String? pickedFilePath = result?.files.first.path;
    if (pickedFilePath != null) {
      File pickedFile = File(pickedFilePath);
      ref.read(wordViewModelProvider).addToKnownWordsFromFile(pickedFile);
    }
  }

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
        actions: [
          IconButton(
              onPressed: () async {
                final firstImportTextFile = await ref
                    .read(wordViewModelProvider)
                    .isFirstImportTextFile();
                if (firstImportTextFile) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Add new words from files'),
                      content: SingleChildScrollView(
                        child: Column(children: [
                          SvgPicture.asset(
                            'assets/images/img_add_words_from_document.svg',
                            height: 125,
                            width: 125,
                          ),
                          const Text(
                              'Add your new words from any subtitle or lyric file')
                        ]),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _addWordsFromFile(ref);
                            Navigator.pop(context);
                          },
                          child: const Text('Ok'),
                        )
                      ],
                    ),
                  );
                } else {
                  _addWordsFromFile(ref);
                }
              },
              icon: const Icon(Icons.file_open_rounded))
        ],
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
