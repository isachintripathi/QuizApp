import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'exams_selection_screen.dart';

const String baseApiUrl = 'http://localhost:8080/api';

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
    String apiUrl = '$baseApiUrl/subgroups/${widget.groupId}';

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
