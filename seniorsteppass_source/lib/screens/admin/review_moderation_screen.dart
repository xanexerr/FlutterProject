import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../models/mock_data.dart';
import '../../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModerationScreen extends StatefulWidget {
  const ReviewModerationScreen({super.key});

  @override
  State<ReviewModerationScreen> createState() => _ReviewModerationScreenState();
}

class _ReviewModerationScreenState extends State<ReviewModerationScreen> {
  Stream<String> _getReviewerName(String reviewerID) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('student_id', isEqualTo: reviewerID)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs.first.get('full_name') ?? reviewerID;
          }
          return reviewerID;
        });
  }

  Future<void> _updateStatus(String reviewId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .update({'status': newStatus});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review marked as $newStatus'),
          backgroundColor: newStatus == 'Approved'
              ? AppTheme.success
              : AppTheme.bad,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.bad),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading reviews'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data!.docs.map((doc) {
            return ReviewModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews to moderate.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];

              Color statusColor;
              if (review.status == 'Approved') {
                statusColor = AppTheme.success;
              } else if (review.status == 'Hidden') {
                statusColor = AppTheme.bad;
              } else {
                statusColor = AppTheme.warning;
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Company: ${review.company}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.head,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              review.status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      StreamBuilder<String>(
                        stream: _getReviewerName(review.reviewer_id),
                        builder: (context, nameSnapshot) {
                          return Text(
                            'Reviewer: ${nameSnapshot.data ?? review.reviewer_id}',
                            style: const TextStyle(fontSize: 13, color: AppTheme.head3),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            ' ${review.rating}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.third.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '"${review.comment}"',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppTheme.head2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (review.status != 'Hidden')
                            TextButton.icon(
                              onPressed: () => _updateStatus(review.id, 'Hidden'),
                              icon: const Icon(Icons.visibility_off, size: 18),
                              label: const Text('Hide'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.bad,
                              ),
                            ),
                          const SizedBox(width: 8),
                          if (review.status != 'Approved')
                            ElevatedButton.icon(
                              onPressed: () => _updateStatus(review.id, 'Approved'),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
