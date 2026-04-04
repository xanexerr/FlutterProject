import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import 'project_detail_screen.dart';

class ProjectMainScreen extends StatefulWidget {
  const ProjectMainScreen({super.key});

  @override
  State<ProjectMainScreen> createState() => _ProjectMainScreenState();
}

class _ProjectMainScreenState extends State<ProjectMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> selectedFilters = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
                  Container(
                    height: 48,
                    width: 75,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B6A68),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showFilterDialog(),
                        borderRadius: BorderRadius.circular(24),
                        child: const Center(
                          child: Text(
                            'All',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hot Project Section
            Container(
              width: double.infinity,
              color: const Color(0xFF5A5A5A),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: const Text(
                'Hot Project',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 310,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                itemCount: mockProjects.length,
                itemBuilder: (context, index) {
                  final project = mockProjects[index];
                  return _buildProjectCard(project, context);
                },
              ),
            ),

            // Recommend Project Section
            Container(
              width: double.infinity,
              color: const Color(0xFF5A5A5A),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: const Text(
                'Recommend Project',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 310,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                itemCount: mockProjects.length,
                itemBuilder: (context, index) {
                  final project = mockProjects[index];
                  return _buildProjectCard(project, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(dynamic project, BuildContext context) {
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
        width: 170,
        margin: const EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5DD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Square Image - Top Half
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                height: 170,
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
            // Content - Bottom Half
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
                  const Text(
                    'Project Detail :',
                    style: TextStyle(fontSize: 10, color: Color(0xFF1B6A68)),
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

  void _showFilterDialog() {
    final List<String> filterOptions = [
      'Software Engineer',
      'Data Science',
      'Internet Of Thing',
      'Cyber Security',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6A68),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Project Filter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Color(0xFF1B6A68),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filter Options
                    ...filterOptions.map((option) {
                      final isSelected = selectedFilters.contains(option);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              if (isSelected) {
                                selectedFilters.remove(option);
                              } else {
                                selectedFilters.add(option);
                              }
                            });
                            // Also update the parent state
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1B6A68)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: const Color(0xFF1B6A68),
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1B6A68),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}