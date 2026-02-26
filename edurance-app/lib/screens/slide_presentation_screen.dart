import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────
class SlideData {
  final String title;
  final List<String> content;
  final String? teacherNote;

  SlideData({
    required this.title,
    required this.content,
    this.teacherNote,
  });

  factory SlideData.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    List<String> contentList = [];

    if (rawContent is List) {
      contentList = rawContent.map((e) => e.toString()).toList();
    } else if (rawContent is String) {
      contentList = rawContent
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();
    }

    return SlideData(
      title: json['title']?.toString() ?? 'Slide',
      content: contentList,
      teacherNote: json['teacherNote']?.toString(),
    );
  }
}

// ─────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────
class SlidePresentationScreen extends StatefulWidget {
  final String subject;
  final String topic;
  final String classLevel;

  const SlidePresentationScreen({
    super.key,
    required this.subject,
    required this.topic,
    required this.classLevel,
  });

  @override
  State<SlidePresentationScreen> createState() =>
      _SlidePresentationScreenState();
}

class _SlidePresentationScreenState extends State<SlidePresentationScreen>
    with TickerProviderStateMixin {
  List<SlideData> _slides = [];
  int _currentIndex = 0;
  bool _loading = true;
  bool _showTeacherNote = false;
  String? _error;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  static const String backendUrl =
      "https://edurance-ai-v2.onrender.com/api/teach";

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnim =
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    _fetchSlides();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  double get _progressValue {
    if (_slides.isEmpty) return 0;
    return (_currentIndex + 1) / _slides.length;
  }

  Future<void> _fetchSlides() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "subject": widget.subject,
          "topic": widget.topic,
          "classLevel": widget.classLevel,
          "mode": "slides",
          "message": null,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<SlideData> parsed = [];

        if (data['slides'] != null && data['slides'] is List) {
          parsed = (data['slides'] as List)
              .map((s) => SlideData.fromJson(s as Map<String, dynamic>))
              .toList();
        } else if (data['reply'] != null) {
          parsed = _parseReplyToSlides(data['reply'].toString());
        }

        if (parsed.isEmpty) {
          parsed = _generateFallbackSlides();
        }

        setState(() {
          _slides = parsed;
          _loading = false;
          _currentIndex = 0;
          _showTeacherNote = false;
        });
        _playTransition();
        _updateProgress();
      } else {
        setState(() {
          _error = "Server error (${response.statusCode}). Please try again.";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Network error. Please check your connection.";
        _loading = false;
      });
    }
  }

  List<SlideData> _parseReplyToSlides(String text) {
    final slides = <SlideData>[];
    final sections = text.split(RegExp(r'\n(?=[A-Z#])'));

    for (final section in sections) {
      final lines = section
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;

      final title = lines.first
          .replaceAll(RegExp(r'^#+\s*'), '')
          .replaceAll('**', '')
          .trim();
      final content = lines
          .skip(1)
          .map((l) => l.replaceAll(RegExp(r'^[-•*]\s*'), '').trim())
          .where((l) => l.isNotEmpty)
          .toList();

      if (title.isNotEmpty) {
        slides.add(SlideData(
          title: title,
          content: content.isEmpty
              ? ['Content for this slide will appear here.']
              : content,
        ));
      }
    }

    return slides;
  }

  List<SlideData> _generateFallbackSlides() {
    return [
      SlideData(
        title: 'Introduction to ${widget.topic}',
        content: [
          'Welcome to this lesson on ${widget.topic}.',
          'We will explore the key concepts step by step.',
          'Take notes and ask questions as we go.',
          'By the end, you will be confident for your exams.',
        ],
        teacherNote:
            'Welcome class! Today we are going to explore ${widget.topic}. This is an important topic in your syllabus and I want you to pay close attention. Let\'s begin!',
      ),
      SlideData(
        title: 'Key Concepts',
        content: [
          'This topic covers important ideas in ${widget.subject}.',
          'Each concept builds on the previous one.',
          'Understanding these will help you excel in your class.',
          'Connect what you learn here to real life situations around you.',
        ],
        teacherNote:
            'Now, think about it this way — every concept we cover today is connected. Once you understand the foundation, everything else will fall into place naturally.',
      ),
      SlideData(
        title: 'Summary & Exam Tips',
        content: [
          'You have completed this lesson on ${widget.topic}.',
          'Review the key points before moving on.',
          'Practice questions will help reinforce your learning.',
          'In your exam, always write definitions clearly and give examples.',
        ],
        teacherNote:
            'Excellent work today! In your exam, remember to always write full sentences in descriptive answers. Do not just write keywords. And always give one real-life example to score bonus marks.',
      ),
    ];
  }

  void _playTransition() {
    _fadeCtrl.forward(from: 0);
    _slideCtrl.forward(from: 0);
  }

  void _updateProgress() {
    if (_slides.isEmpty) return;
    _progressCtrl.animateTo(_progressValue);
  }

  void _goNext() {
    if (_currentIndex < _slides.length - 1) {
      setState(() {
        _currentIndex++;
        _showTeacherNote = false;
      });
      _playTransition();
      _updateProgress();
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showTeacherNote = false;
      });
      _playTransition();
      _updateProgress();
    }
  }

  void _goToSlide(int index) {
    if (index >= 0 && index < _slides.length && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _showTeacherNote = false;
      });
      _playTransition();
      _updateProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) _goNext();
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _goPrev();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A15),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              _buildProgressBar(),
              Expanded(child: _buildBody()),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.classLevel,
                  style: TextStyle(
                    color: const Color(0xFF00D4FF).withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  widget.topic.length > 50
                      ? '${widget.topic.substring(0, 50)}...'
                      : widget.topic,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_slides.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4FF).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withOpacity(0.25),
                ),
              ),
              child: Text(
                '${_currentIndex + 1} / ${_slides.length}',
                style: const TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Progress bar ─────────────────────────────
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _slides.isEmpty ? 0 : _progressValue,
                  minHeight: 5,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00D4FF),
                  ),
                ),
              );
            },
          ),
          if (_slides.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _currentIndex == _slides.length - 1
                    ? '🎉 Lesson complete!'
                    : '${_slides.length - _currentIndex - 1} slide${_slides.length - _currentIndex - 1 == 1 ? '' : 's'} remaining',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Main body ────────────────────────────────
  Widget _buildBody() {
    if (_loading) return _buildLoadingState();
    if (_error != null) return _buildErrorState();
    if (_slides.isEmpty) return _buildEmptyState();
    return _buildSlideCanvas();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(
                color: Color(0xFF00D4FF),
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Preparing your lesson...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is building slides for ${widget.topic}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off,
                size: 48, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _fetchSlides,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No slides available.',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  // ── Slide canvas ─────────────────────────────
  Widget _buildSlideCanvas() {
    final slide = _slides[_currentIndex];
    final hasNote =
        slide.teacherNote != null && slide.teacherNote!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              // ── Main slide card (16:9) ──
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF13131F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.08),
                        blurRadius: 40,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background accent glow
                      Positioned(
                        top: -40,
                        right: -40,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF00D4FF).withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Slide number
                      Positioned(
                        bottom: 16,
                        right: 20,
                        child: Text(
                          '${_currentIndex + 1}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.2),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Slide content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(36, 28, 36, 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subject pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF00D4FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF00D4FF)
                                      .withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                widget.subject.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF00D4FF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Title
                            Text(
                              slide.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 2,
                              width: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00D4FF),
                                    Color(0xFF7C3AED),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Bullet points
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: slide.content.map((point) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 7),
                                            child: Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(0xFF00D4FF)
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              point,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.85),
                                                fontSize: 13.5,
                                                height: 1.6,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Teacher Note Panel ──
              if (hasNote) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () =>
                      setState(() => _showTeacherNote = !_showTeacherNote),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _showTeacherNote
                          ? const Color(0xFF1A1228)
                          : const Color(0xFF13131F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF7C3AED).withOpacity(
                            _showTeacherNote ? 0.5 : 0.25),
                      ),
                      boxShadow: _showTeacherNote
                          ? [
                              BoxShadow(
                                color: const Color(0xFF7C3AED)
                                    .withOpacity(0.08),
                                blurRadius: 20,
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('🎓',
                                      style: TextStyle(fontSize: 12)),
                                  SizedBox(width: 6),
                                  Text(
                                    "TEACHER'S EXPLANATION",
                                    style: TextStyle(
                                      color: Color(0xFFAB7BFF),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            AnimatedRotation(
                              turns: _showTeacherNote ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFFAB7BFF),
                                size: 20,
                              ),
                            ),
                          ],
                        ),

                        // Note text
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: _showTeacherNote
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              slide.teacherNote!.length > 90
                                  ? '${slide.teacherNote!.substring(0, 90)}...'
                                  : slide.teacherNote!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.38),
                                fontSize: 12,
                                height: 1.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              slide.teacherNote!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 14,
                                height: 1.75,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom controls ───────────────────────────
  Widget _buildBottomControls() {
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == _slides.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          // Dot indicators
          if (_slides.isNotEmpty && _slides.length <= 15)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final isActive = i == _currentIndex;
                  return GestureDetector(
                    onTap: () => _goToSlide(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF00D4FF)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
          // Prev / Next buttons
          Row(
            children: [
              // Prev
              Expanded(
                child: GestureDetector(
                  onTap: isFirst ? null : _goPrev,
                  child: AnimatedOpacity(
                    opacity: isFirst ? 0.3 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_ios,
                              size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Previous',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Next
              Expanded(
                child: GestureDetector(
                  onTap: isLast ? null : _goNext,
                  child: AnimatedOpacity(
                    opacity: isLast ? 0.4 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: isLast
                            ? null
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF00D4FF),
                                  Color(0xFF7C3AED),
                                ],
                              ),
                        color: isLast
                            ? Colors.white.withOpacity(0.07)
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isLast
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(0xFF00D4FF)
                                      .withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'Finished' : 'Next',
                            style: TextStyle(
                              color: isLast
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (!isLast) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_ios,
                                size: 14, color: Colors.white),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}