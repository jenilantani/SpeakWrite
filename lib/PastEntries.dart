import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PastEntriesPage extends StatefulWidget {
  @override
  _PastEntriesPageState createState() => _PastEntriesPageState();
}

class _PastEntriesPageState extends State<PastEntriesPage> {
  late Future<Map<String, List<DocumentSnapshot>>> _entriesByMonthFuture;
  bool _groupedByMood = false;

  @override
  void initState() {
    super.initState();
    _fetchEntriesByMonth();
  }

  void _fetchEntriesByMonth() {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      _entriesByMonthFuture = _getEntriesByMonth(userEmail);
    } else {
    }
  }

  Future<Map<String, List<DocumentSnapshot>>> _getEntriesByMonth(String userEmail) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('stories')
          .where('userName', isEqualTo: userEmail)
          .orderBy('timestamp', descending: true)
          .get();
      Map<String, List<DocumentSnapshot>> entriesByMonth = {};
      querySnapshot.docs.forEach((entry) {
        Timestamp timestamp = entry['timestamp'] as Timestamp;
        String monthYear = '${timestamp.toDate().month}-${timestamp.toDate().year}';

        if (!entriesByMonth.containsKey(monthYear)) {
          entriesByMonth[monthYear] = [];
        }

        entriesByMonth[monthYear]!.add(entry);
      });

      return entriesByMonth;
    } catch (e) {
      throw Exception('Failed to fetch entries: $e');
    }
  }

  Future<void> _deleteEntry(String entryId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this entry?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );


    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('stories').doc(entryId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entry deleted successfully!'),
          ),
        );
        setState(() {
          _fetchEntriesByMonth();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete entry. Please try again.'),
          ),
        );
      }
    }
  }

  void _toggleGroupByMood() {
    setState(() {
      _groupedByMood = !_groupedByMood;
    });
  }

  Color _getColorForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      default:
        return Colors.grey; 
    }
  }

  IconData _getIconForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_neutral;
      default:
        return Icons.sentiment_neutral; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Entries'),
        backgroundColor: Colors.deepPurpleAccent, 
        actions: [
          
        ],
      ),
      body: FutureBuilder<Map<String, List<DocumentSnapshot>>>(
        future: _entriesByMonthFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final entriesByMonth = snapshot.data!;
            return ListView.builder(
              itemCount: entriesByMonth.length,
              itemBuilder: (context, index) {
                final monthYear = entriesByMonth.keys.toList()[index];
                final entries = entriesByMonth[monthYear]!;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.deepPurple, width: 2.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            monthYear,
                            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Divider(),
                        Column(
                          children: entries.map((entry) {
                            final timestamp = entry['timestamp'] as Timestamp;
                            final story = entry['story'] as String;
                            final mood = entry['mood'] as String;
                            final entryId = entry.id;

                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: Card(
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: _getColorForMood(mood), width: 2.0),
                                ),
                                child: ListTile(
                                  title: Text(
                                    story,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Icon(
                                        _getIconForMood(mood),
                                        color: _getColorForMood(mood),
                                      ),
                                      SizedBox(width: 8.0),
                                      Text(
                                        mood,
                                        style: TextStyle(color: _getColorForMood(mood)),
                                      ),
                                      SizedBox(width: 16.0),
                                      Text(
                                        'Saved on: ${timestamp.toDate()}',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteEntry(entryId);
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
