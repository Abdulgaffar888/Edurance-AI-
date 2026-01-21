import 'package:flutter/material.dart';



class DiagnosticScreen extends StatefulWidget {

  @override

  _DiagnosticScreenState createState() => _DiagnosticScreenState();

}



class _DiagnosticScreenState extends State<DiagnosticScreen> {

  // Hardcoded questions based on your 6 topics from agent.js

  final List<Map<String, dynamic>> _questions = [

    {

      'id': '1',

      'question': 'What is an electric cell?',

      'options': [

        'A device that produces electricity',

        'A type of wire',

        'A light source', 

        'A switch'

      ],

      'correctAnswer': 0,

      'topic': 'electric_cell'

    },

    {

      'id': '2',

      'question': 'What does a bulb need to glow?',

      'options': [

        'A complete circuit',

        'Only a battery',

        'Only wires',

        'A switch'

      ],

      'correctAnswer': 0,

      'topic': 'circuit_completion'

    },

    {

      'id': '3',

      'question': 'What is the purpose of a switch?',

      'options': [

        'To make light',

        'To open or close circuit',

        'To store electricity',

        'To measure current'

      ],

      'correctAnswer': 1,

      'topic': 'switch_function'

    },

    {

      'id': '4',

      'question': 'What completes a circuit?',

      'options': [

        'Having a battery',

        'Connecting all components',

        'Having a bulb',

        'Using copper wires'

      ],

      'correctAnswer': 1,

      'topic': 'circuit_basics'

    },

    {

      'id': '5',

      'question': 'What are wires made of?',

      'options': [

        'Insulators',

        'Conductors',

        'Plastic',

        'Wood'

      ],

      'correctAnswer': 1,

      'topic': 'conductors'

    },

    {

      'id': '6',

      'question': 'When is circuit "closed"?',

      'options': [

        'When switch is off',

        'When electricity flows',

        'When bulb is broken',

        'When battery removed'

      ],

      'correctAnswer': 1,

      'topic': 'circuit_types'

    },

  ];



  int _currentQuestionIndex = 0;

  Map<int, int> _answers = {};



  void _selectAnswer(int optionIndex) {

    setState(() {

      _answers[_currentQuestionIndex] = optionIndex;

    });

  }



  void _nextQuestion() {

    if (_currentQuestionIndex < _questions.length - 1) {

      setState(() {

        _currentQuestionIndex++;

      });

    }

  }



  void _previousQuestion() {

    if (_currentQuestionIndex > 0) {

      setState(() {

        _currentQuestionIndex--;

      });

    }

  }



  void _submitTest() {

    // Calculate score

    int correct = 0;

    for (int i = 0; i < _questions.length; i++) {

      if (_answers[i] == _questions[i]['correctAnswer']) {

        correct++;

      }

    }

    

    final score = ((correct / _questions.length) * 100).round();

    

    // Navigate to HomeScreen for now

    Navigator.pushReplacementNamed(context, '/home');

    

    // Show result

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text('You scored $score%! Starting AI tutoring...'),

        duration: Duration(seconds: 3),

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    final question = _questions[_currentQuestionIndex];

    final selectedAnswer = _answers[_currentQuestionIndex];



    return Scaffold(

      appBar: AppBar(

        title: Text('Assessment Test'),

        backgroundColor: Colors.indigo,

      ),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // Question counter

            Text(

              'Question ${_currentQuestionIndex + 1}/${_questions.length}',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),

            ),

            

            SizedBox(height: 20),

            Divider(),

            SizedBox(height: 20),

            

            // Question

            Text(

              question['question'],

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),

            ),

            

            SizedBox(height: 30),

            

            // Options

            Column(

              children: List.generate(4, (index) {

                final isSelected = selectedAnswer == index;

                return Container(

                  margin: EdgeInsets.only(bottom: 10),

                  child: Material(

                    color: isSelected ? Colors.indigo.withOpacity(0.1) : Colors.transparent,

                    borderRadius: BorderRadius.circular(10),

                    child: InkWell(

                      onTap: () => _selectAnswer(index),

                      borderRadius: BorderRadius.circular(10),

                      child: Container(

                        padding: EdgeInsets.all(16),

                        decoration: BoxDecoration(

                          borderRadius: BorderRadius.circular(10),

                          border: Border.all(

                            color: isSelected ? Colors.indigo : Colors.grey.shade300,

                            width: isSelected ? 2 : 1,

                          ),

                        ),

                        child: Row(

                          children: [

                            CircleAvatar(

                              backgroundColor: isSelected ? Colors.indigo : Colors.grey.shade200,

                              child: Text(

                                String.fromCharCode(65 + index), // A, B, C, D

                                style: TextStyle(

                                  color: isSelected ? Colors.white : Colors.black,

                                  fontWeight: FontWeight.bold,

                                ),

                              ),

                            ),

                            SizedBox(width: 16),

                            Expanded(

                              child: Text(

                                question['options'][index],

                                style: TextStyle(fontSize: 16),

                              ),

                            ),

                          ],

                        ),

                      ),

                    ),

                  ),

                );

              }),

            ),

            

            SizedBox(height: 40),

            

            // Navigation buttons

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                ElevatedButton(

                  onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,

                  child: Text('Previous'),

                ),

                

                if (_currentQuestionIndex < _questions.length - 1)

                  ElevatedButton(

                    onPressed: _nextQuestion,

                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),

                    child: Text('Next'),

                  ),

                

                if (_currentQuestionIndex == _questions.length - 1)

                  ElevatedButton(

                    onPressed: _submitTest,

                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

                    child: Text('Submit Test'),

                  ),

              ],

            ),

            

            SizedBox(height: 20),

            

            // Progress

            LinearProgressIndicator(

              value: (_answers.length / _questions.length),

              backgroundColor: Colors.grey.shade200,

              color: Colors.indigo,

            ),

            SizedBox(height: 10),

            Text(

              '${_answers.length}/${_questions.length} answered',

              style: TextStyle(color: Colors.grey),

            ),

          ],

        ),

      ),

    );

  }  
}