import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      "https://YOUR-NEW-RENDER-URL.onrender.com/api/teach";

  static Future<String> sendMessage({
    required String subject,
    required String topic,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "subject": subject,
        "topic": topic,
        "message": message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Backend error ${response.statusCode}");
    }

    return jsonDecode(response.body)["reply"];
  }
}
