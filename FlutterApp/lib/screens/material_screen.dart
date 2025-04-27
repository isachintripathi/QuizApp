import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'mcq_screens/mcq_quiz_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../enum/material_type.dart';

const String baseApiUrl = 'http://192.168.1.37:8080/api';

// ===============================
// 6 Material Screen
// ===============================
class MaterialScreen extends StatefulWidget {
  final String topic;
  final String subject;
  final MaterialTypes materialType;

  const MaterialScreen({
    super.key,
    required this.topic,
    required this.subject,
    this.materialType = MaterialTypes.all
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
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Extract path components
      List<String> pathParts = widget.topic.split('/');
      String groupId = pathParts.isNotEmpty ? pathParts[0] : "default";
      String subgroupId = pathParts.length > 1 ? pathParts[1] : "default";
      String examId = pathParts.length > 2 ? pathParts[2] : "default";
      
      // Fetch PDFs - always fetch for simplicity
      final pdfResponse = await http.get(
          Uri.parse('$baseApiUrl/pdfs/$groupId/$subgroupId/$examId/${widget.subject}')
      );
      if (pdfResponse.statusCode == 200) {
        setState(() {
          pdfs = List<String>.from(json.decode(pdfResponse.body));
        });
      } else {
        print("PDF API Error: ${pdfResponse.statusCode}");
      }

      // Fetch Docs
      final docResponse = await http.get(
          Uri.parse('$baseApiUrl/docs/$groupId/$subgroupId/$examId/${widget.subject}')
      );
      if (docResponse.statusCode == 200) {
        setState(() {
          docs = List<String>.from(json.decode(docResponse.body));
        });
      } else {
        print("Docs API Error: ${docResponse.statusCode}");
      }

      // Fetch Videos
      final videoResponse = await http.get(
          Uri.parse('$baseApiUrl/videos/$groupId/$subgroupId/$examId/${widget.subject}')
      );
      if (videoResponse.statusCode == 200) {
        setState(() {
          videos = List<String>.from(json.decode(videoResponse.body));
        });
      } else {
        print("Videos API Error: ${videoResponse.statusCode}");
      }

      setState(() {
        isLoading = false;
        print("Loaded ${pdfs.length} PDFs, ${docs.length} docs, and ${videos.length} videos");
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Materials for ${widget.subject}'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : pdfs.isEmpty && docs.isEmpty && videos.isEmpty
                  ? _buildEmptyState()
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No materials available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different subject',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              fetchMaterials(); // Retry loading materials
            },
            child: const Text('Retry'),
          ),
        ],
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
