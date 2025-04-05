import 'package:quiz_app/screens/selection_screens/subject_selection_screen.dart';
import '../mcq_stats_screen.dart';
import 'selection_screens/group_selection_screen.dart';
import 'package:flutter/material.dart';
import 'material_screen.dart';
import 'mcq_screens/mcq_quiz_screen.dart';
import '../services/favorite_service.dart';
import 'selection_screens/topic_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<FavoriteExam> favoriteExams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final favorites = await FavoriteService.getFavorites();
      setState(() {
        favoriteExams = favorites;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Select Group'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroupSelectionScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.subject),
              title: const Text('Select Subject'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubjectSelectionScreen(
                      topic: 'Class 10',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Materials'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaterialScreen(
                      topic: 'Class 10',
                      subject: 'Mathematics',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('MCQ Quiz'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MCQQuizScreen(
                      topic: 'history',
                      subject: 'indian_history',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('MCQ Statistics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MCQStatsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to the Educational App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Favorites Section
              if (favoriteExams.isNotEmpty) ...[
                const Text(
                  'Your Favorite Exams',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: favoriteExams.length,
                    itemBuilder: (context, index) {
                      final exam = favoriteExams[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            // Navigate to the topic selection screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TopicSelectionScreen(
                                  exam: exam.name,
                                  groupId: exam.groupId,
                                  subgroupId: exam.subgroupId,
                                  examId: exam.examId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 150,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.school, color: Theme.of(context).primaryColor),
                                const SizedBox(height: 8),
                                Text(
                                  exam.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
              ],
              
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GroupSelectionScreen()),
                    ).then((_) {
                      // Refresh favorites when returning from navigation
                      loadFavorites();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  child: const Text('Get Started', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
