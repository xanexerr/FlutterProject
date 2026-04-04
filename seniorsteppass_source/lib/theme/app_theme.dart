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

  static ThemeData get themeData {
    return ThemeData(
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
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: head, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: head2, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: head3, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: head),
        bodyMedium: TextStyle(color: head2),
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
