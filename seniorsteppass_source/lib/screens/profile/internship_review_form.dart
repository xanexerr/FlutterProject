import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class InternshipReviewForm extends StatefulWidget {
  final String companyName;
  final String role;

  const InternshipReviewForm({
    super.key,
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
                  ),
                  child: const Text(
                    'Submit Review',
                    style: TextStyle(
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
