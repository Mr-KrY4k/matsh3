import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const Match3ExampleApp());
}

class Match3ExampleApp extends StatelessWidget {
  const Match3ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Match 3 Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}
