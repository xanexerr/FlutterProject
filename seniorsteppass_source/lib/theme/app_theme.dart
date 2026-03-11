import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF1E6C68); // Dark Teal
  static const Color lightYellow = Color(0xFFEFF5C9); // Background Yellow
  static const Color darkYellow = Color(0xFFFDB913); // Orange/Yellow 
  static const Color white = Colors.white;
  static const Color textTeal = Color(0xFF1E6C68);

  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: lightYellow,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightYellow,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTeal),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightYellow,
        selectedItemColor: white,
        unselectedItemColor: primaryTeal,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
