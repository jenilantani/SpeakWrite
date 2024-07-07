import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/VoiceDiary.dart';
import 'sign_up.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VoiceDiaryApp()));
    } on FirebaseAuthException catch (e) {
      // Handle login failure
      print('Failed to sign in: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sign in')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/diary_image.png', 
                height: 100,
              ),
              SizedBox(height: 10.0),
              Text(
                'SpeakWrite',
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => _signIn(context),
                child: Text('Login'),
              ),
              SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  // Navigate to SignupPage
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
                },
                child: Text("Don't have an account? Sign up here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}