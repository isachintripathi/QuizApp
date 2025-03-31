class MCQ {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String subject;
  final String topic;
  final String difficulty;

  MCQ({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.subject,
    required this.topic,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'subject': subject,
      'topic': topic,
      'difficulty': difficulty,
    };
  }

  factory MCQ.fromJson(Map<String, dynamic> json) {
    return MCQ(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      explanation: json['explanation'],
      subject: json['subject'],
      topic: json['topic'],
      difficulty: json['difficulty'],
    );
  }

  @override
  String toString() {
    return 'MCQ{id: $id, question: $question, options: $options, correctAnswerIndex: $correctAnswerIndex, subject: $subject, topic: $topic, difficulty: $difficulty}';
  }
} 