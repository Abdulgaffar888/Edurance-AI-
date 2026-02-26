import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'slide_presentation_screen.dart';

class TopicListScreen extends StatelessWidget {
  final String subject;
  final String classLevel;

  const TopicListScreen({
    super.key,
    required this.subject,
    required this.classLevel,
  });

  static const Map<String, Map<String, List<String>>> topicsByClass = {
    // ─────────────────────────────────────────
    // CLASS 5
    // ─────────────────────────────────────────
    'Class 5': {
      'evs': [
        'Animals - The Base of our life',
        'Agriculture - Crops',
        'Let\'s Grow Trees',
        'Nutritious Food',
        'Our Body Parts - Sense Organs',
        'Our Body - Its Internal Organ System',
        'Forests - Tribals',
        'Rivers - Means of Livelihood',
        'Atmosphere - Wind',
        'The Sun and The Planets',
        'Safety and First Aid',
        'Historical Sites - Wanaparthy Fort',
        'Energy',
        'Our Country - World',
        'Our Constitution',
        'Child Rights',
      ],
    },

    // ─────────────────────────────────────────
    // CLASS 6
    // ─────────────────────────────────────────
    'Class 6': {
      'general science': [
        'Our food',
        'Playing with magnets',
        'Rain: where does it come from?',
        'What do animals eat?',
        'Materials - Objects',
        'Habitat',
        'Separation of Substances',
        'Fibre to Fabric',
        'Plants: parts and functions',
        'Changes around us',
        'Water in our life',
        'Simple electric circuits',
        'Learning how to measure',
        'Movements in animals',
        'Light, Shadows and Images',
        'Living and non living',
      ],
      'social studies': [
        'Reading and Making Maps',
        'Globe – A Model of the earth',
        'Land Forms (Part - A)',
        'Penamakuru – A Village in the Krishna Delta (Part - B)',
        'Dokur – A Village on the Plateau',
        'Penugolu – A Village on the Hills',
        'From Gathering Food to Growing Food – The Earliest People',
        'Agriculture in Our Times',
        'Trade in Agricultural Produce – Part - A',
        'Trade in Agricultural Produce – Part - B',
        'Community Decision Making in a Tribe',
        'Emergence of Kingdoms and Republics',
        'First Empires',
        'Democratic Government',
        'Village Panchayats',
        'Local Self – Government in Urban Areas',
        'Diversity in our Society',
        'Towards gender equality',
        'Religion and society in early times',
        'Devotion and love towards god',
        'Language, Script and Scriptures',
        'Sculptures and Buildings',
        'Greenery in Telangana',
      ],
    },

    // ─────────────────────────────────────────
    // CLASS 7
    // ─────────────────────────────────────────
    'Class 7': {
      'general science': [
        'Food Components',
        'Acids and Bases',
        'Silk - Wool',
        'Motion - Time',
        'Heat - Measurement',
        'Weather - Climate',
        'Electric Current - Its Effect',
        'Air, Winds and Cyclones',
        'Reflection of Light',
        'Nutrition in Plants',
        'Respiration in Organisms',
        'Reproduction in Plants',
        'Seed Dispersal',
        'Water - Too Little to Waste',
        'Soil - Our Life',
        'Forest - Our Life',
        'Changes Around Us',
      ],
      'social studies': [
        'Reading Maps of Different kinds',
        'Rain and Rivers',
        'Tanks and Ground Water',
        'Oceans and Fishing',
        'Europe',
        'Africa',
        'Handicrafts and Handlooms',
        'Industrial Revolution',
        'Production in a Factory – A Paper Mill',
        'Importance of Transport System',
        'New Kings and Kingdoms',
        'The Kakatiyas – Emergence of a Regional Kingdom',
        'The Kings of Vijayanagara',
        'Mughal Empire',
        'Establishment of the British Empire in India',
        'Making of Laws in the State Assembly',
        'Implementation of Laws in the District',
        'Caste Discrimination and the Struggle for Equalities',
        'Livelihood and Struggles of Urban Workers',
        'Folk – Religion',
        'Devotional Paths to the Divine',
        'Rulers and Buildings',
      ],
    },
  };

  List<String>? _getTopics() {
    final classData = topicsByClass[classLevel];
    if (classData == null) return null;
    final key = subject.toLowerCase().trim();
    return classData[key];
  }

  @override
  Widget build(BuildContext context) {
    final list = _getTopics();

    return Scaffold(
      appBar: AppBar(
        title: Text('$classLevel — $subject'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      backgroundColor: AppTheme.darkBackground,
      body: list == null || list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off,
                      size: 48, color: AppTheme.secondaryText),
                  const SizedBox(height: 16),
                  Text(
                    'No topics found for "$subject" in $classLevel',
                    style: const TextStyle(
                        fontSize: 16, color: AppTheme.secondaryText),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) => _TopicCard(
                  topicText: list[i],
                  index: i,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SlidePresentationScreen(
                        subject: subject,
                        topic: list[i],
                        classLevel: classLevel,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _TopicCard extends StatefulWidget {
  final String topicText;
  final int index;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topicText,
    required this.index,
    required this.onTap,
  });

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.98)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
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
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.auroraGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          color: AppTheme.auroraGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
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
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppTheme.secondaryText),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}