import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import '../../models/favorites_manager.dart';
import 'project_detail_screen.dart';
import '../../widgets/common_buttons.dart';

class ProjectFilteredScreen extends StatefulWidget {
  const ProjectFilteredScreen({super.key});

  @override
  State<ProjectFilteredScreen> createState() => _ProjectFilteredScreenState();
}

class _ProjectFilteredScreenState extends State<ProjectFilteredScreen> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> selectedFilters = {};
  List<dynamic> filteredResults = [];
  bool hasFiltered = false;
  final FavoritesManager _favoritesManager = FavoritesManager();

  final List<String> filterOptions = [
    'Software Engineer',
    'Data Science',
    'Internet Of Thing',
    'Cyber Security',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateResults() {
    setState(() {
      hasFiltered = selectedFilters.isNotEmpty || _searchController.text.isNotEmpty;
      
      if (!hasFiltered) {
        filteredResults = [];
        return;
      }

      filteredResults = mockProjects.where((project) {
        // Check filter
        bool matchesFilter = selectedFilters.isEmpty;
        if (selectedFilters.isNotEmpty) {
          matchesFilter = project.tags.any((tag) => selectedFilters.contains(tag));
        }

        // Check search
        bool matchesSearch = _searchController.text.isEmpty;
        if (_searchController.text.isNotEmpty) {
          matchesSearch = project.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              project.description.toLowerCase().contains(_searchController.text.toLowerCase());
        }

        return matchesFilter && matchesSearch;
      }).toList();
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
                        onChanged: (_) => _updateResults(),
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
                    onTap: () => _showFilterDialog(),
                    child: Container(
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
                          child: Center(
                            child: Text(
                              selectedFilters.isEmpty ? 'All' : '${selectedFilters.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
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
                hasFiltered
                    ? 'RESULT (${filteredResults.length})'
                    : 'FILTER RESULT',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Filtered Results List
            if (hasFiltered && filteredResults.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    _searchController.text.isNotEmpty
                        ? 'ไม่พบโปรเจค "${_searchController.text}"'
                        : 'ไม่พบโปรเจคที่ตรงกับเงื่อนไข',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else if (filteredResults.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                itemCount: filteredResults.length,
                itemBuilder: (context, index) {
                  final project = filteredResults[index];
                  return _buildFilteredResultCard(project, context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredResultCard(dynamic project, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(project: project),
          ),
        ).then((_) {
          setState(() {});
        });
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project.title.isNotEmpty ? project.title : "Title",
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
                            await _favoritesManager.toggleFavorite(project.id, isProject: true);
                            setState(() {});
                          },
                          child: Icon(
                            _favoritesManager.isFavorite(project.id, isProject: true)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _favoritesManager.isFavorite(project.id, isProject: true)
                              ? Colors.red
                              : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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

  void _showFilterDialog() {
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
                padding: const EdgeInsets.all(24),
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
                            width: 40,
                            height: 40,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                            setState(() => _updateResults());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      color: Color(0xFF1B6A68),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
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
