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

  // Topics organized by class → subject
  static const Map<String, Map<String, List<String>>> topicsByClass = {
    'Class 5': {
      'social studies': [
        'Our Environment - Chapter 1 (Land, Water, Air)',
        'Maps and Directions - Chapter 2 (Types of maps, Compass)',
        'Natural Vegetation - Chapter 3 (Forests, Grasslands, Deserts)',
        'Wildlife Conservation - Chapter 4 (National parks, Endangered species)',
        'Our Country India - Chapter 5 (States, Union territories, Capital)',
      ],
      'physics': [
        'Force and Energy - Chapter 1 (Types of force, Work)',
        'Simple Machines - Chapter 2 (Lever, Pulley, Inclined plane)',
        'Light and Shadow - Chapter 3 (Reflection, Sources of light)',
        'Matter and Materials - Chapter 4 (Solids, Liquids, Gases)',
        'Electricity - Chapter 5 (Circuit, Conductors, Insulators)',
      ],
      'biology': [
        'Plants - Chapter 1 (Parts of plant, Photosynthesis basics)',
        'Animals - Chapter 2 (Habitats, Food chains)',
        'Human Body - Chapter 3 (Organs, Senses)',
        'Food and Nutrition - Chapter 4 (Nutrients, Balanced diet)',
        'Health and Hygiene - Chapter 5 (Disease prevention)',
      ],
    },
    'Class 6': {
      'social studies': [
        'The Earth in the Solar System - Chapter 1 (Planets, Sun, Moon)',
        'Globe and Maps - Chapter 2 (Latitudes, Longitudes)',
        'Motions of the Earth - Chapter 3 (Rotation, Revolution, Seasons)',
        'Major Domains of the Earth - Chapter 4 (Lithosphere, Hydrosphere)',
        'Major Landforms - Chapter 5 (Mountains, Plateaus, Plains)',
        'Our Country India - Chapter 6 (Location, Physical features)',
        'India: Climate, Vegetation and Wildlife - Chapter 7',
      ],
      'physics': [
        'Food: Where Does It Come From? - Chapter 1',
        'Components of Food - Chapter 2 (Nutrients, Deficiency diseases)',
        'Motion and Measurement - Chapter 3 (Types of motion)',
        'Light, Shadows and Reflections - Chapter 4',
        'Electricity and Circuits - Chapter 5',
        'Magnets - Chapter 6 (Properties, Uses)',
      ],
      'biology': [
        'Getting to Know Plants - Chapter 1 (Herbs, Shrubs, Trees)',
        'Body Movements - Chapter 2 (Joints, Skeleton)',
        'Living Organisms and Surroundings - Chapter 3 (Habitat, Adaptation)',
        'Changes Around Us - Chapter 4 (Reversible, Irreversible)',
        'Garbage In, Garbage Out - Chapter 5 (Waste management)',
      ],
    },
    'Class 7': {
      'social studies': [
        'Environment - Chapter 1 (Natural and Human-made)',
        'Inside Our Earth - Chapter 2 (Layers, Rocks, Minerals)',
        'Our Changing Earth - Chapter 3 (Earthquakes, Volcanoes)',
        'Air - Chapter 4 (Atmosphere, Weather, Climate)',
        'Water - Chapter 5 (Distribution, Ocean circulation)',
        'Natural Vegetation and Wildlife - Chapter 6',
        'Human Environment - Chapter 7 (Tribes, Nomads, Communities)',
        'Human Environment Interactions - Chapter 8 (Amazon basin, Ganga plains)',
      ],
      'physics': [
        'Nutrition in Plants - Chapter 1 (Photosynthesis, Parasitic plants)',
        'Nutrition in Animals - Chapter 2 (Digestive system)',
        'Heat - Chapter 3 (Temperature, Conduction, Convection)',
        'Acids, Bases and Salts - Chapter 4 (Properties, Indicators)',
        'Physical and Chemical Changes - Chapter 5',
        'Light - Chapter 6 (Reflection, Plane mirror)',
        'Electric Current and Effects - Chapter 7',
        'Motion and Time - Chapter 8 (Speed, Distance-time graphs)',
      ],
      'biology': [
        'Respiration in Organisms - Chapter 1 (Aerobic, Anaerobic)',
        'Transportation in Animals and Plants - Chapter 2',
        'Reproduction in Plants - Chapter 3 (Asexual, Sexual)',
        'Forests: Our Lifeline - Chapter 4',
        'Wastewater Management - Chapter 5',
        'Weather, Climate and Adaptations - Chapter 6',
      ],
    },
    'Class 8': {
      'social studies': [
        'Resources - Chapter 1 (Types, Conservation)',
        'Land, Soil, Water, Natural Vegetation - Chapter 2',
        'Mineral and Power Resources - Chapter 3',
        'Agriculture - Chapter 4 (Types of farming, Crops)',
        'Industries - Chapter 5 (Iron, Steel, IT)',
        'Human Resources - Chapter 6 (Population distribution)',
        'The Indian Constitution - Chapter 7',
        'Understanding Laws - Chapter 8',
        'Judiciary - Chapter 9 (Courts, Rights)',
      ],
      'physics': [
        'Crop Production and Management - Chapter 1',
        'Combustion and Flame - Chapter 2 (Types, Fire extinguisher)',
        'Force and Pressure - Chapter 3 (Contact/Non-contact forces)',
        'Friction - Chapter 4 (Types, Uses, Reducing friction)',
        'Sound - Chapter 5 (Vibration, Properties, Noise pollution)',
        'Chemical Effects of Electric Current - Chapter 6',
        'Some Natural Phenomena - Chapter 7 (Lightning, Earthquakes)',
        'Light - Chapter 8 (Laws of reflection, Eye)',
      ],
      'biology': [
        'Microorganisms - Chapter 1 (Friend and Foe)',
        'Cell — Structure and Functions - Chapter 2',
        'Reproduction in Animals - Chapter 3',
        'Reaching the Age of Adolescence - Chapter 4',
        'Conservation of Plants and Animals - Chapter 5',
        'Pollution of Air and Water - Chapter 6',
      ],
    },
    'Class 9': {
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
        'Sustainable Development with Equity - Chapter 11 (Environment vs Growth)',
        'The World Between Wars - Chapter 12 (World War I & II, Great Depression)',
        'National Liberation Movements in Colonies - Chapter 13 (China, Vietnam, Nigeria)',
        'National Movement in India - Chapter 14 (Quit India, Partition, Role of Gandhi)',
        'The Making of Independent India\'s Constitution - Chapter 15',
        'The Election Process in India - Chapter 16',
        'Independent India (First 30 Years) - Chapter 17',
        'Emerging Political Trends (1977-2000) - Chapter 18',
        'Post-War World and India - Chapter 19 (Cold war, Non-Aligned Movement)',
        'Social Movements in Our Times - Chapter 20',
        'The Movement for the Formation of Telangana State - Chapter 21',
      ],
      'physics': [
        'Reflection of Light at Curved Surfaces - Chapter 1 (Spherical mirrors, Ray diagrams)',
        'Chemical Equations - Chapter 2 (Types of reactions, Balancing)',
        'Acids, Bases and Salts - Chapter 3 (pH Scale, Indicators)',
        'Refraction of Light at Curved Surfaces - Chapter 4 (Lenses)',
        'The Human Eye and the Colourful World - Chapter 5 (Dispersion, Scattering)',
        'Structure of Atom - Chapter 6 (Spectrum, Quantum numbers)',
        'Classification of Elements - The Periodic Table - Chapter 7',
        'Chemical Bonding - Chapter 8 (Ionic and Covalent bonding)',
        'Electric Current - Chapter 9 (Ohm\'s Law, Kirchhoff\'s Laws)',
        'Electromagnetism - Chapter 10 (Magnetic field, Induction)',
        'Principles of Metallurgy - Chapter 11',
        'Carbon and its Compounds - Chapter 12',
      ],
      'biology': [
        'Nutrition - Chapter 1 (Photosynthesis, Digestive system)',
        'Respiration - Chapter 2 (Aerobic/Anaerobic, Human respiratory system)',
        'Transportation - Chapter 3 (Heart structure, Blood vessels)',
        'Excretion - Chapter 4 (Nephron, Kidney transplantation)',
        'Coordination - Chapter 5 (Nervous system, Brain, Plant hormones)',
        'Reproduction - Chapter 6 (Asexual/Sexual, Flower structure)',
        'Coordination in Life Processes - Chapter 7',
        'Heredity and Evolution - Chapter 8 (Mendel\'s laws, Sex determination)',
        'Our Environment - Chapter 9 (Food chains, Ecological pyramids)',
        'Natural Resources - Chapter 10 (Conservation, Soil/Water management)',
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
                      fontSize: 16,
                      color: AppTheme.secondaryText,
                    ),
                    textAlign: TextAlign.center,
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
                          builder: (_) => SlidePresentationScreen(
                            subject: subject,
                            topic: list[i],
                            classLevel: classLevel,
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