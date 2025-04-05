import 'package:flutter/material.dart';
import 'package:quiz_app/screens/home_Screen.dart';

const String baseApiUrl = 'http://localhost:8080/api';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mock Test App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
