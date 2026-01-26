import 'package:flutter/material.dart';
import '../services/api_service.dart';


class AIChatScreen extends StatefulWidget {
  final String subject;
  final String topic;

  const AIChatScreen({super.key, required this.subject, required this.topic});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startTeaching();
  }

  Future<void> _startTeaching() async {
    _messages.add({
      'role': 'user',
      'text': 'Start teaching ${widget.topic} from basics.'
    });
    await _send();
  }

  Future<void> _send() async {
    setState(() => _loading = true);
    final reply = await GeminiService.sendMessage(_messages);
    setState(() {
      _messages.add({'role': 'ai', 'text': reply});
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topic)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: _messages.map((m) {
                final isUser = m['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.indigo : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                    decoration:
                        const InputDecoration(hintText: 'Your answer...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _messages.add({
                      'role': 'user',
                      'text': _controller.text
                    });
                    _controller.clear();
                    _send();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
