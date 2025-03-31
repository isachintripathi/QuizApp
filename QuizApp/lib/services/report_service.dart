import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../models/quiz_result_model.dart';

class ReportService {
  static Future<String> generateReport(QuizResult result) async {
    try {
      final directory = await getReportsDirectory();
      final file = File('${directory.path}/${result.resultFileName}');
      
      final reportContent = _buildReportContent(result);
      await file.writeAsString(reportContent);
      
      return file.path;
    } catch (e) {
      print('Error generating report: $e');
      rethrow;
    }
  }

  static Future<Directory> getReportsDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${appDocDir.path}/reports');
    
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    
    return reportsDir;
  }

  static String _buildReportContent(QuizResult result) {
    StringBuffer buffer = StringBuffer();
    
    // Header
    buffer.writeln('==========================================================');
    buffer.writeln('                       QUIZ REPORT                        ');
    buffer.writeln('==========================================================\n');
    
    final submissionTime = '${result.submissionTime.day.toString().padLeft(2, '0')}-'
        '${result.submissionTime.month.toString().padLeft(2, '0')}-'
        '${result.submissionTime.year} '
        '${result.submissionTime.hour.toString().padLeft(2, '0')}:'
        '${result.submissionTime.minute.toString().padLeft(2, '0')}:'
        '${result.submissionTime.second.toString().padLeft(2, '0')}';
    
    buffer.writeln('Date and Time: $submissionTime\n');
    
    // User Details
    buffer.writeln('----------------------------------------------------------');
    buffer.writeln('USER DETAILS');
    buffer.writeln('----------------------------------------------------------');
    buffer.writeln('Name: ${result.user.name}');
    buffer.writeln('Date of Birth: ${result.user.formattedDateOfBirth}\n');
    
    // Quiz Details
    buffer.writeln('----------------------------------------------------------');
    buffer.writeln('QUIZ DETAILS');
    buffer.writeln('----------------------------------------------------------');
    buffer.writeln('Quiz Type: ${result.quizType}');
    buffer.writeln('Quiz Name: ${result.quizName}');
    buffer.writeln('Total Questions: ${result.totalQuestions}');
    buffer.writeln('Correct Answers: ${result.correctAnswers}');
    buffer.writeln('Score: ${result.scorePercentage.toStringAsFixed(2)}%\n');
    
    // Question Details
    buffer.writeln('----------------------------------------------------------');
    buffer.writeln('QUESTION DETAILS');
    buffer.writeln('----------------------------------------------------------');
    
    for (int i = 0; i < result.questionResults.length; i++) {
      final qr = result.questionResults[i];
      buffer.writeln('Question ${i + 1}: ${qr.question}');
      buffer.writeln('Your Answer: ${qr.userAnswer}');
      buffer.writeln('Correct Answer: ${qr.correctAnswer}');
      buffer.writeln('Result: ${qr.isCorrect ? "CORRECT" : "INCORRECT"}\n');
    }
    
    // Summary
    buffer.writeln('==========================================================');
    buffer.writeln('SUMMARY');
    buffer.writeln('==========================================================');
    buffer.writeln('Total Questions: ${result.totalQuestions}');
    buffer.writeln('Correct Answers: ${result.correctAnswers}');
    buffer.writeln('Incorrect Answers: ${result.totalQuestions - result.correctAnswers}');
    buffer.writeln('Final Score: ${result.scorePercentage.toStringAsFixed(2)}%');
    
    // Performance Evaluation
    buffer.write('\nPerformance Evaluation: ');
    double percentage = result.scorePercentage;
    if (percentage >= 90) {
      buffer.writeln('Excellent! Keep up the good work.');
    } else if (percentage >= 75) {
      buffer.writeln('Good! You\'re on the right track.');
    } else if (percentage >= 60) {
      buffer.writeln('Satisfactory. With more practice, you can improve.');
    } else if (percentage >= 40) {
      buffer.writeln('Needs improvement. Focus on your weak areas.');
    } else {
      buffer.writeln('Requires significant improvement. Consider revisiting the material and try again.');
    }
    
    return buffer.toString();
  }
} 