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

  // ✅ ONLY backend endpoint
  static const String backendUrl =
      "https://YOUR-NEW-RENDER-URL.onrender.com/api/teach";

  @override
  void initState() {
    super.initState();
    _sendMessage(null); // auto-start teaching
  }

  Future<void> _sendMessage(String? text) async {
    if (_loading) return;
    setState(() => _loading = true);

    if (text != null && text.trim().isNotEmpty) {
      _messages.add({"role": "student", "text": text.trim()});
    }

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "subject": widget.subject,
          "topic": widget.topic,
          "message": text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _messages.add({
          "role": "teacher",
          "text": data["reply"] ?? "No response from teacher.",
        });
      } else {
        _messages.add({
          "role": "teacher",
          "text": "Server error (${response.statusCode})",
        });
      }
    } catch (_) {
      _messages.add({
        "role": "teacher",
        "text": "Network error. Please try again.",
      });
    }

    setState(() => _loading = false);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A15),
      appBar: AppBar(
        title: Text(widget.topic, style: const TextStyle(fontSize: 16)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isStudent = msg["role"] == "student";

                return Align(
                  alignment:
                      isStudent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isStudent
                          ? const Color(0xFF00D4FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration:
                        const InputDecoration(hintText: "Type your answer…"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
