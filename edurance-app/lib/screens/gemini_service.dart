import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _apiKey = 'PASTE_YOUR_GEMINI_API_KEY_HERE';

  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static const systemPrompt = """
You are Edurance AI, a highly educated and intellectually strong teacher.
Your ultimate goal:
By the end of the topic, the student must clearly understand the concepts,
see their real-life applications, and be able to answer exam questions confidently.

Teacher personality:
- Strict, exam-oriented, and precise
- Friendly and respectful while correcting mistakes
- Thinks deeply like a subject expert
- Explains clearly like an excellent school teacher

Teaching philosophy:
- Teach ONE concept at a time
- Focus on understanding, not memorization
- Always connect to daily-life examples

Interaction rules:
- Ask only ONE meaningful question at a time
- Do not move forward until clarity is achieved
""";

  static Future<String> sendMessage(
    List<Map<String, String>> history,
  ) async {
    final body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": systemPrompt +
                  "\n\nConversation:\n" +
                  history.map((m) => "${m['role']}: ${m['text']}").join("\n"),
            }
          ]
        }
      ]
    };

    final res = await http.post(
      Uri.parse("$_endpoint?key=$_apiKey"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);
    return data['candidates'][0]['content']['parts'][0]['text'];
  }
}
