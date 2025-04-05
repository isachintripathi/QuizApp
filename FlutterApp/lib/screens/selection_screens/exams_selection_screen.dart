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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.25,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final examName = exams[index];
                  final examId = examsData[index]['id'];
                  final isFavorite = favoriteStatus[examId] ?? false;
                  
                  // Choose an icon based on exam name
                  IconData iconData;
                  if (examName.toLowerCase().contains('upsc') || 
                      examName.toLowerCase().contains('civil')) {
                    iconData = Icons.account_balance;
                  } else if (examName.toLowerCase().contains('gate') || 
                           examName.toLowerCase().contains('engineering')) {
                    iconData = Icons.engineering;
                  } else if (examName.toLowerCase().contains('neet') || 
                           examName.toLowerCase().contains('medical')) {
                    iconData = Icons.medical_services;
                  } else if (examName.toLowerCase().contains('bank') || 
                           examName.toLowerCase().contains('sbi')) {
                    iconData = Icons.account_balance_wallet;
                  } else if (examName.toLowerCase().contains('ssc') || 
                           examName.toLowerCase().contains('staff')) {
                    iconData = Icons.badge;
                  } else if (examName.toLowerCase().contains('ctet') || 
                           examName.toLowerCase().contains('teaching')) {
                    iconData = Icons.school;
                  } else {
                    iconData = Icons.quiz;
                  }
                  
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: examName,
                        waitDuration: const Duration(milliseconds: 200),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TopicSelectionScreen(
                                  exam: examName,
                                  groupId: widget.groupId,
                                  subgroupId: widget.subgroupId,
                                  examId: examId,
                                ),
                              ),
                            ).then((_) {
                              // Refresh favorite status when returning from topic screen
                              fetchExams();
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          hoverColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: SizedBox(
                            width: 150,
                            height: 120,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    iconData,
                                    size: 40,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    examName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    icon: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: isFavorite ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () => toggleFavorite(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
