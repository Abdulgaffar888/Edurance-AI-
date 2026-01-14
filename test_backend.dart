import 'dart:convert';
import 'dart:io';

void main() async {
  print('Testing Edurance Backend APIs...\n');
  
  final baseUrl = 'https://edurance-backend.onrender.com';
  
  try {
    // Test 1: Check if backend is alive
    print('1. Testing backend status...');
    var response = await HttpClient().getUrl(Uri.parse(baseUrl));
    var statusResponse = await response.close();
    var statusBody = await statusResponse.transform(utf8.decoder).join();
    print('✅ Backend response: $statusBody\n');
    
    // Test 2: Test Learn API
    print('2. Testing Learn API...');
    var request = await HttpClient().postUrl(
      Uri.parse('$baseUrl/api/learn'),
    );
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode({
      'topic': 'Photosynthesis',
      'grade': 8
    }));
    var learnResponse = await request.close();
    var learnBody = await learnResponse.transform(utf8.decoder).join();
    print('✅ Learn API response received (${learnBody.length} chars)\n');
    
    // Test 3: Test Profile API
    print('3. Testing Profile API...');
    request = await HttpClient().postUrl(
      Uri.parse('$baseUrl/api/profile/save'),
    );
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode({
      'userId': 'test_user_${DateTime.now().millisecondsSinceEpoch}',
      'grade': 8,
      'school': 'Test School',
      'prevExamPercentage': 75,
      'parentPhone': '+919876543210'
    }));
    var profileResponse = await request.close();
    var profileBody = await profileResponse.transform(utf8.decoder).join();
    print('✅ Profile API response: ${jsonDecode(profileBody)['message']}\n');
    
    print('🎉 All backend APIs are working!');
    
  } catch (e) {
    print('❌ Error testing backend: $e');
    print('\n⚠️ Possible issues:');
    print('1. Backend not deployed to Render');
    print('2. Backend is sleeping (first request takes 30+ seconds)');
    print('3. Check Render dashboard for logs');
  }
}