import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../widgets/custom_app_bar.dart';
import 'exams_selection_screen.dart';
import '../../utils/ui_constants.dart';

const String baseApiUrl = 'http://192.168.1.37:8080/api';

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
      backgroundColor: UIConstants.getScaffoldBackgroundColor(context),
      appBar: CustomAppBar(
        title: 'SubGroups for ${widget.group}',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? _buildErrorMessage()
          : _buildSubGroupsGrid(),
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
              onPressed: fetchSubGroups,
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
  
  Widget _buildSubGroupsGrid() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category breadcrumb
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
                  widget.group,
                  style: UIConstants.getBodyTextStyle(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          
          // Subgroup title
          Padding(
            padding: const EdgeInsets.only(
              left: UIConstants.paddingSmall,
              bottom: UIConstants.paddingMedium,
            ),
            child: Text(
              'Select a subcategory to continue',
              style: UIConstants.getSubtitleTextStyle(context),
            ),
          ),
          
          // Grid of subgroups
          Expanded(
            child: GridView.builder(
              gridDelegate: UIConstants.getGridDelegate(context: context),
              itemCount: subGroups.length,
              itemBuilder: (context, index) {
                final subgroupName = subGroups[index];
                final subgroupId = subGroupsData[index]['id'];
                final iconData = _getIconForSubGroup(subgroupName);
                
                return _buildSubGroupCard(subgroupName, subgroupId, iconData);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getIconForSubGroup(String subgroupName) {
    if (subgroupName.toLowerCase().contains('school')) {
      return Icons.school;
    } else if (subgroupName.toLowerCase().contains('college')) {
      return Icons.account_balance;
    } else if (subgroupName.toLowerCase().contains('competitive')) {
      return Icons.diversity_3;
    } else if (subgroupName.toLowerCase().contains('government')) {
      return Icons.account_balance_wallet;
    } else if (subgroupName.toLowerCase().contains('entrance')) {
      return Icons.door_front_door;
    } else {
      return Icons.category;
    }
  }
  
  Widget _buildSubGroupCard(String subGroupName, String subGroupId, IconData iconData) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Card(
      elevation: UIConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          message: subGroupName,
          waitDuration: const Duration(milliseconds: 200),
          child: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamSelectionScreen(
                    subGroup: subGroupName,
                    groupId: widget.groupId,
                    subgroupId: subGroupId,
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
                      subGroupName,
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
