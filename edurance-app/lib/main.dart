import 'package:flutter/material.dart';
import 'screens/class_selection_screen.dart';
import 'theme/app_theme.dart';

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
      theme: AppTheme.darkTheme,
      home: const ClassSelectionScreen(),
    );
  }
}