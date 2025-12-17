import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'viewer_screen.dart';

class LearnScreen extends StatefulWidget {
  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final _topicController = TextEditingController();
  int _grade = 8;
  bool _loading = false;

  Future<void> _generate() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() => _loading = true);

    final res = await http.post(
      Uri.parse("http://localhost:3000/api/learn"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "topic": topic,
        "grade": _grade,
      }),
    );

    setState(() => _loading = false);

    if (res.statusCode != 200) return;

    final data = jsonDecode(res.body);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewerScreen(data: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learn")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: "What do you want to learn?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButton<int>(
              value: _grade,
              items: List.generate(
                9,
                (i) => DropdownMenuItem(
                  value: i + 4,
                  child: Text("Grade ${i + 4}"),
                ),
              ),
              onChanged: (v) => setState(() => _grade = v!),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _generate,
                child: const Text("Generate Lesson"),
              ),
            ),
            if (_loading) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ]
          ],
        ),
      ),
    );
  }
}
