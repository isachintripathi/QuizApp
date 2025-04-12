import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../enum/material_type.dart';
import '../widgets/custom_app_bar.dart';

const String baseApiUrl = 'http://192.168.1.37:8080/api';

// ===============================
// Topic Material Screen (for direct material display)
// ===============================
class TopicMaterialScreen extends StatefulWidget {
  final String topic;
  final MaterialTypes materialType;

  const TopicMaterialScreen({
    super.key,
    required this.topic,
    required this.materialType,
  });

  @override
  TopicMaterialScreenState createState() => TopicMaterialScreenState();
}

class TopicMaterialScreenState extends State<TopicMaterialScreen> {
  List<String> pdfs = [];
  List<String> docs = [];
  List<String> videos = [];
  bool isLoading = true;
  String? errorMessage;
  List<String> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    String apiUrl = '$baseApiUrl/subjects?topic=${widget.topic}';
    print("Url -->  ${Uri.parse('$baseApiUrl/subjects?topic=${widget.topic}')}");

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          subjects = List<String>.from(json.decode(response.body));
          isLoading = false;
        });
        // Pre-fetch materials for all subjects
        for (String subject in subjects) {
          fetchMaterialsForSubject(subject);
        }
      } else {
        throw Exception("Failed to load subjects.");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  Future<void> fetchMaterialsForSubject(String subject) async {
    try {
      // Extract path components from topic (assuming format: "Group/Subgroup/Exam")
      List<String> pathParts = widget.topic.split('/');
      String groupId = pathParts.isNotEmpty ? pathParts[0] : "default";
      String subgroupId = pathParts.length > 1 ? pathParts[1] : "default";
      String examId = pathParts.length > 2 ? pathParts[2] : "default";
      
      if (widget.materialType == MaterialTypes.pdf ||
          widget.materialType == MaterialTypes.pdfAndDoc ||
          widget.materialType == MaterialTypes.all) {
        final pdfResponse = await http.get(
            Uri.parse('$baseApiUrl/pdfs/$groupId/$subgroupId/$examId/$subject')
        );
        if (pdfResponse.statusCode == 200) {
          setState(() {
            pdfs.addAll(List<String>.from(json.decode(pdfResponse.body)));
          });
        } else {
          print("PDF API Error: ${pdfResponse.statusCode}");
        }
      }

      if (widget.materialType == MaterialTypes.doc ||
          widget.materialType == MaterialTypes.pdfAndDoc ||
          widget.materialType == MaterialTypes.all) {
        final docResponse = await http.get(
            Uri.parse('$baseApiUrl/docs/$groupId/$subgroupId/$examId/$subject')
        );
        if (docResponse.statusCode == 200) {
          setState(() {
            docs.addAll(List<String>.from(json.decode(docResponse.body)));
          });
        } else {
          print("Docs API Error: ${docResponse.statusCode}");
        }
      }

      if (widget.materialType == MaterialTypes.video ||
          widget.materialType == MaterialTypes.all) {
        final videoResponse = await http.get(
            Uri.parse('$baseApiUrl/videos/$groupId/$subgroupId/$examId/$subject')
        );
        if (videoResponse.statusCode == 200) {
          setState(() {
            videos.addAll(List<String>.from(json.decode(videoResponse.body)));
          });
        } else {
          print("Videos API Error: ${videoResponse.statusCode}");
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String screenTitle = '';

    switch (widget.materialType) {
      case MaterialTypes.pdf:
        screenTitle = 'PDFs for ${widget.topic}';
        break;
      case MaterialTypes.doc:
        screenTitle = 'Documents for ${widget.topic}';
        break;
      case MaterialTypes.video:
        screenTitle = 'Videos for ${widget.topic}';
        break;
      case MaterialTypes.pdfAndDoc:
        screenTitle = 'Materials for ${widget.topic}';
        break;
      case MaterialTypes.all:
        screenTitle = 'All Materials for ${widget.topic}';
        break;
    }

    return Scaffold(
      appBar: CustomAppBar(title: screenTitle),
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
              if (widget.materialType == MaterialTypes.pdf ||
                  widget.materialType == MaterialTypes.pdfAndDoc ||
                  widget.materialType == MaterialTypes.all)
                _buildMaterialSection('PDFs', pdfs, Icons.picture_as_pdf),

              if (widget.materialType == MaterialTypes.pdf ||
                  widget.materialType == MaterialTypes.pdfAndDoc ||
                  widget.materialType == MaterialTypes.all)
                const SizedBox(height: 24),

              if (widget.materialType == MaterialTypes.doc ||
                  widget.materialType == MaterialTypes.pdfAndDoc ||
                  widget.materialType == MaterialTypes.all)
                _buildMaterialSection('Docs', docs, Icons.article),

              if (widget.materialType == MaterialTypes.doc ||
                  widget.materialType == MaterialTypes.pdfAndDoc ||
                  widget.materialType == MaterialTypes.all)
                const SizedBox(height: 24),

              if (widget.materialType == MaterialTypes.video ||
                  widget.materialType == MaterialTypes.all)
                _buildMaterialSection('Videos', videos, Icons.video_library),
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
        if (items.isEmpty)
          const Text('No materials available')
        else
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
