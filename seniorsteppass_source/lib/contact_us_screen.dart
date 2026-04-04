import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/common_buttons.dart';

class ContactPerson {
  final String name;
  final String studentId;
  final String profileImage;

  ContactPerson({
    required this.name,
    required this.studentId,
    required this.profileImage,
  });
}

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static final List<ContactPerson> contactPeople = [
    ContactPerson(
      name: 'Natthahumin Klammat',
      studentId: '6787028 ITDS/B',
      profileImage:
          'xanprofile.png',
    ),
    ContactPerson(
      name: 'Arthitaya Prommee',
      studentId: '6787088 ITDS/B',
      profileImage:
          'arthitayaprofile.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar:  const CustomHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 12.0),
                
                child: Text(
                  'Contact Us',
                  
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Inter',
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: contactPeople.length,
                itemBuilder: (context, index) {
                  final person = contactPeople[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _buildContactCard(context, person),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, ContactPerson person) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(
          color: AppTheme.lightGrey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            
            // Profile Image
            Container(
              width: 160,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
  
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/${person.profileImage}',
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.lightYellow,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppTheme.primaryTeal,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              person.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.head,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 6),

            // Student ID
            Text(
              person.studentId,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.head3,
                    fontSize: 13,
                  ),
            ),
            const SizedBox(height: 20),

            // Contact Methods
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactIcon(
                  Icons.phone,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Call ${person.name}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),
                _buildContactIcon(
                  Icons.email_outlined,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Email ${person.name}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),
                _buildContactIcon(
                  Icons.message_outlined,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Message ${person.name}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.lightYellow,
          border: Border.all(
            color: AppTheme.primaryTeal,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryTeal,
          size: 22,
        ),
      ),
    );
  }
}
