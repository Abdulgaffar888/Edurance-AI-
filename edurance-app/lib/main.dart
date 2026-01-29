import 'package:flutter/material.dart';
import 'screens/subject_selection_screen_V2.dart';
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
      home: SubjectSelectionScreen(),
    );
  }
}
