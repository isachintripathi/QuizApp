import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'subgroup_selection_screen.dart';

const String baseApiUrl = 'http://localhost:8080/api';

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
    String apiUrl = '$baseApiUrl/groups';

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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.25,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final groupName = groups[index];
                  final groupId = groupsData[index]['id'];
                  
                  // Choose an icon based on group name
                  IconData iconData;
                  if (groupName.toLowerCase().contains('teaching') || 
                      groupName.toLowerCase().contains('education')) {
                    iconData = Icons.school;
                  } else if (groupName.toLowerCase().contains('banking')) {
                    iconData = Icons.account_balance;
                  } else if (groupName.toLowerCase().contains('defence') || 
                            groupName.toLowerCase().contains('military')) {
                    iconData = Icons.security;
                  } else if (groupName.toLowerCase().contains('engineering')) {
                    iconData = Icons.engineering;
                  } else if (groupName.toLowerCase().contains('medical')) {
                    iconData = Icons.medical_services;
                  } else {
                    iconData = Icons.book;
                  }
                  
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: groupName,
                        waitDuration: const Duration(milliseconds: 200),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubGroupSelectionScreen(
                                  group: groupName,
                                  groupId: groupId,
                                ),
                              ),
                            );
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
                                    size: 48,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    groupName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
