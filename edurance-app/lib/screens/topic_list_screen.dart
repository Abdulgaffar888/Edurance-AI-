import 'package:flutter/material.dart';
import 'ai_chat_screen.dart';

class TopicListScreen extends StatelessWidget {
  final String subject;
  const TopicListScreen({super.key, required this.subject});

  static const topics = {
    'Mathematics': [
    'Real Numbers (Prime Factorization, HCF, LCM, Irrational Numbers)',
    'Sets (Venn Diagrams, Union, Intersection, Complement)',
    'Polynomials (Zeroes, Division Algorithm, Relationship)',
    'Pair of Linear Equations in Two Variables (Graphical & Algebraic Methods)',
    'Quadratic Equations (Factorization & Quadratic Formula)',
    'Progressions (Arithmetic & Geometric Progressions)',
    'Coordinate Geometry (Distance Formula, Section Formula)',
    'Similar Triangles (Criteria & Applications)',
    'Tangents and Secants to a Circle (Theorems & Properties)',
    'Mensuration (Surface Area & Volume of Solids)',
    'Trigonometry (Trigonometric Ratios & Identities)',
    'Applications of Trigonometry (Heights & Distances)',
    'Probability (Theoretical & Experimental Probability)',
    'Statistics (Mean, Median, Mode of Grouped Data)',
  ],
  'Chemistry': [
    'Chemical Equations (Balancing, Types, Stoichiometry)',
    'Acids, Bases and Salts (Properties, pH Scale, Indicators)',
    'Structure of Atom (Electron Configuration, Quantum Numbers)',
    'Classification of Elements (Periodic Table, Trends)',
    'Chemical Bonding (Ionic, Covalent, Metallic Bonds)',
    'Principles of Metallurgy (Extraction, Refining, Alloys)',
    'Carbon and its Compounds (Hydrocarbons, Functional Groups)',
  ],
  'Biology': [
    'Nutrition (Autotrophic & Heterotrophic Nutrition)',
    'Respiration (Aerobic & Anaerobic Respiration)',
    'Transportation in Animals and Plants (Circulatory System)',
    'Excretion (Kidneys, Nephron, Plant Excretion)',
    'Coordination (Nervous System & Hormones)',
    'Reproduction (Sexual & Asexual Reproduction)',
    'Heredity and Evolution (Mendelian Genetics)',
    'Our Environment (Ecosystem, Food Chains)',
    'Natural Resources (Conservation, Management)',
  ],
  'Physics': [
    'Electricity (Ohm\'s Law, Circuits, Heating Effect)',
    'Motion (Distance, Displacement, Velocity, Acceleration)',
    'Force and Laws of Motion (Newton\'s Laws, Momentum)',
    'Work and Energy (Conservation, Power, Simple Machines)',
    'Light (Reflection, Refraction, Lenses, Human Eye)',
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
