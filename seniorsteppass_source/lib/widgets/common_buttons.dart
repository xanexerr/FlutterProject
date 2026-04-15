import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../screens/menu/menu_screen.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const SubmitButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppTheme.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CancelButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.head2,
          side: const BorderSide(color: AppTheme.head3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  
  const CustomHeader({super.key, this.showBackButton = true});
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        color: AppTheme.lightYellow,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 24, right: 24, bottom: 10,
        ),
        child: Row(
          children: [
            if (showBackButton)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryTeal, size: 20),
              ),
            const SizedBox(width: 8),
            Image.asset('assets/logo.png', height: 48, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}


class MainHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;

  const MainHeader({super.key, this.showBackButton = true});
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        color: AppTheme.lightYellow,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 24,
          right: 24,
          bottom: 10,
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Image.asset('assets/logo.png', height: 48, fit: BoxFit.contain),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.menu,
                size: 36,
                color: AppTheme.primaryTeal,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class NavigationMenuItem extends StatelessWidget {
  final String title;
  final Widget destination;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const NavigationMenuItem({
    super.key,
    required this.title,
    required this.destination,
    this.backgroundColor = AppTheme.lightYellow,
    this.textColor = AppTheme.primaryTeal,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        width: double.infinity,
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
