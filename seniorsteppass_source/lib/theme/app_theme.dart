import 'package:flutter/material.dart';

class AppTheme {
  // Theme Colors from Palette
  static const Color primary = Color(0xFF136F73);
  static const Color second = Color(0xFFFFB72B);
  static const Color third = Color(0xFFF3F4C8);
  static const Color info = Color(0xFF17A2B8);
  static const Color bg = Color(0xFFF7F8E0);
  static const Color head = Color(0xFF212529);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color bad = Color(0xFFDC3545);
  static const Color head2 = Color(0xFF606060);
  static const Color head3 = Color(0xFF878787);

  // Additional color aliases for easier usage
  static const Color primaryTeal = primary;
  static const Color textTeal = primary;
  static const Color darkYellow = second;
  static const Color lightYellow = third;
  static const Color paleYellow = bg;
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);

  static ThemeData get themeData {
    return ThemeData(
      fontFamily: 'Inter', // Default font สำหรับทั้งแอป
      primaryColor: primary,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: second,
        surface: bg,
        error: bad,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          color: head,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: head,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        displayMedium: TextStyle(
          color: head2,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        displaySmall: TextStyle(
          color: head3,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        bodyLarge: TextStyle(color: head, fontFamily: 'Inter'),
        bodyMedium: TextStyle(color: head2, fontFamily: 'Inter'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: primary,
        unselectedItemColor: head3,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
