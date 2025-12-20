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
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
    final res = await http.post(
      Uri.parse("https://edurance-backend.onrender.com/api/learn"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "topic": topic,
        "grade": _grade,
      }),
    );

    setState(() => _loading = false);

      if (res.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${res.statusCode}')),
        );
        return;
      }

    final data = jsonDecode(res.body);

      // Ensure grade is included in data
      data['grade'] = _grade;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewerScreen(data: data),
      ),
    );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
          children: [
                          Icon(Icons.school, color: Colors.indigo[700], size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "What do you want to learn?",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
            TextField(
              controller: _topicController,
                        decoration: InputDecoration(
                          labelText: "Enter topic",
                          hintText: "e.g., Photosynthesis, Algebra, World War 2",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          prefixIcon: const Icon(Icons.search),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _generate(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Select Grade Level",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<int>(
              value: _grade,
                          isExpanded: true,
                          underline: const SizedBox(),
              items: List.generate(
                9,
                (i) => DropdownMenuItem(
                  value: i + 4,
                  child: Text("Grade ${i + 4}"),
                ),
              ),
              onChanged: (v) => setState(() => _grade = v!),
            ),
                      ),
                      const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                onPressed: _loading ? null : _generate,
                          icon: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(_loading ? "Generating..." : "Generate Lesson"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          ),
        ),
      ),
    );
  }
}
