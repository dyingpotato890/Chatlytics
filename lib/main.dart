import 'package:chatlytics/pages/analysis_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatlytics',
      theme: ThemeData(
      ),
      home: const AnalysisPage(),
    );
  }
}
