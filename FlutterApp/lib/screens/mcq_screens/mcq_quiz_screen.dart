import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'mcq_review_screen.dart';
import 'dart:convert';
import 'dart:async';
import '../../Helper/user_session.dart';
import '../../utils/subject_id_mapper.dart';

const String baseApiUrl = 'http://192.168.1.37:8080/api';
// ===============================
// 7 MCQ Quiz Screen
// ===============================
class MCQQuizScreen extends StatefulWidget {
  final String topic;
  final String subject;
  final int questionCount;
  final int timeLimitMinutes;

  const MCQQuizScreen({
    super.key,
    this.topic = "",
    required this.subject,
    this.questionCount = 10,
    this.timeLimitMinutes = 0,
  });

  @override
  MCQQuizScreenState createState() => MCQQuizScreenState();
}

class MCQQuizScreenState extends State<MCQQuizScreen> {
  List<Map<String, dynamic>> mcqs = [];
  bool isLoading = true;
  String? errorMessage;
  int currentQuestionIndex = 0;
  List<int?> userAnswers = [];
  bool quizCompleted = false;

  // Timer related variables
  bool hasTimeLimit = false;
  int remainingSeconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchMCQs();

    // Set up the timer if there's a time limit
    if (widget.timeLimitMinutes > 0) {
      hasTimeLimit = true;
      remainingSeconds = widget.timeLimitMinutes * 60;
      startTimer();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          // Time's up
          timer.cancel();
          if (!quizCompleted) {
            quizCompleted = true;
            // Show a dialog informing the user that time is up
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Time\'s Up!'),
                content: const Text('Your time has expired. Let\'s see your results.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('View Results'),
                  ),
                ],
              ),
            );
          }
        }
      });
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> fetchMCQs() async {
    try {
      // Convert subject name to subjectId using the mapper
      String subjectId = SubjectIdMapper.getSubjectId(widget.subject);
      
      // Debug: Print subject and mapped ID
      print("Original subject: '${widget.subject}'");
      print("Mapped to subjectId: '$subjectId'");
      
      // Use the MCQ endpoint with the correct subjectId
      final Uri uri = Uri.parse('$baseApiUrl/mcqs/$subjectId');
      print("Requesting MCQs from: $uri");
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> mcqData = json.decode(response.body);

        // Check if we're dealing with CTET Child Development questions
        bool isCtetChildDevelopment = widget.subject.toLowerCase().contains('child_development') || 
                                     (mcqData.isNotEmpty && mcqData[0]['id'].toString().contains('ctet'));

        // If this is CTET Child Development and we have fewer than 20 questions
        // we want to ensure we use all available questions without repetition
        if (isCtetChildDevelopment) {
          // For CTET Child Development, use all 20 questions without repetition
          print("Handling CTET Child Development questions (${mcqData.length} total questions)");
          
          // If all 20 questions have been seen, clear history to start fresh
          if (mcqData.length <= UserSession().recentMcqIds.length) {
            print("All questions have been seen, clearing history");
            UserSession().clearRecentMcqs();
          }
          
          // First, separate questions into seen and unseen
          List<dynamic> unseenQuestions = [];
          List<dynamic> seenQuestions = [];
          
          for (var mcq in mcqData) {
            if (UserSession().hasSeen(mcq['id'].toString())) {
              seenQuestions.add(mcq);
            } else {
              unseenQuestions.add(mcq);
            }
          }
          
          print("Found ${unseenQuestions.length} unseen questions and ${seenQuestions.length} seen questions");
          
          // Create a list with unseen questions first, then add seen ones if needed
          List<dynamic> orderedMcqs = [...unseenQuestions];
          
          // If we don't have enough unseen questions, add some seen ones
          if (orderedMcqs.length < widget.questionCount && seenQuestions.isNotEmpty) {
            // Shuffle seen questions to avoid repetitive patterns
            seenQuestions.shuffle();
            orderedMcqs.addAll(seenQuestions);
          }
          
          // Limit to requested question count
          if (orderedMcqs.length > widget.questionCount && widget.questionCount > 0) {
            orderedMcqs = orderedMcqs.sublist(0, widget.questionCount);
          }
          
          mcqData = orderedMcqs;
        } else {
          // For other subjects, use the original logic with shuffling
          // If we have more MCQs than requested, take a random subset
          if (mcqData.length > widget.questionCount && widget.questionCount > 0) {
            mcqData.shuffle();
            mcqData = mcqData.sublist(0, widget.questionCount);
          }
        }

        setState(() {
          mcqs = mcqData.map((mcq) => {
            'id': mcq['id'],
            'question': mcq['question'],
            'options': List<String>.from(mcq['options']),
            'correctAnswerIndex': mcq['correctAnswerIndex'],
            'explanation': mcq['explanation'],
            'difficultyLevel': mcq['difficultyLevel'] ?? 'MEDIUM'
          }).toList();

          userAnswers = List.filled(mcqs.length, null);
          isLoading = false;
        });

        // Record these MCQs in the user session
        for (var mcq in mcqs) {
          if (mcq['id'] != null) {
            UserSession().recordMcq(mcq['id'].toString());
          }
        }
      } else {
        throw Exception("Failed to load MCQs.");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < mcqs.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        quizCompleted = true;
        timer?.cancel(); // Stop the timer when quiz is completed
      });
    }
  }

  void goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  int calculateScore() {
    int score = 0;
    for (int i = 0; i < mcqs.length; i++) {
      if (userAnswers[i] == mcqs[i]['correctAnswerIndex']) {
        score++;
      }
    }
    return score;
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      userAnswers = List.filled(mcqs.length, null);
      quizCompleted = false;

      // Reset timer if there's a time limit
      if (hasTimeLimit) {
        remainingSeconds = widget.timeLimitMinutes * 60;
        startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String quizTitle = widget.subject == 'Full Test'
        ? 'Full Mock Test'
        : 'MCQ Quiz - ${widget.subject}';

    return Scaffold(
      appBar: AppBar(
        title: Text(quizTitle),
        actions: hasTimeLimit ? [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                formatTime(remainingSeconds),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ] : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : quizCompleted
          ? _buildResultScreen()
          : _buildQuizScreen(),
    );
  }

  Widget _buildQuizScreen() {
    if (mcqs.isEmpty) {
      return const Center(child: Text('No MCQs available'));
    }

    Map<String, dynamic> currentQuestion = mcqs[currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Progress
          Row(
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} of ${mcqs.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (hasTimeLimit) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: remainingSeconds < 60
                        ? Colors.red
                        : remainingSeconds < 300
                        ? Colors.orange
                        : Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    formatTime(remainingSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / mcqs.length,
            minHeight: 10,
          ),
          const SizedBox(height: 24),

          // Question
          Text(
            currentQuestion['question'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Options
          ...List.generate(
            currentQuestion['options'].length,
                (index) => RadioListTile<int>(
              title: Text(currentQuestion['options'][index]),
              value: index,
              groupValue: userAnswers[currentQuestionIndex],
              onChanged: (value) {
                setState(() {
                  userAnswers[currentQuestionIndex] = value;
                });
              },
            ),
          ),

          const Spacer(),

          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: currentQuestionIndex > 0 ? goToPreviousQuestion : null,
                child: const Text('Previous'),
              ),
              ElevatedButton(
                onPressed: () => goToNextQuestion(),
                child: Text(currentQuestionIndex < mcqs.length - 1 ? 'Next' : 'Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    int score = calculateScore();
    double percentage = (score / mcqs.length) * 100;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Quiz Completed!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Score: $score out of ${mcqs.length}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Percentage: ${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 24),

          // Performance message
          Text(
            percentage >= 70
                ? 'Great job! You did well!'
                : percentage >= 40
                ? 'Good effort! Keep practicing.'
                : 'Keep studying! You\'ll do better next time.',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: restartQuiz,
            child: const Text('Restart Quiz', style: TextStyle(fontSize: 16)),
          ),

          const SizedBox(height: 16),

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MCQReviewScreen(
                    mcqs: mcqs,
                    userAnswers: userAnswers,
                  ),
                ),
              );
            },
            child: const Text('Review Answers', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
