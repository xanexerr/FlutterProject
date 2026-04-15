import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import '../../loading_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                        'SIGN UP',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppTheme.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Username Field
                      _buildTextField(
                        controller: _usernameController,
                        hintText: 'Username',
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

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            _handleSignUp(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
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

                      // Log In option
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Have an account? ',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppTheme.white,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: 'Log In',
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

  void _handleSignUp(BuildContext context) async {
    final String email = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

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

    // Show loading screen
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (context) =>
            const LoadingScreen(message: 'Creating account...'),
      ),
    );

    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        if (!mounted) return;
        navigator.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User Not Found, Please Contact Admin'),
            backgroundColor: AppTheme.bad,
          ),
        );
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userQuery.docs.first.id)
          .update({'id': userCredential.user!.uid});

      if (!mounted) return;
      navigator.pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account activated! Please login.'),
          backgroundColor: AppTheme.success,
        ),
      );

      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      navigator.pop();

      // have an Account but login first time
      if (e.toString().contains('email-already-in-use')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account already activated. Please login.'),
            backgroundColor: AppTheme.success,
            duration: Duration(seconds: 3),
          ),
        );
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      String errorMessage = 'An error occurred $e';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.bad,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
