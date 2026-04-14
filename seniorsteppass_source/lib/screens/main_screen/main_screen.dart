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
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const MainHeader(),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: AppTheme.lightYellow,
        // padding: const EdgeInsets.only(bottom: 16.0, top: 8.0, left: 16.0, right: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.lightYellow,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_filled),
              _buildNavItem(1, Icons.assignment_outlined),
              _buildNavItem(2, Icons.work_outline),
              _buildNavItem(3, Icons.bookmark_border),
              _buildNavItem(4, Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        width: 65,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(30),
            right: Radius.circular(30),
          ),

          // borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.white : AppTheme.primaryTeal,
          size: 28,
        ),
      ),
    );
  }
}
