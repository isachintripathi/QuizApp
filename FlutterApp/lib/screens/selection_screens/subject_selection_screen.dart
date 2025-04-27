import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../material_screen.dart';
import '../mcq_screens/mcq_quiz_screen.dart';

const String baseApiUrl = 'http://localhost:8080/api';

// ===============================
// 5 Subject Selection Screen
// ===============================
class SubjectSelectionScreen extends StatefulWidget {
  final String topic;
  final bool isMockTest;

  const SubjectSelectionScreen({
    super.key,
    required this.topic,
    this.isMockTest = false,
  });

  @override
  SubjectSelectionScreenState createState() => SubjectSelectionScreenState();
}

class SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  List<String> subjects = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    String apiUrl = '$baseApiUrl/subjects?topic=${widget.topic}';
    
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          subjects = List<String>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load subjects.");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isMockTest
            ? Text('Subject Mock Tests')
            : Text('Subjects for ${widget.topic}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(subjects[index]),
            trailing: widget.isMockTest
                ? const Icon(Icons.quiz)
                : const Icon(Icons.arrow_forward),
            onTap: () {
              if (widget.isMockTest) {
                // For mock tests, go directly to the MCQ quiz with 20 questions
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MCQQuizScreen(
                      topic: widget.topic,
                      subject: subjects[index],
                      questionCount: 20, // 20 MCQs for subject tests
                      timeLimitMinutes: 20, // 20 minutes for subject tests
                    ),
                  ),
                );
              } else {
                // For regular subjects, show material screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MaterialScreen(
                      topic: widget.topic,
                      subject: subjects[index],
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
