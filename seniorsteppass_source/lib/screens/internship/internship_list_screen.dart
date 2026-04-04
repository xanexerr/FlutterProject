import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/item_card.dart';

class InternshipListScreen extends StatelessWidget {
  const InternshipListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Internship Programs',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.head,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: mockCompanies.length,
                itemBuilder: (context, index) {
                  final company = mockCompanies[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ItemCard(
                      title: company.name,
                      subtitle: '${company.department} • ${company.overallRating}⭐',
                      trailing: SizedBox(
                        width: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${company.overallRating}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                            Text(
                              '${company.reviewCount} reviews',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppTheme.head3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tapped: ${company.name}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
