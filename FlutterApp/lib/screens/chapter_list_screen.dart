import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'mcq_screens/mcq_quiz_screen.dart';

const String baseApiUrl = 'http://localhost:8080/api';

// ===============================
// Chapter List Screen for Mock Tests
// ===============================
class ChapterListScreen extends StatefulWidget {
  final String exam;
  final String groupId;
  final String subgroupId;
  final String examId;
  final String subjectId;
  final String subject;

  const ChapterListScreen({
    super.key,
    required this.exam,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
    required this.subjectId,
    required this.subject,
  });

  @override
  ChapterListScreenState createState() => ChapterListScreenState();
}

class ChapterListScreenState extends State<ChapterListScreen> {
  List<dynamic> chaptersData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchChapters();
  }

  Future<void> fetchChapters() async {
    try {
      final response = await http.get(
          Uri.parse('$baseApiUrl/chapters/${widget.groupId}/${widget.subgroupId}/${widget.examId}/${widget.subjectId}')
      );
      print("Url -->  ${Uri.parse('$baseApiUrl/chapters/${widget.groupId}/${widget.subgroupId}/${widget.examId}/${widget.subjectId}')}");
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          chaptersData = data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load chapters");
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
        title: Text('Select Chapters for ${widget.subject}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : chaptersData.isEmpty
          ? const Center(child: Text('No chapters available'))
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: chaptersData.length,
          itemBuilder: (context, index) {
            final chapter = chaptersData[index];
            final chapterName = chapter['name'] ?? 'Unknown Chapter';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  chapterName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text('20 MCQs • 20 Minutes'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MCQQuizScreen(
                        subject: chapterName,
                        questionCount: 20,
                        timeLimitMinutes: 20,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}