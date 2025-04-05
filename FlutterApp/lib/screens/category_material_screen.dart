import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../model/subject.dart';
import '../enum/material_type.dart';

const String baseApiUrl = 'http://localhost:8080/api';
// ===============================
// CategoryMaterialScreen - For category-specific materials
// ===============================
class CategoryMaterialScreen extends StatefulWidget {
  final String title;
  final MaterialTypes materialType;
  final String groupId;
  final String subgroupId;
  final String examId;

  const CategoryMaterialScreen({
    super.key,
    required this.title,
    required this.materialType,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
  });

  @override
  CategoryMaterialScreenState createState() => CategoryMaterialScreenState();
}

class CategoryMaterialScreenState extends State<CategoryMaterialScreen> {
  List<String> pdfs = [];
  List<String> docs = [];
  List<String> videos = [];
  List<Subject> subjects = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    try {
      final response = await http.get(
          Uri.parse('$baseApiUrl/subjects/${widget.groupId}/${widget.subgroupId}/${widget.examId}')
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subjects = data.map((subject) => Subject(
            id: subject['id'],
            name: subject['name'],
            pdfs: List<String>.from(subject['pdfs'] ?? []),
            docs: List<String>.from(subject['docs'] ?? []),
            videos: List<String>.from(subject['videos'] ?? []),
          )).toList();

          // Extract all PDFs, docs, videos from all subjects
          for (var subject in subjects) {
            pdfs.addAll(subject.pdfs ?? []);
            docs.addAll(subject.docs ?? []);
            videos.addAll(subject.videos ?? []);
          }

          isLoading = false;
        });
      } else {
        throw Exception("Failed to load subjects");
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
      appBar: AppBar(title: Text(widget.title)),
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
                _buildMaterialSection('Documents', docs, Icons.article),

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
