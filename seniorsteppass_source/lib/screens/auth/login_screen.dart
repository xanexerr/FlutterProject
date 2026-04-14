import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/current_user_service.dart';
import 'signup_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../main_screen/main_screen.dart';
import '../../loading_screen.dart';
// firebase auth and firestore
import 'package:firebase_auth/firebase_auth.dart';
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
        duration: const Duration(seconds: 2),
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
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.pushReplacement(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => const SignUpScreen(),
                      //       ),
                      //     );
                      //   },
                      //   child: RichText(
                      //     text: const TextSpan(
                      //       text: 'Don\'t have an account? ',
                      //       style: TextStyle(
                      //         fontFamily: 'Inter',
                      //         color: AppTheme.white,
                      //         fontSize: 13,
                      //       ),
                      //       children: [
                      //         TextSpan(
                      //           text: 'Sign Up',
                      //           style: TextStyle(
                      //             fontFamily: 'Inter',
                      //             color: AppTheme.darkYellow,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
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

    // Validate input - fields must not be empty
    if (email.isEmpty || password.isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: AppTheme.bad,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppTheme.bad,
          duration: Duration(seconds: 2),
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
      // Attempt to login user using Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (!mounted) return;
      Navigator.pop(context); // Remove loading screen

      // Login successful, check user role and navigate accordingly
      if (userQuery.docs.isNotEmpty) {
        String role = userQuery.docs.first['role'] ?? 'User';
        
        // Cache user data in CurrentUserService
        await CurrentUserService().fetchCurrentUserData();

        if (isAdminRoute){
          if (role == 'Admin') {
            // Admin login successful
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
              (route) => false, // Remove all previous routes
            );
          } else {
            // Not an admin, show error and return to login
            await FirebaseAuth.instance.signOut();
            _showErrorSnackBar(context, 'You do not have admin access.');
            return;
          }
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false, // Remove all previous routes
          );
        }

      } else {
        await FirebaseAuth.instance.signOut();
        _showErrorSnackBar(context, 'User data not found. Please contact support.');
        return;
      }

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Remove loading screen

      String errorMessage = 'An unexpected error occurred. Please try again.';

      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-email') {
          errorMessage = 'Invalid email or password. Please try again.';
        }
      }
      
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
