import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seniorsteppass_source/theme/app_theme.dart';
import '../../models/favorites_manager.dart';
import '../../widgets/common_buttons.dart';
import '../main_screen/main_screen.dart';
import 'request_join_project.dart';
import '../../services/current_user_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final dynamic project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final FavoritesManager _favoritesManager = FavoritesManager();
  final CurrentUserService _userService = CurrentUserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? currentUserStudentId;
  bool isCurrentUserOwner = false;
  bool isLoadingOwnerCheck = true;

  // Project data from Firebase
  Map<String, dynamic>? firebaseProjectData;
  Map<String, dynamic>? projectOwnerData;
  String projectStage = 'Developing';
  String ownerName = 'Unknown';
  String? ownerProfilePic;

  @override
  void initState() {
    super.initState();
    _loadProjectAndOwnerData();
  }

  Future<void> _loadProjectAndOwnerData() async {
    try {
      // Fetch full project data from Firebase
      final projectQuery = await _firestore
          .collection('projects')
          .where('id', isEqualTo: widget.project.id)
          .limit(1)
          .get();

      // If not found by id, try by document ID
      late DocumentSnapshot<Map<String, dynamic>> projectDoc;
      if (projectQuery.docs.isEmpty) {
        projectDoc = await _firestore
            .collection('projects')
            .doc(widget.project.id)
            .get();
      } else {
        projectDoc =
            projectQuery.docs.first as DocumentSnapshot<Map<String, dynamic>>;
      }

      if (projectDoc.exists) {
        firebaseProjectData = projectDoc.data();
        projectStage = firebaseProjectData?['stage'] ?? 'Developing';

        // Fetch owner data
        final ownerId = firebaseProjectData?['owner_id'] as String?;
        if (ownerId != null && ownerId.isNotEmpty) {
          final ownerQuery = await _firestore
              .collection('users')
              .where('student_id', isEqualTo: ownerId)
              .limit(1)
              .get();

          if (ownerQuery.docs.isNotEmpty) {
            projectOwnerData = ownerQuery.docs.first.data();
            ownerName = projectOwnerData?['full_name'] ?? 'Unknown';
            ownerProfilePic = projectOwnerData?['profilePic'] as String?;
          }
        }
      }

      // Check if current user is owner
      await _checkIfCurrentUserIsOwner();
    } catch (e) {
      print('Error loading project data: $e');
      setState(() => isLoadingOwnerCheck = false);
    }
  }

  Future<void> _checkIfCurrentUserIsOwner() async {
    try {
      final userEmail = _userService.getCurrentUserEmail();
      if (userEmail == null) {
        setState(() => isLoadingOwnerCheck = false);
        return;
      }

      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        final studentId = userData['student_id'] as String? ?? '';
        final projectOwnerId = widget.project.owner_id as String? ?? '';

        setState(() {
          currentUserStudentId = studentId;
          isCurrentUserOwner = studentId == projectOwnerId;
          isLoadingOwnerCheck = false;
        });
      } else {
        setState(() => isLoadingOwnerCheck = false);
      }
    } catch (e) {
      print('Error checking project owner: $e');
      setState(() => isLoadingOwnerCheck = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with Heart Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.project.title ?? 'TOPIC Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await _favoritesManager.toggleFavorite(
                        widget.project.id,
                        isProject: true,
                      );
                      setState(() {});
                    },
                    child: Icon(
                      _favoritesManager.isFavorite(
                            widget.project.id,
                            isProject: true,
                          )
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          _favoritesManager.isFavorite(
                            widget.project.id,
                            isProject: true,
                          )
                          ? Colors.red
                          : Colors.grey[400],
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                widget.project.description ??
                    'The Author has not provided a description for this project yet.',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Categories Badge
              Builder(
                builder: (context) {
                  final categories = widget.project.tags;
                  final categoryList = categories is List
                      ? categories
                      : categories != null
                      ? [categories]
                      : <dynamic>[];

                  if (categoryList.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categoryList.map((category) {
                      final label = category.toString();

                      return InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(
                                initialIndex: 1,
                                projectFilters: {label},
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA500),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Picture Placeholder
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'picture',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1B6A68),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Team Section
              const Text(
                'Team',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Team Members List from Firestore
              if (firebaseProjectData != null &&
                  firebaseProjectData!.containsKey('members'))
                Builder(
                  builder: (context) {
                    final members =
                        firebaseProjectData!['members']
                            as Map<String, dynamic>?;
                    if (members == null || members.isEmpty) {
                      return const Text(
                        'No team members yet',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      );
                    }

                    return Column(
                      children: members.entries.map((entry) {
                        final studentId = entry.key;
                        final role = entry.value;

                        return FutureBuilder<DocumentSnapshot>(
                          future: _firestore
                              .collection('users')
                              .where('student_id', isEqualTo: studentId)
                              .limit(1)
                              .get()
                              .then(
                                (query) => query.docs.isNotEmpty
                                    ? Future.value(query.docs.first)
                                    : Future.error('User not found'),
                              ),
                          builder: (context, snapshot) {
                            String userName = 'Unknown';
                            String userEmail = 'N/A';

                            if (snapshot.hasData && snapshot.data != null) {
                              final userData =
                                  snapshot.data!.data()
                                      as Map<String, dynamic>?;
                              userName = userData?['full_name'] ?? 'Unknown';
                              userEmail = userData?['email'] ?? 'N/A';
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.info,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E0E0),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: AppTheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.head,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                        
                                          Text(
                                            userEmail,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.head,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            role,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.head,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                )
              else
                const Text(
                  'No team members',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const SizedBox(height: 20),

              // Project Status Section
              const Text(
                'Project Stage',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: projectStage == 'Complete'
                      ? const Color(0xFF27AE60)
                      : AppTheme.info,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  projectStage,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Want to Join Section - Only show if not owner
              if (!isCurrentUserOwner && !isLoadingOwnerCheck)
                const Text(
                  'Want to Join?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              if (!isCurrentUserOwner && !isLoadingOwnerCheck)
                const SizedBox(height: 8),
              if (!isCurrentUserOwner && !isLoadingOwnerCheck)
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RequestJoinProjectScreen(project: widget.project),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Request JOIN!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (isCurrentUserOwner) const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
