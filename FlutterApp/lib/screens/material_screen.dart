import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'mcq_screens/mcq_quiz_screen.dart';

const String baseApiUrl = 'http://localhost:8080/api';

// ===============================
// 6 Material Screen
// ===============================
class MaterialScreen extends StatefulWidget {
  final String topic;
  final String subject;

  const MaterialScreen({
    super.key,
    required this.topic,
    required this.subject
  });

  @override
  MaterialScreenState createState() => MaterialScreenState();
}

class MaterialScreenState extends State<MaterialScreen> {
  List<String> pdfs = [];
  List<String> docs = [];
  List<String> videos = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchMaterials();
  }

  Future<void> fetchMaterials() async {
    try {
      // Fetch PDFs
      final pdfResponse = await http.get(
          Uri.parse('$baseApiUrl/pdfs?topic=${widget.topic}&subject=${widget.subject}')
      );

      // Fetch Docs
      final docResponse = await http.get(
          Uri.parse('$baseApiUrl/docs?topic=${widget.topic}&subject=${widget.subject}')
      );

      // Fetch Videos
      final videoResponse = await http.get(
          Uri.parse('$baseApiUrl/videos?topic=${widget.topic}&subject=${widget.subject}')
      );

      if (pdfResponse.statusCode == 200 &&
          docResponse.statusCode == 200 &&
          videoResponse.statusCode == 200) {
        setState(() {
          pdfs = List<String>.from(json.decode(pdfResponse.body));
          docs = List<String>.from(json.decode(docResponse.body));
          videos = List<String>.from(json.decode(videoResponse.body));
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load materials.");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Materials for ${widget.subject}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Only show PDFs section if there are PDFs
              if (pdfs.isNotEmpty) ...[
                _buildMaterialSection('PDFs', pdfs, Icons.picture_as_pdf),
                const SizedBox(height: 24),
              ],

              // Only show Docs section if there are Docs
              if (docs.isNotEmpty) ...[
                _buildMaterialSection('Docs', docs, Icons.article),
                const SizedBox(height: 24),
              ],

              // Only show Videos section if there are Videos
              if (videos.isNotEmpty) ...[
                _buildMaterialSection('Videos', videos, Icons.video_library),
                const SizedBox(height: 24),
              ],

              // MCQ Quiz Button
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
                child: const Text('Start MCQ Quiz', style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialSection(String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(icon),
                title: Text(items[index]),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening ${items[index]}'))
                  );
                  // Here you would implement functionality to open the file
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
