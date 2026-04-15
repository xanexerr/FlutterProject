import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seniorsteppass_source/services/cloudinary_service.dart';
import '../../models/index.dart';
import '../../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyManagementScreen extends StatefulWidget {
  const CompanyManagementScreen({super.key});

  @override
  State<CompanyManagementScreen> createState() =>
      _CompanyManagementScreenState();
}

class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  void _showCompanyModal([CompanyModel? company]) {
    final isEditing = company != null;
    final nameCtrl = TextEditingController(text: company?.company_name ?? '');
    final deptCtrl = TextEditingController(text: company?.department ?? '');
    final descCtrl = TextEditingController(text: company?.description ?? '');
    final locationCtrl = TextEditingController(text: company?.location ?? '');
    final websiteCtrl = TextEditingController(text: company?.website ?? '');

    File? localSelectedLogo;
    String? currentNetworkLogo = company?.logo_url;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Company' : 'Add New Company',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // upload img
                    GestureDetector(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setStateModal(
                            () => localSelectedLogo = File(image.path),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryTeal.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: localSelectedLogo != null
                                ? ClipOval(
                                    child: Image.file(
                                      localSelectedLogo!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : (currentNetworkLogo != null &&
                                          currentNetworkLogo.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            currentNetworkLogo,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.business_center,
                                          size: 40,
                                          color: Colors.grey,
                                        )),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Upload Company Logo',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.head3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: deptCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Department / Field',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: websiteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Website',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.head3),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      String finalLogoUrl = currentNetworkLogo ?? '';

                      if (localSelectedLogo != null) {
                        final uploadedUrl = await _cloudinaryService
                            .uploadImage(
                              localSelectedLogo!,
                              'SeniorPassStep_Internships',
                            );
                        if (uploadedUrl != null) finalLogoUrl = uploadedUrl;
                      }

                      final data = {
                        'company_name': nameCtrl.text,
                        'department': deptCtrl.text,
                        'description': descCtrl.text,
                        'location': locationCtrl.text,
                        'website': websiteCtrl.text,
                        'logo_url': finalLogoUrl,
                        'overallRating': company?.overallRating ?? 0.0,
                        'reviewCount': company?.reviewCount ?? 0,
                        'reviews': company?.reviews ?? [],
                      };

                      if (isEditing) {
                        await FirebaseFirestore.instance
                            .collection('internships')
                            .doc(company.id)
                            .update(data);
                      } else {
                        await FirebaseFirestore.instance
                            .collection('internships')
                            .add(data);
                      }

                      navigator.pop();
                      if (!mounted) return;
                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Company updated successfully'
                                : 'Company added successfully',
                          ),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    } catch (e) {
                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: AppTheme.bad,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                  ),
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
        title: const Text(
          'Delete Company',
          style: TextStyle(color: AppTheme.bad),
        ),
        content: Text(
          'Are you sure you want to delete "${company.company_name}"?',
  ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.head3),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              try {
                await FirebaseFirestore.instance
                    .collection('internships')
                    .doc(company.id)
                    .delete();

                if (!mounted) return;

                navigator.pop(context);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Company deleted successfully'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete company: $e'),
                    backgroundColor: AppTheme.bad,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bad,
              foregroundColor: Colors.white,
            ),
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
        label: const Text(
          'Add Company',
          style: TextStyle(color: AppTheme.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('internships')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return const Center(child: Text('Error loading companies'));
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final companies = snapshot.data!.docs.map((doc) {
              return CompanyModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();

            if (companies.isEmpty) {
              return const Center(child: Text('No companies found.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 56,
                                height: 56,
                                color: Colors.grey[50],
                                child: company.logo_url.isNotEmpty
                                    ? Image.network(
                                        company.logo_url,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.business, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 16),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
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
                            const Icon(
                              Icons.business_center,
                              size: 16,
                              color: AppTheme.head3,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                company.department,
                                style: const TextStyle(
                                  color: AppTheme.head3,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppTheme.head3,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                company.location,
                                style: const TextStyle(
                                  color: AppTheme.head2,
                                  fontSize: 14,
                                ),
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
                              icon: const Icon(
                                Icons.edit,
                                color: AppTheme.info,
                                size: 22,
                              ),
                              onPressed: () => _showCompanyModal(company),
                              tooltip: 'Edit',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppTheme.bad,
                                size: 22,
                              ),
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
            );
          },
        ),
      ),
    );
  }
}
