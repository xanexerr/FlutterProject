import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  double _rating = 0;
  final _reviewController = TextEditingController();
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
          _rating = (reviewData['rating'] as num?)?.toDouble() ?? 0.0;
          _reviewController.text = reviewData['review_text'] ?? '';
          _isEditing = true;
        });
      }
    } catch (e) {
      print('Error checking existing review: $e');
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleYellow,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text('Internship Review', style: TextStyle(color: AppTheme.white)),
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Review your Internship Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.head,
                ),
              ),
              const SizedBox(height: 20),
              
              const Text('Company Name', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.head)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: widget.companyName, // ไว้รับค่าจากหน้า Profile อีกที
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Role / Department', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.head)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: widget.role, // ไว้รับค่าจากหน้า Profile อีกที
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                    
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Rating', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.head)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),

              const Text('Review Details', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.head)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reviewController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  filled: true,
                  fillColor: AppTheme.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your review';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate() && _rating > 0) {
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
                          'rating': _rating,
                          'review_text': _reviewController.text,
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
                              const SnackBar(content: Text('Review updated successfully!')),
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
                              const SnackBar(content: Text('Review submitted successfully!')),
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
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
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
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: AppTheme.white),
                        )
                      : Text(
                          _isEditing ? 'Update Review' : 'Submit Review',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
