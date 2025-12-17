import 'package:flutter/material.dart';


class SolveScreen extends StatefulWidget {
@override
_SolveScreenState createState() => _SolveScreenState();
}


class _SolveScreenState extends State<SolveScreen> {
// placeholder for image picker / OCR preview
String _ocrText = '';


_pickImage() async {
// TODO: implement image picker -> upload to /api/solve-image -> show OCR preview
setState(() { _ocrText = 'x^2 + 2x + 1 = 0'; });
}


_solve() async {
// TODO: request hint from backend, show hint, then request full solution on tap
showDialog(context: context, builder: (_) => AlertDialog(content: Text('Hint: Try factoring')));
}


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text('Solve')),
body: Padding(
padding: EdgeInsets.all(16),
child: Column(
children: [
ElevatedButton(onPressed: _pickImage, child: Text('Pick Image')),
SizedBox(height: 12),
Text('OCR preview:'),
SizedBox(height:8),
Text(_ocrText),
SizedBox(height:12),
ElevatedButton(onPressed: _solve, child: Text('Show Hint'))
],
),
),
);
}
}