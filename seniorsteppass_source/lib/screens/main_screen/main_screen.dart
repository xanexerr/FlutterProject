import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../landing_page.dart';
import '../internship/internship_main.dart';
import '../../widgets/common_buttons.dart';
import '../project_main/project_main.dart';
import '../project_main/favorites_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final Set<String>? projectFilters;
  final Set<String>? projectCategoryFilters;
  final Set<String>? internshipFilters;

  const MainScreen({
    super.key, 
    this.initialIndex = 0, 
    this.projectFilters,
    this.projectCategoryFilters,
    this.internshipFilters,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late int _lastInitialIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _lastInitialIndex = widget.initialIndex;
  }

  List<Widget> get _buildPages => [
    const LandingPage(),
    ProjectMainScreen(
      key: ValueKey('project_${_currentIndex == 1 && _currentIndex == _lastInitialIndex ? widget.projectFilters : null}'),
      initialFilters: _currentIndex == 1 && _currentIndex == _lastInitialIndex ? widget.projectFilters : null,
      initialCategoryFilters: _currentIndex == 1 && _currentIndex == _lastInitialIndex ? widget.projectCategoryFilters : null,
    ),
    InternshipMainScreen(
      key: ValueKey('internship_${_currentIndex == 2 && _currentIndex == _lastInitialIndex ? widget.internshipFilters : null}'),
      initialFilters: _currentIndex == 2 && _currentIndex == _lastInitialIndex ? widget.internshipFilters : null,
    ),
    const FavoritesScreen(),
    const ProfileScreen(), // Profile Screen
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale factor: at 320px use 0.8, at 400px use 0.9, at 500px+ use 1.0
    final scaleFactor = screenWidth < 360 ? 0.8 : (screenWidth < 420 ? 0.9 : 1.0);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const MainHeader(),
      body: _buildPages[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: AppTheme.lightYellow,
            padding: EdgeInsets.symmetric(
              horizontal: 16.0 * scaleFactor,
              vertical: 4.0 * scaleFactor,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightYellow,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_filled, scaleFactor),
                  _buildNavItem(1, Icons.assignment_outlined, scaleFactor),
                  _buildNavItem(2, Icons.work_outline, scaleFactor),
                  _buildNavItem(3, Icons.bookmark_border, scaleFactor),
                  _buildNavItem(4, Icons.person_outline, scaleFactor),
                ],
              ),
            
            ),
            
          ),
          // Bottom spacing with same color as nav
          Container(
            width: double.infinity,
            height: 16,
            color: AppTheme.lightYellow,
          ),
          Container(
            width: double.infinity,
            height: 8,
            color: AppTheme.lightYellow,
          ),
        ],
      ),
      
    );
  }

  Widget _buildNavItem(int index, IconData icon, [double scaleFactor = 1.0]) {
    final isSelected = _currentIndex == index;
    final itemWidth = 65.0 * scaleFactor;
    final padding = 12.0 * scaleFactor;
    final iconSize = 28.0 * scaleFactor;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _lastInitialIndex = -1; // Reset to indicate navbar navigation
          _currentIndex = index;
        });
      },
      child: Container(
        width: itemWidth,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(30),
            right: Radius.circular(30),
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.white : AppTheme.primaryTeal,
          size: iconSize,
        ),
      ),
    );
  }
}
