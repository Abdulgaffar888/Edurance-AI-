import 'package:flutter/material.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edurance AI ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3D9974),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              // await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/auth');
              }
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3D9974), Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                color: Color(0xFF3D9974),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
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
                "Your AI Tutor is ready to explain how currents flow and the secrets of the electric circuit.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: 250,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D9974)
,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/learn',
                    arguments: 'Electricity and Circuits',
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

            Container(
              width: 250,
              height: 55,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: const Color(0xFF3D9974)
, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/diagnostic'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, color: const Color(0xFF3D9974)
),
                    SizedBox(width: 10),
                    Text("Assessment Test",
                        style:
                            TextStyle(color: const Color(0xFF3D9974)
, fontSize: 18)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: 250,
              height: 55,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/progress'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics_outlined, color: Colors.green),
                    SizedBox(width: 10),
                    Text("Progress Dashboard",
                        style:
                            TextStyle(color: Colors.green, fontSize: 18)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Take assessment first for personalized learning",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
