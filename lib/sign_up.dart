import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/VoiceDiary.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signUp(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navigate to VoiceDiary.dart upon successful signup
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VoiceDiaryApp()));
    } on FirebaseAuthException catch (e) {
      // Handle signup failure
      print('Failed to sign up: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sign up')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Please Sign Up!')),
      body: Center( // Center the content vertically
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/diary_image.png', // Adjust the path according to your project structure
                height: 100, // Adjust height as needed
              ),
              SizedBox(height: 10.0),
              Text(
                'SpeakWrite',
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.4, // Adjust width as needed
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                width: MediaQuery.of(context).size.width * 0.4, // Adjust width as needed
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => _signUp(context),
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}