import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIChatScreen extends StatefulWidget {
  final String subject;
  final String topic;

  const AIChatScreen({
    super.key,
    required this.subject,
    required this.topic,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  static const String backendUrl =
      "https://edurance-ai.onrender.com/api/teach";

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  Future<void> _startConversation() async {
    await _sendMessage(null);
  }

  Future<void> _sendMessage(String? text) async {
    setState(() => _loading = true);

    if (text != null && text.trim().isNotEmpty) {
      _messages.add({
        "role": "student",
        "text": text.trim(),
      });
    }

    try {
      final res = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "subject": widget.subject,
          "topic": widget.topic,
          "message": text,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        _messages.add({
          "role": "teacher",
          "text": data["reply"] ?? "No response from teacher.",
        });
      } else {
        _messages.add({
          "role": "teacher",
          "text": "Server error (${res.statusCode}). Please try again.",
        });
      }
    } catch (_) {
      _messages.add({
        "role": "teacher",
        "text": "Network error. Please check your connection.",
      });
    }

    setState(() => _loading = false);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A15), // deep space background
      appBar: AppBar(
        title: Text(
          widget.topic,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final msg = _messages[index];
                final isStudent = msg["role"] == "student";

                return Align(
                  alignment:
                      isStudent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isStudent
                          ? const Color(0xFF00D4FF).withOpacity(0.85)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: TextStyle(
                        color: isStudent ? Colors.black : Colors.black87,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_loading)
            const LinearProgressIndicator(minHeight: 2),

          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: const Color(0xFF0F0F1E),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type your answer...",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A1A2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00D4FF)),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
