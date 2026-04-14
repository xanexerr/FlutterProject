import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/index.dart';
import '../../theme/app_theme.dart';

class CompanyManagementScreen extends StatefulWidget {
  const CompanyManagementScreen({super.key});

  @override
  State<CompanyManagementScreen> createState() => _CompanyManagementScreenState();
}

class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Format DateTime to: April 15, 2026 at 12:55:08 AM UTC+7
  String _formatTimestamp(DateTime dateTime) {
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

  void _showCompanyModal([CompanyModel? company]) {
    final isEditing = company != null;
    final nameCtrl = TextEditingController(text: company?.company_name ?? '');
    final deptCtrl = TextEditingController(text: company?.department ?? '');
    final descCtrl = TextEditingController(text: company?.description ?? '');
    final locationCtrl = TextEditingController(text: company?.location ?? '');
    final websiteCtrl = TextEditingController(text: company?.website ?? '');
    final logoUrlCtrl = TextEditingController(text: company?.logo_url ?? '');

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
                      controller: logoUrlCtrl,
                      decoration: const InputDecoration(labelText: 'Logo URL', border: OutlineInputBorder()),
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
                  onPressed: () async {
                    try {
                      if (isEditing) {
                        // UPDATE
                        await _firestore.collection('internships').doc(company.id).update({
                          'company_name': nameCtrl.text,
                          'department': deptCtrl.text,
                          'description': descCtrl.text,
                          'location': locationCtrl.text,
                          'website': websiteCtrl.text,
                          'logo_url': logoUrlCtrl.text,
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Company updated successfully')),
                          );
                        }
                      } else {
                        // CREATE
                        final now = DateTime.now();
                        final timestamp = _formatTimestamp(now);
                        
                        await _firestore.collection('internships').add({
                          'company_name': nameCtrl.text,
                          'department': deptCtrl.text,
                          'description': descCtrl.text,
                          'location': locationCtrl.text,
                          'website': websiteCtrl.text,
                          'logo_url': logoUrlCtrl.text,
                          'overallRating': 0.0,
                          'reviewCount': 0,
                          'created_at': timestamp,
                          'created_timestamp': now,
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Company added successfully')),
                          );
                        }
                      }
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, foregroundColor: Colors.white),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String companyId, String companyName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Company', style: TextStyle(color: AppTheme.bad)),
        content: Text('Are you sure you want to delete "$companyName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.head3)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // DELETE
                await _firestore.collection('internships').doc(companyId).delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Company deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bad, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('internships').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: AppTheme.bad),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No companies found',
                  style: TextStyle(color: AppTheme.head3, fontSize: 16),
                ),
              );
            }

            final companies = snapshot.data!.docs;

            return ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final doc = companies[index];
                final data = doc.data() as Map<String, dynamic>;
                final company = CompanyModel.fromJson(data, doc.id);

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
                              onPressed: () => _confirmDelete(company.id, company.company_name),
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
            );
          },
        ),
      ),
    );
  }
}