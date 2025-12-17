import 'package:http/http.dart' as http;
import 'dart:convert';


class ApiService {
static const base = 'http://localhost:3000';


static Future<dynamic> generate(String topic, int grade) async {
final res = await http.post(Uri.parse('$base/api/generate'), body: jsonEncode({ 'topic': topic, 'grade': grade }), headers: { 'Content-Type': 'application/json' });
return jsonDecode(res.body);
}


static Future<dynamic> solveImage(/* file */) async {
// TODO: implement multipart upload
return {};
}
}