import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'diagnostic_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _grade = '8';
  String _school = '';
  String _prevExamPercentage = '';
  String _parentPhone = '';
  
  bool _isLoading = false;
  
  final List<String> _grades = ['4', '5', '6', '7', '8', '9', '10', '11', '12'];
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      final response = await _apiService.saveProfile(
        userId: user.uid,
        grade: int.parse(_grade),
        school: _school,
        prevExamPercentage: _prevExamPercentage.isNotEmpty 
            ? double.parse(_prevExamPercentage) 
            : null,
        parentPhone: _parentPhone,
      );
      
      if (response['success'] == true) {
        // Navigate to diagnostic test
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DiagnosticScreen()),
        );
      } else {
        throw Exception('Failed to save profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Your Profile'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _grade,
                decoration: InputDecoration(
                  labelText: 'Grade Level',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                items: _grades.map((String grade) {
                  return DropdownMenuItem<String>(
                    value: grade,
                    child: Text('Grade $grade'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _grade = newValue!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your grade';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'School Name (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                onChanged: (value) => _school = value,
              ),
              
              SizedBox(height: 20),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Last Exam Percentage (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assessment),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _prevExamPercentage = value,
                validator: (value) {
                  if (value!.isNotEmpty) {
                    final perc = double.tryParse(value);
                    if (perc == null || perc < 0 || perc > 100) {
                      return 'Enter valid percentage (0-100)';
                    }
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Parent Phone Number*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: '+91 9876543210',
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => _parentPhone = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Parent phone is required';
                  }
                  if (value.length < 10) {
                    return 'Enter valid phone number';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Continue to Diagnostic Test',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              
              SizedBox(height: 20),
              
              Text(
                'Note: This information helps create your personalized learning plan. '
                'Parent phone is for progress updates.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}