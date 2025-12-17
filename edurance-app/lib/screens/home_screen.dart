import 'package:flutter/material.dart';
import 'learn_screen.dart';
import 'solve_screen.dart';


class HomeScreen extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text('Edurance AI')),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
ElevatedButton.icon(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => LearnScreen())); }, icon: Icon(Icons.school), label: Text('Learn')),
SizedBox(height: 20),
ElevatedButton.icon(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => SolveScreen())); }, icon: Icon(Icons.camera_alt), label: Text('Solve')),
],
),
),
);
}
}


