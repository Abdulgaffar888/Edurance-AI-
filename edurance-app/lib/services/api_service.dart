import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://edurance-backend.onrender.com';

  // ========== TUTOR DIAGNOSTIC ==========

  Future<Map<String, dynamic>> startTutorDiagnostic() async {
    try {
      print('📞 Calling: $_baseUrl/api/tutor/diagnostic/start');

      final response = await _dio.post(
        '$_baseUrl/api/tutor/diagnostic/start',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('✅ Response received: ${response.statusCode}');
      return response.data;
    } catch (e) {
      print('❌ API Error: $e');
      // Fallback: guaranteed local questions
      return {
        'success': true,
        'questions': _getGuaranteedQuestions(),
        'total_questions': 6,
      };
    }
  }

  Future<Map<String, dynamic>> submitTutorDiagnostic({
    required String sessionId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      print('📞 Submitting diagnostic for session: $sessionId');

      final response = await _dio.post(
        '$_baseUrl/api/tutor/diagnostic/submit',
        data: {
          'session_id': sessionId,
          'answers': answers,
        },
      );

      return response.data;
    } catch (e) {
      print('❌ Submit error: $e');
      // Fallback: local scoring
      return _calculateLocalResults(answers);
    }
  }

  // ========== TUTOR PROGRESS ==========

  Future<Map<String, dynamic>> getTutorProgress(String sessionId) async {
    try {
      print('📞 Getting progress for: $sessionId');

      final response = await _dio.get(
        '$_baseUrl/api/tutor/progress/$sessionId',
      );

      return response.data;
    } catch (e) {
      print('❌ Progress error: $e');
      // Fallback: mock progress
      return _getMockProgressData();
    }
  }

  // ========== GUARANTEED QUESTIONS ==========

  List<Map<String, dynamic>> _getGuaranteedQuestions() {
    return [
      {
        'id': 'q1',
        'question': 'What is electric current?',
        'options': ['Flow of charge', 'Electrical pressure', 'Resistance', 'Power'],
        'correctAnswer': 0,
        'topic': 'electric_current',
      },
      {
        'id': 'q2',
        'question': 'What measures electric current?',
        'options': ['Volt', 'Ampere', 'Ohm', 'Watt'],
        'correctAnswer': 1,
        'topic': 'electric_current',
      },
      {
        'id': 'q3',
        'question': 'What is potential difference?',
        'options': ['Current', 'Voltage', 'Resistance', 'Power'],
        'correctAnswer': 1,
        'topic': 'potential_difference',
      },
      {
        'id': 'q4',
        'question': 'What provides voltage in a circuit?',
        'options': ['Bulb', 'Switch', 'Battery', 'Wire'],
        'correctAnswer': 2,
        'topic': 'potential_difference',
      },
      {
        'id': 'q5',
        'question': 'What does resistance do?',
        'options': ['Creates current', 'Opposes current', 'Increases voltage', 'Stores energy'],
        'correctAnswer': 1,
        'topic': 'resistance',
      },
      {
        'id': 'q6',
        'question': 'What measures resistance?',
        'options': ['Ampere', 'Volt', 'Ohm', 'Watt'],
        'correctAnswer': 2,
        'topic': 'resistance',
      },
    ];
  }

  Map<String, dynamic> _calculateLocalResults(List<Map<String, dynamic>> answers) {
    final questions = _getGuaranteedQuestions();
    int correct = 0;

    for (var answer in answers) {
      final questionId = answer['questionId'];
      final selectedAnswer = answer['selectedAnswer'];

      for (var q in questions) {
        if (q['id'] == questionId && q['correctAnswer'] == selectedAnswer) {
          correct++;
          break;
        }
      }
    }

    final score = ((correct / questions.length) * 100).round();

    return {
      'success': true,
      'message': 'You scored $score% ($correct/${questions.length} correct)',
      'score': score,
      'correct': correct,
      'total': questions.length,
    };
  }

  Map<String, dynamic> _getMockProgressData() {
    return {
      'success': true,
      'progress': {
        'topics': {
          'electric_current': {'taught': true, 'mastered': true, 'score': 85},
          'potential_difference': {'taught': true, 'mastered': false, 'score': 60},
          'resistance': {'taught': false, 'mastered': false, 'score': 40},
          'ohms_law': {'taught': false, 'mastered': false, 'score': 30},
          'ohmic_materials': {'taught': false, 'mastered': false, 'score': 20},
          'circuit_components': {'taught': false, 'mastered': false, 'score': 10},
        },
        'overall': {
          'topics_taught': 2,
          'topics_mastered': 1,
          'total_topics': 6,
          'percentage': 33
        },
        'recommendations': ['Practice resistance and Ohm\'s Law']
      }
    };
  }
}
