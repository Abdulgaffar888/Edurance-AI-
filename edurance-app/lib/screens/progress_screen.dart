import 'package:flutter/material.dart';
import '../screens/auth_screen.dart'; // for SessionManager
import '../services/api_service.dart';
import 'home_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ApiService _apiService = ApiService();

  
  Map<String, dynamic>? _progressData;
  bool _isLoading = true;
  String? _errorMessage;
  
  final List<String> _topics = [
    'electric_current',
    'potential_difference',
    'resistance',
    'ohms_law',
    'ohmic_materials',
    'circuit_components'
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final sessionId = SessionManager.sessionId 
         ?? "guest_${DateTime.now().millisecondsSinceEpoch}";
      SessionManager.sessionId = sessionId;

      final response = await _apiService.getTutorProgress(sessionId);

      
      if (response['success'] == true) {
        setState(() {
          _progressData = response['progress'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load progress';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading progress: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTopicName(String topic) {
    return topic
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Color _getTopicColor(String topic) {
    if (_progressData == null) return Colors.grey;
    
    final topicData = _progressData!['topics'][topic];
    if (topicData == null) return Colors.grey;
    
    if (topicData['mastered'] == true) return Colors.green;
    if (topicData['taught'] == true) return Colors.blue;
    return Colors.grey;
  }

  IconData _getTopicIcon(String topic) {
    if (_progressData == null) return Icons.radio_button_unchecked;
    
    final topicData = _progressData!['topics'][topic];
    if (topicData == null) return Icons.radio_button_unchecked;
    
    if (topicData['mastered'] == true) return Icons.check_circle;
    if (topicData['taught'] == true) return Icons.play_circle_outline;
    return Icons.radio_button_unchecked;
  }

  Widget _buildOverallProgress() {
    if (_progressData == null) return SizedBox();
    
    final overall = _progressData!['overall'];
    final percentage = overall['percentage'] ?? 0;
    final topicsTaught = overall['topics_taught'] ?? 0;
    final topicsMastered = overall['topics_mastered'] ?? 0;
    final totalTopics = overall['total_topics'] ?? 6;

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF3D9974)),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF3D9974)),
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF3D9974),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.school, color: Colors.blue, size: 32),
                    SizedBox(height: 8),
                    Text(
                      '$topicsTaught/$totalTopics',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    Text('Topics Taught', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 32),
                    SizedBox(height: 8),
                    Text(
                      '$topicsMastered/$totalTopics',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    Text('Topics Mastered', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicList() {
    if (_progressData == null) return SizedBox();

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topic Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: const Color(0xFF3D9974)),
            ),
            SizedBox(height: 16),
            ..._topics.map((topic) => _buildTopicItem(topic)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicItem(String topic) {
    final topicData = _progressData!['topics'][topic];
    final isTaught = topicData?['taught'] ?? false;
    final isMastered = topicData?['mastered'] ?? false;
    final score = topicData?['score'];
    
    final color = _getTopicColor(topic);
    final icon = _getTopicIcon(topic);
    
    String statusText = isMastered ? 'Mastered' : (isTaught ? 'In Progress' : 'Not Started');

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTopicName(topic),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(statusText, style: TextStyle(fontSize: 11)),
                      backgroundColor: color.withOpacity(0.2),
                      labelStyle: TextStyle(color: color),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    if (score != null) ...[
                      SizedBox(width: 8),
                      Text(
                        'Diagnostic: $score%',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    if (_progressData == null) return SizedBox();
    
    final recommendations = _progressData!['recommendations'] ?? [];
    if (recommendations.isEmpty) return SizedBox();

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      color: Colors.amber.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
                SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_forward, size: 16, color: Colors.amber.shade700),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: TextStyle(fontSize: 14, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      margin: EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3D9974),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Continue Learning',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 20),
          Text(
            'No Progress Data',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          SizedBox(height: 10),
          Text(
            'Complete a diagnostic test to start tracking progress',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/diagnostic');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D9974),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text('Take Assessment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Dashboard'),
        backgroundColor: const Color(0xFF3D9974),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProgress,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: const Color(0xFF3D9974)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProgress,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _progressData == null
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadProgress,
                      color: const Color(0xFF3D9974),
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildOverallProgress(),
                            _buildTopicList(),
                            _buildRecommendations(),
                            _buildContinueButton(),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
    );
  }
}