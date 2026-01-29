import 'package:flutter/material.dart';
import 'ai_chat_screen.dart';

class TopicListScreen extends StatelessWidget {
  final String subject;
  const TopicListScreen({super.key, required this.subject});

  static const Map<String, List<String>> topics = {
    'Mathematics (Class 10 NCERT)': [
      'Real Numbers - Chapter 1 (Euclid\'s Division Lemma, HCF, LCM, Irrational Numbers)',
      'Sets - Chapter 2 (Venn Diagrams, Union, Intersection, Complement, De Morgan\'s Laws)',
      'Polynomials - Chapter 3 (Zeroes, Division Algorithm, Relationship between Zeroes and Coefficients)',
      'Pair of Linear Equations in Two Variables - Chapter 4 (Graphical Method, Substitution, Elimination, Cross-Multiplication)',
      'Quadratic Equations - Chapter 5 (Factorization Method, Quadratic Formula, Nature of Roots)',
      'Progressions - Chapter 6 (Arithmetic Progression, nth term, Sum of n terms)',
      'Coordinate Geometry - Chapter 7 (Distance Formula, Section Formula)',
      'Similar Triangles - Chapter 8 (AAA, SSS, SAS Criteria)',
      'Trigonometry - Chapter 11 (Ratios, Identities)',
      'Probability - Chapter 13 (Theoretical Probability)',
      'Statistics - Chapter 14 (Mean, Median, Mode)',
    ],
    'Physics (Class 10 NCERT)': [
      'Electricity - Chapter 12 (Ohm\'s Law, Circuits, Power)',
      'Magnetic Effects of Electric Current - Chapter 13 (Motor, Generator)',
      'Light - Reflection and Refraction - Chapter 10',
      'The Human Eye and the Colourful World - Chapter 11',
      'Sources of Energy - Chapter 14',
    ],
    'Chemistry (Class 10 NCERT)': [
      'Chemical Reactions and Equations - Chapter 1',
      'Acids, Bases and Salts - Chapter 2 (pH Scale, Indicators)',
      'Metals and Non-Metals - Chapter 3',
      'Carbon and its Compounds - Chapter 4',
      'Periodic Classification of Elements - Chapter 5',
    ],
    'Biology (Class 10 NCERT)': [
      'Life Processes: Nutrition - Chapter 6',
      'Life Processes: Respiration - Chapter 6',
      'Life Processes: Transportation - Chapter 6',
      'Life Processes: Excretion - Chapter 6',
      'Control and Coordination - Chapter 7',
      'How do Organisms Reproduce? - Chapter 8',
      'Heredity and Evolution - Chapter 9',
      'Our Environment - Chapter 15',
    ],
  };

  /// 🔑 SUBJECT NORMALIZATION (THIS FIXES EVERYTHING)
  String _normalizedSubjectKey(String subject) {
    return '$subject (Class 10 NCERT)';
  }

  @override
  Widget build(BuildContext context) {
    final key = _normalizedSubjectKey(subject);
    final list = topics[key];

    return Scaffold(
      appBar: AppBar(title: Text(subject)),
      body: list == null || list.isEmpty
          ? const Center(
              child: Text(
                'No topics found for this subject',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
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
