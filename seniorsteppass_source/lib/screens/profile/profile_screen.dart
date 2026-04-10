import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../main_screen/main_screen.dart';
import '../project_main/project_submission.dart';
import 'internship_review_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ตอนดึงงข้อมูลมาจาก API หรือฐานข้อมูลจริงๆ ให้แทนที่ List<Map<String, String>> ด้วยโมเดลข้อมูลจริง และดึงข้อมูลมาแสดงแทนการใช้ mock data นี้
  List<Map<String, String>> projects = [
    {
      'name': 'Project Name 1',
      'detail': 'Project Detail : Lorem ipsum dolor sit amet, consectetur adipiscing elit...'
    },
    {
      'name': 'Project Name 2',
      'detail': 'Another project detail : Sed do eiusmod tempor incididunt ut labore et dolore...'
    },
  ];

  List<Map<String, String>> internships = [
    {'company': 'Company Name 1', 'department': 'Department 1'},
    {'company': 'Company Name 2', 'department': 'Department 2'},
  ];

  bool get hasProject => projects.isNotEmpty;
  bool get hasInternship => internships.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleYellow,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // My Profile Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Header
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Profile Picture
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    const Text(
                      'FIRSTNAME LASTNAME',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // ID
                    const Text(
                      '6787000 ITDS/B',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Faculty
                    const Text(
                      'FACULTY OF INFORMATION AND COMMUNICATION TECHNOLOGY',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Career Section - Show based on what's available
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Career',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                        if (hasProject && hasInternship)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppTheme.second,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications,
                              color: AppTheme.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Projects Section
                    if (hasProject) ...[
                      ...projects.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, String> project = entry.value;
                        return Column(
                          key: ValueKey(index),
                          children: [
                            _buildProjectCard(project),
                            if (index < projects.length - 1)
                              const SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                      if (internships.isNotEmpty) const SizedBox(height: 20),
                    ] else ...[
                      const Text(
                        'Looking for a Project?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.second,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MainScreen(initialIndex: 1),
                                      ),
                                    );
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Select Project',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.head,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(height: 1, color: Colors.black12),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProjectSubmissionScreen(),
                                      ),
                                    );
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Add Project',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.head,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (internships.isNotEmpty) const SizedBox(height: 20),
                    ],

                    // Internships Section
                    if (hasInternship) ...[
                      ...internships.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, String> internship = entry.value;
                        return Column(
                          key: ValueKey('internship_$index'),
                          children: [
                            _buildInternshipCard(internship),
                            if (index < internships.length - 1)
                              const SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                    ] else ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Looking for an Internship?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.second,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MainScreen(initialIndex: 2),
                                      ),
                                    );
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Select Internship',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.head,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(height: 1, color: Colors.black12),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MainScreen(initialIndex: 2),
                                      ),
                                    );
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Request Internship',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.head,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Requests News Activity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                           
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.info,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ProjectSubmissionScreen(),
                                          ),
                                        );
                                      },
                                      child: const Center(
                                        child: Text(
                                          'Request Add Project',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(height: 1, color: Colors.black12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        
                                      },
                                      child: const Center(
                                        child: Text(
                                          'Request New Workplace',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build Project Card Widget
  Widget _buildProjectCard(Map<String, String> project) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Project Image
          Container(
            width: 160,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: const Icon(Icons.image, color: AppTheme.head),
          ),
          const SizedBox(width: 12),

          // Project Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project['name'] ?? 'Project Name',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.head,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  project['detail'] ?? 'Project Detail',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.head3,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Internship Card Widget
  Widget _buildInternshipCard(Map<String, String> internship) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          // Company Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.head,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Text(
                'LOGO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Company Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  internship['company'] ?? 'Company Name',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.head,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  internship['department'] ?? 'Department',
                  style: const TextStyle(fontSize: 11, color: AppTheme.head2),
                ),
              ],
            ),
          ),

          // Icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InternshipReviewForm(),
                ),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: AppTheme.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
