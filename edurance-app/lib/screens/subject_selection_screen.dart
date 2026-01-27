import 'package:flutter/material.dart';
import 'topic_list_screen.dart';

class SubjectSelectionScreen extends StatelessWidget {
  const SubjectSelectionScreen({super.key});

  static const subjects = [
    {'name': 'Mathematics', 'color': Colors.blue},
    {'name': 'Physics', 'color': Colors.deepPurple},
    {'name': 'Chemistry', 'color': Colors.green},
    {'name': 'Biology', 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Subject')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: subjects.map((s) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TopicListScreen(subject: s['name'] as String),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: s['color'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    s['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
