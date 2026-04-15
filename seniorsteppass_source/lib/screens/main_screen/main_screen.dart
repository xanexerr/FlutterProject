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

  const MainScreen({super.key, this.initialIndex = 0, this.projectFilters});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  late final List<Widget> _pages = [
    const LandingPage(),
    ProjectMainScreen(initialFilters: widget.projectFilters),
    const InternshipMainScreen(),
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
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
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
