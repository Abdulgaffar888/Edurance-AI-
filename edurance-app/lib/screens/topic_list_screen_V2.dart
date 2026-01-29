import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ai_chat_screen_V2.dart';

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
      appBar: AppBar(
        title: Text(subject),
        backgroundColor: AppTheme.surfaceColor,
      ),
      backgroundColor: AppTheme.darkBackground,
      body: list == null || list.isEmpty
          ? Center(
              child: Text(
                'No topics found for this subject',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.secondaryText,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  return _TopicCard(
                    topicText: list[i],
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
            ),
    );
  }
}

class _TopicCard extends StatefulWidget {
  final String topicText;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topicText,
    required this.onTap,
  });

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    _animationController.forward().then((_) {
                      _animationController.reverse();
                      widget.onTap();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.auroraGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.topicText,
                            style: const TextStyle(
                              color: AppTheme.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppTheme.secondaryText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
