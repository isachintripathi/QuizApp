import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'main.dart'; // Import for UserSession and TopicMCQQuizScreen

class CustomTestScreen extends StatefulWidget {
  final String exam;
  final String groupId;
  final String subgroupId;
  final String examId;

  const CustomTestScreen({
    super.key,
    required this.exam,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
  });

  @override
  CustomTestScreenState createState() => CustomTestScreenState();
}

class CustomTestScreenState extends State<CustomTestScreen> {
  int questionCount = 50;
  int easyPercentage = 30;
  int mediumPercentage = 50;
  int hardPercentage = 20;
  int durationMinutes = 45;
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    // Calculate the number of questions for each difficulty
    final int easyQuestions = (questionCount * easyPercentage / 100).round();
    final int mediumQuestions = (questionCount * mediumPercentage / 100).round();
    final int hardQuestions = questionCount - easyQuestions - mediumQuestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Test'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Number of Questions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Slider(
                                value: questionCount.toDouble(),
                                min: 10,
                                max: 100,
                                divisions: 9,
                                label: questionCount.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    questionCount = value.round();
                                  });
                                },
                              ),
                              Center(
                                child: Text(
                                  '$questionCount Questions',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Test Duration',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Slider(
                                value: durationMinutes.toDouble(),
                                min: 10,
                                max: 120,
                                divisions: 11,
                                label: durationMinutes.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    durationMinutes = value.round();
                                  });
                                },
                              ),
                              Center(
                                child: Text(
                                  '$durationMinutes Minutes',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Difficulty Distribution',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDifficultySlider(
                                'Easy',
                                easyPercentage,
                                Colors.green,
                                (value) {
                                  setState(() {
                                    easyPercentage = value.round();
                                    // Ensure percentages always add up to 100%
                                    _adjustOtherPercentages('easy');
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              _buildDifficultySlider(
                                'Medium',
                                mediumPercentage,
                                Colors.orange,
                                (value) {
                                  setState(() {
                                    mediumPercentage = value.round();
                                    // Ensure percentages always add up to 100%
                                    _adjustOtherPercentages('medium');
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              _buildDifficultySlider(
                                'Hard',
                                hardPercentage,
                                Colors.red,
                                (value) {
                                  setState(() {
                                    hardPercentage = value.round();
                                    // Ensure percentages always add up to 100%
                                    _adjustOtherPercentages('hard');
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildQuestionCountChip('Easy', easyQuestions, Colors.green),
                                  _buildQuestionCountChip('Medium', mediumQuestions, Colors.orange),
                                  _buildQuestionCountChip('Hard', hardQuestions, Colors.red),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _startCustomTest(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Start Custom Test',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDifficultySlider(String label, int value, Color color, Function(double) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            '$value%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCountChip(String label, int count, Color color) {
    return Chip(
      label: Text(
        '$count $label',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
    );
  }

  void _adjustOtherPercentages(String changedDifficulty) {
    // Ensure percentages always add up to 100%
    final int total = easyPercentage + mediumPercentage + hardPercentage;
    
    if (total != 100) {
      final int excess = total - 100;
      
      if (changedDifficulty == 'easy') {
        if (mediumPercentage >= excess) {
          mediumPercentage -= excess;
        } else {
          hardPercentage -= excess;
        }
      } else if (changedDifficulty == 'medium') {
        if (easyPercentage >= excess) {
          easyPercentage -= excess;
        } else {
          hardPercentage -= excess;
        }
      } else {
        if (mediumPercentage >= excess) {
          mediumPercentage -= excess;
        } else {
          easyPercentage -= excess;
        }
      }
    }
  }

  void _startCustomTest() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      // Get subjects to gather MCQs from
      final subjectsResponse = await http.get(
        Uri.parse('$BASE_API_URL/subjects/${widget.groupId}/${widget.subgroupId}/${widget.examId}')
      );
      
      if (subjectsResponse.statusCode != 200) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load subjects';
        });
        return;
      }
      
      final List<dynamic> subjectsData = json.decode(subjectsResponse.body);
      Map<String, List<dynamic>> mcqsByDifficulty = {
        'EASY': [],
        'MEDIUM': [],
        'HARD': [],
      };
      
      // Get MCQs from each subject and categorize by difficulty
      for (var subject in subjectsData) {
        final subjectName = subject['name'];
        final mcqsResponse = await http.get(
          Uri.parse('$BASE_API_URL/mcqs/$subjectName')
        );
        
        if (mcqsResponse.statusCode == 200) {
          final List<dynamic> subjectMcqs = json.decode(mcqsResponse.body);
          
          for (var mcq in subjectMcqs) {
            String difficulty = mcq['difficultyLevel'] ?? 'MEDIUM';
            mcqsByDifficulty[difficulty]?.add(mcq);
          }
        }
      }
      
      // Calculate required number of questions by difficulty
      final int easyQs = (questionCount * easyPercentage / 100).round();
      final int mediumQs = (questionCount * mediumPercentage / 100).round();
      final int hardQs = questionCount - easyQs - mediumQs;
      
      // Shuffle and select the required number of questions for each difficulty
      mcqsByDifficulty.forEach((key, value) {
        value.shuffle();
      });
      
      // Fill in missing questions from other difficulty levels if needed
      List<dynamic> easyMcqs = _getQuestions(mcqsByDifficulty, 'EASY', easyQs);
      List<dynamic> mediumMcqs = _getQuestions(mcqsByDifficulty, 'MEDIUM', mediumQs);
      List<dynamic> hardMcqs = _getQuestions(mcqsByDifficulty, 'HARD', hardQs);
      
      List<Map<String, dynamic>> finalMcqs = [];
      
      // Transform MCQ format
      for (var mcq in [...easyMcqs, ...mediumMcqs, ...hardMcqs]) {
        finalMcqs.add({
          'id': mcq['id'],
          'question': mcq['question'],
          'options': List<String>.from(mcq['options']),
          'correctAnswerIndex': mcq['correctAnswerIndex'],
          'explanation': mcq['explanation'],
          'difficultyLevel': mcq['difficultyLevel'] ?? 'MEDIUM'
        });
      }
      
      // Shuffle final questions and navigate to quiz screen
      finalMcqs.shuffle();
      
      setState(() {
        isLoading = false;
      });
      
      if (finalMcqs.isEmpty) {
        setState(() {
          errorMessage = 'No MCQs available for this test';
        });
        return;
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TopicMCQQuizScreen(
            topic: '',
            timeLimitMinutes: durationMinutes,
            mcqs: finalMcqs,
            testTitle: 'Custom Test - ${widget.exam}',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }
  
  List<dynamic> _getQuestions(Map<String, List<dynamic>> mcqsByDifficulty, String difficulty, int count) {
    List<dynamic> availableMcqs = mcqsByDifficulty[difficulty] ?? [];
    if (availableMcqs.length >= count) {
      return availableMcqs.sublist(0, count);
    }
    
    // If not enough questions of requested difficulty, borrow from others
    List<dynamic> result = [...availableMcqs];
    int remaining = count - result.length;
    
    if (remaining > 0) {
      List<String> otherDifficulties = ['EASY', 'MEDIUM', 'HARD']..remove(difficulty);
      
      for (String otherDiff in otherDifficulties) {
        List<dynamic> otherMcqs = mcqsByDifficulty[otherDiff] ?? [];
        if (otherMcqs.isNotEmpty) {
          int borrowCount = otherMcqs.length > remaining ? remaining : otherMcqs.length;
          result.addAll(otherMcqs.sublist(0, borrowCount));
          remaining -= borrowCount;
          
          // Remove borrowed questions to avoid duplication
          mcqsByDifficulty[otherDiff] = otherMcqs.sublist(borrowCount);
          
          if (remaining <= 0) break;
        }
      }
    }
    
    return result;
  }
}

// Helper class for math operations
class Math {
  static int max(int a, int b) => a > b ? a : b;
} 