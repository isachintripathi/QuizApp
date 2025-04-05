import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/screens/chapter_list_screen.dart';
import 'dart:convert';
import 'dart:async';
import 'mcq_screens/mcq_quiz_screen.dart';

const String baseApiUrl = 'http://localhost:8080/api';

// ===============================
// Subject List Screen for Mock Tests
// ===============================
class SubjectListScreen extends StatefulWidget {
  final String exam;
  final String groupId;
  final String subgroupId;
  final String examId;
  final bool isChapterWiseTest;

  const SubjectListScreen({
    super.key,
    required this.exam,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
    this.isChapterWiseTest = false,
  });

  @override
  SubjectListScreenState createState() => SubjectListScreenState();
}

class SubjectListScreenState extends State<SubjectListScreen> {
  List<dynamic> subjectsData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    try {
      final response = await http.get(
          Uri.parse('$baseApiUrl/subjects/${widget.groupId}/${widget.subgroupId}/${widget.examId}')
      );
      print("Url -->  ${Uri.parse('$baseApiUrl/subjects/${widget.groupId}/${widget.subgroupId}/${widget.examId}')}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subjectsData = data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load subjects");
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
        title: widget.isChapterWiseTest
          ? Text('Chapters for Subject')
          : Text('Select Subjects for ${widget.exam}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : subjectsData.isEmpty
          ? const Center(child: Text('No subjects available'))
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: subjectsData.length,
          itemBuilder: (context, index) {
            final subject = subjectsData[index];
            final subjectName = subject['name'] ?? 'Unknown Subject';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  subjectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: widget.isChapterWiseTest
                    ? const Text('Each chapter consists of 20 MCQs')
                    : const Text('20 MCQs • 20 Minutes'),
                trailing: widget.isChapterWiseTest
                    ? const Icon(Icons.quiz)
                    : const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  if (widget.isChapterWiseTest) {
                    // For chapter mock tests, go to the Chapter lists
                    final String subjectId = subject['id']?.toString() ?? subject['name']?.toString() ?? 'unknown';
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterListScreen(
                          exam: widget.exam,
                          groupId: widget.groupId,
                          subgroupId: widget.subgroupId,
                          examId: widget.examId,
                          subjectId: subjectId,
                          subject: subjectName,
                        ),
                      ),
                    );
                  } else {
                    // For mock tests, go directly to the MCQ quiz with 20 questions
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MCQQuizScreen(
                          subject: subjectName,
                          questionCount: 20,
                          timeLimitMinutes: 20,
                        ),
                      ),
                    );
                  }
                }
              ),
            );
          },
        ),
      ),
    );
  }
}