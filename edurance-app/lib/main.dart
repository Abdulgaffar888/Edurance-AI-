import 'package:flutter/material.dart';
import 'screens/subject_selection_screen.dart';

void main() {
  runApp(const EduranceApp());
}

class EduranceApp extends StatelessWidget {
  const EduranceApp({super.key});

  static const Color brandColor = Color(0xFF3D9974);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edurance AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: brandColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: brandColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SubjectSelectionScreen(),
    );
  }
}
