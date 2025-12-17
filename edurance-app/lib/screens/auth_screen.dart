import 'package:flutter/material.dart';
import 'home_screen.dart';


class AuthScreen extends StatefulWidget {
@override
_AuthScreenState createState() => _AuthScreenState();
}


class _AuthScreenState extends State<AuthScreen> {
final _phoneController = TextEditingController();
@override
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: Padding(
padding: EdgeInsets.all(16),
child: Column(
children: [
SizedBox(height: 40),
Text('Edurance AI', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
SizedBox(height: 20),
TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone number')),
SizedBox(height: 12),
ElevatedButton(onPressed: () {
// TODO: trigger firebase phone auth
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
}, child: Text('Get OTP'))
],
),
)
)
);
}
}


// Minimal import to avoid circular reference in scaffolded code
