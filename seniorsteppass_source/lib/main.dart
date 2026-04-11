import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
  // Firebase setup commands (run in terminal):
  // dart pub global activate flutterfire_cli
  // firebase login
  // flutterfire configure

void main() async {
  // Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ------------------------------------
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
