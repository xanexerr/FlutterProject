import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import 'project_detail_screen.dart';
import '../../widgets/common_buttons.dart';
import '../../theme/app_theme.dart';


class ProjectSearchScreen extends StatefulWidget {
  const ProjectSearchScreen({super.key});

  @override
  State<ProjectSearchScreen> createState() => _ProjectSearchScreenState();
}

class _ProjectSearchScreenState extends State<ProjectSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      hasSearched = true;
      if (query.isEmpty) {
        searchResults = [];
      } else {
        searchResults = mockProjects
            .where((project) =>
                project.title.toLowerCase().contains(query.toLowerCase()) ||
                project.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              width: double.infinity,
              color: const Color(0xFFDBDBDB),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _performSearch,
                        decoration: const InputDecoration(
                          hintText: 'keyword',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.black87),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B6A68),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Result Header
            Container(
              width: double.infinity,
              color: const Color(0xFF5A5A5A),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Text(
                hasSearched
                    ? 'RESULT (${searchResults.length})'
                    : 'SEARCH RESULT',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Search Results List
            if (hasSearched && searchResults.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'ไม่พบโปรเจค "${_searchController.text}"',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else if (searchResults.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final project = searchResults[index];
                  return _buildSearchResultCard(project, context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(dynamic project, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(project: project),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5DD),
          borderRadius: BorderRadius.circular(12),
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
                height: 150,
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D9D9),
                ),
                child: const Center(
                  child: Text(
                    'image',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title.isNotEmpty ? project.title : "Title",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Project Detail : ${project.description.isNotEmpty ? project.description : "No description available"}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF1B6A68),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
