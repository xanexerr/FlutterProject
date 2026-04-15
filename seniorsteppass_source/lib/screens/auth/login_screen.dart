import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/current_user_service.dart';
import 'signup_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../main_screen/main_screen.dart';
import '../../loading_screen.dart';
// firebase
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Error message state
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.bad,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightYellow,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 60.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Text
                Image.asset('assets/logo.png', height: 80, fit: BoxFit.contain),
                const SizedBox(height: 40),

                // Main Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppTheme.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email Field
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          // Login Handler รอ
                          onPressed: () {
                            _handleLogin(context, isAdminRoute: false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppTheme.primaryTeal,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign Up option
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'First time logging in? ',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppTheme.white,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: 'Activate Account',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: AppTheme.darkYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Admin Sign-In Button
                SizedBox(
                  width: 200,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      _handleLogin(context, isAdminRoute: true);
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const AdminDashboardScreen(),
                      //     // builder: (context) => const MainScreen(),
                      //     // builder: (context) => const AdminLoginScreen(),
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.info,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Admin Sign-In',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppTheme.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, {required bool isAdminRoute}) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    print('DEBUG: Login attempt with email: $email');

    // Validate input - fields must not be empty
    if (email.isEmpty || password.isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: AppTheme.bad,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppTheme.bad,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Show loading screen
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (context) => const LoadingScreen(message: 'Logging in...'),
      ),
    );

    try {
      print('DEBUG: ================================');
      print('DEBUG: Querying Firestore for email: "$email"');
      print('DEBUG: Email length: ${email.length}');
      print('DEBUG: Email bytes: ${email.codeUnits}');
      
      // Query user from Firestore by email
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      print('DEBUG: Query returned ${userQuery.docs.length} documents');
      print('DEBUG: ================================');
      
      // Debug: Print all users in collection to see what's there
      if (userQuery.docs.isEmpty) {
        print('DEBUG: ❌ No user found with email: "$email"');
        print('DEBUG: Fetching ALL users from collection...');
        final allUsers = await FirebaseFirestore.instance
            .collection('users')
            .get();
        print('DEBUG: Total users in collection: ${allUsers.docs.length}');
        for (var i = 0; i < allUsers.docs.length; i++) {
          final doc = allUsers.docs[i];
          final data = doc.data();
          final emailField = data['email'] ?? 'NO EMAIL FIELD';
          print('DEBUG: User #${i + 1}: email="$emailField", docId=${doc.id}');
          print('DEBUG:   Full data: $data');
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // Remove loading screen

      if (userQuery.docs.isEmpty) {
        print('DEBUG: User not found for email: $email');
        _showErrorSnackBar(context, 'User not found. Please check your email.');
        return;
      }

      // Get user data
      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();
      final storedPassword = userData['password'] ?? '';
      final role = userData['role'] ?? 'User';

      print('DEBUG: User found - role: $role');
      print('DEBUG: Password match: ${password == storedPassword}');

      // Verify password
      if (password != storedPassword) {
        print('DEBUG: Password mismatch. Stored: $storedPassword, Input: $password');
        _showErrorSnackBar(context, 'Invalid password. Please try again.');
        return;
      }

      print('DEBUG: Login successful for $email');

      // Password is correct, proceed with login
      // Set email dan fetch user data
      final userService = CurrentUserService();
      userService.setCurrentUserEmail(email);
      await userService.fetchCurrentUserData(email: email);

      if (isAdminRoute) {
        if (role == 'Admin') {
          // Admin login successful
          print('DEBUG: Navigating to AdminDashboardScreen');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
            (route) => false, // Remove all previous routes
          );
        } else {
          // Not an admin, show error
          _showErrorSnackBar(context, 'You do not have admin access.');
          return;
        }
      } else {
        print('DEBUG: Navigating to MainScreen');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false, // Remove all previous routes
        );
      }

    } catch (e) {
      print('DEBUG: Login error: $e');
      if (!mounted) return;
      Navigator.pop(context); // Remove loading screen

      String errorMessage = 'An unexpected error occurred. Please try again.';
      
      _showErrorSnackBar(context, 'Login failed: $errorMessage');
    }

  }

  @override
  void dispose() {  // Clean up controllers when the widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

}
