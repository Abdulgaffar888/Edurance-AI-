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
    'Progressions - Chapter 6 (Arithmetic Progression, Geometric Progression, nth term, Sum of n terms)',
    'Coordinate Geometry - Chapter 7 (Distance Formula, Section Formula, Area of Triangle)',
    'Similar Triangles - Chapter 8 (AAA, SSS, SAS Criteria, Basic Proportionality Theorem)',
    'Tangents and Secants to a Circle - Chapter 9 (Tangent Properties, Number of Tangents, Secant-Tangent Theorem)',
    'Mensuration - Chapter 10 (Surface Area & Volume: Cube, Cuboid, Cylinder, Cone, Sphere)',
    'Trigonometry - Chapter 11 (Trigonometric Ratios, Trigonometric Identities, Complementary Angles)',
    'Applications of Trigonometry - Chapter 12 (Heights and Distances, Angle of Elevation, Angle of Depression)',
    'Probability - Chapter 13 (Theoretical Probability, Experimental Probability, Cards, Dice)',
    'Statistics - Chapter 14 (Mean, Median, Mode of Grouped Data, Cumulative Frequency, Ogives)',
  ],
  'Chemistry (Class 10 NCERT)': [
    'Chemical Reactions and Equations - Chapter 1 (Balancing, Types, Corrosion, Rancidity)',
    'Acids, Bases and Salts - Chapter 2 (pH Scale, Indicators, Neutralization, Salts, Washing Soda)',
    'Metals and Non-Metals - Chapter 3 (Properties, Reactivity Series, Extraction, Corrosion)',
    'Carbon and its Compounds - Chapter 4 (Covalent Bonding, Hydrocarbons, Functional Groups, Soaps)',
    'Periodic Classification of Elements - Chapter 5 (Mendeleev, Modern Periodic Table, Trends, Valency)',
  ],
  'Biology (Class 10 NCERT)': [
    'Life Processes: Nutrition - Chapter 6 (Autotrophic, Heterotrophic, Photosynthesis, Human Digestive System)',
    'Life Processes: Respiration - Chapter 6 (Aerobic, Anaerobic, Human Respiratory System)',
    'Life Processes: Transportation - Chapter 6 (Human Circulatory System, Blood, Heart, Lymph)',
    'Life Processes: Excretion - Chapter 6 (Human Excretory System, Kidneys, Nephron, Dialysis)',
    'Control and Coordination - Chapter 7 (Nervous System, Reflex Actions, Hormones in Animals and Plants)',
    'How do Organisms Reproduce? - Chapter 8 (Asexual Reproduction, Sexual Reproduction, Human Reproductive System)',
    'Heredity and Evolution - Chapter 9 (Mendel\'s Experiments, Sex Determination, Evolution, Fossils)',
    'Our Environment - Chapter 15 (Ecosystem, Food Chains, Ozone Layer, Waste Management)',
    'Sustainable Management of Natural Resources - Chapter 16 (Conservation, Water Harvesting, Forests, Wildlife)',
  ],
  'Physics (Class 10 NCERT)': [
    'Electricity - Chapter 12 (Ohm\'s Law, Series & Parallel Circuits, Heating Effect, Power)',
    'Magnetic Effects of Electric Current - Chapter 13 (Magnetic Field, Electromagnet, Electric Motor, Generator)',
    'Light - Reflection and Refraction - Chapter 10 (Mirrors, Lenses, Refractive Index, Human Eye)',
    'The Human Eye and the Colourful World - Chapter 11 (Defects of Vision, Dispersion, Scattering, Atmospheric Refraction)',
    'Sources of Energy - Chapter 14 (Renewable & Non-renewable, Solar, Wind, Biomass, Nuclear)',
  ],
};

   @override
  Widget build(BuildContext context) {
    final list = topics[subject];

    return Scaffold(
      appBar: AppBar(title: Text(subject)),
      body: list == null
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