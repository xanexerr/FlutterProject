import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/current_user_service.dart';

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
          _workloadRating = (reviewData['workload_rating'] as num?)?.toDouble() ?? 0.0;
          _environmentRating = (reviewData['environment_rating'] as num?)?.toDouble() ?? 0.0;
          _mentorshipRating = (reviewData['mentorship_rating'] as num?)?.toDouble() ?? 0.0;
          _benefitsRating = (reviewData['benefits_rating'] as num?)?.toDouble() ?? 0.0;
          _commentController.text = reviewData['review_text'] ?? '';
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
      appBar: AppBar(
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        title: const Text('Internship Feedback'),
        centerTitle: true,
      ),
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
                    const Text(
                      'Internship Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
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

              const SizedBox(height: 24),

              // Submit and Cancel Buttons
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isEditing ? 'Update Feedback' : 'Submit',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
        final studentId = currentUserService.getCurrentUserId();

        if (studentId == null) {
          throw Exception('User not authenticated');
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
          'review_text': _commentController.text,
          'status': 'Pending',
          'updated_at': Timestamp.now(),
        };

        if (_isEditing && _existingReviewId != null) {
          // UPDATE existing review
          await FirebaseFirestore.instance
              .collection('reviews')
              .doc(_existingReviewId)
              .update(reviewData);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Feedback updated successfully!'),
                backgroundColor: AppTheme.success,
              ),
            );
          }
        } else {
          // CREATE new review
          reviewData['created_at'] = Timestamp.now();
          await FirebaseFirestore.instance
              .collection('reviews')
              .add(reviewData);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Feedback submitted successfully!'),
                backgroundColor: AppTheme.success,
              ),
            );
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
