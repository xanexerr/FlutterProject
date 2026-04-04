import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/mock_data.dart';
import '../../widgets/common_buttons.dart';
import 'internship_detail_screen.dart';

class InternshipListingScreen extends StatelessWidget {
  const InternshipListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: const CustomHeader(showBackButton: true),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        itemCount: mockCompanies.length,
        itemBuilder: (context, index) {
          final company = mockCompanies[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      InternshipDetailScreen(company: company),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                        color: AppTheme.lightGrey,
                      ),
                      child: Image.network(
                        company.logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.lightGrey,
                            child: const Icon(
                              Icons.business,
                              color: AppTheme.primaryTeal,
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
                              color: AppTheme.head,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company.department,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.head2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.head3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFB72B),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${company.overallRating}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.head,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${company.reviewCount})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.head2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
