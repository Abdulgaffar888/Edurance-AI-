import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'topic_list_screen_V2.dart';

class SubjectSelectionScreen extends StatelessWidget {
  const SubjectSelectionScreen({super.key});

  static const subjects = [
    {
      'name': 'Social Studies',
      'gradient': [AppTheme.auroraBlue, AppTheme.auroraPurple]
    },
    {
      'name': 'Physics',
      'gradient': [AppTheme.auroraPurple, AppTheme.auroraPink]
    },
    {
      'name': 'Chemistry',
      'gradient': [AppTheme.auroraGreen, AppTheme.auroraBlue]
    },
    {
      'name': 'Biology',
      'gradient': [AppTheme.auroraPink, AppTheme.auroraGreen]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Subject'),
        backgroundColor: AppTheme.surfaceColor,
      ),
      backgroundColor: AppTheme.darkBackground,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid for web
            int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
            double childAspectRatio = constraints.maxWidth > 600 ? 0.8 : 0.9;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: childAspectRatio,
              children: subjects.map((s) {
                return _SubjectCard(
                  subjectName: s['name'] as String,
                  gradient: s['gradient'] as List<Color>,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TopicListScreen(subject: s['name'] as String),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _SubjectCard extends StatefulWidget {
  final String subjectName;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subjectName,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.first
                        .withOpacity(0.3 + _glowAnimation.value * 0.3),
                    blurRadius: 20 + _glowAnimation.value * 10,
                    spreadRadius: 2 + _glowAnimation.value * 2,
                  ),
                  BoxShadow(
                    color: widget.gradient.last
                        .withOpacity(0.2 + _glowAnimation.value * 0.2),
                    blurRadius: 15 + _glowAnimation.value * 8,
                    spreadRadius: 1 + _glowAnimation.value * 1,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getSubjectIcon(widget.subjectName),
                          size: 40,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.subjectName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
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

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Mathematics':
        return Icons.functions;
      case 'Physics':
        return Icons.bolt;
      case 'Chemistry':
        return Icons.science;
      case 'Biology':
        return Icons.biotech;
      default:
        return Icons.school;
    }
  }
}
