import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ai_chat_screen_V2.dart';

class TopicListScreen extends StatelessWidget {
  final String subject;
  const TopicListScreen({super.key, required this.subject});

  /// 🛡️ Use clean, lowercase keys for the data
  static const Map<String, List<String>> topics = {
    'social studies': [
      'India: Relief Features - Chapter 1 (Himalayas, Indo-Gangetic plains, Peninsular plateau)',
      'Ideas on Development - Chapter 2 (HDI, Income vs Goals, Public facilities)',
      'Production and Employment - Chapter 3 (Sectors of economy, GDP, Organized/Unorganized)',
      'Climate of India - Chapter 4 (Monsoons, Climatic controls, Global warming)',
      'Indian Rivers and Water Resources - Chapter 5 (Himalayan/Peninsular rivers, Water usage)',
      'The People - Chapter 6 (Census, Population change, Literacy rates)',
      'Settlement and Migration - Chapter 7 (Urbanization, Internal/International migration)',
      'Rampur: A Village Economy - Chapter 8 (Land distribution, Non-farm activities)',
      'Globalization - Chapter 9 (MNCs, Trade barriers, WTO impact)',
      'Food Security - Chapter 10 (PDS, Nutrition status, Buffer stock)',
      'Sustainable Development with Equity - Chapter 11 (Environment vs Growth, Silent Valley)',
      'The World Between Wars - Chapter 12 (World War I & II, Great Depression, USSR)',
      'National Liberation Movements in Colonies - Chapter 13 (China, Vietnam, Nigeria)',
      'National Movement in India - Chapter 14 (Quit India, Partition, Role of Gandhi)',
      'The Making of Independent India’s Constitution - Chapter 15 (Drafting committee, Preamble)',
      'The Election Process in India - Chapter 16 (Election commission, Political parties, Voter code)',
      'Independent India (First 30 Years) - Chapter 17 (Reorganization of states, Social reforms)',
      'Emerging Political Trends (1977-2000) - Chapter 18 (Regional parties, Coalition politics)',
      'Post-War World and India - Chapter 19 (Cold war, Non-Aligned Movement, UN)',
      'Social Movements in Our Times - Chapter 20 (Civil rights, Environmental/Women\'s movements)',
      'The Movement for the Formation of Telangana State - Chapter 21 (1969 agitation, TRS, 2014 Act)',
    ],
    'physics': [
      'Reflection of Light at Curved Surfaces - Chapter 1 (Spherical mirrors, Ray diagrams, Magnification)',
      'Refraction of Light at Plane Surfaces - Chapter 2 (Refractive index, Snell\'s law, Total Internal Reflection)',
      'Refraction of Light at Curved Surfaces - Chapter 3 (Lenses, Lens maker\'s formula)',
      'The Human Eye and the Colourful World - Chapter 4 (Eye defects, Dispersion, Scattering of light)',
      'Electric Current - Chapter 5 (Ohm\'s Law, Kirchhoff\'s Laws, Resistance in Series/Parallel)',
      'Electromagnetism - Chapter 6 (Magnetic field, Induction, Motor, Generator)',
    ],
    'chemistry': [
      'Chemical Equations - Chapter 1 (Types of reactions, Balancing, Effects of oxidation)',
      'Acids, Bases and Salts - Chapter 1 (pH Scale, Indicators, Salts from common salt)',
      'Structure of Atom - Chapter 3 (Spectrum, Quantum numbers, Electronic configuration)',
      'Classification of Elements - The Periodic Table - Chapter 4 (Periodic properties, Groups/Periods)',
      'Chemical Bonding - Chapter 5 (Ionic and Covalent bonding, VSEPR theory)',
      'Principles of Metallurgy - Chapter 6 (Extraction of metals, Corrosion, Purification)',
      'Carbon and its Compounds - Chapter 7 (Hybridization, Allotropes, IUPAC nomenclature)',
    ],
    'biology': [
      'Nutrition - Chapter 1 (Photosynthesis, Digestive system, Malnutrition)',
      'Respiration - Chapter 2 (Aerobic/Anaerobic, Human respiratory system, Combustion)',
      'Transportation - Chapter 3 (Heart structure, Blood vessels, Lymphatic system)',
      'Excretion - Chapter 4 (Nephron, Kidney transplantation, Excretion in plants)',
      'Control and Coordination - Chapter 5 (Nervous system, Brain, Plant hormones)',
      'Reproduction - Chapter 6 (Asexual/Sexual, Flower structure, Human birth control)',
      'Coordination in Life Processes - Chapter 7 (Hunger signals, Peristalsis, Villus)',
      'Heredity - Chapter 8 (Mendel\'s laws, Sex determination, Evolution)',
      'Our Environment - Chapter 9 (Food chains, Ecological pyramids, Bio-accumulation)',
      'Natural Resources - Chapter 10 (Conservation, Soil/Water management, Sustainability)',
    ],
  };

  /// 🔑 This logic now cleans ANY variation of the subject name
  List<String>? _getNormalizedTopics(String input) {
    // 1. Convert to lowercase: "Physics (Class 10 TS-SSC)" -> "physics (class 10 ts-ssc)"
    String key = input.toLowerCase().trim();
    
    // 2. Remove all common suffixes using a regex or simple replaces
    key = key.replaceAll(' (class 10 ts-ssc)', '');
    key = key.replaceAll(' (class 10 ncert)', '');
    
    // 3. Match against the clean keys in our Map
    return topics[key];
  }

  @override
  Widget build(BuildContext context) {
    final list = _getNormalizedTopics(subject);

    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      backgroundColor: AppTheme.darkBackground,
      body: list == null || list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 48, color: AppTheme.secondaryText),
                  const SizedBox(height: 16),
                  Text(
                    'No topics found for "$subject"',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
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

  const _TopicCard({required this.topicText, required this.onTap});

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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}