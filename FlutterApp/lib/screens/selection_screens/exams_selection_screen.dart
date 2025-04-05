import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../services/favorite_service.dart';

import 'topic_selection_screen.dart';

const String baseApiUrl = 'http://localhost:8080/api';

// ===============================
// 3️⃣ Exam Selection Screen
// ===============================
class ExamSelectionScreen extends StatefulWidget {
  final String subGroup;
  final String groupId;
  final String subgroupId;

  const ExamSelectionScreen({
    super.key,
    required this.subGroup,
    required this.groupId,
    required this.subgroupId
  });

  @override
  ExamSelectionScreenState createState() => ExamSelectionScreenState();
}

class ExamSelectionScreenState extends State<ExamSelectionScreen> {
  List<String> exams = [];
  List<dynamic> examsData = [];
  Map<String, bool> favoriteStatus = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchExams();
  }

  Future<void> fetchExams() async {
    String apiUrl = '$baseApiUrl/exams/${widget.groupId}/${widget.subgroupId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Get initial favorite status for all exams
        Map<String, bool> initialFavorites = {};
        for (var exam in data) {
          String examId = exam['id'];
          initialFavorites[examId] = await FavoriteService.isFavorite(examId);
        }
        
        setState(() {
          examsData = data;
          exams = data.map((exam) => exam['name'] as String).toList();
          favoriteStatus = initialFavorites;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load exams.");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  Future<void> toggleFavorite(int index) async {
    final exam = examsData[index];
    final examId = exam['id'];
    final examName = exam['name'];
    
    final favoriteExam = FavoriteExam(
      id: examId,
      name: examName,
      groupId: widget.groupId,
      subgroupId: widget.subgroupId,
      examId: examId
    );
    
    final result = await FavoriteService.toggleFavorite(favoriteExam);
    
    if (result) {
      setState(() {
        favoriteStatus[examId] = !favoriteStatus[examId]!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exams for ${widget.subGroup}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ListView.builder(
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final examId = examsData[index]['id'];
          final isFavorite = favoriteStatus[examId] ?? false;
          
          return ListTile(
            title: Text(exams[index]),
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => toggleFavorite(index),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TopicSelectionScreen(
                    exam: exams[index],
                    groupId: widget.groupId,
                    subgroupId: widget.subgroupId,
                    examId: examsData[index]['id'],
                  ),
                ),
              ).then((_) {
                // Refresh favorite status when returning from topic screen
                fetchExams();
              });
            },
          );
        },
      ),
    );
  }
}
