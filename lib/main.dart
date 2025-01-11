import 'package:flutter/material.dart';
import 'package:flutter_isolate/isolate_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Isolation App',
      home: IsolateScreen(),
    );
  }
}