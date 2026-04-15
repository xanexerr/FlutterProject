import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seniorsteppass_source/models/project_model.dart';
import '../../theme/app_theme.dart';
import '../main_screen/main_screen.dart';
import '../project_main/project_submission.dart';
import 'internship_review_form.dart';
import '../../services/database_service.dart';
import '../../services/current_user_service.dart';
import 'project_requests_notification_screen.dart';
import 'request_workplace.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _dbService = DatabaseService();

  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> internships = [];
  int pendingProjectRequests = 0;
  String userDocId = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final userEmail = CurrentUserService().getCurrentUserEmail();
    if (userEmail != null) {
      // Fetch user data and projects from Firestore
      final data = await _dbService.getUserData(userEmail);
      
      // Get the current user's doc ID
      String userDocId = '';
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (userDoc.docs.isNotEmpty) {
          userDocId = userDoc.docs.first.id;
        }
      } catch (e) {
        print('Error fetching user doc ID: $e');
      }

      // Fetch projects by student ID (projects user created)
      final List<ProjectModel> projectData = await _dbService.getUserProjects(
        data.student_id,
      );

      // Fetch projects user joined (from users/{userDocId}/projects subcollection)
      List<Map<String, dynamic>> joinedProjects = [];
      if (userDocId.isNotEmpty) {
        try {
          final joinedSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userDocId)
              .collection('projects')
              .get();

          for (var doc in joinedSnapshot.docs) {
            final projectDocId = doc['project_id'] as String?;
            if (projectDocId != null) {
              try {
                final projectDoc = await FirebaseFirestore.instance
                    .collection('projects')
                    .doc(projectDocId)
                    .get();
                
                if (projectDoc.exists) {
                  final projectData = projectDoc.data() as Map<String, dynamic>;
                  projectData['id'] = projectDocId;
                  joinedProjects.add(projectData);
                }
              } catch (e) {
                print('Error fetching joined project: $e');
              }
            }
          }
        } catch (e) {
          print('Error fetching joined projects: $e');
        }
      }

      // Fetch pending project requests count
      int requestsCount = 0;
      try {
        if (userDocId.isNotEmpty) {
          final requestsSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userDocId)
              .collection('project_requests')
              .where('status', isEqualTo: 'pending')
              .get();
          requestsCount = requestsSnapshot.docs.length;
        }
      } catch (e) {
        print('Error fetching pending requests: $e');
      }

      List<Map<String, dynamic>> resolvedInternships = [];

      if (data.intern_list != null && data.intern_list!.isNotEmpty) {
        resolvedInternships = await Future.wait(
          data.intern_list!.map((item) async {
            final companyName = item['company'] ?? '';
            final logo = await _dbService.getCompanyLogo(companyName);
            
            // Fetch internship document ID from Firestore
            String internshipId = '';
            try {
              final query = await FirebaseFirestore.instance
                  .collection('internships')
                  .where('company_name', isEqualTo: companyName)
                  .limit(1)
                  .get();
              if (query.docs.isNotEmpty) {
                internshipId = query.docs.first.id;
              }
            } catch (e) {
              print('Error fetching internship ID: $e');
            }
            
            return {
              'id': internshipId,
              'company': companyName,
              'department': item['role'] ?? 'Intern',
              'logo_url': logo,
            };
          }),
        );
      }

      // Combine user's own projects with joined projects
      List<Map<String, dynamic>> allProjects = [
        ...projectData.map((p) => p.toJson()).toList(),
        ...joinedProjects,
      ];

      if (mounted) {
        setState(() {
          userData = data.toJson();
          projects = allProjects;
          internships = resolvedInternships;
          pendingProjectRequests = requestsCount;
          this.userDocId = userDocId;
          isLoading = false;
        });
      }
    }
  }

  bool get hasProject => projects.isNotEmpty;
  bool get hasInternship => internships.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while fetching data
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

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

                    // Profile Picture from Firebase Auth or default icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(8),
                        image: userData['profilePic'] != null
                            ? DecorationImage(
                                image: NetworkImage(userData['profilePic']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: userData['profilePic'] == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: AppTheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      userData['full_name']?.toUpperCase() ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // ID
                    Text(
                      userData['student_id'] ?? 'N/A',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Faculty
                    Text(
                      userData['faculty']?.toUpperCase() ?? 'N/A',
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
                        if (hasProject)
                          GestureDetector(
                            onTap: userDocId.isNotEmpty
                                ? () {
                                    // Navigate to project requests screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProjectRequestsNotificationScreen(
                                              userDocId: userDocId,
                                            ),
                                      ),
                                    );
                                  }
                                : null,
                            child: Stack(
                              children: [
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
                                if (pendingProjectRequests > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          pendingProjectRequests > 99
                                              ? '99+'
                                              : '$pendingProjectRequests',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
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
                    const SizedBox(height: 20),

                    // Projects Section
                    if (hasProject) ...[
                      ...projects.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> project = entry.value;
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
                                            const RequestWorkplaceScreen(),
                                      ),
                                    );
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Request Workplace',
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
                        Map<String, dynamic> internship = entry.value;
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
                            children: [],
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RequestWorkplaceScreen(),
                                          ),
                                        );
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
  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Project Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
              right: Radius.circular(12),
            ),
            child: Image.network(
              project['image_url'] ?? '',
              width: 160,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 160,
                  height: 90,
                  color: AppTheme.lightGrey,
                  child: const Icon(Icons.image, color: AppTheme.head),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Project Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project['title'] ?? 'Project Name',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.head,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  project['description'] ?? 'Project Detail',
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
  Widget _buildInternshipCard(Map<String, dynamic> internship) {
    final internshipId = internship['id'] as String? ?? '';
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
              image: internship['logo_url'] != null
                  ? DecorationImage(
                      image: NetworkImage(internship['logo_url']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child:
                (internship['logo_url'] == null || internship['logo_url'] == "")
                ? const Center(
                    child: Text(
                      'LOGO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
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
                  builder: (context) => InternshipReviewForm(
                    internshipId: internshipId,
                    companyName: internship['company'] ?? 'N/A',
                    role: internship['department'] ?? 'Intern',
                  ),
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
