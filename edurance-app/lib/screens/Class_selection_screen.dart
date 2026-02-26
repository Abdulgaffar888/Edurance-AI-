import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'subject_selection_screen_V2.dart';

class ClassSelectionScreen extends StatelessWidget {
  const ClassSelectionScreen({super.key});

  static const classes = [
    {'level': 'Class 5', 'emoji': '🌱', 'subtitle': 'Foundation Years', 'active': true},
    {'level': 'Class 6', 'emoji': '📚', 'subtitle': 'Building Blocks', 'active': true},
    {'level': 'Class 7', 'emoji': '🔭', 'subtitle': 'Exploring Ideas', 'active': true},
    {'level': 'Class 8', 'emoji': '⚡', 'subtitle': 'Coming Soon', 'active': false},
    {'level': 'Class 9', 'emoji': '🚀', 'subtitle': 'Coming Soon', 'active': false},
  ];

  static const List<List<Color>> gradients = [
    [Color(0xFF00D4FF), Color(0xFF7C3AED)],
    [Color(0xFF7C3AED), Color(0xFFEC4899)],
    [Color(0xFFEC4899), Color(0xFF10B981)],
    [Color(0xFF10B981), Color(0xFF00D4FF)],
    [Color(0xFF00D4FF), Color(0xFFF59E0B)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edurance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Choose Your Class',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your class to get started with AI-powered learning',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final cls = classes[index];
                    final gradient = gradients[index % gradients.length];
                    final isActive = cls['active'] as bool;
                    return _ClassCard(
                      classLevel: cls['level']! as String,
                      emoji: cls['emoji']! as String,
                      subtitle: cls['subtitle']! as String,
                      gradient: gradient,
                      isActive: isActive,
                      onTap: isActive
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubjectSelectionScreen(
                                    classLevel: cls['level']! as String,
                                  ),
                                ),
                              )
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassCard extends StatefulWidget {
  final String classLevel;
  final String emoji;
  final String subtitle;
  final List<Color> gradient;
  final bool isActive;
  final VoidCallback? onTap;

  const _ClassCard({
    required this.classLevel,
    required this.emoji,
    required this.subtitle,
    required this.gradient,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<_ClassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isActive ? (_) => _ctrl.forward() : null,
      onTapUp: widget.isActive
          ? (_) {
              _ctrl.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.isActive ? () => _ctrl.reverse() : null,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: widget.isActive ? 1.0 : 0.45,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: widget.gradient,
                ),
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: widget.gradient.first.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.15), width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(widget.emoji,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.classLevel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Coming Soon',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white, size: 14),
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