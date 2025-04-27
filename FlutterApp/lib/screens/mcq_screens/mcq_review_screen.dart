import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const String baseApiUrl = 'http://localhost:8080/api';

// ===============================
// 8 MCQ Review Screen
// ===============================
class MCQReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> mcqs;
  final List<int?> userAnswers;

  const MCQReviewScreen({
    super.key,
    required this.mcqs,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Review'),
      ),
      body: ListView.builder(
        itemCount: mcqs.length,
        itemBuilder: (context, index) {
          bool isCorrect = userAnswers[index] == mcqs[index]['correctAnswerIndex'];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number and correctness indicator
                  Row(
                    children: [
                      Text(
                        'Question ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCorrect ? 'Correct' : 'Incorrect',
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Question
                  Text(
                    mcqs[index]['question'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // Options
                  ...List.generate(
                    mcqs[index]['options'].length,
                        (optionIndex) {
                      bool isCorrectOption = optionIndex == mcqs[index]['correctAnswerIndex'];
                      bool isSelectedOption = optionIndex == userAnswers[index];

                      Color? bgColor;
                      if (isCorrectOption) {
                        bgColor = Colors.green.withOpacity(0.2);
                      } else if (isSelectedOption) {
                        bgColor = Colors.red.withOpacity(0.2);
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCorrectOption
                                ? Colors.green
                                : isSelectedOption
                                ? Colors.red
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${String.fromCharCode(65 + optionIndex)}. ${mcqs[index]['options'][optionIndex]}',
                            ),
                            if (isCorrectOption) ...[
                              const Spacer(),
                              const Icon(Icons.check, color: Colors.green),
                            ] else if (isSelectedOption) ...[
                              const Spacer(),
                              const Icon(Icons.close, color: Colors.red),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Explanation
                  const Text(
                    'Explanation:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(mcqs[index]['explanation']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
