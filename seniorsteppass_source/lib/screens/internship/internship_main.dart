import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import 'internship_detail_screen.dart';

class InternshipMainScreen extends StatefulWidget {
  final Set<String>? initialFilters;

  const InternshipMainScreen({super.key, this.initialFilters});

  @override
  State<InternshipMainScreen> createState() => _InternshipMainScreenState();
}

class _InternshipMainScreenState extends State<InternshipMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Set<String> selectedFilters;
  List<dynamic> displayedResults = [];
  bool isSearchActive = false;
  bool isFilterActive = false;
  String sortOrder = 'newest'; // newest, oldest, ratingHigh, ratingLow

  final List<String> filterOptions = [
    'Software Engineer',
    'Data Science',
    'Internet Of Thing',
    'Cyber Security',
  ];

  final Map<String, String> sortOptions = {
    'newest': 'ใหม่ไปเก่า (ค่าเริ่มต้น)',
    'oldest': 'เก่าไปใหม่',
    'ratingHigh': 'คะแนนมากไปน้อย',
    'ratingLow': 'คะแนนน้อยไปมาก',
  };

  @override
  void initState() {
    super.initState();
    selectedFilters = widget.initialFilters ?? {};
    _searchController.addListener(_updateDisplay);
    _updateDisplay();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateDisplay() {
    setState(() {
      String searchText = _searchController.text.trim();
      isSearchActive = searchText.isNotEmpty;
      isFilterActive = selectedFilters.isNotEmpty;

      if (isFilterActive && isSearchActive) {
        // Combined filter + search
        displayedResults = mockCompanies.where((company) {
          bool matchesFilter = selectedFilters.contains(company.department);
          bool matchesSearch = company.name
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
              company.description.toLowerCase().contains(searchText.toLowerCase());
          return matchesFilter && matchesSearch;
        }).toList();
      } else if (isFilterActive) {
        // Filter only
        displayedResults = mockCompanies
            .where((company) => selectedFilters.contains(company.department))
            .toList();
      } else if (isSearchActive) {
        // Search only
        displayedResults = mockCompanies
            .where((company) =>
                company.name.toLowerCase().contains(searchText.toLowerCase()) ||
                company.description
                    .toLowerCase()
                    .contains(searchText.toLowerCase()))
            .toList();
      } else {
        // No search/filter - show home
        displayedResults = [];
      }

      // Apply sorting
      _applySorting();
    });
  }

  void _applySorting() {
    switch (sortOrder) {
      case 'oldest':
        displayedResults.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'ratingHigh':
        displayedResults.sort((a, b) => b.overallRating.compareTo(a.overallRating));
        break;
      case 'ratingLow':
        displayedResults.sort((a, b) => a.overallRating.compareTo(b.overallRating));
        break;
      case 'newest':
      default:
        displayedResults.sort((a, b) => b.id.compareTo(a.id));
    }
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
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showFilterDialog,
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
                          onTap: _showFilterDialog,
                          borderRadius: BorderRadius.circular(24),
                          child: const Center(
                            child: Icon(Icons.filter_list, color: Colors.white, size: 20),
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

            // Show home content if no search/filter
            if (!isSearchActive && !isFilterActive) ...[
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
                itemCount: mockCompanies.length,
                itemBuilder: (context, index) {
                  final company = mockCompanies[index];
                  return _buildHorizontalCompanyCard(company, context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<dynamic> _getTop3ByRating() {
    final sorted = [...mockCompanies];
    sorted.sort((a, b) => b.overallRating.compareTo(a.overallRating));
    return sorted.take(3).toList();
  }

  List<dynamic> _getTop3ByReviews() {
    final sorted = [...mockCompanies];
    sorted.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return sorted.take(3).toList();
  }

  Widget _buildInlineCompanyItem(dynamic company, BuildContext context, int rank) {
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
                    company.name,
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
                      Text(
                        company.overallRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
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
            // Logo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFD9D9D9),
              ),
              child: Image.network(
                company.logoUrl,
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
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCompanyCard(dynamic company, BuildContext context) {
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
                  company.logoUrl,
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
                      company.name,
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
                  ],
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
                  company.logoUrl,
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
                      company.name,
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
                  ],
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
                          sortOrder = entry.key;
                          _applySorting();
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
                          'Internship Filter',
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
