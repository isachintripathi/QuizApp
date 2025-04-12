import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../widgets/custom_app_bar.dart';
import 'subgroup_selection_screen.dart';
import '../../utils/ui_constants.dart';

const String baseApiUrl = 'http://192.168.1.37:8080/api';

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
      backgroundColor: UIConstants.getScaffoldBackgroundColor(context),
      appBar: const CustomAppBar(
        title: 'Select a Group',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? _buildErrorMessage()
          : _buildGroupsGrid(),
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
              onPressed: fetchGroups,
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
  
  Widget _buildGroupsGrid() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: UIConstants.paddingSmall,
              bottom: UIConstants.paddingMedium,
            ),
            child: Text(
              'Choose a category to continue',
              style: UIConstants.getSubtitleTextStyle(context),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: UIConstants.getGridDelegate(context: context),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final groupName = groups[index];
                final groupId = groupsData[index]['id'];
                final iconData = _getIconForGroup(groupName);
                
                return _buildGroupCard(groupName, groupId, iconData);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getIconForGroup(String groupName) {
    if (groupName.toLowerCase().contains('teaching') || 
        groupName.toLowerCase().contains('education')) {
      return Icons.school;
    } else if (groupName.toLowerCase().contains('banking')) {
      return Icons.account_balance;
    } else if (groupName.toLowerCase().contains('defence') || 
              groupName.toLowerCase().contains('military')) {
      return Icons.security;
    } else if (groupName.toLowerCase().contains('engineering')) {
      return Icons.engineering;
    } else if (groupName.toLowerCase().contains('medical')) {
      return Icons.medical_services;
    } else {
      return Icons.book;
    }
  }
  
  Widget _buildGroupCard(String groupName, String groupId, IconData iconData) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Card(
      elevation: UIConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          message: groupName,
          waitDuration: const Duration(milliseconds: 200),
          child: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SubGroupSelectionScreen(
                    group: groupName,
                    groupId: groupId,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
            hoverColor: primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(UIConstants.paddingMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(UIConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      size: 40,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: UIConstants.paddingMedium),
                  Expanded(
                    child: Text(
                      groupName,
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
            ),
          ),
        ),
      ),
    );
  }
}
