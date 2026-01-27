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
    _startTopic();
  }

  Future<void> _startTopic() async {
    await _sendMessage(null);
  }

  Future<void> _sendMessage(String? text) async {
    setState(() => _loading = true);

    if (text != null && text.trim().isNotEmpty) {
      _messages.add({"role": "student", "text": text});
    }

    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {"Content-Type": "application/json"},
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
        "text": data["reply"] ?? "No response",
      });
    } else {
      _messages.add({
        "role": "teacher",
        "text": "Server error. Please try again.",
      });
    }

    setState(() => _loading = false);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.subject} • ${widget.topic}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isStudent = msg["role"] == "student";

                return Align(
                  alignment:
                      isStudent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isStudent
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg["text"] ?? ""),
                  ),
                );
              },
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your answer...",
                    ),
                    onSubmitted: (v) => _sendMessage(v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
