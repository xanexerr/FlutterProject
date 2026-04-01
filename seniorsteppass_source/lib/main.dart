import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const SeniorStepPassApp());
}

class SeniorStepPassApp extends StatelessWidget {
  const SeniorStepPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSP',
      theme: AppTheme.themeData,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
