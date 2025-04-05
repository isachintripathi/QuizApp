import 'package:uuid/uuid.dart'; // Add UUID package for user tracking

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