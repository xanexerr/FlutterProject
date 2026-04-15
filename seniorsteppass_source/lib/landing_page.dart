import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen/main_screen.dart';
import 'services/current_user_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String _currentUser = 'User';
  int _projectCount = 0;
  int _internshipCount = 0;
  int _usersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadStatistics();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userData = await CurrentUserService().fetchCurrentUserData();
      if (userData != null && mounted) {
        setState(() => _currentUser = userData.full_name ?? 'User');
      }
    } catch (e) {
      // Handle error silently, keep default 'User'
    }
  }

  Future<void> _loadStatistics() async {
    try {
      // Get project count
      final projectsSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .count()
          .get();
      
      // Get internships count
      final internshipsSnapshot = await FirebaseFirestore.instance
          .collection('internships')
          .count()
          .get();
      
      // Get users count
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .count()
          .get();

      if (mounted) {
        setState(() {
          _projectCount = projectsSnapshot.count ?? 0;
          _internshipCount = internshipsSnapshot.count ?? 0;
          _usersCount = usersSnapshot.count ?? 0;
        });
      }
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              color: AppTheme.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  Text(
                    '$_currentUser',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Discover your next opportunity with Senior Step Pass',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.primaryTeal,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textTeal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('$_projectCount', 'Project', Icons.folder_open),
                      _buildStatCard('$_internshipCount', 'Internship', Icons.computer),
                      _buildStatCard('$_usersCount', 'Users', Icons.bar_chart),
                    ],
                  ),
                ],
              ),
            ),

            // Explore Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: AppTheme.lightYellow),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        'Explore ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      Icon(
                        Icons.explore_outlined,
                        color: AppTheme.primaryTeal,
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildActionBtn(
                          'Find Project',
                          AppTheme.primaryTeal,
                          AppTheme.white,
                          context,
                          initialFilters: {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionBtn(
                          'Find Internship',
                          AppTheme.primaryTeal,
                          AppTheme.white,
                          context,
                          initialFilters: {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildActionBtn(
                          'Software Engineer',
                          AppTheme.darkYellow,
                          AppTheme.primaryTeal,
                          context,
                          initialFilters: {'Software Engineer'},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionBtn(
                          'Software Engineer',
                          AppTheme.darkYellow,
                          AppTheme.primaryTeal,
                          context,
                          initialFilters: {'Software Engineer'},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildActionBtn(
                          'Data Science',
                          AppTheme.darkYellow,
                          AppTheme.primaryTeal,
                          context,
                          initialFilters: {'Data Science'},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionBtn(
                          'Data Science',
                          AppTheme.darkYellow,
                          AppTheme.primaryTeal,
                          context,
                          initialFilters: {'Data Science'},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildActionBtn(
                          'IOT',
                          AppTheme.darkYellow,
                          AppTheme.primaryTeal,
                          context,
                          initialFilters: {'Internet Of Thing'},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionBtn(
                          'IOT',
                          AppTheme.darkYellow,
                          AppTheme.primaryTeal,
                          context,
                          initialFilters: {'Internet Of Thing'},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildActionBtn(
                          'Cyber Security',
                          AppTheme.darkYellow,
                          AppTheme.primaryTeal,
                          context,
                          initialFilters: {'Cyber Security'},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionBtn(
                          'Cyber Security',
                          AppTheme.darkYellow,
                          AppTheme.primaryTeal,
                          context,
                          initialFilters: {'Cyber Security'},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String count, String label, IconData icon) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive width based on available space
        // Default size: 110x120 (width:height ratio = 0.917)
        final double baseWidth = 90;
        final double baseHeight = 110;
        final double aspectRatio = baseWidth / baseHeight;
        
        // Use max 110 width on normal screens, scale down on smaller screens
        final double cardWidth = constraints.maxWidth > baseWidth 
            ? baseWidth 
            : constraints.maxWidth * 0.85;
        final double cardHeight = cardWidth / aspectRatio;

        return Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.white, size: cardWidth * 0.25),
              SizedBox(height: cardHeight * 0.08),
              Text(
                count,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.white,
                  fontSize: cardWidth * 0.18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: cardHeight * 0.04),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.white,
                  fontSize: cardWidth * 0.11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionBtn(
    String title,
    Color bgColor,
    Color textColor,
    BuildContext context, {
    required Set<String> initialFilters,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MainScreen(initialIndex: 1, projectFilters: initialFilters),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
