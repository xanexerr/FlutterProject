import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/current_user_service.dart';
import '../../services/cloudinary_service.dart';

class InternshipReviewForm extends StatefulWidget {
  final String internshipId;
  final String companyName;
  final String role;

  const InternshipReviewForm({
    super.key,
    required this.internshipId,
    required this.companyName, 
    required this.role
  });

  @override
  State<InternshipReviewForm> createState() => _InternshipReviewFormState();
}

class _InternshipReviewFormState extends State<InternshipReviewForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Rating categories
  double _workloadRating = 0;
  double _environmentRating = 0;
  double _mentorshipRating = 0;
  double _benefitsRating = 0;
  
  final _commentController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  String? _existingReviewId;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _checkExistingReview();
  }

  Future<void> _checkExistingReview() async {
    try {
      final currentUserService = CurrentUserService();
      
      // First, fetch and cache the current user data to get the Firestore doc ID
      await currentUserService.fetchCurrentUserData();
      
      final studentId = currentUserService.getCurrentUserId();
      if (studentId == null) return;

      final query = await FirebaseFirestore.instance
          .collection('reviews')
          .where('student_id', isEqualTo: studentId)
          .where('internship_id', isEqualTo: widget.internshipId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final reviewData = query.docs[0].data();
        setState(() {
          _existingReviewId = query.docs[0].id;
          
          // Handle both old format (single rating) and new format (category ratings)
          if (reviewData.containsKey('workload_rating')) {
            _workloadRating = (reviewData['workload_rating'] as num?)?.toDouble() ?? 0.0;
            _environmentRating = (reviewData['environment_rating'] as num?)?.toDouble() ?? 0.0;
            _mentorshipRating = (reviewData['mentorship_rating'] as num?)?.toDouble() ?? 0.0;
            _benefitsRating = (reviewData['benefits_rating'] as num?)?.toDouble() ?? 0.0;
          } else if (reviewData.containsKey('rating')) {
            // Old format - convert single rating to all categories
            final singleRating = (reviewData['rating'] as num?)?.toDouble() ?? 0.0;
            _workloadRating = singleRating;
            _environmentRating = singleRating;
            _mentorshipRating = singleRating;
            _benefitsRating = singleRating;
          }
          
          _commentController.text = reviewData['review_text'] as String? ?? '';
          _isEditing = true;
        });
      }
    } catch (e) {
      print('Error checking existing review: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Widget _buildStarRating(double rating, Function(int) onRatingChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged(index + 1),
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 28,
          ),
        );
      }),
    );
  }

  Widget _buildRatingCategory(
    String label,
    double rating,
    Function(int) onRatingChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 12),
          _buildStarRating(rating, onRatingChanged),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryTeal,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // Company Info Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.companyName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.role,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Rating Categories Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildRatingCategory(
                      'Workload',
                      _workloadRating,
                      (rating) => setState(() => _workloadRating = rating.toDouble()),
                    ),
                    _buildRatingCategory(
                      'Environment',
                      _environmentRating,
                      (rating) => setState(() => _environmentRating = rating.toDouble()),
                    ),
                    _buildRatingCategory(
                      'Mentorship',
                      _mentorshipRating,
                      (rating) => setState(() => _mentorshipRating = rating.toDouble()),
                    ),
                    _buildRatingCategory(
                      'Benefits',
                      _benefitsRating,
                      (rating) => setState(() => _benefitsRating = rating.toDouble()),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),

              // Comment Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _commentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Share your experience...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your comment';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Image Upload Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Choose File',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _selectedImage != null
                                  ? _selectedImage!.path.split('/').last
                                  : 'No image selected',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _rating > 0) {
                      final reviewData = {
                        'company': widget.companyName,
                        'position': widget.role,
                        'rating': _rating,
                        'comment': _reviewController.text,
                        'reviewer_id': FirebaseAuth.instance.currentUser?.email ?? 'anonymous',
                        'timestamp': FieldValue.serverTimestamp(),
                        'status': 'Pending',
                        'techStack': [],
                      };

                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );

                        await FirebaseFirestore.instance.collection('reviews').add(reviewData);

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review submitted successfully!')),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to submit review. Please try again later.')),
                        );
                      }
                    } else if (_rating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please provide a rating')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate() &&
        _workloadRating > 0 &&
        _environmentRating > 0 &&
        _mentorshipRating > 0 &&
        _benefitsRating > 0) {
      setState(() => _isLoading = true);

      try {
        final currentUserService = CurrentUserService();
        
        // Fetch and cache the current user data to get the Firestore doc ID
        await currentUserService.fetchCurrentUserData();
        
        final studentId = currentUserService.getCurrentUserId();

        if (studentId == null) {
          throw Exception('User not authenticated');
        }

        // Upload image to Cloudinary if selected
        String? imageUrl;
        if (_selectedImage != null) {
          final cloudinaryService = CloudinaryService();
          final xFile = XFile(_selectedImage!.path);
          imageUrl = await cloudinaryService.uploadImage(xFile);
        }

        final reviewData = {
          'student_id': studentId,
          'internship_id': widget.internshipId,
          'company_name': widget.companyName,
          'department': widget.role,
          'workload_rating': _workloadRating,
          'environment_rating': _environmentRating,
          'mentorship_rating': _mentorshipRating,
          'benefits_rating': _benefitsRating,
          'review_text': _commentController.text.trim(),
          'status': 'Pending',
          'updated_at': Timestamp.now(),
        };

        // Add image URL if upload was successful
        if (imageUrl != null && imageUrl.isNotEmpty) {
          reviewData['image_url'] = imageUrl;
        }

        if (_isEditing && _existingReviewId != null) {
          // UPDATE existing review
          try {
            await FirebaseFirestore.instance
                .collection('reviews')
                .doc(_existingReviewId!)
                .update(reviewData);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback updated successfully!'),
                  backgroundColor: AppTheme.success,
                ),
              );
            }
          } catch (e) {
            print('Update error: $e');
            throw Exception('Failed to update review: $e');
          }
        } else {
          // CREATE new review
          reviewData['created_at'] = Timestamp.now();
          try {
            await FirebaseFirestore.instance
                .collection('reviews')
                .add(reviewData);

            // Update internship reviewCount and overallRating
            try {
              final internshipDoc = await FirebaseFirestore.instance
                  .collection('internships')
                  .doc(widget.internshipId)
                  .get();

              if (internshipDoc.exists) {
                final data = internshipDoc.data() as Map<String, dynamic>;
                final currentReviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
                final currentRating = (data['overallRating'] as num?)?.toDouble() ?? 0.0;

                // Calculate new review average
                final newReviewAverage = 
                    (_workloadRating + _environmentRating + _mentorshipRating + _benefitsRating) / 4;

                // Calculate updated overall rating
                // If overallRating is 0, use newReviewAverage directly
                final updatedRating = currentRating == 0.0 ? newReviewAverage : (newReviewAverage + currentRating) / 2;

                // Update internship document
                await FirebaseFirestore.instance
                    .collection('internships')
                    .doc(widget.internshipId)
                    .update({
                      'reviewCount': currentReviewCount + 1,
                      'overallRating': updatedRating,
                    });
              }
            } catch (e) {
              print('Error updating internship stats: $e');
              // Continue even if update fails
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback submitted successfully!'),
                  backgroundColor: AppTheme.success,
                ),
              );
            }
          } catch (e) {
            print('Create error: $e');
            throw Exception('Failed to submit review: $e');
          }
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.bad,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all ratings and comment'),
          backgroundColor: AppTheme.warning,
        ),
      );
    }
  }
}
