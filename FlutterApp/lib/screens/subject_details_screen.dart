import 'package:flutter/material.dart';
import 'mcq_screens/mcq_quiz_screen.dart';

const String baseApiUrl = 'http://localhost:8080/api';

// ===============================
// Subject Detail Screen
// ===============================
class SubjectDetailScreen extends StatefulWidget {
  final String topic;
  final String subject;
  final String groupId;
  final String subgroupId;
  final String examId;
  final Map<String, dynamic> subjectData;

  const SubjectDetailScreen({
    super.key,
    required this.topic,
    required this.subject,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
    required this.subjectData,
  });

  @override
  SubjectDetailScreenState createState() => SubjectDetailScreenState();
}

class SubjectDetailScreenState extends State<SubjectDetailScreen> {
  bool isLoading = false;
  String? errorMessage;
  List<String> pdfs = [];
  List<String> docs = [];
  List<String> videos = [];

  @override
  void initState() {
    super.initState();
    // Extract materials from subject data
    if (widget.subjectData.containsKey('pdfs')) {
      pdfs = List<String>.from(widget.subjectData['pdfs'] ?? []);
    }
    if (widget.subjectData.containsKey('docs')) {
      docs = List<String>.from(widget.subjectData['docs'] ?? []);
    }
    if (widget.subjectData.containsKey('videos')) {
      videos = List<String>.from(widget.subjectData['videos'] ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.subject} Materials')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MCQs Section
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MCQQuizScreen(
                      topic: "",  // Not needed with new API
                      subject: widget.subject,
                      questionCount: 10,
                    ),
                  ),
                );
              },
              child: const Text('Practice MCQs'),
            ),

            const SizedBox(height: 20),

            // PDFs Section
            if (pdfs.isNotEmpty) ...[
              const Text(
                'PDFs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pdfs.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: Text(pdfs[index]),
                      onTap: () {
                        // Handle PDF viewing
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // Documents Section
            if (docs.isNotEmpty) ...[
              const Text(
                'Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(docs[index]),
                      onTap: () {
                        // Handle document viewing
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // Videos Section
            if (videos.isNotEmpty) ...[
              const Text(
                'Videos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.video_library),
                      title: Text(videos[index]),
                      onTap: () {
                        // Handle video viewing
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
