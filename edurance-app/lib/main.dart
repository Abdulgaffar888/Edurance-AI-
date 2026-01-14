import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// SCREENS - Importing all files found in your folder structure
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/diagnostic_screen.dart';
import 'screens/learn_screen.dart';  
import 'screens/solve_screen.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase configuration for Web
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDHhkDFV-PbDI98WvGYmv35bJAJTRZatlk",
      authDomain: "edurance023.firebaseapp.com",
      projectId: "edurance023",
      storageBucket: "edurance023.firebasestorage.app",
      messagingSenderId: "504266407774",
      appId: "1:504266407774:web:e87c07895b9c7fb67fd9cf",
      measurementId: "G-5SY4J41YWW",
    ),
  );
  
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // This is the line that was causing the error - AuthWrapper is defined below
      home: const AuthWrapper(), 
      routes: {
        '/auth': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/diagnostic': (context) => DiagnosticScreen(),
        '/learn': (context) => LearnScreen(),
        '/solve': (context) => SolveScreen(),
      },
    );
  }
}

// THIS IS THE PART THAT WAS MISSING
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If Firebase is still checking the login status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            ),
          );
        }
        
        // If the user is already logged in, send them to Home (where they select topics)
        if (snapshot.hasData) {
          return HomeScreen();
        }
        
        // If the user is NOT logged in, show the Auth/Login Screen
        return AuthScreen();
      },
    );
  }
}