import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/index.dart';
import '../../models/favorites_manager.dart';
import '../../theme/app_theme.dart';
import 'project_detail_screen.dart';
import '../internship/internship_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesManager _favoritesManager = FavoritesManager();
  bool _showProjects = true;
  bool _isLoading = true;
  List<ProjectModel> _favoriteProjects = [];
  List<CompanyModel> _favoriteInternships = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      // Load favorites from Firestore
      await _favoritesManager.loadFavorites();

      // Fetch favorite projects
      final projectIds = _favoritesManager.favoriteProjects.toList();
      _favoriteProjects = [];
      if (projectIds.isNotEmpty) {
        final projectSnapshots = await FirebaseFirestore.instance
            .collection('projects')
            .where(FieldPath.documentId, whereIn: projectIds)
            .get();
        _favoriteProjects = projectSnapshots.docs
            .map((doc) => ProjectModel.fromJson(doc.data(), doc.id))
            .toList();
      }

      // Fetch favorite internships
      final internshipIds = _favoritesManager.favoriteInternships.toList();
      _favoriteInternships = [];
      if (internshipIds.isNotEmpty) {
        final internshipSnapshots = await FirebaseFirestore.instance
            .collection('companies')
            .where(FieldPath.documentId, whereIn: internshipIds)
            .get();
        _favoriteInternships = internshipSnapshots.docs
            .map((doc) => CompanyModel.fromJson(doc.data(), doc.id))
            .toList();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedFavorites = _showProjects ? _favoriteProjects : _favoriteInternships;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5DD),
      body: Column(
        children: [
          // Toggle Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showProjects = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _showProjects ? AppTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.primary),
                      ),
                      child: Center(
                        child: Text(
                          'Projects',
                          style: TextStyle(
                            color: _showProjects ? Colors.white : AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showProjects = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_showProjects ? AppTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.primary),
                      ),
                      child: Center(
                        child: Text(
                          'Internships',
                          style: TextStyle(
                            color: !_showProjects ? Colors.white : AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedFavorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showProjects ? 'No favorite projects yet' : 'No favorite internships yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            displayedFavorites.length,
                            (index) {
                              final item = displayedFavorites[index];
                              final isProject = _showProjects;
                              return _buildFavoriteCard(
                                isProject ? item as ProjectModel : item as CompanyModel,
                                isProject,
                                context,
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
    dynamic item,
    bool isProject,
    BuildContext context,
  ) {
    late String title;
    late String description;
    String? imageUrl;
    late String id;
    double? rating;
    int? reviewCount;

    if (isProject) {
      final project = item as ProjectModel;
      title = project.title;
      description = project.description;
      imageUrl = project.image_url;
      id = project.id;
    } else {
      final company = item as CompanyModel;
      title = company.company_name;
      description = company.department;
      imageUrl = company.logo_url;
      id = company.id;
      rating = company.overallRating;
      reviewCount = company.reviewCount;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isProject
                ? ProjectDetailScreen(project: item as ProjectModel)
                : InternshipDetailScreen(company: item as CompanyModel),
          ),
        ).then((_) {
          _loadFavorites();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D9D9),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.image, size: 50, color: AppTheme.primaryTeal),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, size: 50, color: AppTheme.primaryTeal),
                      ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await _favoritesManager.toggleFavorite(id, isProject: isProject);
                          _loadFavorites();
                        },
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description.isNotEmpty ? description : "No description",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1B6A68),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (isProject)
                    Wrap(
                      spacing: 6,
                      children: (item as ProjectModel)
                          .tags
                          .take(2)
                          .map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.second.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFFFB72B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  if (!isProject && rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '($reviewCount reviews)',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
