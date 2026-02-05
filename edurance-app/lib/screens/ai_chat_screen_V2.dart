import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum MessageType {
  definition,
  explanation,
  example,
  question,
  general,
}

class MessageSection {
  final String content;
  final MessageType type;

  MessageSection({
    required this.content,
    required this.type,
  });
}

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
      "https://edurance-ai-v2.onrender.com/api/teach";

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

  Widget _buildTeacherMessage(String text) {
    final sections = _parseMessageSections(text);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections.map((section) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getSectionColor(section.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getSectionColor(section.type).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (section.type != MessageType.general) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getSectionColor(section.type),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getSectionTitle(section.type),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  section.content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: section.type == MessageType.definition
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  List<MessageSection> _parseMessageSections(String text) {
    final sections = <MessageSection>[];
    final lines = text.split('\n');

    String currentContent = '';
    MessageType currentType = MessageType.general;

    for (final line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.toLowerCase().startsWith('definition:') ||
          trimmedLine.toLowerCase().startsWith('def:')) {
        if (currentContent.isNotEmpty) {
          sections.add(MessageSection(
              content: currentContent.trim(), type: currentType));
        }
        currentContent = trimmedLine.replaceFirst(
            RegExp(r'^\w*:\s*', caseSensitive: false), '');
        currentType = MessageType.definition;
      } else if (trimmedLine.toLowerCase().startsWith('explanation:') ||
          trimmedLine.toLowerCase().startsWith('explain:')) {
        if (currentContent.isNotEmpty) {
          sections.add(MessageSection(
              content: currentContent.trim(), type: currentType));
        }
        currentContent = trimmedLine.replaceFirst(
            RegExp(r'^\w*:\s*', caseSensitive: false), '');
        currentType = MessageType.explanation;
      } else if (trimmedLine.toLowerCase().startsWith('example:') ||
          trimmedLine.toLowerCase().startsWith('examples:')) {
        if (currentContent.isNotEmpty) {
          sections.add(MessageSection(
              content: currentContent.trim(), type: currentType));
        }
        currentContent = trimmedLine.replaceFirst(
            RegExp(r'^\w*:\s*', caseSensitive: false), '');
        currentType = MessageType.example;
      } else if (trimmedLine.toLowerCase().startsWith('question:') ||
          trimmedLine.toLowerCase().startsWith('check:') ||
          trimmedLine.toLowerCase().startsWith('checking question:')) {
        if (currentContent.isNotEmpty) {
          sections.add(MessageSection(
              content: currentContent.trim(), type: currentType));
        }
        currentContent = trimmedLine.replaceFirst(
            RegExp(r'^[\w\s]*:\s*', caseSensitive: false), '');
        currentType = MessageType.question;
      } else {
        if (currentContent.isNotEmpty) currentContent += '\n';
        currentContent += line;
      }
    }

    if (currentContent.isNotEmpty) {
      sections.add(
          MessageSection(content: currentContent.trim(), type: currentType));
    }

    return sections.isNotEmpty
        ? sections
        : [MessageSection(content: text, type: MessageType.general)];
  }

  Color _getSectionColor(MessageType type) {
    switch (type) {
      case MessageType.definition:
        return const Color(0xFF00D4FF);
      case MessageType.explanation:
        return const Color(0xFF7C3AED);
      case MessageType.example:
        return const Color(0xFF10B981);
      case MessageType.question:
        return const Color(0xFFF59E0B);
      case MessageType.general:
        return const Color(0xFF6B7280);
    }
  }

  String _getSectionTitle(MessageType type) {
    switch (type) {
      case MessageType.definition:
        return 'DEFINITION';
      case MessageType.explanation:
        return 'EXPLANATION';
      case MessageType.example:
        return 'EXAMPLE';
      case MessageType.question:
        return 'CHECKING QUESTION';
      case MessageType.general:
        return '';
    }
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
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    decoration: BoxDecoration(
                      color: isStudent
                          ? const Color(0xFF00D4FF).withOpacity(0.15)
                          : const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(16),
                      border: isStudent
                          ? Border.all(
                              color: const Color(0xFF00D4FF).withOpacity(0.3),
                              width: 1,
                            )
                          : null,
                      boxShadow: isStudent
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFF00D4FF).withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: isStudent
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              msg["text"] ?? "",
                              style: const TextStyle(
                                color: Color(0xFF00D4FF),
                                fontSize: 15,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E2E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border(
                                left: BorderSide(
                                  color:
                                      const Color(0xFF00D4FF).withOpacity(0.7),
                                  width: 3,
                                ),
                              ),
                            ),
                            child: _buildTeacherMessage(msg["text"] ?? ""),
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
