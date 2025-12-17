import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class ViewerScreen extends StatefulWidget {
  final Map data;
  const ViewerScreen({super.key, required this.data});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  bool _speaking = false;
  String _doubtText = "";
  String? _doubtAnswer;

  html.SpeechSynthesisUtterance? _utterance;

  void _toggleSpeak() {
    final synth = html.window.speechSynthesis;
    if (synth == null) return;

    if (_speaking) {
      synth.cancel();
      setState(() => _speaking = false);
      return;
    }

    final fullText = widget.data['sections']
        .map((s) => "${s['heading']}. ${s['content']}")
        .join(". ");

    _utterance = html.SpeechSynthesisUtterance(fullText)
      ..rate = 0.95
      ..pitch = 1.1;

    synth.speak(_utterance!);
    setState(() => _speaking = true);
  }

  Future<void> _sendDoubt(String text) async {
    final res = await http.post(
      Uri.parse("http://localhost:3000/api/doubt"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "topic": widget.data['title'],
        "grade": widget.data['grade'],
        "doubt": text,
      }),
    );

    final data = jsonDecode(res.body);
    setState(() => _doubtAnswer = data['answer']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['title']),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(_speaking ? Icons.stop : Icons.volume_up),
            onPressed: _toggleSpeak,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var section in widget.data['sections'])
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section['heading'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(section['content']),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),
          const Text(
            "Ask a doubt (voice/text)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (v) => _doubtText = v,
            decoration: const InputDecoration(
              hintText: "Speak or type your doubt...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _sendDoubt(_doubtText),
            child: const Text("Ask Doubt"),
          ),

          if (_doubtAnswer != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_doubtAnswer!),
              ),
            )
          ]
        ],
      ),
    );
  }
}
