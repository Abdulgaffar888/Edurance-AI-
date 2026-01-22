import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_screen.dart'; // for SessionManager

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  late final String sessionId;

  @override
  void initState() {
    super.initState();
    sessionId = SessionManager.sessionId ?? "guest_${DateTime.now().millisecondsSinceEpoch}";
    _sendMessage("START_LESSON_ONBOARDING");
  }

  Future<void> _sendMessage(String userText) async {
    if (userText.trim().isEmpty) return;

    setState(() {
      if (_messages.isNotEmpty) {
        _messages.add({"role": "user", "content": userText});
      }
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.18.129:3000/api/tutor/chat');


      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": userText,
          "session_id": sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = "${data['teaching_point']}\n\n${data['question']}";

        setState(() {
          // 🔥 YC DEMO MAGIC LINE
         

          _messages.add({"role": "agent", "content": aiResponse});
        });
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection failed. Is backend running?");
    } finally {
      setState(() => _isLoading = false);
      _controller.clear();
    }
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Tutor: Electricity"),
        backgroundColor: const Color(0xFF3D9974)
,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg["role"] == "user";
                bool isSystem = msg["role"] == "system";
                return _buildChatBubble(msg["content"]!, isUser, isSystem);
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser, bool isSystem) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isSystem
              ? Colors.amber.shade50
              : isUser
                  ? Colors.indigo
                  : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          border: isSystem ? Border.all(color: Colors.amber) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
            fontStyle: isSystem ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type your answer...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onSubmitted: (val) => _sendMessage(val),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF3D9974)
,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMessage(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}
