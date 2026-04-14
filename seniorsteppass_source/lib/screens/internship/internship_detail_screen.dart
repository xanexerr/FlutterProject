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
                    'Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.head,
                    ),
                  ),
                  const SizedBox(height: 12),
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

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final reviewData =
                              reviews[index].data() as Map<String, dynamic>;
                          final rating = reviewData['rating'] ?? 0;
                          final reviewText = reviewData['review_text'] ?? '';
                          final createdAt = reviewData['created_at'] ?? '';

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      reviewData['department'] ?? 'Intern',
                                      style: const TextStyle(
                                        fontSize: 14,
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
                                          '$rating/5',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.head,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  createdAt,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.head3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  reviewText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.head2,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
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
