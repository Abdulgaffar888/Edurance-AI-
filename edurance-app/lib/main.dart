import 'package:flutter/material.dart';
import 'screens/subject_selection_screen.dart';

void main() {
  runApp(const EduranceApp());
}

class EduranceApp extends StatelessWidget {
  const EduranceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edurance AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const SubjectSelectionScreen(),
    );
  }
}
