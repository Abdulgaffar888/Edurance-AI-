import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ViewerScreen extends StatefulWidget {
  final Map data;
  const ViewerScreen({super.key, required this.data});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  FlutterTts? _flutterTts;
  stt.SpeechToText? _speech;

  bool _speaking = false;
  bool _listening = false;
  bool _ttsInitialized = false;

  final TextEditingController _doubtController = TextEditingController();
  String? _doubtAnswer;

  double _speechRate = 0.45;

  int _currentCardIndex = 0;
  List<dynamic> _flashcards = [];

  @override
  void initState() {
    super.initState();
    _flashcards = List.from(widget.data['flashcards'] ?? []);
    _initTts();
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlay());
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts!.setLanguage("en-US");
    await _flutterTts!.setPitch(1.15);
    await _flutterTts!.setSpeechRate(_speechRate);
    await _flutterTts!.setVolume(1.0);
    _flutterTts!.setCompletionHandler(() {
      setState(() => _speaking = false);
    });
    setState(() => _ttsInitialized = true);
  }

  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    await _speech!.initialize(
      onStatus: (s) => setState(() => _listening = s == 'listening'),
      onError: (_) => setState(() => _listening = false),
    );
  }

  void _autoPlay() {
    if (_flashcards.isNotEmpty) _readCard();
  }

  Future<void> _readCard() async {
    if (!_ttsInitialized) return;
    final card = _flashcards[_currentCardIndex];
    final text = "${card['hook']} ${card['content']}";
    setState(() => _speaking = true);
    await _flutterTts!.speak(text);
  }

  void _toggleSpeak() {
    if (_speaking) {
      _flutterTts!.stop();
      setState(() => _speaking = false);
    } else {
      _readCard();
    }
  }

  void _startListening() async {
    if (_listening) {
      _speech!.stop();
      return;
    }
    await _speech!.listen(onResult: (r) {
      setState(() => _doubtController.text = r.recognizedWords);
    });
  }

  Future<void> _sendDoubt(String text) async {
    if (text.trim().isEmpty) return;

    final res = await http.post(
      Uri.parse("https://edurance-backend.onrender.com/api/doubt"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "topic": widget.data['title'],
        "grade": widget.data['grade'] ?? 8,
        "doubt": text,
      }),
    );

    if (res.statusCode == 200) {
      setState(() => _doubtAnswer = jsonDecode(res.body)['answer']);
    }
  }

  MaterialColor _gradeColor() {
    final g = widget.data['grade'] ?? 8;
    if (g <= 6) return Colors.blue;
    if (g <= 9) return Colors.indigo;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor();
    final card = _flashcards[_currentCardIndex];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.data['title']),
        backgroundColor: color,
        actions: [
          IconButton(
            icon: Icon(_speaking ? Icons.stop : Icons.play_arrow),
            onPressed: _toggleSpeak,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // FLASHCARD
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.shade50, color.shade100],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Text(
                              card['emoji'],
                              style: const TextStyle(fontSize: 48),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              card['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: color.shade900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              card['hook'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: color.shade700,
                              ),
                            ),

                            // ✅ PROGRESS BAR (SAFE)
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: (_currentCardIndex + 1) /
                                    _flashcards.length,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade300,
                                valueColor:
                                    AlwaysStoppedAnimation(color.shade600),
                              ),
                            ),
                            const SizedBox(height: 10),

                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.45,
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  card['content'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // NAVIGATION
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _currentCardIndex > 0
                                ? () => setState(() => _currentCardIndex--)
                                : null,
                            child: const Text("Previous"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _currentCardIndex < _flashcards.length - 1
                                    ? () =>
                                        setState(() => _currentCardIndex++)
                                    : null,
                            child: const Text("Next"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // DOUBT
                    TextField(
                      controller: _doubtController,
                      onChanged: (_) => setState(() {}),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Ask a doubt...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon:
                              Icon(_listening ? Icons.mic : Icons.mic_none),
                          onPressed: _startListening,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: _doubtController.text.trim().isEmpty
                          ? null
                          : () => _sendDoubt(_doubtController.text),
                      child: const Text("Ask Doubt"),
                    ),

                    if (_doubtAnswer != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _doubtAnswer!,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
