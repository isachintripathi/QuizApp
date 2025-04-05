import 'package:flutter/material.dart';
import '../../enum/material_type.dart';
import '../category_material_screen.dart';
import 'mocktest_option_selection_screen.dart';
import '../../services/favorite_service.dart';

const String baseApiUrl = 'http://localhost:8080/api';

// ===============================
// 4️⃣ Topic Selection Screen
// ===============================
class TopicSelectionScreen extends StatefulWidget {
  final String exam;
  // final String subject;
  final String groupId;
  final String subgroupId;
  final String examId;
  // final String subjectId;

  const TopicSelectionScreen({
    super.key,
    required this.exam,
    // required this.subject,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
    // required this.subjectId,
  });

  @override
  TopicSelectionScreenState createState() => TopicSelectionScreenState();
}

class TopicSelectionScreenState extends State<TopicSelectionScreen> {
  final List<String> categories = [
    'PYQs',
    'Mock Test',
    'Live Lecture',
    'Syllabus',
    'Notes'
  ];

  bool isLoading = true;
  String? errorMessage;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavoriteStatus();
  }

  Future<void> loadFavoriteStatus() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final status = await FavoriteService.isFavorite(widget.examId);
      setState(() {
        isFavorite = status;
        isLoading = false;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleFavorite() async {
    final favoriteExam = FavoriteExam(
      id: widget.examId,
      name: widget.exam,
      groupId: widget.groupId,
      subgroupId: widget.subgroupId,
      examId: widget.examId,
    );
    
    final result = await FavoriteService.toggleFavorite(favoriteExam);
    
    if (result) {
      setState(() {
        isFavorite = !isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Material for ${widget.exam}'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          IconData iconData;
          switch(categories[index]) {
            case 'PYQs':
              iconData = Icons.history;
              break;
            case 'Mock Test':
              iconData = Icons.quiz;
              break;
            case 'Live Lecture':
              iconData = Icons.video_camera_front;
              break;
            case 'Syllabus':
              iconData = Icons.menu_book;
              break;
            case 'Notes':
              iconData = Icons.note;
              break;
            default:
              iconData = Icons.book;
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(iconData, size: 28),
              title: Text(categories[index],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (categories[index] == 'Mock Test') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MockTestSelectionScreen(
                        exam: widget.exam,
                        // subject: widget.subject,
                        groupId: widget.groupId,
                        subgroupId: widget.subgroupId,
                        examId: widget.examId,
                        // subjectId: widget.subjectId,
                      ),
                    ),
                  ).then((_) => loadFavoriteStatus());
                } else if (categories[index] == 'PYQs') {
                  // Show PDFs
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryMaterialScreen(
                        title: 'Previous Year Questions',
                        materialType: MaterialTypes.pdf,
                        groupId: widget.groupId,
                        subgroupId: widget.subgroupId,
                        examId: widget.examId,
                      ),
                    ),
                  ).then((_) => loadFavoriteStatus());
                
                  // Show videos
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryMaterialScreen(
                        title: 'Live Lectures',
                        materialType: MaterialTypes.video,
                        groupId: widget.groupId,
                        subgroupId: widget.subgroupId,
                        examId: widget.examId,
                      ),
                    ),
                  ).then((_) => loadFavoriteStatus());
                } else if (categories[index] == 'Syllabus') {
                  // Show docs
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryMaterialScreen(
                        title: 'Syllabus',
                        materialType: MaterialTypes.doc,
                        groupId: widget.groupId,
                        subgroupId: widget.subgroupId,
                        examId: widget.examId,
                      ),
                    ),
                  ).then((_) => loadFavoriteStatus());
                } else if (categories[index] == 'Notes') {
                  // Show PDFs and docs
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryMaterialScreen(
                        title: 'Study Notes',
                        materialType: MaterialTypes.pdfAndDoc,
                        groupId: widget.groupId,
                        subgroupId: widget.subgroupId,
                        examId: widget.examId,
                      ),
                    ),
                  ).then((_) => loadFavoriteStatus());
                }
              },
            ),
          );
        },
      ),
    );
  }
}
