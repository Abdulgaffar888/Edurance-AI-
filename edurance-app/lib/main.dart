import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/diagnostic_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/progress_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const Color brandColor = Color(0xFF3D9974); // #3d9974

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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: AuthScreen(),
      routes: {
        '/auth': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(),
        '/diagnostic': (context) => DiagnosticScreen(),
        '/learn': (context) => LearnScreen(),
        '/progress': (context) => ProgressScreen(),
      },
    );
  }
}
