import 'package:flutter/material.dart';
import 'learn_screen.dart';
import 'solve_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
      appBar: AppBar(
        title: const Text('Edurance AI'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
                _HomeCardWrapper(
                  child: _HomeCard(
                    icon: Icons.school,
                    title: 'Learn',
                    description: 'AI-powered lessons tailored to your grade',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LearnScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _HomeCardWrapper(
                  child: _HomeCard(
                    icon: Icons.camera_alt,
                    title: 'Solve',
                    description: 'Solve problems with AI assistance',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SolveScreen()),
                      );
                    },
                  ),
                ),
],
),
),
        ),
      ),
);
}
}

/// Wrapper that GUARANTEES equal card height on all screens
class _HomeCardWrapper extends StatelessWidget {
  final Widget child;

  const _HomeCardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 210, // Fixed height = equal cards (increased to prevent overflow)
      child: child,
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 56,
                color: Colors.indigo[700],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
