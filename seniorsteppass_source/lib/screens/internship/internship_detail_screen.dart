import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/company_model.dart';
import '../../models/favorites_manager.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_buttons.dart';
import '../../services/current_user_service.dart';

class InternshipDetailScreen extends StatefulWidget {
  final CompanyModel company;

  const InternshipDetailScreen({
    super.key,
    required this.company,
  });

  @override
  State<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends State<InternshipDetailScreen> {
  final FavoritesManager _favoritesManager = FavoritesManager();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSelected = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfSelected();
  }

  Future<void> _checkIfSelected() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email!)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        final internList = userData['intern_list'] as List<dynamic>? ?? [];
        
        bool isSelected = internList.any((item) =>
            item['company'] == widget.company.company_name &&
            item['role'] == widget.company.department);

        setState(() => _isSelected = isSelected);
      }
    } catch (e) {
      print('Error checking selected internship: $e');
    }
  }

  Future<void> _selectInternship() async {
    if (_isSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This internship is already selected'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email!)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userDocId = userQuery.docs.first.id;
      final userData = userQuery.docs.first.data();
      final internList = userData['intern_list'] as List<dynamic>? ?? [];

      // Add new internship
      final newInternship = {
        'company': widget.company.company_name,
        'role': widget.company.department,
        'logo_url': widget.company.logo_url,
      };

      internList.add(newInternship);

      // Update user document
      await _firestore.collection('users').doc(userDocId).update({
        'intern_list': internList,
      });

      setState(() => _isSelected = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Internship added to your profile!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.bad,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCategoryRating(String label, double rating, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              '${rating.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.head2),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSmallRatingChip(String label, double rating) {
    final stars = List.generate(
      5,
      (index) => Icon(
        index < rating ? Icons.star : Icons.star_border,
        size: 10,
        color: Colors.amber,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppTheme.head2),
          ),
          const SizedBox(width: 2),
          ...stars,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: const CustomHeader(showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header
            Container(
              width: double.infinity,
              color: AppTheme.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo and Favorite Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.lightGrey,
                        ),
                        child: Image.network(
                          widget.company.logo_url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.lightGrey,
                              child: const Icon(
                                Icons.business,
                                color: AppTheme.primaryTeal,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ),
                      // Favorite Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _favoritesManager.toggleFavorite(widget.company.id);
                          });
                        },
                        child: Icon(
                          _favoritesManager.isFavorite(widget.company.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _favoritesManager.isFavorite(widget.company.id)
                              ? Colors.red
                              : Colors.grey[400],
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Company Info
                  Text(
                    widget.company.company_name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.head,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.company.department,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppTheme.primaryTeal,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.company.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.head2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB72B),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.company.overallRating}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.head,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.company.reviewCount} reviews',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.head2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Company',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.head,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.company.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.head2,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Select Internship Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _selectInternship,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSelected ? AppTheme.success : AppTheme.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Text(
                          _isSelected ? '✓ Added to Profile' : 'Select This Internship',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Reviews Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Internship Feedback',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.head,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('reviews')
                        .where('internship_id', isEqualTo: widget.company.id)
                        .where('status', isEqualTo: 'Approved')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'No reviews yet',
                            style: TextStyle(color: AppTheme.head2),
                          ),
                        );
                      }

                      final reviews = snapshot.data!.docs;

                      // Calculate average ratings
                      double avgWorkload = 0, avgEnvironment = 0, avgMentorship = 0, avgBenefits = 0;
                      int count = reviews.length;
                      
                      if (count > 0) {
                        for (var doc in reviews) {
                          final data = doc.data() as Map<String, dynamic>;
                          avgWorkload += (data['workload_rating'] as num?)?.toDouble() ?? 0;
                          avgEnvironment += (data['environment_rating'] as num?)?.toDouble() ?? 0;
                          avgMentorship += (data['mentorship_rating'] as num?)?.toDouble() ?? 0;
                          avgBenefits += (data['benefits_rating'] as num?)?.toDouble() ?? 0;
                        }
                        avgWorkload /= count;
                        avgEnvironment /= count;
                        avgMentorship /= count;
                        avgBenefits /= count;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Ratings
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.head,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildCategoryRating('Workload', avgWorkload, Colors.green),
                                    _buildCategoryRating('Environment', avgEnvironment, Colors.red),
                                    _buildCategoryRating('Mentorship', avgMentorship, Colors.green),
                                    _buildCategoryRating('Benefits', avgBenefits, Colors.amber),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Average Rating Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'แนวคะแนนรวม (Average Rating)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.head,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Workload: ${avgWorkload.toStringAsFixed(1)}/5 | Environment: ${avgEnvironment.toStringAsFixed(1)}/5\nMentorship: ${avgMentorship.toStringAsFixed(1)}/5 | Benefits: ${avgBenefits.toStringAsFixed(1)}/5',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.head2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Reviews List
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final reviewData =
                                  reviews[index].data() as Map<String, dynamic>;
                              final workloadRating = reviewData['workload_rating'] as num? ?? 0;
                              final environmentRating = reviewData['environment_rating'] as num? ?? 0;
                              final mentorshipRating = reviewData['mentorship_rating'] as num? ?? 0;
                              final benefitsRating = reviewData['benefits_rating'] as num? ?? 0;
                              final reviewText = reviewData['review_text'] ?? '';
                              final createdAt = reviewData['created_at'] ?? '';
                              final department = reviewData['department'] ?? 'Intern';

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          department,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.head,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              color: Color(0xFFFFB72B),
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${((workloadRating.toDouble() + environmentRating.toDouble() + mentorshipRating.toDouble() + benefitsRating.toDouble()) / 4).toStringAsFixed(1)}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.head,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Category Ratings for this review
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        _buildSmallRatingChip('Workload', workloadRating.toDouble()),
                                        _buildSmallRatingChip('Environment', environmentRating.toDouble()),
                                        _buildSmallRatingChip('Mentorship', mentorshipRating.toDouble()),
                                        _buildSmallRatingChip('Benefits', benefitsRating.toDouble()),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Timestamp
                                    Text(
                                      createdAt,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.head3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Review text
                                    Text(
                                      reviewText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.head2,
                                        height: 1.4,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
