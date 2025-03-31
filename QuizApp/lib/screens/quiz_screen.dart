import 'package:flutter/material.dart';
import '../models/mcq_model.dart';
import '../models/user_model.dart';
import '../models/quiz_result_model.dart';
import '../services/report_service.dart';
import '../screens/quiz_results_screen.dart';
import '../screens/user_details_screen.dart';

class QuizScreen extends StatefulWidget {
  final String quizType; // "Subject" or "Set"
  final String quizName; // Subject name or Set name
  final List<MCQ> questions;

  const QuizScreen({
    Key? key,
    required this.quizType,
    required this.quizName,
    required this.questions,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  List<int> _userAnswers = [];
  bool _isQuizStarted = false;
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userAnswers = List.filled(widget.questions.length, -1);
    _showUserDetailsScreen();
  }

  void _showUserDetailsScreen() async {
    final user = await UserDetailsScreen.show(
      context: context,
      quizType: widget.quizType,
      quizName: widget.quizName,
    );
    
    if (user != null) {
      setState(() {
        _currentUser = user;
        _isQuizStarted = true;
      });
    } else {
      // User cancelled, go back
      Navigator.of(context).pop();
    }
  }

  void _answerQuestion(int selectedIndex) {
    setState(() {
      _userAnswers[_currentIndex] = selectedIndex;
    });
  }

  void _goToPreviousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _goToNextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  bool _canSubmitQuiz() {
    return !_userAnswers.contains(-1);
  }

  Future<void> _submitQuiz() async {
    if (!_canSubmitQuiz()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all questions before submitting.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int correctCount = 0;
      List<QuestionResult> questionResults = [];

      // Calculate results
      for (int i = 0; i < widget.questions.length; i++) {
        MCQ question = widget.questions[i];
        int userAnswerIndex = _userAnswers[i];
        bool isCorrect = userAnswerIndex == question.correctAnswerIndex;
        
        if (isCorrect) {
          correctCount++;
        }
        
        questionResults.add(
          QuestionResult(
            question: question.question,
            userAnswer: question.options[userAnswerIndex],
            correctAnswer: question.options[question.correctAnswerIndex],
            isCorrect: isCorrect,
          ),
        );
      }
      
      // Create quiz result
      final quizResult = QuizResult(
        user: _currentUser!,
        quizType: widget.quizType,
        quizName: widget.quizName,
        totalQuestions: widget.questions.length,
        correctAnswers: correctCount,
        questionResults: questionResults,
      );
      
      // Generate report
      String reportPath = await ReportService.generateReport(quizResult);
      
      // Navigate to results screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            result: quizResult,
            reportFilePath: reportPath,
            onStartNewQuiz: () {
              Navigator.of(context).pop(); // Go back to main menu
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting quiz: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isQuizStarted) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    MCQ currentQuestion = widget.questions[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizName),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => _showExitConfirmationDialog(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.questions.length,
                    backgroundColor: Colors.grey[300],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1}/${widget.questions.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${_userAnswers.where((a) => a != -1).length}/${widget.questions.length} answered',
                          style: TextStyle(
                            color: _canSubmitQuiz() ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentQuestion.question,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          ...currentQuestion.options
                              .asMap()
                              .entries
                              .map((entry) {
                            int idx = entry.key;
                            String option = entry.value;
                            bool isSelected = _userAnswers[_currentIndex] == idx;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap: () => _answerQuestion(idx),
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: isSelected
                                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 24,
                                        width: 24,
                                        margin: EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey,
                                            width: isSelected ? 2 : 1,
                                          ),
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : null,
                                        ),
                                        child: isSelected
                                            ? Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _currentIndex > 0 ? _goToPreviousQuestion : null,
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back),
                              SizedBox(width: 8),
                              Text('Previous'),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey,
                          ),
                        ),
                        _currentIndex == widget.questions.length - 1
                            ? ElevatedButton(
                                onPressed: _canSubmitQuiz() ? _submitQuiz : null,
                                child: Row(
                                  children: [
                                    Text('Submit'),
                                    SizedBox(width: 8),
                                    Icon(Icons.done_all),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _goToNextQuestion,
                                child: Row(
                                  children: [
                                    Text('Next'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Quiz?'),
        content: Text('Your progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('EXIT'),
            style: TextButton.styleFrom(
              primary: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
} 