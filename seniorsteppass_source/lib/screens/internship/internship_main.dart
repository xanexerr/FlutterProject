import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/company_model.dart';
import '../../models/favorites_manager.dart';
import 'internship_detail_screen.dart';

class InternshipMainScreen extends StatefulWidget {
  final Set<String>? initialFilters;

  const InternshipMainScreen({super.key, this.initialFilters});

  @override
  State<InternshipMainScreen> createState() => _InternshipMainScreenState();
}

class _InternshipMainScreenState extends State<InternshipMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CompanyModel> allCompanies = [];
  List<CompanyModel> displayedResults = [];
  bool isLoading = true;
  bool isSearchActive = false;
  bool isSortActive = false; // Track if sorting is active
  String sortOrder = 'newest'; // newest, oldest, ratingHigh, ratingLow
  final FavoritesManager _favoritesManager = FavoritesManager();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache for calculated ratings
  final Map<String, double> _ratingCache = {};

  final Map<String, String> sortOptions = {
    'newest': 'ใหม่ไปเก่า (ค่าเริ่มต้น)',
    'oldest': 'เก่าไปใหม่',
    'ratingHigh': 'คะแนนมากไปน้อย',
    'ratingLow': 'คะแนนน้อยไปมาก',
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateDisplay);
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('internships').get();
      final companies = snapshot.docs.map((doc) => CompanyModel.fromJson(doc.data(), doc.id)).toList();
      setState(() {
        allCompanies = companies;
        isLoading = false;
        _updateDisplay();
      });
    } catch (e) {
      print('Error fetching companies: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateDisplay() {
    if (!mounted) return;
    setState(() {
      String searchText = _searchController.text.trim();
      isSearchActive = searchText.isNotEmpty;

      // Reset sort if search is active
      if (isSearchActive) {
        isSortActive = false;
      }

      if (isSearchActive) {
        // Search from all fields: company name, department, description, location, website
        displayedResults = allCompanies.where((company) {
          final searchLower = searchText.toLowerCase();
          return company.company_name.toLowerCase().contains(searchLower) ||
              company.department.toLowerCase().contains(searchLower) ||
              company.description.toLowerCase().contains(searchLower) ||
              company.location.toLowerCase().contains(searchLower) ||
              company.website.toLowerCase().contains(searchLower);
        }).toList();
      } else {
        // No search - show home
        displayedResults = [];
      }

      // Apply sorting
      _applySorting();
    });
  }

  void _applySorting() {
    // Sort the appropriate list based on current view
    List<CompanyModel> listToSort;
    
    if (isSearchActive) {
      listToSort = displayedResults;
    } else if (isSortActive) {
      listToSort = allCompanies;
    } else {
      return; // No sorting needed
    }
    
    switch (sortOrder) {
      case 'oldest':
        listToSort.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'ratingHigh':
        listToSort.sort((a, b) => b.overallRating.compareTo(a.overallRating));
        break;
      case 'ratingLow':
        listToSort.sort((a, b) => a.overallRating.compareTo(b.overallRating));
        break;
      case 'newest':
      default:
        listToSort.sort((a, b) => b.id.compareTo(a.id));
    }
  }

  void _performSearch(String query) {
    _updateDisplay();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showSortDialog,
                    child: Container(
                      height: 48,
                      width: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B6A68),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showSortDialog,
                          borderRadius: BorderRadius.circular(24),
                          child: const Center(
                            child: Icon(Icons.sort, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Show results if search is active
            if (isSearchActive)
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
            if (isSearchActive)
              if (displayedResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
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
                    children: List.generate(
                      displayedResults.length,
                      (index) {
                        final company = displayedResults[index];
                        return _buildSearchResultCard(company, context);
                      },
                    ),
                  ),
                ),

            // Show sorted results when sorting is active (without search)
            if (isSortActive && !isSearchActive)
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF5A5A5A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ALL INTERNSHIPS (${allCompanies.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    itemCount: allCompanies.length,
                    itemBuilder: (context, index) {
                      final company = allCompanies[index];
                      return _buildHorizontalCompanyCard(company, context);
                    },
                  ),
                ],
              ),

            // Show home content if no search/sort
            if (!isSearchActive && !isSortActive) ...[
              // Top 3 Highest Rating Section
              Container(
                width: double.infinity,
                color: const Color(0xFF5A5A5A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: const Text(
                  'Most Recommended',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: const Color(0xFFF7F5DD),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: List.generate(
                        _getTop3ByRating().length,
                        (index) {
                          final company = _getTop3ByRating()[index];
                          return Column(
                            children: [
                              _buildInlineCompanyItem(company, context, index + 1),
                              if (index < _getTop3ByRating().length - 1)
                                Divider(
                                  height: 12,
                                  color: Colors.grey[300],
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Top 3 Most Applied Section
              Container(
                width: double.infinity,
                color: const Color(0xFF5A5A5A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: const Text(
                  'Most Applied',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: const Color(0xFFF7F5DD),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: List.generate(
                        _getTop3ByReviews().length,
                        (index) {
                          final company = _getTop3ByReviews()[index];
                          return Column(
                            children: [
                              _buildInlineCompanyItem(company, context, index + 1),
                              if (index < _getTop3ByReviews().length - 1)
                                Divider(
                                  height: 12,
                                  color: Colors.grey[300],
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // All Internship Section
              Container(
                width: double.infinity,
                color: const Color(0xFF5A5A5A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: const Text(
                  'All Internships',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                itemCount: allCompanies.length,
                itemBuilder: (context, index) {
                  final company = allCompanies[index];
                  return _buildHorizontalCompanyCard(company, context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Calculate average rating from Firebase reviews collection
  Future<double> _getAverageRatingFromReviews(String internshipId) async {
    if (_ratingCache.containsKey(internshipId)) {
      return _ratingCache[internshipId]!;
    }

    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('internship_id', isEqualTo: internshipId)
          .where('status', isEqualTo: 'Approved')
          .get();

      if (snapshot.docs.isEmpty) {
        _ratingCache[internshipId] = 0.0;
        return 0.0;
      }

      double totalRating = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final workload = (data['workload_rating'] as num?)?.toDouble() ?? 0;
        final environment = (data['environment_rating'] as num?)?.toDouble() ?? 0;
        final mentorship = (data['mentorship_rating'] as num?)?.toDouble() ?? 0;
        final benefits = (data['benefits_rating'] as num?)?.toDouble() ?? 0;

        final avg = (workload + environment + mentorship + benefits) / 4;
        totalRating += avg;
        count++;
      }

      final averageRating = count > 0 ? totalRating / count : 0.0;
      _ratingCache[internshipId] = averageRating;
      return averageRating;
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0.0;
    }
  }

  List<CompanyModel> _getTop3ByRating() {
    final sorted = [...allCompanies];
    sorted.sort((a, b) => b.overallRating.compareTo(a.overallRating));
    return sorted.take(3).toList();
  }

  List<CompanyModel> _getTop3ByReviews() {
    final sorted = [...allCompanies];
    sorted.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return sorted.take(3).toList();
  }

  Widget _buildInlineCompanyItem(CompanyModel company, BuildContext context, int rank) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InternshipDetailScreen(company: company),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1B6A68),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
                    company.company_name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company.department,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1B6A68),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      FutureBuilder<double>(
                        future: _getAverageRatingFromReviews(company.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text(
                              'Loading',
                              style: TextStyle(fontSize: 11),
                            );
                          }
                          final rating = snapshot.data ?? 0.0;
                          return Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${company.reviewCount} reviews)',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Logo and Favorite Button
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFD9D9D9),
              ),
              child: Image.network(
                company.logo_url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFD9D9D9),
                    child: const Icon(
                      Icons.business,
                      color: Color(0xFF1B6A68),
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _favoritesManager.toggleFavorite(company.id);
                });
              },
              child: Icon(
                _favoritesManager.isFavorite(company.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: _favoritesManager.isFavorite(company.id)
                    ? Colors.red
                    : Colors.grey[400],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCompanyCard(CompanyModel company, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InternshipDetailScreen(company: company),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFFF7F5DD),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFD9D9D9),
                ),
                child: Image.network(
                  company.logo_url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFD9D9D9),
                      child: const Icon(
                        Icons.business,
                        color: Color(0xFF1B6A68),
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Company Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.company_name,
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
                      company.department,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1B6A68),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.description,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        FutureBuilder<double>(
                          future: _getAverageRatingFromReviews(company.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text(
                                'Loading',
                                style: TextStyle(fontSize: 10),
                              );
                            }
                            final rating = snapshot.data ?? 0.0;
                            return Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${company.reviewCount})',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Favorite Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _favoritesManager.toggleFavorite(company.id);
                  });
                },
                child: Icon(
                  _favoritesManager.isFavorite(company.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _favoritesManager.isFavorite(company.id)
                      ? Colors.red
                      : Colors.grey[400],
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(dynamic company, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InternshipDetailScreen(company: company),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFFF7F5DD),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFD9D9D9),
                ),
                child: Image.network(
                  company.logo_url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFD9D9D9),
                      child: const Icon(
                        Icons.business,
                        color: Color(0xFF1B6A68),
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Company Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.company_name,
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
                      company.department,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1B6A68),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.description,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        FutureBuilder<double>(
                          future: _getAverageRatingFromReviews(company.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text(
                                'Loading',
                                style: TextStyle(fontSize: 10),
                              );
                            }
                            final rating = snapshot.data ?? 0.0;
                            return Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${company.reviewCount})',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Favorite Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _favoritesManager.toggleFavorite(company.id);
                  });
                },
                child: Icon(
                  _favoritesManager.isFavorite(company.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _favoritesManager.isFavorite(company.id)
                      ? Colors.red
                      : Colors.grey[400],
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortDialog() {
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
                          'เรียงลำดับ',
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

                    // Sort Options
                    ...sortOptions.entries.map((entry) {
                      final isSelected = sortOrder == entry.key;
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected && isSortActive) {
                                // If selecting the same sort option again, toggle off
                                isSortActive = false;
                                sortOrder = 'newest';
                              } else {
                                // Select new sort option
                                sortOrder = entry.key;
                                isSortActive = true;
                                _applySorting();
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
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
                                    color: isSelected && isSortActive
                                        ? const Color(0xFF1B6A68)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: const Color(0xFF1B6A68),
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: isSelected && isSortActive
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value,
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
