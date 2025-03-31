import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../models/quiz_result_model.dart';

class QuizResultsScreen extends StatelessWidget {
  final QuizResult result;
  final String reportFilePath;
  final VoidCallback onStartNewQuiz;

  const QuizResultsScreen({
    Key? key,
    required this.result,
    required this.reportFilePath,
    required this.onStartNewQuiz,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Results'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareResults(context),
            tooltip: 'Share results',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultHeader(context),
              Expanded(
                child: _buildResultDetails(context),
              ),
              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    '${result.correctAnswers}/${result.totalQuestions}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${result.scorePercentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.headline5?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(context),
                            ),
                      ),
                      Text(
                        _getPerformanceText(),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Text(
              'Name: ${result.user.name}',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 4),
            Text(
              'Date of Birth: ${result.user.formattedDateOfBirth}',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            SizedBox(height: 4),
            Text(
              'Quiz: ${result.quizType} - ${result.quizName}',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            SizedBox(height: 4),
            Text(
              'Date: ${_getFormattedDate()}',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDetails(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 16),
        Text(
          'Questions',
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 8),
        ...result.questionResults.asMap().entries.map((entry) {
          int index = entry.key;
          QuestionResult qResult = entry.value;
          return _buildQuestionResultCard(context, index, qResult);
        }).toList(),
      ],
    );
  }

  Widget _buildQuestionResultCard(BuildContext context, int index, QuestionResult qResult) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: qResult.isCorrect
                      ? Colors.green
                      : Colors.red,
                  child: Icon(
                    qResult.isCorrect ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        qResult.question,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 16),
            Text(
              'Your Answer: ${qResult.userAnswer}',
              style: TextStyle(
                color: qResult.isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!qResult.isCorrect) ...[
              SizedBox(height: 4),
              Text(
                'Correct Answer: ${qResult.correctAnswer}',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onStartNewQuiz,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text('NEW QUIZ'),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    return '${result.submissionTime.day.toString().padLeft(2, '0')}-'
        '${result.submissionTime.month.toString().padLeft(2, '0')}-'
        '${result.submissionTime.year}';
  }

  Color _getScoreColor(BuildContext context) {
    double percentage = result.scorePercentage;
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 75) {
      return Colors.lightGreen;
    } else if (percentage >= 60) {
      return Colors.amber;
    } else if (percentage >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getPerformanceText() {
    double percentage = result.scorePercentage;
    if (percentage >= 90) {
      return 'Excellent!';
    } else if (percentage >= 75) {
      return 'Good job!';
    } else if (percentage >= 60) {
      return 'Satisfactory';
    } else if (percentage >= 40) {
      return 'Needs improvement';
    } else {
      return 'Try harder next time';
    }
  }

  void _shareResults(BuildContext context) async {
    try {
      final File reportFile = File(reportFilePath);
      if (await reportFile.exists()) {
        await Share.shareFiles(
          [reportFilePath],
          text: 'My ${result.quizType} Quiz Result: '
              '${result.scorePercentage.toStringAsFixed(1)}% '
              '(${result.correctAnswers}/${result.totalQuestions})',
          subject: '${result.quizType} Quiz Report - ${result.quizName}',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report file not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 