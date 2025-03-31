import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:uuid/uuid.dart'; // Add UUID package for user tracking
import 'custom_test_screen.dart'; // Import the custom test screen
import 'mcq_stats_screen.dart'; // Import the MCQ stats screen

const String BASE_API_URL = 'http://localhost:8080/api';

// User session manager 
class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();
  
  final String userId = Uuid().v4(); // Generate a unique ID for this user session
  
  // Track recent MCQ IDs to avoid repetition
  final List<String> recentMcqIds = [];
  
  // Record an MCQ as seen
  void recordMcq(String mcqId) {
    if (!recentMcqIds.contains(mcqId)) {
      recentMcqIds.add(mcqId);
      // Keep only the 100 most recent MCQs
      if (recentMcqIds.length > 100) {
        recentMcqIds.removeAt(0);
      }
    }
  }
  
  // Check if an MCQ has been seen recently
  bool hasSeen(String mcqId) {
    return recentMcqIds.contains(mcqId);
  }
  
  // Clear recent MCQ history
  void clearRecentMcqs() {
    recentMcqIds.clear();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mock Test App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Educational App',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroupSelectionScreen()),
                );
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// 1️⃣ Group Selection Screen
// ===============================
class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  GroupSelectionScreenState createState() => GroupSelectionScreenState();
}

