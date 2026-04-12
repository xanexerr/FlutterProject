import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../models/mock_data.dart';
import '../../theme/app_theme.dart';

class CompanyManagementScreen extends StatefulWidget {
  const CompanyManagementScreen({super.key});

  @override
  State<CompanyManagementScreen> createState() => _CompanyManagementScreenState();
}

class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
  late List<CompanyModel> _companies;

  @override
  void initState() {
    super.initState();
    _companies = List.from(mockCompanies);
  }

  void _showCompanyModal([CompanyModel? company]) {
    final isEditing = company != null;
    final nameCtrl = TextEditingController(text: company?.company_name ?? '');
    final deptCtrl = TextEditingController(text: company?.department ?? '');
    final descCtrl = TextEditingController(text: company?.description ?? '');
    final locationCtrl = TextEditingController(text: company?.location ?? '');
    final websiteCtrl = TextEditingController(text: company?.website ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Company' : 'Add New Company',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl, 
                      decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: deptCtrl, 
                      decoration: const InputDecoration(labelText: 'Department / Field', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationCtrl, 
                      decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: websiteCtrl, 
                      decoration: const InputDecoration(labelText: 'Website', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl, 
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.head3)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (isEditing) {
                        int index = _companies.indexWhere((c) => c.id == company.id);
                        if (index != -1) {
                          final updatedCompany = CompanyModel(
                            id: company.id,
                            company_name: nameCtrl.text,
                            department: deptCtrl.text,
                            logo_url: company.logo_url,
                            description: descCtrl.text,
                            overallRating: company.overallRating,
                            reviewCount: company.reviewCount,
                            reviews: company.reviews,
                            location: locationCtrl.text,
                            website: websiteCtrl.text,
                          );
                          _companies[index] = updatedCompany;

                          int mockIndex = mockCompanies.indexWhere((c) => c.id == company.id);
                          if (mockIndex != -1) mockCompanies[mockIndex] = updatedCompany;
                        }
                      } else {
                        final newCompany = CompanyModel(
                          id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                          company_name: nameCtrl.text,
                          department: deptCtrl.text,
                          logo_url: 'https://via.placeholder.com/150',
                          description: descCtrl.text,
                          overallRating: 0.0,
                          reviewCount: 0,
                          reviews: [],
                          location: locationCtrl.text,
                          website: websiteCtrl.text,
                        );
                        _companies.add(newCompany);
                        mockCompanies.add(newCompany);
                      }
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Company updated successfully' : 'Company added successfully')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, foregroundColor: Colors.white),
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _confirmDelete(CompanyModel company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Company', style: TextStyle(color: AppTheme.bad)),
        content: Text('Are you sure you want to delete "${company.company_name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.head3)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _companies.removeWhere((c) => c.id == company.id);
                mockCompanies.removeWhere((c) => c.id == company.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Company deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bad, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCompanyModal(),
        backgroundColor: AppTheme.primaryTeal,
        icon: const Icon(Icons.add, color: AppTheme.white),
        label: const Text('Add Company', style: TextStyle(color: AppTheme.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _companies.length,
          itemBuilder: (context, index) {
            final company = _companies[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            company.company_name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.head,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${company.overallRating.toStringAsFixed(1)} ★ (${company.reviewCount})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.business_center, size: 16, color: AppTheme.head3),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            company.department,
                            style: const TextStyle(color: AppTheme.head3, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppTheme.head3),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            company.location,
                            style: const TextStyle(color: AppTheme.head2, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.black12),
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.info, size: 22),
                          onPressed: () => _showCompanyModal(company),
                          tooltip: 'Edit',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.bad, size: 22),
                          onPressed: () => _confirmDelete(company),
                          tooltip: 'Delete',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}