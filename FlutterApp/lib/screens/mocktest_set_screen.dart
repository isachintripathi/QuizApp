import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/screens/topic_screens/topic_mcq_quiz_screen.dart';
import 'dart:convert';
import '../custom_test_screen.dart';
import '../../Helper/user_session.dart';

const String baseApiUrl = 'http://192.168.1.37:8080/api';

// ===============================
// Mock Test Sets Screen
// ===============================
class MockTestSetsScreen extends StatefulWidget {
  final String exam;
  final String groupId;
  final String subgroupId;
  final String examId;

  const MockTestSetsScreen({
    super.key,
    required this.exam,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
  });

  @override
  MockTestSetsScreenState createState() => MockTestSetsScreenState();
}

class MockTestSetsScreenState extends State<MockTestSetsScreen> {
  final List<Map<String, dynamic>> mockTestSets = [
    {
      'title': 'Set 1 - Easy',
      'subtitle': '50 Questions - 45 Minutes',
      'questions': 50,
      'duration': 45,
      'difficulty': 'EASY',
    },
    {
      'title': 'Set 2 - Medium',
      'subtitle': '100 Questions - 90 Minutes',
      'questions': 100,
      'duration': 90,
      'difficulty': 'MEDIUM',
    },
    {
      'title': 'Set 3 - Hard',
      'subtitle': '75 Questions - 60 Minutes',
      'questions': 75,
      'duration': 60,
      'difficulty': 'HARD',
    },
    {
      'title': 'Quick Test',
      'subtitle': '25 Questions - 20 Minutes',
      'questions': 25,
      'duration': 20,
      'difficulty': 'MIXED',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Sets for ${widget.exam}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomTestScreen(
                      exam: widget.exam,
                      groupId: widget.groupId,
                      subgroupId: widget.subgroupId,
                      examId: widget.examId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text(
                'Create Custom Test',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mockTestSets.length,
              itemBuilder: (context, index) {
                Color setColor;
                switch(mockTestSets[index]['difficulty']) {
                  case 'EASY':
                    setColor = Colors.green;
                    break;
                  case 'MEDIUM':
                    setColor = Colors.orange;
                    break;
                  case 'HARD':
                    setColor = Colors.red;
                    break;
                  default:
                    setColor = Colors.blue;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: setColor.withOpacity(0.2),
                      child: Text(
                        '${mockTestSets[index]['questions']}',
                        style: TextStyle(
                          color: setColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(mockTestSets[index]['title']),
                    subtitle: Text(mockTestSets[index]['subtitle']),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => startTestSet(
                      mockTestSets[index]['questions'],
                      mockTestSets[index]['duration'],
                      mockTestSets[index]['difficulty'],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void startTestSet(int questionCount, int duration, String difficulty) async {
    await loadMockTest(questionCount, duration, difficulty);
  }

  Future<void> loadMockTest(int questionCount, int duration, String difficulty) async {
    try {
      // Show a loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get subjects for this exam
      final subjectsResponse = await http.get(
          Uri.parse('$baseApiUrl/subjects/${widget.groupId}/${widget.subgroupId}/${widget.examId}')
      );

      if (subjectsResponse.statusCode != 200) {
        throw Exception('Failed to load subjects for this exam');
      }

      List<dynamic> subjectsData = json.decode(subjectsResponse.body);
      List<Map<String, dynamic>> allMcqs = [];
      
      // To track CTET Child Development questions separately
      bool hasCtetChildDevelopment = false;
      List<Map<String, dynamic>> ctetChildDevMcqs = [];

      // Get MCQs from each subject
      for (var subject in subjectsData) {
        final subjectName = subject['name'];
        final subjectId = subject['id'];
        final bool isCtetChildDev = subjectName.toLowerCase().contains('child_development') ||
                                   subjectId.toString().toLowerCase().contains('ctet');
        
        if (isCtetChildDev) {
          hasCtetChildDevelopment = true;
        }
        
        final mcqsResponse = await http.get(
            Uri.parse('$baseApiUrl/mcqs/$subjectId')
        );

        if (mcqsResponse.statusCode == 200) {
          final List<dynamic> subjectMcqs = json.decode(mcqsResponse.body);

          // Filter by difficulty if needed
          List<dynamic> filteredMcqs = difficulty == 'MIXED'
              ? subjectMcqs
              : subjectMcqs.where((mcq) =>
          mcq['difficultyLevel'] == difficulty ||
              mcq['difficultyLevel'] == null).toList();

          // Convert to the format we need
          for (var mcq in filteredMcqs) {
            final mcqMap = {
              'id': mcq['id'],
              'question': mcq['question'],
              'options': List<String>.from(mcq['options']),
              'correctAnswerIndex': mcq['correctAnswerIndex'],
              'explanation': mcq['explanation'],
              'difficultyLevel': mcq['difficultyLevel'] ?? 'MEDIUM'
            };
            
            if (isCtetChildDev) {
              ctetChildDevMcqs.add(mcqMap);
            } else {
              allMcqs.add(mcqMap);
            }
          }
        }
      }
      
      // Handle the CTET Child Development questions specially to avoid repetition
      if (hasCtetChildDevelopment && ctetChildDevMcqs.isNotEmpty) {
        print("Processing ${ctetChildDevMcqs.length} CTET Child Development questions");
        
        // If all questions have been seen, reset history
        if (ctetChildDevMcqs.length <= UserSession().recentMcqIds.length) {
          print("All CTET Child Development questions have been seen, clearing history");
          UserSession().clearRecentMcqs();
        }
        
        // Separate questions into seen and unseen
        List<Map<String, dynamic>> unseenQuestions = [];
        List<Map<String, dynamic>> seenQuestions = [];
        
        for (var mcq in ctetChildDevMcqs) {
          if (UserSession().hasSeen(mcq['id'].toString())) {
            seenQuestions.add(mcq);
          } else {
            unseenQuestions.add(mcq);
          }
        }
        
        // Create a list with unseen questions first, then add seen ones if needed
        List<Map<String, dynamic>> orderedMcqs = [...unseenQuestions];
        
        // If we don't have enough unseen questions, add some seen ones
        if (seenQuestions.isNotEmpty) {
          seenQuestions.shuffle(); // Randomize the seen questions
          orderedMcqs.addAll(seenQuestions);
        }
        
        // Add the CTET Child Development questions to the main list
        allMcqs.addAll(orderedMcqs);
      }

      // Pop the loading dialog
      Navigator.pop(context);

      if (allMcqs.isEmpty) {
        showErrorDialog('No MCQs found for the selected difficulty');
        return;
      }

      // Shuffle and limit the questions
      allMcqs.shuffle();
      if (allMcqs.length > questionCount) {
        allMcqs = allMcqs.sublist(0, questionCount);
      }
      
      // Record the questions in the session
      for (var mcq in allMcqs) {
        if (mcq['id'] != null) {
          UserSession().recordMcq(mcq['id'].toString());
        }
      }

      // Navigate to the MCQ quiz with the fetched questions
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TopicMCQQuizScreen(
            topic: '',
            timeLimitMinutes: duration,
            mcqs: allMcqs,
            testTitle: '${widget.exam} - ${mockTestSets.firstWhere((set) =>
            set['questions'] == questionCount &&
                set['duration'] == duration &&
                set['difficulty'] == difficulty
            )['title']}',
          ),
        ),
      );
    } catch (e) {
      // Pop the loading dialog if it's still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      showErrorDialog('Error: ${e.toString()}');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
