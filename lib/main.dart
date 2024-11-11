import 'package:flutter/material.dart';
import 'package:flaviapp/screens/home_screen.dart';

void main() {
  runApp(const FlaviApp());
}

class FlaviApp extends StatelessWidget {
  const FlaviApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Migraña',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}