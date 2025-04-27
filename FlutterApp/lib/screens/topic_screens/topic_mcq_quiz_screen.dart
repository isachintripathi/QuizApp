import 'package:flutter/material.dart';
import 'dart:async';
import '../../Helper/user_session.dart';
import '../mcq_screens/mcq_review_screen.dart';

// ===============================
// Topic MCQ Quiz Screen (for large test sets)
// ===============================
class TopicMCQQuizScreen extends StatefulWidget {
  final String topic;
  final int timeLimitMinutes;
  final List<Map<String, dynamic>> mcqs;
  final String testTitle;

  const TopicMCQQuizScreen({
    super.key,
    required this.topic,
    required this.timeLimitMinutes,
    required this.mcqs,
    required this.testTitle,
  });

  @override
  TopicMCQQuizScreenState createState() => TopicMCQQuizScreenState();
}

class TopicMCQQuizScreenState extends State<TopicMCQQuizScreen> {
  int currentQuestionIndex = 0;
  late List<int?> userAnswers;
  bool quizCompleted = false;

  // Timer related variables
  int remainingSeconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(widget.mcqs.length, null);

    // Record MCQs in user session for tracking
    for (var mcq in widget.mcqs) {
      if (mcq['id'] != null) {
        UserSession().recordMcq(mcq['id'].toString());
      }
    }

    // Set up the timer
    remainingSeconds = widget.timeLimitMinutes * 60;
    startTimer();
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

  void goToNextQuestion() {
    if (currentQuestionIndex < widget.mcqs.length - 1) {
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
    for (int i = 0; i < widget.mcqs.length; i++) {
      if (userAnswers[i] == widget.mcqs[i]['correctAnswerIndex']) {
        score++;
      }
    }
    return score;
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      userAnswers = List.filled(widget.mcqs.length, null);
      quizCompleted = false;

      // Reset timer
      remainingSeconds = widget.timeLimitMinutes * 60;
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testTitle),
        actions: [
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
        ],
      ),
      body: quizCompleted
          ? _buildResultScreen()
          : _buildQuizScreen(),
    );
  }

  Widget _buildQuizScreen() {
    if (widget.mcqs.isEmpty) {
      return const Center(child: Text('No questions available'));
    }

    Map<String, dynamic> currentQuestion = widget.mcqs[currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Progress
          Row(
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} of ${widget.mcqs.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
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
          ),
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / widget.mcqs.length,
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
                child: Text(currentQuestionIndex < widget.mcqs.length - 1 ? 'Next' : 'Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    int score = calculateScore();
    double percentage = (score / widget.mcqs.length) * 100;

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
            'Your Score: $score out of ${widget.mcqs.length}',
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
                    mcqs: widget.mcqs,
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
