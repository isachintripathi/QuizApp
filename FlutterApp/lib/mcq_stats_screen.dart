import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Import for UserSession and BASE_API_URL

class MCQStatsScreen extends StatefulWidget {
  const MCQStatsScreen({super.key});

  @override
  MCQStatsScreenState createState() => MCQStatsScreenState();
}

class MCQStatsScreenState extends State<MCQStatsScreen> {
  bool isLoading = true;
  Map<String, dynamic> stats = {};
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_API_URL/mcq-stats')
      );
      
      if (response.statusCode == 200) {
        setState(() {
          stats = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load MCQ statistics');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCQ Statistics'),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : errorMessage != null
            ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Question Database Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildStatCard(
                      'Total MCQs', 
                      stats['totalMCQs']?.toString() ?? '0',
                      Icons.quiz,
                      Colors.blue,
                    ),
                    
                    const SizedBox(height: 16),
                    const Text(
                      'MCQs by Difficulty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (stats['byDifficulty'] != null)
                      _buildDifficultyStats(stats['byDifficulty']),
                    
                    const SizedBox(height: 16),
                    const Text(
                      'MCQs by Topic',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (stats['byTopic'] != null)
                      Expanded(
                        child: _buildTopicStats(stats['byTopic']),
                      ),
                      
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _resetUserTracking();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset My Question History'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDifficultyStats(Map<String, dynamic> difficultyStats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Easy', 
            difficultyStats['EASY']?.toString() ?? '0',
            Icons.sentiment_very_satisfied,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatCard(
            'Medium', 
            difficultyStats['MEDIUM']?.toString() ?? '0',
            Icons.sentiment_satisfied,
            Colors.orange,
          ),
        ),
        Expanded(
          child: _buildStatCard(
            'Hard', 
            difficultyStats['HARD']?.toString() ?? '0',
            Icons.sentiment_very_dissatisfied,
            Colors.red,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTopicStats(Map<String, dynamic> topicStats) {
    final entries = topicStats.entries.toList();
    
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final topic = entries[index].key;
        final subjectMap = entries[index].value as Map<String, dynamic>;
        final totalForTopic = subjectMap.values.fold<int>(
          0, (sum, count) => sum + (count as int));
        
        return ExpansionTile(
          title: Text(topic),
          subtitle: Text('$totalForTopic questions'),
          children: subjectMap.entries.map<Widget>((entry) {
            final subject = entry.key;
            final count = entry.value;
            
            return ListTile(
              title: Text(subject),
              trailing: Text('$count questions'),
              dense: true,
            );
          }).toList(),
        );
      },
    );
  }
  
  Future<void> _resetUserTracking() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Question History'),
        content: const Text(
          'This will reset your question history, allowing previously seen questions to appear again in your tests. Continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final response = await http.post(
                  Uri.parse('$BASE_API_URL/reset-mcq-tracking'),
                  body: {'userId': UserSession().userId},
                );
                
                if (response.statusCode == 200) {
                  // Clear local tracking as well
                  UserSession().clearRecentMcqs();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Question history has been reset'),
                      ),
                    );
                  }
                } else {
                  throw Exception('Failed to reset tracking');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
} 