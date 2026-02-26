import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'topic_list_screen_V2.dart';
import 'under_development_screen.dart';

class SubjectSelectionScreen extends StatelessWidget {
  final String classLevel;
  const SubjectSelectionScreen({super.key, required this.classLevel});

  // Per-class subject config
  // functional: true = leads to topics, false = shows coming soon
  static Map<String, List<Map<String, dynamic>>> subjectsByClass = {
    'Class 5': [
      {
        'name': 'EVS',
        'icon': Icons.eco,
        'gradient': [const Color(0xFF00D4FF), const Color(0xFF7C3AED)],
        'functional': true,
      },
      {
        'name': 'Mathematics',
        'icon': Icons.functions,
        'gradient': [const Color(0xFF7C3AED), const Color(0xFFEC4899)],
        'functional': false,
      },
      {
        'name': 'English',
        'icon': Icons.menu_book,
        'gradient': [const Color(0xFFEC4899), const Color(0xFF10B981)],
        'functional': false,
      },
    ],
    'Class 6': [
      {
        'name': 'General Science',
        'icon': Icons.science,
        'gradient': [const Color(0xFF00D4FF), const Color(0xFF7C3AED)],
        'functional': true,
      },
      {
        'name': 'Social Studies',
        'icon': Icons.public,
        'gradient': [const Color(0xFF7C3AED), const Color(0xFFEC4899)],
        'functional': true,
      },
      {
        'name': 'Mathematics',
        'icon': Icons.functions,
        'gradient': [const Color(0xFFEC4899), const Color(0xFF10B981)],
        'functional': false,
      },
      {
        'name': 'English',
        'icon': Icons.menu_book,
        'gradient': [const Color(0xFF10B981), const Color(0xFF00D4FF)],
        'functional': false,
      },
    ],
    'Class 7': [
      {
        'name': 'General Science',
        'icon': Icons.science,
        'gradient': [const Color(0xFF00D4FF), const Color(0xFF7C3AED)],
        'functional': true,
      },
      {
        'name': 'Social Studies',
        'icon': Icons.public,
        'gradient': [const Color(0xFF7C3AED), const Color(0xFFEC4899)],
        'functional': true,
      },
      {
        'name': 'Mathematics',
        'icon': Icons.functions,
        'gradient': [const Color(0xFFEC4899), const Color(0xFF10B981)],
        'functional': false,
      },
      {
        'name': 'English',
        'icon': Icons.menu_book,
        'gradient': [const Color(0xFF10B981), const Color(0xFF00D4FF)],
        'functional': false,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final subjects = subjectsByClass[classLevel] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('$classLevel — Choose a Subject'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      backgroundColor: AppTheme.darkBackground,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 800
                ? 3
                : constraints.maxWidth > 500
                    ? 2
                    : 1;
            double childAspectRatio = constraints.maxWidth > 800
                ? 1.2
                : constraints.maxWidth > 500
                    ? 1.1
                    : 2.5;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: childAspectRatio,
              children: subjects.map((s) {
                final isFunctional = s['functional'] as bool;
                return _SubjectCard(
                  subjectName: s['name'] as String,
                  icon: s['icon'] as IconData,
                  gradient: s['gradient'] as List<Color>,
                  isComingSoon: !isFunctional,
                  onTap: () {
                    if (!isFunctional) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UnderDevelopmentScreen(
                            subjectName: s['name'] as String,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicListScreen(
                            subject: s['name'] as String,
                            classLevel: classLevel,
                          ),
                        ),
                      );
                    }
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
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  final bool isComingSoon;

  const _SubjectCard({
    required this.subjectName,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _glow = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: widget.isComingSoon ? 0.6 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isComingSoon
                      ? widget.gradient
                          .map((c) => c.withOpacity(0.5))
                          .toList()
                      : widget.gradient,
                ),
                boxShadow: widget.isComingSoon
                    ? []
                    : [
                        BoxShadow(
                          color: widget.gradient.first
                              .withOpacity(0.3 + _glow.value * 0.3),
                          blurRadius: 20 + _glow.value * 10,
                          spreadRadius: 2,
                        ),
                      ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white
                        .withOpacity(widget.isComingSoon ? 0.1 : 0.2),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Icon(
                              widget.icon,
                              size: screenSize.width > 500 ? 40 : 32,
                              color: Colors.white.withOpacity(
                                  widget.isComingSoon ? 0.5 : 0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Text(
                              widget.subjectName,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(
                                    widget.isComingSoon ? 0.6 : 1.0),
                                fontSize: screenSize.width > 500 ? 16 : 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isComingSoon)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.auroraPink.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Coming Soon',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}