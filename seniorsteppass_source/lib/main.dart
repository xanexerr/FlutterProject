import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen/main_screen.dart';

void main() {
  runApp(const SeniorStepPassApp());
}

class SeniorStepPassApp extends StatelessWidget {
  const SeniorStepPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Senior Step Pass',
      theme: AppTheme.themeData,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
