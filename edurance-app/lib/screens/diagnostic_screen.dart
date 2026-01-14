import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'prescription_screen.dart'; // We'll create this next

class DiagnosticScreen extends StatefulWidget {
  @override
  _DiagnosticScreenState createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<dynamic> _questions = [];
  Map<int, int> _answers = {}; // questionIndex -> selectedOptionIndex
  int _currentQuestionIndex = 0;
  String? _sessionId;
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _timeLeft = 1800; // 30 minutes in seconds
  
  @override
  void initState() {
    super.initState();
    _startDiagnostic();
    _startTimer();
  }
  
  Future<void> _startDiagnostic() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');
      
      // Get grade from profile (for now, default to 8)
      final response = await _apiService.startDiagnostic(
        userId: user.uid,
        grade: 8, // TODO: Get from user profile
      );
      
      if (response['success'] == true) {
        setState(() {
          _questions = response['questions'];
          _sessionId = response['sessionId'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Start diagnostic error: $e');
      // Fallback to sample questions
      setState(() {
        _questions = _getSampleQuestions();
        _isLoading = false;
      });
    }
  }
  
  void _startTimer() {
    // Update timer every second
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && _timeLeft > 0) {
        setState(() => _timeLeft--);
        _startTimer();
      }
    });
  }
  
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
  
  void _selectAnswer(int optionIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = optionIndex;
    });
  }
  
  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }
  
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }
  
  Future<void> _submitTest() async {
    if (_answers.length < _questions.length) {
      final shouldSubmit = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Incomplete Test'),
          content: Text('You have ${_questions.length - _answers.length} unanswered questions. Submit anyway?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Continue Test'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Submit'),
            ),
          ],
        ),
      );
      
      if (shouldSubmit != true) return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');
      
      // Prepare answers for submission
      final List<Map<String, dynamic>> answerList = [];
      for (int i = 0; i < _questions.length; i++) {
        answerList.add({
          'questionId': _questions[i]['id'],
          'selectedOption': _answers[i] ?? -1, // -1 means unanswered
        });
      }
      
      final response = await _apiService.submitDiagnostic(
        userId: user.uid,
        sessionId: _sessionId ?? 'test_${DateTime.now().millisecondsSinceEpoch}',
        answers: answerList,
      );
      
      if (response['success'] == true) {
        // Navigate to prescription screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PrescriptionScreen(
              testResults: response,
            ),
          ),
        );
      }
    } catch (e) {
      print('Submit error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
  
  Widget _buildQuestionCard() {
    if (_questions.isEmpty) return Center(child: Text('No questions available'));
    
    final question = _questions[_currentQuestionIndex];
    final selectedAnswer = _answers[_currentQuestionIndex];
    
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question number and progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                Chip(
                  backgroundColor: Colors.indigo.withOpacity(0.1),
                  label: Text(
                    _formatTime(_timeLeft),
                    style: TextStyle(
                      color: _timeLeft < 300 ? Colors.red : Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            Divider(height: 30),
            
            // Question text
            Text(
              question['question'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            SizedBox(height: 30),
            
            // Options
            Column(
              children: List.generate(question['options'].length, (index) {
                final option = question['options'][index];
                final isSelected = selectedAnswer == index;
                
                return Card(
                  color: isSelected ? Colors.indigo.withOpacity(0.1) : null,
                  elevation: isSelected ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? Colors.indigo : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Colors.indigo : Colors.grey.shade200,
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(option),
                    onTap: () => _selectAnswer(index),
                  ),
                );
              }),
            ),
            
            SizedBox(height: 20),
            
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                  icon: Icon(Icons.arrow_back),
                  label: Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                  ),
                ),
                
                if (_currentQuestionIndex < _questions.length - 1)
                  ElevatedButton.icon(
                    onPressed: _nextQuestion,
                    icon: Icon(Icons.arrow_forward),
                    label: Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                    ),
                  ),
                
                if (_currentQuestionIndex == _questions.length - 1)
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitTest,
                    icon: _isSubmitting 
                        ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Icon(Icons.check_circle),
                    label: Text(_isSubmitting ? 'Submitting...' : 'Submit Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
              ],
            ),
            
            // Progress indicator
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: (_answers.length / _questions.length),
              backgroundColor: Colors.grey.shade200,
              color: Colors.indigo,
            ),
            SizedBox(height: 10),
            Text(
              'Answered: ${_answers.length}/${_questions.length}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  List<dynamic> _getSampleQuestions() {
    // Fallback if API fails
    return [
      {
        'id': 1,
        'question': 'Sample: What is 5 × 7?',
        'options': ['12', '35', '42', '30'],
        'correctAnswer': 1,
        'explanation': '5 multiplied by 7 equals 35',
        'topic': 'Multiplication',
        'difficulty': 'easy'
      },
      // Add more sample questions as needed
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnostic Test'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Diagnostic Test'),
                  content: Text(
                    'This test helps identify your strengths and weaknesses. '
                    'Answer all questions to get an accurate learning plan.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.indigo))
          : Column(
              children: [
                // Instructions banner
                Container(
                  padding: EdgeInsets.all(12),
                  color: Colors.indigo.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.indigo),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Select the correct answer for each question. You can change answers anytime before submission.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(child: _buildQuestionCard()),
              ],
            ),
    );
  }
}