import 'package:quiz_app/screens/selection_screens/subject_selection_screen.dart';
import '../mcq_stats_screen.dart';
import 'selection_screens/group_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_app_bar.dart';
import 'material_screen.dart';
import 'mcq_screens/mcq_quiz_screen.dart';
import '../services/favorite_service.dart';
import 'selection_screens/topic_selection_screen.dart';
import 'search_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'dart:async';
import 'pdf_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<FavoriteExam> favoriteExams = [];
  bool isLoading = true;
  
  // For auto-shifting ads
  final PageController _adPageController = PageController();
  int _currentAdPage = 0;
  Timer? _adTimer;
  
  // For tab controller
  late TabController _tabController;
  
  // For bottom navigation
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  // Sample data for testimonials
  final List<Map<String, dynamic>> testimonials = [
    {
      'name': 'Saurabh T',
      'rating': 5,
      'review': 'This app has completely transformed my study routine. Highly recommended!',
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Shraddha Tiwari',
      'rating': 4,
      'review': 'Great content and easy to navigate. Helped me prepare for my exams.',
      'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'name': 'Sachin',
      'rating': 5,
      'review': 'The best educational app I\'ve used. The material is comprehensive and well-organized.',
      'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'name': 'Rajani K',
      'rating': 5,
      'review': 'I love the quiz feature. It helps me test my knowledge effectively.',
      'avatar': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      'name': 'D Mayank',
      'rating': 4,
      'review': 'Very useful for my competitive exam preparation. Thank you!',
      'avatar': 'https://randomuser.me/api/portraits/men/5.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    loadFavorites();
    
    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);
    
    // Start auto-shifting ads
    _startAdTimer();
  }
  
  void _startAdTimer() {
    _adTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentAdPage < 2) {
        _currentAdPage++;
      } else {
        _currentAdPage = 0;
      }
      _adPageController.animateToPage(
        _currentAdPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _adPageController.dispose();
    _tabController.dispose();
    _pageController.dispose();
    _adTimer?.cancel();
    super.dispose();
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
    final themeService = Provider.of<ThemeService>(context);
    final notificationService = Provider.of<NotificationService>(context);
    final userService = Provider.of<UserService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Define theme-aware colors
    final cardBgColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final shadowColor = isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.2);
    final highlightColor = Theme.of(context).primaryColor;
    final subtleColor = isDarkMode ? Colors.grey[700] : Colors.grey[200];
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    
    final cardDecoration = BoxDecoration(
      color: cardBgColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Educational App',
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Consumer<UserService>(
              builder: (context, userService, child) {
                return DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 30, color: Colors.blue),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userService.isLoggedIn
                            ? userService.userProfile!.name
                            : 'Welcome, Guest',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (userService.isLoggedIn)
                        Text(
                          userService.userProfile!.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Select Group'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
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
                Navigator.pushReplacement(
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
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Documents'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfViewerScreen(
                      title: 'PDF Documents',
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.star_rate),
              title: const Text('Rate Us'),
              onTap: () {
                Navigator.pop(context);
                // Show a rating dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Rate Our App'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('How would you rate your experience?'),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 36,
                                ),
                                onPressed: () {
                                  // Handle rating
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Thanks for rating ${index + 1} stars!'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share App'),
              onTap: () {
                Navigator.pop(context);
                // Show a share dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Share Our App'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Share this app with your friends!'),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(Icons.messenger_outline, color: Colors.blue, size: 36),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sharing via Messenger'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.email, color: Colors.red, size: 36),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sharing via Email'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.chat, color: Colors.green, size: 36),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sharing via WhatsApp'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            // Home Tab
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: highlightColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: highlightColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${userService.isLoggedIn ? userService.userProfile!.name : 'Guest'}!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome to your personalized learning experience',
                            style: TextStyle(
                              fontSize: 16,
                              color: subtleTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Rectangle 1: Auto-shifting Ads
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Featured Content',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: PageView(
                              controller: _adPageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentAdPage = index;
                                });
                              },
                              children: [
                                _buildAdCard(
                                  'New Course Available',
                                  'Check out our latest course on Advanced Mathematics',
                                  Icons.school,
                                  Colors.blue,
                                  isDarkMode,
                                ),
                                _buildAdCard(
                                  'Special Offer',
                                  'Get 20% off on premium membership for a limited time',
                                  Icons.local_offer,
                                  Colors.orange,
                                  isDarkMode,
                                ),
                                _buildAdCard(
                                  'Study Tips',
                                  'Learn effective study techniques from our experts',
                                  Icons.lightbulb,
                                  Colors.green,
                                  isDarkMode,
                                ),
                              ],
                            ),
                          ),
                          // Page indicators
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentAdPage == index
                                        ? highlightColor
                                        : subtleColor,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Rectangle 2: Tabs
                    Container(
                      width: double.infinity,
                      decoration: cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: TabBar(
                              controller: _tabController,
                              labelColor: highlightColor,
                              unselectedLabelColor: subtleTextColor,
                              indicatorColor: highlightColor,
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Get Started'),
                                Tab(text: 'Latest News'),
                                Tab(text: 'Books'),
                              ],
                            ),
                          ),
                          _buildTabBarView(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Rectangle 3: Testimonials
                    Container(
                      width: double.infinity,
                      decoration: cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'What Our Users Say',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: testimonials.length,
                              itemBuilder: (context, index) {
                                final testimonial = testimonials[index];
                                return Container(
                                  width: 300,
                                  margin: const EdgeInsets.only(left: 16, bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[850] : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.grey[700]! : Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(testimonial['avatar']),
                                            radius: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                testimonial['name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: textColor,
                                                ),
                                              ),
                                              Row(
                                                children: List.generate(5, (i) {
                                                  return Icon(
                                                    i < testimonial['rating']
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: Colors.amber,
                                                    size: 16,
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        testimonial['review'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: subtleTextColor,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Rectangle 4: Community
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Join Our Community',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCommunityButton(
                                'YouTube',
                                Icons.youtube_searched_for,
                                Colors.red,
                                () {
                                  // Open YouTube channel
                                },
                                isDarkMode,
                              ),
                              _buildCommunityButton(
                                'LinkedIn',
                                Icons.link,
                                Colors.blue,
                                () {
                                  // Open LinkedIn page
                                },
                                isDarkMode,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Favorites Tab
            _buildFavoritesScreen(),
            
            // Purchases Tab
            _buildPurchasesScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'My Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'My Purchases',
          ),
        ],
        selectedItemColor: highlightColor,
        unselectedItemColor: subtleTextColor,
        backgroundColor: cardBgColor,
        elevation: 8,
      ),
    );
  }
  
  Widget _buildAdCard(String title, String description, IconData icon, Color color, bool isDarkMode) {
    final cardColor = isDarkMode ? Colors.grey[850] : color.withOpacity(0.1);
    final borderColor = isDarkMode ? color.withOpacity(0.5) : color.withOpacity(0.3);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: subtleTextColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNewsItem(String title, String description, String time, bool isDarkMode) {
    final bgColor = isDarkMode ? Colors.grey[850] : Colors.grey.withOpacity(0.1);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: subtleTextColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookItem(String title, String author, String rating, bool isDarkMode) {
    final bgColor = isDarkMode ? Colors.grey[850] : Colors.grey.withOpacity(0.1);
    final coverColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              color: coverColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.book,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtleTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  rating,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommunityButton(String platform, IconData icon, Color color, VoidCallback onTap, bool isDarkMode) {
    final bgColor = isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.1);
    final borderColor = isDarkMode ? color.withOpacity(0.5) : color.withOpacity(0.3);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              platform,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Favorites Screen
  Widget _buildFavoritesScreen() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final highlightColor = Theme.of(context).primaryColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    final cardBgColor = isDarkMode ? Colors.grey[800] : Colors.white;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Favorite Exams',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : favoriteExams.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 80,
                              color: subtleTextColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No favorites yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add exams to your favorites to see them here',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: subtleTextColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GroupSelectionScreen(),
                                  ),
                                ).then((_) {
                                  loadFavorites();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                backgroundColor: highlightColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Browse Exams'),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: favoriteExams.length,
                        itemBuilder: (context, index) {
                          final exam = favoriteExams[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
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
                                ).then((_) {
                                  loadFavorites();
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: highlightColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.school,
                                        size: 40,
                                        color: highlightColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: Text(
                                        exam.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await FavoriteService.removeFavorite(exam.examId);
                                        loadFavorites();
                                      },
                                      tooltip: 'Remove from favorites',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  // Purchases Screen
  Widget _buildPurchasesScreen() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final highlightColor = Theme.of(context).primaryColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Purchased Courses',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: subtleTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No purchases yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your purchased courses will appear here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: subtleTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to store or premium content
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      backgroundColor: highlightColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Browse Premium Content'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fix the TabBarView to prevent overflow
  Widget _buildTabBarView() {
    return SizedBox(
      height: 250,
      child: TabBarView(
        controller: _tabController,
        children: [
          // Get Started Tab
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Your Learning Journey',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GroupSelectionScreen()),
                      ).then((_) {
                        loadFavorites();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Get Started', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Explore our comprehensive study materials and challenging quizzes to enhance your learning experience.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (favoriteExams.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your favorites are now in the "My Favorites" tab',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        Icon(
                          Icons.arrow_downward,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Latest News Tab
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest Educational News',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNewsItem(
                    'New Education Policy Announced',
                    'The government has announced a new education policy...',
                    '2 hours ago',
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                  const SizedBox(height: 12),
                  _buildNewsItem(
                    'Online Learning Trends',
                    'Online learning has seen a significant increase...',
                    '1 day ago',
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                  const SizedBox(height: 12),
                  _buildNewsItem(
                    'Exam Schedule Updates',
                    'Important updates regarding upcoming exam schedules...',
                    '2 days ago',
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                ],
              ),
            ),
          ),
          
          // Books Tab
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Books',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBookItem(
                    'Mathematics for Competitive Exams',
                    'By John Smith',
                    '4.5 ★',
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                  const SizedBox(height: 12),
                  _buildBookItem(
                    'General Knowledge 2023',
                    'By Sarah Johnson',
                    '4.3 ★',
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                  const SizedBox(height: 12),
                  _buildBookItem(
                    'English Grammar Mastery',
                    'By Michael Brown',
                    '4.7 ★',
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
