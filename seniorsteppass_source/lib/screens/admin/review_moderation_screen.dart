import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../models/mock_data.dart';
import '../../theme/app_theme.dart';

class ReviewModerationScreen extends StatefulWidget {
  const ReviewModerationScreen({super.key});

  @override
  State<ReviewModerationScreen> createState() => _ReviewModerationScreenState();
}

class _ReviewModerationScreenState extends State<ReviewModerationScreen> {
  late List<Map<String, dynamic>> _moderationList;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }
  
  void _loadReviews() {
    _moderationList = [];
    for (var company in mockCompanies) {
      if (company.reviews.isNotEmpty) {
        for (var review in company.reviews) {
          _moderationList.add({
            'company': company.company_name,
            'review': review,
            'status': 'Pending', // Pending, Approved, Hidden
          });
        }
      }
    }
  }

  void _updateStatus(int index, String status) {
    setState(() {
      _moderationList[index]['status'] = status;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review marked as $status')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _moderationList.length,
        itemBuilder: (context, index) {
          final item = _moderationList[index];
          final ReviewModel review = item['review'];
          final String companyName = item['company'];
          final String status = item['status'];
          
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
                  Text('Reviewer: ${review.reviewer_id}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(' ${review.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      style: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.head2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (status != 'Hidden')
                        TextButton.icon(
                          onPressed: () => _updateStatus(index, 'Hidden'),
                          icon: const Icon(Icons.visibility_off, size: 18),
                          label: const Text('Hide'),
                          style: TextButton.styleFrom(foregroundColor: AppTheme.bad),
                        ),
                      if (status != 'Approved')
                        const SizedBox(width: 8),
                      if (status != 'Approved')
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(index, 'Approved'),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}