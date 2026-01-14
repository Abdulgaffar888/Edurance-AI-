import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edurance AI Explorer', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/auth');
              }
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Fixed: Changed 'getGradient' to the standard 'gradient' parameter
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Module Icon with a "Glow" effect
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.bolt, size: 80, color: Colors.amber),
            ),
            
            const SizedBox(height: 30),
            
            const Text(
              "Physics: Grade 6",
              style: TextStyle(
                color: Colors.indigo, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.2
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              "Electricity & Circuits",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 15),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                "Your AI Tutor is ready to explain how currents flow and the secrets of the electric circuit using NCERT notes.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // MAIN ENTRY BUTTON
            SizedBox(
              width: 250,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    '/learn', 
                    arguments: 'Electricity and Circuits'
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology),
                    SizedBox(width: 10),
                    Text("Start AI Tutoring", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Diagnostic Test Button
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/diagnostic'),
              icon: const Icon(Icons.assignment_outlined, color: Colors.indigo),
              label: const Text("Take Pre-Assessment", 
                style: TextStyle(color: Colors.indigo)),
            ),
            
            /* // PREVIOUS USERFLOW (Commented Out)
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/learn'),
              child: const Text('Start Learning'),
            ),
            */
          ],
        ),
      ),
    );
  }
}
