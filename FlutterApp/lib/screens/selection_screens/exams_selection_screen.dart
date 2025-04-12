import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../services/favorite_service.dart';
import '../../widgets/custom_app_bar.dart';
import 'topic_selection_screen.dart';
import '../../utils/ui_constants.dart';

const String baseApiUrl = 'http://192.168.1.37:8080/api';

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
      backgroundColor: UIConstants.getScaffoldBackgroundColor(context),
      appBar: CustomAppBar(
        title: 'Exams for ${widget.subGroup}',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? _buildErrorMessage()
          : _buildExamsGrid(),
    );
  }
  
  Widget _buildErrorMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        decoration: UIConstants.getContainerDecoration(
          context, 
          color: Colors.red[50],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            Text(
              'Error',
              style: UIConstants.getTitleTextStyle(context).copyWith(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            Text(
              errorMessage!,
              style: UIConstants.getBodyTextStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            ElevatedButton(
              onPressed: fetchExams,
              style: ElevatedButton.styleFrom(
                backgroundColor: UIConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExamsGrid() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation breadcrumb
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingMedium,
              vertical: UIConstants.paddingSmall,
            ),
            decoration: UIConstants.getContainerDecoration(
              context,
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              borderRadius: UIConstants.borderRadiusSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.subGroup,
                  style: UIConstants.getBodyTextStyle(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          
          // Heading
          Padding(
            padding: const EdgeInsets.only(
              left: UIConstants.paddingSmall,
              bottom: UIConstants.paddingMedium,
            ),
            child: Text(
              'Select an exam to view topics',
              style: UIConstants.getSubtitleTextStyle(context),
            ),
          ),
          
          // Grid of exams
          Expanded(
            child: GridView.builder(
              gridDelegate: UIConstants.getGridDelegate(context: context),
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final examName = exams[index];
                final examId = examsData[index]['id'];
                final isFavorite = favoriteStatus[examId] ?? false;
                final iconData = _getIconForExam(examName);
                
                return _buildExamCard(
                  examName, 
                  examId, 
                  iconData, 
                  isFavorite, 
                  () => toggleFavorite(index)
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getIconForExam(String examName) {
    if (examName.toLowerCase().contains('upsc') || 
        examName.toLowerCase().contains('civil')) {
      return Icons.account_balance;
    } else if (examName.toLowerCase().contains('gate') || 
             examName.toLowerCase().contains('engineering')) {
      return Icons.engineering;
    } else if (examName.toLowerCase().contains('neet') || 
             examName.toLowerCase().contains('medical')) {
      return Icons.medical_services;
    } else if (examName.toLowerCase().contains('bank') || 
             examName.toLowerCase().contains('sbi')) {
      return Icons.account_balance_wallet;
    } else if (examName.toLowerCase().contains('ssc') || 
             examName.toLowerCase().contains('staff')) {
      return Icons.badge;
    } else if (examName.toLowerCase().contains('ctet') || 
             examName.toLowerCase().contains('teaching')) {
      return Icons.school;
    } else {
      return Icons.quiz;
    }
  }
  
  Widget _buildExamCard(
    String examName, 
    String examId, 
    IconData iconData, 
    bool isFavorite,
    VoidCallback onFavoriteToggle
  ) {
    final primaryColor = Theme.of(context).primaryColor;
    final iconBgColor = isFavorite 
        ? Colors.pink.withOpacity(0.1)
        : primaryColor.withOpacity(0.1);
        
    return Card(
      elevation: UIConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
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
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
            hoverColor: primaryColor.withOpacity(0.1),
            child: Container(
              width: 150,
              padding: const EdgeInsets.all(UIConstants.paddingMedium),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(UIConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          size: 40,
                          color: isFavorite ? Colors.pink : primaryColor,
                        ),
                      ),
                      const SizedBox(height: UIConstants.paddingMedium),
                      Expanded(
                        child: Text(
                          examName,
                          textAlign: TextAlign.center,
                          style: UIConstants.getSubtitleTextStyle(context).copyWith(
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  // Favorite button
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                        onTap: onFavoriteToggle,
                        child: Padding(
                          padding: const EdgeInsets.all(UIConstants.paddingSmall),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.pink : Colors.grey,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
