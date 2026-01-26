import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'https://edurance-backend.onrender.com/api/teach';
  // during local testing:
  // 'http://localhost:3000/api/teach';

  static Future<String> sendMessage({
    required String subject,
    required String topic,
    String? message,
  }) async {
    final body = {
      'subject': subject,
      'topic': topic,
      if (message != null && message.trim().isNotEmpty)
        'message': message.trim(),
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return data['reply'] as String;
  }
}
