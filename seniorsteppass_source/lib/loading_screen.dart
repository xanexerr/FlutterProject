import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;

  const LoadingScreen({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Loading Circle
            Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightYellow,
                  ),
                ),
                // Loading spinner
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryTeal,
                    ),
                    strokeWidth: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // App Title
            const Text(
              'SENIOR STEP PASS',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTeal,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Loading Message
            Text(
              message ?? 'Loading projects...',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppTheme.head2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),

            // Decorative dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(),
                const SizedBox(width: 8),
                _buildDot(),
                const SizedBox(width: 8),
                _buildDot(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.darkYellow,
      ),
    );
  }
}