class GroupSelectionScreenState extends State<GroupSelectionScreen> {
  List<String> groups = [];
  List<dynamic> groupsData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    String apiUrl = '$BASE_API_URL/groups';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          groupsData = data;
          groups = data.map((group) => group['name'] as String).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load groups.");
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
      appBar: AppBar(title: const Text('Select a Group')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(groups[index]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubGroupSelectionScreen(
                              group: groups[index],
                              groupId: groupsData[index]['id'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

// ===============================
// 2️⃣ SubGroup Selection Screen
// ===============================
class SubGroupSelectionScreen extends StatefulWidget {
  final String group;
  final String groupId;
  const SubGroupSelectionScreen({super.key, required this.group, required this.groupId});

  @override
  SubGroupSelectionScreenState createState() => SubGroupSelectionScreenState();
}


class SubGroupSelectionScreenState extends State<SubGroupSelectionScreen> {
  List<String> subGroups = [];
  List<dynamic> subGroupsData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSubGroups();
  }

  Future<void> fetchSubGroups() async {
    String apiUrl = '$BASE_API_URL/subgroups/${widget.groupId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subGroupsData = data;
          subGroups = data.map((subgroup) => subgroup['name'] as String).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load subgroups.");
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
      appBar: AppBar(title: Text('SubGroups for ${widget.group}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: subGroups.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(subGroups[index]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExamSelectionScreen(
                              subGroup: subGroups[index],
                              groupId: widget.groupId,
                              subgroupId: subGroupsData[index]['id'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

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
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchExams();
  }

  Future<void> fetchExams() async {
    String apiUrl = '$BASE_API_URL/exams/${widget.groupId}/${widget.subgroupId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          examsData = data;
          exams = data.map((exam) => exam['name'] as String).toList();
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
                    return ListTile(
                      title: Text(exams[index]),
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
                        );
                      },
                    );
                  },
                ),
    );
  }
}

// ===============================
// 4️⃣ Topic Selection Screen
// ===============================
class TopicSelectionScreen extends StatefulWidget {
  final String exam;
  final String groupId;
  final String subgroupId;
  final String examId;
  
  const TopicSelectionScreen({
    super.key, 
    required this.exam,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
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
  
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Study Material for ${widget.exam}')),
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
                                  groupId: widget.groupId,
                                  subgroupId: widget.subgroupId,
                                  examId: widget.examId,
                                ),
                              ),
                            );
                          } else if (categories[index] == 'PYQs') {
                            // Show PDFs
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryMaterialScreen(
                                  title: 'Previous Year Questions',
                                  materialType: MaterialType.pdf,
                                  groupId: widget.groupId,
                                  subgroupId: widget.subgroupId,
                                  examId: widget.examId,
                                ),
                              ),
                            );
                          } else if (categories[index] == 'Live Lecture') {
                            // Show videos
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryMaterialScreen(
                                  title: 'Live Lectures',
                                  materialType: MaterialType.video,
                                  groupId: widget.groupId,
                                  subgroupId: widget.subgroupId,
                                  examId: widget.examId,
                                ),
                              ),
                            );
                          } else if (categories[index] == 'Syllabus') {
                            // Show docs
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryMaterialScreen(
                                  title: 'Syllabus',
                                  materialType: MaterialType.doc,
                                  groupId: widget.groupId,
                                  subgroupId: widget.subgroupId,
                                  examId: widget.examId,
                                ),
                              ),
                            );
                          } else if (categories[index] == 'Notes') {
                            // Show PDFs and docs
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryMaterialScreen(
                                  title: 'Study Notes',
                                  materialType: MaterialType.pdfAndDoc,
                                  groupId: widget.groupId,
                                  subgroupId: widget.subgroupId,
                                  examId: widget.examId,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

// Enum to represent material types
enum MaterialType {
  pdf,
  doc,
  video,
  pdfAndDoc,
  all
}

// ===============================
// Topic Material Screen (for direct material display)
// ===============================
class TopicMaterialScreen extends StatefulWidget {
  final String topic;
  final MaterialType materialType;
  
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
    String apiUrl = '$BASE_API_URL/subjects?topic=${widget.topic}';

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
      if (widget.materialType == MaterialType.pdf || 
          widget.materialType == MaterialType.pdfAndDoc || 
          widget.materialType == MaterialType.all) {
        final pdfResponse = await http.get(
          Uri.parse('$BASE_API_URL/pdfs?topic=${widget.topic}&subject=$subject')
        );
        if (pdfResponse.statusCode == 200) {
          setState(() {
            pdfs.addAll(List<String>.from(json.decode(pdfResponse.body)));
          });
        }
      }
      
      if (widget.materialType == MaterialType.doc || 
          widget.materialType == MaterialType.pdfAndDoc || 
          widget.materialType == MaterialType.all) {
        final docResponse = await http.get(
          Uri.parse('$BASE_API_URL/docs?topic=${widget.topic}&subject=$subject')
        );
        if (docResponse.statusCode == 200) {
          setState(() {
            docs.addAll(List<String>.from(json.decode(docResponse.body)));
          });
        }
      }
      
      if (widget.materialType == MaterialType.video || 
          widget.materialType == MaterialType.all) {
        final videoResponse = await http.get(
          Uri.parse('$BASE_API_URL/videos?topic=${widget.topic}&subject=$subject')
        );
        if (videoResponse.statusCode == 200) {
          setState(() {
            videos.addAll(List<String>.from(json.decode(videoResponse.body)));
          });
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
      case MaterialType.pdf:
        screenTitle = 'PDFs for ${widget.topic}';
        break;
      case MaterialType.doc:
        screenTitle = 'Documents for ${widget.topic}';
        break;
      case MaterialType.video:
        screenTitle = 'Videos for ${widget.topic}';
        break;
      case MaterialType.pdfAndDoc:
        screenTitle = 'Materials for ${widget.topic}';
        break;
      case MaterialType.all:
        screenTitle = 'All Materials for ${widget.topic}';
        break;
    }
    
    return Scaffold(
      appBar: AppBar(title: Text(screenTitle)),
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
                        if (widget.materialType == MaterialType.pdf || 
                            widget.materialType == MaterialType.pdfAndDoc || 
                            widget.materialType == MaterialType.all)
                          _buildMaterialSection('PDFs', pdfs, Icons.picture_as_pdf),
                        
                        if (widget.materialType == MaterialType.pdf || 
                            widget.materialType == MaterialType.pdfAndDoc || 
                            widget.materialType == MaterialType.all)
                          const SizedBox(height: 24),
                        
                        if (widget.materialType == MaterialType.doc || 
                            widget.materialType == MaterialType.pdfAndDoc || 
                            widget.materialType == MaterialType.all)
                          _buildMaterialSection('Docs', docs, Icons.article),
                        
                        if (widget.materialType == MaterialType.doc || 
                            widget.materialType == MaterialType.pdfAndDoc || 
                            widget.materialType == MaterialType.all)
                          const SizedBox(height: 24),
                        
                        if (widget.materialType == MaterialType.video || 
                            widget.materialType == MaterialType.all)
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

// ===============================
// Mock Test Selection Screen
// ===============================
class MockTestSelectionScreen extends StatelessWidget {
  final String exam;
  final String groupId;
  final String subgroupId;
  final String examId;
  
  const MockTestSelectionScreen({
    super.key, 
    required this.exam,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mock Test Options'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Select Test Type',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildOptionCard(
                context,
                'Subject Wise Tests',
                'Take subject-specific tests with at least 20 MCQs per subject',
                Icons.subject,
                () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                      builder: (context) => SubjectListScreen(
                        exam: exam,
                        groupId: groupId,
                        subgroupId: subgroupId,
                        examId: examId,
                      ),
                          ),
                        );
                      },
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                'Set Wise Tests',
                'Complete mock tests with predefined sets of questions',
                Icons.quiz,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MockTestSetsScreen(
                        exam: exam,
                        groupId: groupId,
                        subgroupId: subgroupId,
                        examId: examId,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOptionCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================
// Mock Test Sets Screen
// ===============================
class MockTestSetsScreen extends StatefulWidget {
  final String exam;
  final String groupId;
  final String subgroupId;
  final String examId;
  
  const MockTestSetsScreen({
    super.key, 
    required this.exam,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
  });

  @override
  MockTestSetsScreenState createState() => MockTestSetsScreenState();
}

class MockTestSetsScreenState extends State<MockTestSetsScreen> {
  final List<Map<String, dynamic>> mockTestSets = [
    {
      'title': 'Set 1 - Easy',
      'subtitle': '50 Questions - 45 Minutes',
      'questions': 50,
      'duration': 45,
      'difficulty': 'EASY',
    },
    {
      'title': 'Set 2 - Medium',
      'subtitle': '100 Questions - 90 Minutes',
      'questions': 100,
      'duration': 90,
      'difficulty': 'MEDIUM',
    },
    {
      'title': 'Set 3 - Hard',
      'subtitle': '75 Questions - 60 Minutes',
      'questions': 75,
      'duration': 60,
      'difficulty': 'HARD',
    },
    {
      'title': 'Quick Test',
      'subtitle': '25 Questions - 20 Minutes',
      'questions': 25,
      'duration': 20,
      'difficulty': 'MIXED',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Sets for ${widget.exam}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomTestScreen(
                      exam: widget.exam,
                      groupId: widget.groupId,
                      subgroupId: widget.subgroupId,
                      examId: widget.examId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text(
                'Create Custom Test',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mockTestSets.length,
              itemBuilder: (context, index) {
                Color setColor;
                switch(mockTestSets[index]['difficulty']) {
                  case 'EASY':
                    setColor = Colors.green;
                    break;
                  case 'MEDIUM':
                    setColor = Colors.orange;
                    break;
                  case 'HARD':
                    setColor = Colors.red;
                    break;
                  default:
                    setColor = Colors.blue;
                }
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: setColor.withOpacity(0.2),
                      child: Text(
                        '${mockTestSets[index]['questions']}',
                        style: TextStyle(
                          color: setColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(mockTestSets[index]['title']),
                    subtitle: Text(mockTestSets[index]['subtitle']),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => startTestSet(
                      mockTestSets[index]['questions'],
                      mockTestSets[index]['duration'],
                      mockTestSets[index]['difficulty'],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void startTestSet(int questionCount, int duration, String difficulty) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Get subjects to gather MCQs from
      final subjectsResponse = await http.get(
        Uri.parse('$BASE_API_URL/subjects/${widget.groupId}/${widget.subgroupId}/${widget.examId}')
      );
      
      if (subjectsResponse.statusCode != 200) {
        Navigator.pop(context); // Close loading dialog
        showErrorDialog('Failed to load subjects');
        return;
      }
      
      final List<dynamic> subjectsData = json.decode(subjectsResponse.body);
      List<Map<String, dynamic>> allMcqs = [];
      
      // Get MCQs from each subject
      for (var subject in subjectsData) {
        final subjectName = subject['name'];
        final mcqsResponse = await http.get(
          Uri.parse('$BASE_API_URL/mcqs/$subjectName')
        );
        
        if (mcqsResponse.statusCode == 200) {
          final List<dynamic> subjectMcqs = json.decode(mcqsResponse.body);
          
          // Filter by difficulty if needed
          List<dynamic> filteredMcqs = difficulty == 'MIXED' 
              ? subjectMcqs 
              : subjectMcqs.where((mcq) => 
                  mcq['difficultyLevel'] == difficulty || 
                  mcq['difficultyLevel'] == null).toList();
          
          // Convert to the format we need
          for (var mcq in filteredMcqs) {
            allMcqs.add({
              'id': mcq['id'],
              'question': mcq['question'],
              'options': List<String>.from(mcq['options']),
              'correctAnswerIndex': mcq['correctAnswerIndex'],
              'explanation': mcq['explanation'],
              'difficultyLevel': mcq['difficultyLevel'] ?? 'MEDIUM'
            });
          }
        }
      }
      
      // Pop the loading dialog
      Navigator.pop(context);
      
      if (allMcqs.isEmpty) {
        showErrorDialog('No MCQs found for the selected difficulty');
        return;
      }
      
      // Shuffle and limit the questions
      allMcqs.shuffle();
      if (allMcqs.length > questionCount) {
        allMcqs = allMcqs.sublist(0, questionCount);
      }
      
      // Navigate to the MCQ quiz with the fetched questions
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TopicMCQQuizScreen(
            topic: '',
            timeLimitMinutes: duration,
            mcqs: allMcqs,
            testTitle: '${widget.exam} - ${mockTestSets.firstWhere((set) => 
              set['questions'] == questionCount && 
              set['duration'] == duration &&
              set['difficulty'] == difficulty
            )['title']}',
          ),
        ),
      );
    } catch (e) {
      // Pop the loading dialog if it's still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      showErrorDialog('Error: ${e.toString()}');
    }
  }
  
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ===============================
// Topic MCQ Quiz Screen (for large test sets)
// ===============================
class TopicMCQQuizScreen extends StatefulWidget {
  final String topic;
  final int timeLimitMinutes;
  final List<Map<String, dynamic>> mcqs;
  final String testTitle;
  
  const TopicMCQQuizScreen({
    super.key, 
    required this.topic,
    required this.timeLimitMinutes,
    required this.mcqs,
    required this.testTitle,
  });

  @override
  TopicMCQQuizScreenState createState() => TopicMCQQuizScreenState();
}

class TopicMCQQuizScreenState extends State<TopicMCQQuizScreen> {
  int currentQuestionIndex = 0;
  late List<int?> userAnswers;
  bool quizCompleted = false;
  
  // Timer related variables
  int remainingSeconds = 0;
  Timer? timer;
  
  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(widget.mcqs.length, null);
    
    // Set up the timer
    remainingSeconds = widget.timeLimitMinutes * 60;
    startTimer();
  }
  
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          // Time's up
          timer.cancel();
          if (!quizCompleted) {
            quizCompleted = true;
            // Show a dialog informing the user that time is up
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Time\'s Up!'),
                content: const Text('Your time has expired. Let\'s see your results.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('View Results'),
                  ),
                ],
              ),
            );
          }
        }
      });
    });
  }
  
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < widget.mcqs.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        quizCompleted = true;
        timer?.cancel(); // Stop the timer when quiz is completed
      });
    }
  }

  void goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }
  
  int calculateScore() {
    int score = 0;
    for (int i = 0; i < widget.mcqs.length; i++) {
      if (userAnswers[i] == widget.mcqs[i]['correctAnswerIndex']) {
        score++;
      }
    }
    return score;
  }
  
  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      userAnswers = List.filled(widget.mcqs.length, null);
      quizCompleted = false;
      
      // Reset timer
      remainingSeconds = widget.timeLimitMinutes * 60;
      startTimer();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                formatTime(remainingSeconds),
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: quizCompleted
          ? _buildResultScreen()
          : _buildQuizScreen(),
    );
  }

  Widget _buildQuizScreen() {
    if (widget.mcqs.isEmpty) {
      return const Center(child: Text('No questions available'));
    }

    Map<String, dynamic> currentQuestion = widget.mcqs[currentQuestionIndex];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Progress
          Row(
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} of ${widget.mcqs.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: remainingSeconds < 60 
                      ? Colors.red 
                      : remainingSeconds < 300 
                          ? Colors.orange 
                          : Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  formatTime(remainingSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / widget.mcqs.length,
            minHeight: 10,
          ),
          const SizedBox(height: 24),

          // Question
          Text(
            currentQuestion['question'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Options
          ...List.generate(
            currentQuestion['options'].length,
            (index) => RadioListTile<int>(
              title: Text(currentQuestion['options'][index]),
              value: index,
              groupValue: userAnswers[currentQuestionIndex],
              onChanged: (value) {
                setState(() {
                  userAnswers[currentQuestionIndex] = value;
                });
              },
            ),
          ),

          const Spacer(),

          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: currentQuestionIndex > 0 ? goToPreviousQuestion : null,
                child: const Text('Previous'),
              ),
              ElevatedButton(
                onPressed: () => goToNextQuestion(),
                child: Text(currentQuestionIndex < widget.mcqs.length - 1 ? 'Next' : 'Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    int score = calculateScore();
    double percentage = (score / widget.mcqs.length) * 100;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Quiz Completed!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Score: $score out of ${widget.mcqs.length}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Percentage: ${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 24),
          
          // Performance message
          Text(
            percentage >= 70
                ? 'Great job! You did well!'
                : percentage >= 40
                    ? 'Good effort! Keep practicing.'
                    : 'Keep studying! You\'ll do better next time.',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: restartQuiz,
            child: const Text('Restart Quiz', style: TextStyle(fontSize: 16)),
          ),
          
          const SizedBox(height: 16),
          
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MCQReviewScreen(
                    mcqs: widget.mcqs,
                    userAnswers: userAnswers,
                  ),
                ),
              );
            },
            child: const Text('Review Answers', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ===============================
// 5 Subject Selection Screen
// ===============================
class SubjectSelectionScreen extends StatefulWidget {
  final String topic;
  final bool isMockTest;
  
  const SubjectSelectionScreen({
    super.key, 
    required this.topic, 
    this.isMockTest = false,
  });

  @override
  SubjectSelectionScreenState createState() => SubjectSelectionScreenState();
}

class SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  List<String> subjects = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    String apiUrl = '$BASE_API_URL/subjects?topic=${widget.topic}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          subjects = List<String>.from(json.decode(response.body));
          isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isMockTest 
            ? Text('Subject Mock Tests') 
            : Text('Subjects for ${widget.topic}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(subjects[index]),
                      trailing: widget.isMockTest 
                          ? const Icon(Icons.quiz) 
                          : const Icon(Icons.arrow_forward),
                      onTap: () {
                        if (widget.isMockTest) {
                          // For mock tests, go directly to the MCQ quiz with 15 questions
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MCQQuizScreen(
                                topic: widget.topic,
                                subject: subjects[index],
                                questionCount: 15, // 15 MCQs for subject tests
                                timeLimitMinutes: 15, // 15 minutes for subject tests
                              ),
                            ),
                          );
                        } else {
                          // For regular subjects, show material screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MaterialScreen(
                                topic: widget.topic,
                                subject: subjects[index],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}

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
        Uri.parse('$BASE_API_URL/pdfs?topic=${widget.topic}&subject=${widget.subject}')
      );
      
      // Fetch Docs
      final docResponse = await http.get(
        Uri.parse('$BASE_API_URL/docs?topic=${widget.topic}&subject=${widget.subject}')
      );
      
      // Fetch Videos
      final videoResponse = await http.get(
        Uri.parse('$BASE_API_URL/videos?topic=${widget.topic}&subject=${widget.subject}')
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

// ===============================
// 7 MCQ Quiz Screen
// ===============================
class MCQQuizScreen extends StatefulWidget {
  final String topic;
  final String subject;
  final int questionCount;
  final int timeLimitMinutes;
  
  const MCQQuizScreen({
    super.key, 
    this.topic = "", 
    required this.subject,
    this.questionCount = 10,
    this.timeLimitMinutes = 0,
  });

  @override
  MCQQuizScreenState createState() => MCQQuizScreenState();
}

class MCQQuizScreenState extends State<MCQQuizScreen> {
  List<Map<String, dynamic>> mcqs = [];
  bool isLoading = true;
  String? errorMessage;
  int currentQuestionIndex = 0;
  List<int?> userAnswers = [];
  bool quizCompleted = false;
  
  // Timer related variables
  bool hasTimeLimit = false;
  int remainingSeconds = 0;
  Timer? timer;
  
  @override
  void initState() {
    super.initState();
    fetchMCQs();
    
    // Set up the timer if there's a time limit
    if (widget.timeLimitMinutes > 0) {
      hasTimeLimit = true;
      remainingSeconds = widget.timeLimitMinutes * 60;
      startTimer();
    }
  }
  
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          // Time's up
          timer.cancel();
          if (!quizCompleted) {
            quizCompleted = true;
            // Show a dialog informing the user that time is up
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Time\'s Up!'),
                content: const Text('Your time has expired. Let\'s see your results.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('View Results'),
                  ),
                ],
              ),
            );
          }
        }
      });
    });
  }
  
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> fetchMCQs() async {
    try {
      // Use the simpler MCQ endpoint that just takes a subject
      final response = await http.get(
        Uri.parse('$BASE_API_URL/mcqs/${widget.subject}')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> mcqData = json.decode(response.body);
        
        setState(() {
          mcqs = mcqData.map((mcq) => {
            'id': mcq['id'],
            'question': mcq['question'],
            'options': List<String>.from(mcq['options']),
            'correctAnswerIndex': mcq['correctAnswerIndex'],
            'explanation': mcq['explanation'],
            'difficultyLevel': mcq['difficultyLevel'] ?? 'MEDIUM'
          }).toList();
          
          // If we have more MCQs than requested, take a random subset
          if (mcqs.length > widget.questionCount && widget.questionCount > 0) {
            mcqs.shuffle();
            mcqs = mcqs.sublist(0, widget.questionCount);
          }
          
          userAnswers = List.filled(mcqs.length, null);
          isLoading = false;
        });
        
        // Record these MCQs in the user session
        for (var mcq in mcqs) {
          if (mcq['id'] != null) {
            UserSession().recordMcq(mcq['id']);
          }
        }
      } else {
        throw Exception("Failed to load MCQs.");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < mcqs.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        quizCompleted = true;
        timer?.cancel(); // Stop the timer when quiz is completed
      });
    }
  }

  void goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  int calculateScore() {
    int score = 0;
    for (int i = 0; i < mcqs.length; i++) {
      if (userAnswers[i] == mcqs[i]['correctAnswerIndex']) {
        score++;
      }
    }
    return score;
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      userAnswers = List.filled(mcqs.length, null);
      quizCompleted = false;
      
      // Reset timer if there's a time limit
      if (hasTimeLimit) {
        remainingSeconds = widget.timeLimitMinutes * 60;
        startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String quizTitle = widget.subject == 'Full Test' 
        ? 'Full Mock Test' 
        : 'MCQ Quiz - ${widget.subject}';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(quizTitle),
        actions: hasTimeLimit ? [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                formatTime(remainingSeconds),
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ] : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : quizCompleted
                  ? _buildResultScreen()
                  : _buildQuizScreen(),
    );
  }

  Widget _buildQuizScreen() {
    if (mcqs.isEmpty) {
      return const Center(child: Text('No MCQs available'));
    }

    Map<String, dynamic> currentQuestion = mcqs[currentQuestionIndex];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Progress
          Row(
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} of ${mcqs.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (hasTimeLimit) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: remainingSeconds < 60 
                        ? Colors.red 
                        : remainingSeconds < 300 
                            ? Colors.orange 
                            : Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    formatTime(remainingSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / mcqs.length,
            minHeight: 10,
          ),
          const SizedBox(height: 24),

          // Question
          Text(
            currentQuestion['question'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Options
          ...List.generate(
            currentQuestion['options'].length,
            (index) => RadioListTile<int>(
              title: Text(currentQuestion['options'][index]),
              value: index,
              groupValue: userAnswers[currentQuestionIndex],
              onChanged: (value) {
                setState(() {
                  userAnswers[currentQuestionIndex] = value;
                });
              },
            ),
          ),

          const Spacer(),

          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: currentQuestionIndex > 0 ? goToPreviousQuestion : null,
                child: const Text('Previous'),
              ),
              ElevatedButton(
                onPressed: () => goToNextQuestion(),
                child: Text(currentQuestionIndex < mcqs.length - 1 ? 'Next' : 'Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    int score = calculateScore();
    double percentage = (score / mcqs.length) * 100;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Quiz Completed!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Score: $score out of ${mcqs.length}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Percentage: ${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 24),
          
          // Performance message
          Text(
            percentage >= 70
                ? 'Great job! You did well!'
                : percentage >= 40
                    ? 'Good effort! Keep practicing.'
                    : 'Keep studying! You\'ll do better next time.',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: restartQuiz,
            child: const Text('Restart Quiz', style: TextStyle(fontSize: 16)),
          ),
          
          const SizedBox(height: 16),
          
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MCQReviewScreen(
                    mcqs: mcqs,
                    userAnswers: userAnswers,
                  ),
                ),
              );
            },
            child: const Text('Review Answers', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ===============================
// 8 MCQ Review Screen
// ===============================
class MCQReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> mcqs;
  final List<int?> userAnswers;
  
  const MCQReviewScreen({
    super.key,
    required this.mcqs,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Review'),
      ),
      body: ListView.builder(
        itemCount: mcqs.length,
        itemBuilder: (context, index) {
          bool isCorrect = userAnswers[index] == mcqs[index]['correctAnswerIndex'];
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number and correctness indicator
                  Row(
                    children: [
                      Text(
                        'Question ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCorrect ? 'Correct' : 'Incorrect',
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Question
                  Text(
                    mcqs[index]['question'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  
                  // Options
                  ...List.generate(
                    mcqs[index]['options'].length,
                    (optionIndex) {
                      bool isCorrectOption = optionIndex == mcqs[index]['correctAnswerIndex'];
                      bool isSelectedOption = optionIndex == userAnswers[index];
                      
                      Color? bgColor;
                      if (isCorrectOption) {
                        bgColor = Colors.green.withOpacity(0.2);
                      } else if (isSelectedOption) {
                        bgColor = Colors.red.withOpacity(0.2);
                      }
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCorrectOption
                                ? Colors.green
                                : isSelectedOption
                                    ? Colors.red
                                    : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${String.fromCharCode(65 + optionIndex)}. ${mcqs[index]['options'][optionIndex]}',
                            ),
                            if (isCorrectOption) ...[
                              const Spacer(),
                              const Icon(Icons.check, color: Colors.green),
                            ] else if (isSelectedOption) ...[
                              const Spacer(),
                              const Icon(Icons.close, color: Colors.red),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Explanation
                  const Text(
                    'Explanation:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(mcqs[index]['explanation']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

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

// ===============================
// CategoryMaterialScreen - For category-specific materials
// ===============================
class CategoryMaterialScreen extends StatefulWidget {
  final String title;
  final MaterialType materialType;
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
        Uri.parse('$BASE_API_URL/subjects/${widget.groupId}/${widget.subgroupId}/${widget.examId}')
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subjects = data.map((subject) => Subject(
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
                        if (widget.materialType == MaterialType.pdf || 
                            widget.materialType == MaterialType.pdfAndDoc || 
                            widget.materialType == MaterialType.all)
                          _buildMaterialSection('PDFs', pdfs, Icons.picture_as_pdf),
                        
                        if (widget.materialType == MaterialType.pdf || 
                            widget.materialType == MaterialType.pdfAndDoc || 
                            widget.materialType == MaterialType.all)
                          const SizedBox(height: 24),
                        
                        if (widget.materialType == MaterialType.doc || 
                            widget.materialType == MaterialType.pdfAndDoc || 
                            widget.materialType == MaterialType.all)
                          _buildMaterialSection('Documents', docs, Icons.article),
                        
                        if (widget.materialType == MaterialType.doc || 
                            widget.materialType == MaterialType.pdfAndDoc || 
                            widget.materialType == MaterialType.all)
                          const SizedBox(height: 24),
                        
                        if (widget.materialType == MaterialType.video || 
                            widget.materialType == MaterialType.all)
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

// Helper Subject class for CategoryMaterialScreen
class Subject {
  final String name;
  final List<String> pdfs;
  final List<String> docs;
  final List<String> videos;
  
  Subject({
    required this.name, 
    this.pdfs = const [], 
    this.docs = const [], 
    this.videos = const []
  });
}

// ===============================
// Subject List Screen for Mock Tests
// ===============================
class SubjectListScreen extends StatefulWidget {
  final String exam;
  final String groupId;
  final String subgroupId;
  final String examId;
  
  const SubjectListScreen({
    super.key,
    required this.exam,
    required this.groupId,
    required this.subgroupId,
    required this.examId,
  });

  @override
  SubjectListScreenState createState() => SubjectListScreenState();
}

class SubjectListScreenState extends State<SubjectListScreen> {
  List<dynamic> subjectsData = [];
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
        Uri.parse('$BASE_API_URL/subjects/${widget.groupId}/${widget.subgroupId}/${widget.examId}')
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subjectsData = data;
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
      appBar: AppBar(
        title: Text('Subject Tests for ${widget.exam}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : subjectsData.isEmpty
                  ? const Center(child: Text('No subjects available'))
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListView.builder(
                        itemCount: subjectsData.length,
                        itemBuilder: (context, index) {
                          final subject = subjectsData[index];
                          final subjectName = subject['name'] ?? 'Unknown Subject';
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                subjectName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: const Text('20 MCQs • 20 Minutes'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MCQQuizScreen(
                                      subject: subjectName,
                                      questionCount: 20,
                                      timeLimitMinutes: 20,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
} 