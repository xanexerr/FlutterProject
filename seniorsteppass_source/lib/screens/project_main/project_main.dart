import 'package:flutter/material.dart';
import '../../models/favorites_manager.dart';
import 'project_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/project_model.dart';

class ProjectMainScreen extends StatefulWidget {
  final Set<String>? initialFilters;
  final Set<String>? initialCategoryFilters;

  const ProjectMainScreen({
    super.key, 
    this.initialFilters,
    this.initialCategoryFilters,
  });

  @override
  State<ProjectMainScreen> createState() => _ProjectMainScreenState();
}

class _ProjectMainScreenState extends State<ProjectMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Set<String> selectedFilters;
  List<ProjectModel> displayedResults = [];
  List<ProjectModel> allProjects = [];
  List<ProjectModel> hotProjects = [];
  List<ProjectModel> recommendProjects = [];
  bool isSearchActive = false;
  bool isFilterActive = false;
  final FavoritesManager _favoritesManager = FavoritesManager();
  // Firestore reference for projects collection
  final CollectionReference projectsRef = FirebaseFirestore.instance.collection(
    'projects',
  );
  bool isLoading = true;

  final List<String> filterOptions = [
    'Software Engineer',
    'Data Science',
    'Internet Of Thing',
    'Cyber Security',
  ];

  @override
  void initState() {
    super.initState();
    // Apply initial category filters if provided (for filtering, not search)
    if (widget.initialCategoryFilters != null && widget.initialCategoryFilters!.isNotEmpty) {
      selectedFilters = widget.initialCategoryFilters!;
      _searchController.text = '';
    } else if (widget.initialFilters != null && widget.initialFilters!.isNotEmpty) {
      // Apply initial search if initialFilters provided (for search, not filter)
      selectedFilters = {};
      _searchController.text = widget.initialFilters!.first;
    } else {
      // No filters or search
      selectedFilters = {};
      _searchController.text = '';
    }
    _searchController.addListener(_updateDisplay);
    _loadProjectsFromFirestore();
  }

  @override
  void didUpdateWidget(covariant ProjectMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update when initialFilters or initialCategoryFilters changes
    if (oldWidget.initialCategoryFilters != widget.initialCategoryFilters ||
        oldWidget.initialFilters != widget.initialFilters) {
      if (widget.initialCategoryFilters != null && widget.initialCategoryFilters!.isNotEmpty) {
        selectedFilters = widget.initialCategoryFilters!;
        _searchController.text = '';
      } else if (widget.initialFilters != null && widget.initialFilters!.isNotEmpty) {
        selectedFilters = {};
        _searchController.text = widget.initialFilters!.first;
      } else {
        selectedFilters = {};
        _searchController.text = '';
      }
      _updateDisplay();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProjectModel> allProjectsFromFirestore = [];

  Future<void> _loadProjectsFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('status', isEqualTo: 'Approved')
          .get();
      
      final projects = snapshot.docs
          .map((doc) => ProjectModel.fromJson(doc.data(), doc.id))
          .toList();
      
      setState(() {
        allProjects = projects;
        hotProjects = projects.take(5).toList();
        recommendProjects = projects.length > 5 
            ? projects.sublist(5, projects.length > 10 ? 10 : projects.length)
            : projects;
        isLoading = false;
      });
      
      _updateDisplay();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading projects: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  void _updateDisplay() {
    setState(() {
      String searchText = _searchController.text.trim().toLowerCase();
      isSearchActive = searchText.isNotEmpty;
      isFilterActive = selectedFilters.isNotEmpty;

      if (isFilterActive && isSearchActive) {
        // Combined filter + search
        displayedResults = allProjects.where((project) {
          bool matchesFilter = project.tags.any(
            (tag) => selectedFilters.contains(tag),
          );
          bool matchesSearch =
              project.title.toLowerCase().contains(searchText) ||
              project.description.toLowerCase().contains(searchText);
          return matchesFilter && matchesSearch;
        }).toList();
      } else if (isFilterActive) {
        // Filter only
        displayedResults = allProjects
            .where(
              (project) => project.tags.any(
                (tag) => selectedFilters.contains(tag),
              ),
            )
            .toList();
      } else if (isSearchActive) {
        // Search only
        displayedResults = allProjects
            .where(
              (project) =>
                  project.title.toLowerCase().contains(searchText) ||
                  project.description.toLowerCase().contains(searchText),
            )
            .toList();
      } else {
        // No search/filter - show home
        displayedResults = [];
      }
    });
  }

  void _performSearch(String query) {
    _updateDisplay();
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
                    onTap: _showFilterDialog,
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
                          onTap: _showFilterDialog,
                          borderRadius: BorderRadius.circular(24),
                          child: const Center(
                            child: Text(
                              'All',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Show results if search/filter is active
            if (isSearchActive || isFilterActive)
              Container(
                width: double.infinity,
                color: const Color(0xFF5A5A5A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Text(
                  'RESULT (${displayedResults.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            if (isSearchActive || isFilterActive)
              if (displayedResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    children: List.generate(displayedResults.length, (index) {
                      final project = displayedResults[index];
                      return _buildSearchResultCard(project, context);
                    }),
                  ),
                ),

            // Show home content if no search/filter
            if (!isSearchActive && !isFilterActive) ...[
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
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : hotProjects.isEmpty
                        ? const Center(
                            child: Text('No projects available'),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            itemCount: hotProjects.length,
                            itemBuilder: (context, index) {
                              final project = hotProjects[index];
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
                child: recommendProjects.isEmpty
                    ? const Center(
                        child: Text('No projects available'),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        itemCount: recommendProjects.length,
                        itemBuilder: (context, index) {
                          final project = recommendProjects[index];
                          return _buildProjectCard(project, context);
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project, BuildContext context) {
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
        margin: const EdgeInsets.only(right: 12.0),
        width: 280,
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
                decoration: const BoxDecoration(color: Color(0xFFD9D9D9)),
                child: project.image_url.isNotEmpty
                    ? Image.network(
                        project.image_url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Text('Image failed to load',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF999999))),
                        ),
                      )
                    : const Center(
                        child: Text(
                          'No image',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFF999999)),
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
                  const SizedBox(height: 8),
                  // Heart icon at bottom right
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(ProjectModel project, BuildContext context) {
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
                decoration: const BoxDecoration(color: Color(0xFFD9D9D9)),
                child: project.image_url.isNotEmpty
                    ? Image.network(
                        project.image_url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Text('Image failed to load',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF999999))),
                        ),
                      )
                    : const Center(
                        child: Text(
                          'No image',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFF999999)),
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
          builder: (BuildContext context, StateSetter setStateDialog) {
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
                              Icons.close,
                              color: Color(0xFF1B6A68),
                              size: 20,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              if (isSelected) {
                                selectedFilters.remove(option);
                              } else {
                                selectedFilters.add(option);
                              }
                            });
                            _updateDisplay();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
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
