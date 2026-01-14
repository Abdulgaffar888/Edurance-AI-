import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://edurance-backend.onrender.com';

  // EXISTING METHODS
  Future<Map<String, dynamic>> learnTopic(String topic, int grade) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/learn',
        data: {'topic': topic, 'grade': grade},
      );
      return response.data;
    } catch (e) {
      print('Learn error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> solveQuestion(String question, int grade) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/solve',
        data: {'question': question, 'grade': grade},
      );
      return response.data;
    } catch (e) {
      print('Solve error: $e');
      rethrow;
    }
  }

  // PROFILE METHODS
  Future<Map<String, dynamic>> saveProfile({
    required String userId,
    required int grade,
    String? school,
    double? prevExamPercentage,
    required String parentPhone,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/profile/save',
        data: {
          'userId': userId,
          'grade': grade,
          'school': school ?? '',
          'prevExamPercentage': prevExamPercentage,
          'parentPhone': parentPhone,
        },
      );
      return response.data;
    } catch (e) {
      print('Save profile error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/profile/$userId');
      return response.data;
    } catch (e) {
      print('Get profile error: $e');
      rethrow;
    }
  }

  // DIAGNOSTIC METHODS
  Future<Map<String, dynamic>> startDiagnostic({
    required String userId,
    required int grade,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/diagnostic/start',
        data: {
          'userId': userId,
          'grade': grade,
        },
      );
      return response.data;
    } catch (e) {
      print('Start diagnostic error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> submitDiagnostic({
    required String userId,
    required String sessionId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/diagnostic/submit',
        data: {
          'userId': userId,
          'sessionId': sessionId,
          'answers': answers,
        },
      );
      return response.data;
    } catch (e) {
      print('Submit diagnostic error: $e');
      rethrow;
    }
  }

  // CURRICULUM METHODS
  Future<Map<String, dynamic>> generateCurriculum({
    required List<String> weakAreas,
    required List<String> strengthAreas,
    required double overallScore,
    required int grade,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final response = await _dio.post(
        '$_baseUrl/api/curriculum/generate',
        data: {
          'userId': user?.uid,
          'weakAreas': weakAreas,
          'strengthAreas': strengthAreas,
          'overallScore': overallScore,
          'grade': grade,
        },
      );
      return response.data;
    } catch (e) {
      print('Curriculum generation error: $e');
      rethrow;
    }
  }

  // PROGRESS METHODS
  Future<Map<String, dynamic>> recordProgress({
    required String date,
    required int timeSpent,
    required List<String> topicsCompleted,
    required int dayRating,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final response = await _dio.post(
        '$_baseUrl/api/progress/record',
        data: {
          'userId': user?.uid,
          'date': date,
          'timeSpent': timeSpent,
          'topicsCompleted': topicsCompleted,
          'dayRating': dayRating,
        },
      );
      return response.data;
    } catch (e) {
      print('Progress recording error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getProgressSummary({int days = 7}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final response = await _dio.get(
        '$_baseUrl/api/progress/summary/${user?.uid}',
        queryParameters: {'days': days},
      );
      return response.data;
    } catch (e) {
      print('Progress summary error: $e');
      rethrow;
    }
  }
}