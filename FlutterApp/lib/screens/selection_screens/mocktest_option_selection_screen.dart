import 'package:flutter/material.dart';
import 'package:quiz_app/screens/subject_list_screen.dart';
import '../mocktest_set_screen.dart';

const String baseApiUrl = 'http://localhost:8080/api';

// ===============================
// Mock Test Selection Screen
// ===============================
class MockTestSelectionScreen extends StatelessWidget {
  final String exam;
  final String groupId;
  final String subgroupId;
  final String examId;
  // final String subject;
  // final String subjectId;

  const MockTestSelectionScreen({
    super.key,
    required this.exam,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
    // required this.subject,
    // required this.subjectId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mock Test Options'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Select Test Type',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildOptionCard(
                context,
                'Subject Wise Tests',
                'Take subject-specific tests with at least 20 MCQs per subject',
                Icons.subject,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubjectListScreen(
                        exam: exam,
                        groupId: groupId,
                        subgroupId: subgroupId,
                        examId: examId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                'Set Wise Tests',
                'Complete mock tests with predefined sets of questions',
                Icons.quiz,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MockTestSetsScreen(
                        exam: exam,
                        groupId: groupId,
                        subgroupId: subgroupId,
                        examId: examId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildOptionCard(
                context,
                'Chapter Wise Tests',
                'Take chapter-specific tests with at least 20 MCQs per chapter',
                Icons.topic,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubjectListScreen(
                        exam: exam,
                        groupId: groupId,
                        subgroupId: subgroupId,
                        examId: examId,
                        isChapterWiseTest: true,
                        // subject: subject,
                        // subjectId: subjectId,
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
