import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class ReviewModerationScreen extends StatefulWidget {
  const ReviewModerationScreen({super.key});

  @override
  State<ReviewModerationScreen> createState() => _ReviewModerationScreenState();
}

class _ReviewModerationScreenState extends State<ReviewModerationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Format Timestamp to: April 15, 2026 at 12:55:08 AM UTC+7
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is String) return timestamp;
    if (timestamp == null) return '';
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return '';
    }

    final monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                        'July', 'August', 'September', 'October', 'November', 'December'];
    final month = monthNames[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year at $hour:$minute:$second $period UTC+7';
  }

  Future<void> _updateReviewStatus(String reviewId, String newStatus) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'status': newStatus,
        'updated_at': DateTime.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review marked as $newStatus'),
            backgroundColor: newStatus == 'Approved' ? AppTheme.success : AppTheme.bad,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.bad),
        );
      }
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted'), backgroundColor: AppTheme.bad),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.bad),
        );
      }
    }
  }

  void _confirmDelete(String reviewId, String companyName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review', style: TextStyle(color: AppTheme.bad)),
        content: Text('Are you sure you want to delete the review for $companyName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteReview(reviewId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bad),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('reviews').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reviews found'));
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final reviewDoc = reviews[index];
              final reviewData = reviewDoc.data() as Map<String, dynamic>;
              final reviewId = reviewDoc.id;

              final String companyName = reviewData['company_name'] ?? 'Unknown Company';
              final String reviewText = reviewData['review_text'] ?? '';
              final int rating = reviewData['rating'] ?? 0;
              final String userId = reviewData['user_id'] ?? 'Unknown User';
              final String createdAt = _formatTimestamp(reviewData['created_at']);
              final String status = reviewData['status'] ?? 'Pending';

              Color statusColor;
              if (status == 'Approved') {
                statusColor = AppTheme.success;
              } else if (status == 'Hidden') {
                statusColor = AppTheme.bad;
              } else {
                statusColor = AppTheme.warning;
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              'Company: $companyName',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.head),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Reviewer: $userId', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' $rating/5', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          Text(createdAt, style: const TextStyle(fontSize: 12, color: AppTheme.head2)),
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
                          '"$reviewText"',
                          style: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.head2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status != 'Hidden')
                            TextButton.icon(
                              onPressed: () => _updateReviewStatus(reviewId, 'Hidden'),
                              icon: const Icon(Icons.visibility_off, size: 18),
                              label: const Text('Hide'),
                              style: TextButton.styleFrom(foregroundColor: AppTheme.bad),
                            ),
                          if (status != 'Approved')
                            const SizedBox(width: 8),
                          if (status != 'Approved')
                            ElevatedButton.icon(
                              onPressed: () => _updateReviewStatus(reviewId, 'Approved'),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _confirmDelete(reviewId, companyName),
                            icon: const Icon(Icons.delete, size: 20),
                            color: AppTheme.bad,
                          ),
                        ],
                      )
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