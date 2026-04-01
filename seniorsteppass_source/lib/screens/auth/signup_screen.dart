import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import '../main_screen/main_screen.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Text
                const Text(
                  'SENIOR',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryTeal,
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  'STEP PASS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.darkYellow,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Main Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SIGN UP',
                        style: TextStyle(
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MainScreen()),
                            );
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
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Have an account? ',
                            style: TextStyle(color: AppTheme.white, fontSize: 13),
                            children: [
                              TextSpan(
                                text: 'Log In',
                                style: TextStyle(
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
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
        ),
      ),
    );
  }
}
