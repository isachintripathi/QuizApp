import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/user_details_form.dart';

class UserDetailsScreen extends StatelessWidget {
  final String quizType;
  final String quizName;
  final Function(User user) onUserSubmit;

  const UserDetailsScreen({
    Key? key,
    required this.quizType,
    required this.quizName,
    required this.onUserSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz Information',
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('Type: $quizType'),
                  Text('Name: $quizName'),
                ],
              ),
            ),
            UserDetailsForm(
              onSubmit: (User user) {
                onUserSubmit(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<User?> show({
    required BuildContext context,
    required String quizType,
    required String quizName,
  }) async {
    return await showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: UserDetailsScreen(
                quizType: quizType,
                quizName: quizName,
                onUserSubmit: (user) {
                  Navigator.of(context).pop(user);
                },
              ),
            );
          },
        );
      },
    );
  }
} 