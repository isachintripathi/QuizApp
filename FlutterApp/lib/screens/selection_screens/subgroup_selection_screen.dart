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
          subGroups = data.map((subGroup) => subGroup['name'] as String).toList();
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.25,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: subGroups.length,
                itemBuilder: (context, index) {
                  final subgroupName = subGroups[index];
                  final subgroupId = subGroupsData[index]['id'];
                  
                  // Choose an icon based on subgroup name
                  IconData iconData;
                  if (subgroupName.toLowerCase().contains('school')) {
                    iconData = Icons.school;
                  } else if (subgroupName.toLowerCase().contains('college')) {
                    iconData = Icons.account_balance;
                  } else if (subgroupName.toLowerCase().contains('competitive')) {
                    iconData = Icons.diversity_3;
                  } else if (subgroupName.toLowerCase().contains('government')) {
                    iconData = Icons.account_balance_wallet;
                  } else if (subgroupName.toLowerCase().contains('entrance')) {
                    iconData = Icons.door_front_door;
                  } else {
                    iconData = Icons.category;
                  }
                  
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: subgroupName,
                        waitDuration: const Duration(milliseconds: 200),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExamSelectionScreen(
                                  subGroup: subgroupName,
                                  groupId: widget.groupId,
                                  subgroupId: subgroupId,
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
                                    subgroupName,
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
