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
      final Uri uri = Uri.parse('$baseApiUrl/chapters/${widget.groupId}/${widget.subgroupId}/${widget.examId}/${widget.subjectId}');
      print("Requesting chapters from: $uri");
      print("Subject ID: ${widget.subjectId}");
      
      final response = await http.get(uri);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        try {
          final dynamic responseData = json.decode(response.body);
          List<dynamic> data;
          
          // Handle different data formats
          if (responseData is List) {
            // Direct list of chapters
            data = responseData;
          } else if (responseData is Map && responseData.containsKey('chapters')) {
            // Object with chapters key
            data = responseData['chapters'];
          } else {
            // Unknown format, convert to a list with a single error item
            data = [{'name': 'Error: unexpected data format'}];
            print("Unexpected data format: $responseData");
          }
          
          print("Parsed ${data.length} chapters");
          setState(() {
            chaptersData = data;
            isLoading = false;
          });
        } catch (e) {
          print("Error parsing chapters data: $e");
          setState(() {
            errorMessage = "Error parsing response data: ${e.toString()}";
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load chapters: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching chapters: $e");
      setState(() {
        errorMessage = "Error: ${e.toString()}\n\nDetails: groupId=${widget.groupId}, subgroupId=${widget.subgroupId}, examId=${widget.examId}, subjectId=${widget.subjectId}";
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
            // Handle both object format and string format for chapter data
            final String chapterName = chapter is String 
                ? chapter  // If the chapter data is directly a string
                : (chapter is Map ? (chapter['name'] ?? 'Unknown Chapter') : 'Unknown Chapter');  // If it's an object with a name field

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