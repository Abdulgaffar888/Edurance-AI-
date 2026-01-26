import 'package:flutter/material.dart';
import 'ai_chat_screen.dart';

class TopicListScreen extends StatelessWidget {
  final String subject;
  const TopicListScreen({super.key, required this.subject});

  static const topics = {
    'Mathematics': [
      'Real Numbers',
      'Sets',
      'Polynomials',
      'Pair of Linear Equations in Two Variables',
      'Quadratic Equations',
      'Progressions',
      'Coordinate Geometry',
      'Similar Triangles',
      'Tangents and Secants to a Circle',
      'Mensuration',
      'Trigonometry',
      'Applications of Trigonometry',
      'Probability',
      'Statistics',
    ],
    'Chemistry': [
      'Chemical Equations',
      'Acids, Bases and Salts',
      'Structure of Atom',
      'Classification of Elements',
      'Chemical Bonding',
      'Principles of Metallurgy',
      'Carbon and its Compounds',
    ],
    'Biology': [
      'Nutrition',
      'Respiration',
      'Transportation',
      'Excretion',
      'Coordination',
      'Reproduction',
      'Heredity and Evolution',
      'Our Environment',
      'Natural Resources',
    ],
    'Physics': [
      'Electricity',
      'Motion',
      'Force and Laws of Motion',
      'Work and Energy',
      'Light',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final list = topics[subject] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(subject)),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) {
          return ListTile(
            title: Text(list[i]),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AIChatScreen(
                    subject: subject,
                    topic: list[i],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
