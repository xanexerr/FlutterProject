import 'package:flutter/material.dart';
import 'package:seniorsteppass_source/theme/app_theme.dart';
import '../../models/favorites_manager.dart';
import '../../widgets/common_buttons.dart';
import '../main_screen/main_screen.dart';
import 'request_join_project.dart';

class ProjectDetailScreen extends StatefulWidget {
  final dynamic project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final FavoritesManager _favoritesManager = FavoritesManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _favoritesManager.toggleFavorite(widget.project.id);
                      });
                    },
                    child: Icon(
                      _favoritesManager.isFavorite(widget.project.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _favoritesManager.isFavorite(widget.project.id)
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
                widget.project.description ?? 'This is detail about the topic that owner write this. This is detail about the topic that owner write this.',
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
                  final categories = widget.project.categories;
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA500),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

              // Team Members List
              _buildTeamMemberCard(
                avatarColor: const Color(0xFFE0E0E0),
                backgroundColor:  AppTheme.info,
                name: 'Mrs. Unknown Norname',
                email: 'contacting@example.com',
                index: 0,
              ),
              const SizedBox(height: 8),
              _buildTeamMemberCard(
                avatarColor: const Color(0xFFE0E0E0),
                backgroundColor:  AppTheme.info,
                name: 'Mrs. Unknown Norname',
                email: 'contacting@example.com',
                index: 1,
              ),
              const SizedBox(height: 8),
              _buildTeamMemberCard(
                avatarColor: const Color(0xFFE0E0E0),
                backgroundColor:  AppTheme.info,
                name: 'Mrs. Unknown Norname',
                email: 'contacting@example.com',
                index: 2,
              ),
              const SizedBox(height: 8),
              _buildTeamMemberCard(
                avatarColor: const Color(0xFFE0E0E0),
                backgroundColor:  AppTheme.info,
                name: 'Mrs. Unknown Norname',
                email: 'contacting@example.com',
                index: 3,
              ),
              const SizedBox(height: 20),

              // Project Status Section
              const Text(
                'Project Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B7BFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Developing',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Want to Join Section
              const Text(
                'Want to Join?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestJoinProjectScreen(
                          project: widget.project,
                        ),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard({
    required Color avatarColor,
    required Color backgroundColor,
    required String name,
    required String email,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: avatarColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),

          // Name and Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.head,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.head,
                  ),
                ),
              ],
            ),
          ),

          // Icons
        
        ],
      ),
    );
  }
}
