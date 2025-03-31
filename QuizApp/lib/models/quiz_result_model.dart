import 'user_model.dart';

class QuizResult {
  final User user;
  final String quizType; // "Subject" or "Set"
  final String quizName; // Subject name or Set name
  final int totalQuestions;
  final int correctAnswers;
  final DateTime submissionTime;
  final List<QuestionResult> questionResults;

  QuizResult({
    required this.user,
    required this.quizType,
    required this.quizName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.questionResults,
    DateTime? submissionTime,
  }) : this.submissionTime = submissionTime ?? DateTime.now();

  double get scorePercentage {
    if (totalQuestions == 0) return 0;
    return (correctAnswers / totalQuestions) * 100;
  }

  String get formattedSubmissionTime {
    return '${submissionTime.year}-'
        '${submissionTime.month.toString().padLeft(2, '0')}-'
        '${submissionTime.day.toString().padLeft(2, '0')}_'
        '${submissionTime.hour.toString().padLeft(2, '0')}-'
        '${submissionTime.minute.toString().padLeft(2, '0')}-'
        '${submissionTime.second.toString().padLeft(2, '0')}';
  }

  String get resultFileName {
    String sanitizedName = user.name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return '${sanitizedName}_$formattedSubmissionTime.txt';
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'quizType': quizType,
      'quizName': quizName,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'submissionTime': submissionTime.toIso8601String(),
      'questionResults': questionResults.map((qr) => qr.toJson()).toList(),
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      user: User.fromJson(json['user']),
      quizType: json['quizType'],
      quizName: json['quizName'],
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      submissionTime: DateTime.parse(json['submissionTime']),
      questionResults: (json['questionResults'] as List)
          .map((qr) => QuestionResult.fromJson(qr))
          .toList(),
    );
  }
}

class QuestionResult {
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  QuestionResult({
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
    };
  }

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      question: json['question'],
      userAnswer: json['userAnswer'],
      correctAnswer: json['correctAnswer'],
      isCorrect: json['isCorrect'],
    );
  }
} 