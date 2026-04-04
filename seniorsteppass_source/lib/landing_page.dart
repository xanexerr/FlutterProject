import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  static const String _currentUser = 'User'; 

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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $_currentUser',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'this is detail about the topic that owner write this. this is detail about the topic that owner write this. this is detail about the topic that owner write this. this is detail about the topic that owner write this.',
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
                      _buildStatCard('920', 'Project', Icons.folder_open),
                      _buildStatCard('52', 'Internship', Icons.computer),
                      _buildStatCard('30', 'Users', Icons.bar_chart),
                    ],
                  ),
                ],
              ),
            ),
            
            // Explore Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.lightYellow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
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
                      Icon(Icons.explore_outlined, color: AppTheme.primaryTeal, size: 28),
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
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionBtn(
                          'Find Internship',
                          AppTheme.primaryTeal,
                          AppTheme.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildActionBtn('Software Engineer', AppTheme.darkYellow, AppTheme.primaryTeal)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildActionBtn('Software Engineer', AppTheme.darkYellow, AppTheme.primaryTeal)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildActionBtn('Data Science', AppTheme.darkYellow, AppTheme.primaryTeal)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildActionBtn('Data Science', AppTheme.darkYellow, AppTheme.primaryTeal)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildActionBtn('IOT', AppTheme.darkYellow, AppTheme.primaryTeal)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildActionBtn('IOT', AppTheme.darkYellow, AppTheme.primaryTeal)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildActionBtn('Cyber Security', AppTheme.darkYellow, AppTheme.primaryTeal)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildActionBtn('Cyber Security', AppTheme.darkYellow, AppTheme.primaryTeal)),
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
    return Container(
      width: 110,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.white, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppTheme.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppTheme.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String title, Color bgColor, Color textColor) {
    return Container(
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
    );
  }
}
