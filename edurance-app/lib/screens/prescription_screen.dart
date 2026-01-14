import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class PrescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> testResults;
  
  const PrescriptionScreen({Key? key, required this.testResults}) : super(key: key);
  
  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final ApiService _apiService = ApiService();
  bool _isGeneratingCurriculum = false;
  Map<String, dynamic>? _generatedCurriculum;
  
  Future<void> _generateCurriculum() async {
    setState(() => _isGeneratingCurriculum = true);
    
    try {
      // Get prescription data
      final prescription = widget.testResults['prescription'];
      
      // Call curriculum generation API
      final response = await _apiService.generateCurriculum(
        weakAreas: prescription['weakAreas'] ?? [],
        strengthAreas: prescription['strengthAreas'] ?? [],
        overallScore: prescription['overallScore'] ?? 50,
        grade: 8, // TODO: Get from profile
      );
      
      setState(() => _generatedCurriculum = response);
      
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 1-Month Curriculum Generated!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Curriculum generation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isGeneratingCurriculum = false);
    }
  }
  
  void _startLearning() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (route) => false,
    );
  }
  
  Widget _buildScoreCard() {
    final score = widget.testResults['score'] ?? '0.0';
    final correct = widget.testResults['correct'] ?? 0;
    final total = widget.testResults['total'] ?? 0;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Diagnostic Test Score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 20),
            // Score Circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getScoreColor(double.parse(score)),
                  width: 6,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(double.parse(score)),
                      ),
                    ),
                    Text(
                      '$correct/$total correct',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreIndicator('Excellent', 80, double.parse(score)),
                _buildScoreIndicator('Good', 60, double.parse(score)),
                _buildScoreIndicator('Average', 40, double.parse(score)),
                _buildScoreIndicator('Needs Help', 0, double.parse(score)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScoreIndicator(String label, double threshold, double score) {
    final isActive = score >= threshold;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? _getScoreColor(threshold) : Colors.grey.shade200,
            border: Border.all(
              color: isActive ? _getScoreColor(threshold) : Colors.grey.shade300,
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
  
  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
  
  Widget _buildPrescriptionCard() {
    final prescription = widget.testResults['prescription'] ?? {};
    final weakAreas = prescription['weakAreas'] ?? [];
    final strengthAreas = prescription['strengthAreas'] ?? [];
    final recommendation = prescription['recommendation'] ?? '';
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Prescription',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 15),
            Text(
              recommendation,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            SizedBox(height: 20),
            if (weakAreas.isNotEmpty) ...[
              Text(
                '📉 Areas Needing Attention:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: weakAreas.map<Widget>((area) {
                  return Chip(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    label: Text(area),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
            ],
            if (strengthAreas.isNotEmpty) ...[
              Text(
                '📈 Strong Areas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: strengthAreas.map<Widget>((area) {
                  return Chip(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    label: Text(area),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurriculumCard() {
    if (_generatedCurriculum == null) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                'Personalized Curriculum',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Generate a 1-month personalized study plan based on your test results.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isGeneratingCurriculum ? null : _generateCurriculum,
                icon: _isGeneratingCurriculum
                    ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Icon(Icons.auto_awesome),
                label: Text(_isGeneratingCurriculum ? 'Generating...' : 'Generate Curriculum'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final curriculum = _generatedCurriculum!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📅 1-Month Study Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                Chip(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  label: Text('Ready'),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              'Daily focus: ${curriculum['dailyFocus'] ?? 'Mixed topics'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Weak areas coverage: ${curriculum['weakAreaCoverage'] ?? '100%'}',
              style: TextStyle(color: Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              'First Week Preview:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: List.generate(
                curriculum['firstWeek']?.length ?? 0,
                (index) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(curriculum['firstWeek'][index]['topic']),
                  subtitle: Text('${curriculum['firstWeek'][index]['time']} mins'),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _startLearning,
                icon: Icon(Icons.play_arrow),
                label: Text('Start Learning Journey'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Learning Prescription'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildScoreCard(),
              SizedBox(height: 20),
              _buildPrescriptionCard(),
              SizedBox(height: 20),
              _buildCurriculumCard(),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Parent analytics will be sent daily via email. Student progress is tracked automatically.',
                          style: TextStyle(fontSize: 12),
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