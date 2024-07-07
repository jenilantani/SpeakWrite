import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'PastEntries.dart';

void main() {
  runApp(VoiceDiaryApp());
}

class VoiceDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeakWrite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VoiceDiaryScreen(),
    );
  }
}

class VoiceDiaryScreen extends StatefulWidget {
  @override
  _VoiceDiaryScreenState createState() => _VoiceDiaryScreenState();
}

class _VoiceDiaryScreenState extends State<VoiceDiaryScreen> {
  stt.SpeechToText? _speechToText;
  bool _isListening = false;
  String _text = '';
  String _mood = ''; 
  TextEditingController _controller = TextEditingController();

  _VoiceDiaryScreenState() {
    _speechToText = stt.SpeechToText();
  }
@override
void initState() {
  super.initState();
  _controller.addListener(_updateTextFromInput);
}

void _updateTextFromInput() {
  setState(() {
    _text = _controller.text;
  });
}

  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text('SpeakWrite'),
    backgroundColor: Colors.deepPurpleAccent,
    actions: [
      IconButton(
        icon: Icon(Icons.logout),
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
        tooltip: "Sign Out"
      ),
      IconButton(
        icon: Icon(Icons.history),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PastEntriesPage()));
        },
        tooltip: 'Past Stories'
      ),
    ],
  ),
  backgroundColor: Color.fromRGBO(129, 83, 230, 0.1),
  body: Padding(
    padding: EdgeInsets.all(20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              _text,
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ),
        SizedBox(height: 20.0),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Write something...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12.0),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _controller.clear();
                  _text = '';
                });
              },
            ),
            IconButton(
              icon: Icon(_isListening ? Icons.mic_none : Icons.mic),
              onPressed: () {
                _toggleListening();
              },
            ),
          ],
        ),
        SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            _promptForMood();
          },
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 178, 152, 249))),
          child: Text(_mood.isEmpty ? 'Select Mood' : 'Selected Mood: $_mood',style: TextStyle(
      color: const Color.fromARGB(255, 0, 0, 0), 
    ),),
        ),
        SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            _saveEntry(_text);
          },
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 178, 152, 249))),
          child: Text('Save Entry',style: TextStyle(
      color: const Color.fromARGB(255, 0, 0, 0), 
    ),),
          
        ),
      ],
    ),
  ),
);

  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      bool available = await _speechToText!.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (error) => print('onError: $error'),
      );

      if (available) {
        _speechToText!.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
              _controller.text = result.recognizedWords;
            });
          },
          listenFor: Duration(seconds: 60),
        );
        setState(() {
          _isListening = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can speak for up to 60 seconds.'),
          ),
        );
      }
    } else {
      _speechToText!.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _promptForMood() async {
    String? selectedMood = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Mood'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'Happy');
                },
                child: Text('Happy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'Sad');
                },
                child: Text('Sad'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'Angry');
                },
                child: Text('Angry'),
              ),
            ],
          ),
        );
      },
    );

    if (selectedMood != null) {
      setState(() {
        _mood = selectedMood;
      });
    }
  }

  Future<void> _saveEntry(String text) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userEmail = user.email ?? ''; 
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        await firestore.collection('stories').add({
          'userName': userEmail,
          'story': text,
          'mood': _mood,
          'timestamp': DateTime.now(), 
        });

        setState(() {
          _text = ''; 
          _controller.clear(); 
          _mood = ''; 
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entry saved successfully!'),
          ),
        );
      } else {
        print('User not authenticated');
      }
    } catch (e) {
      print('Error saving entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving entry. Please try again.'),
        ),
      );
    }
  }
}
