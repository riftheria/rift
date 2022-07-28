import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rift/view/add_new_words.dart';

void main() {
  runApp(const ProviderScope(child: RiftApp()));
}

class RiftApp extends StatefulWidget {
  const RiftApp({super.key});

  @override
  State<RiftApp> createState() => _RiftAppState();
}

class _RiftAppState extends State<RiftApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const AddNewWordsPage(),
    );
  }
}
