import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/index.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_buttons.dart';

class CompanyFormScreen extends StatefulWidget {
  final CompanyModel? company;

  const CompanyFormScreen({super.key, this.company});

  @override
  State<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController nameCtrl;
  late TextEditingController deptCtrl;
  late TextEditingController descCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController websiteCtrl;
  late TextEditingController logoUrlCtrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.company?.company_name ?? '');
    deptCtrl = TextEditingController(text: widget.company?.department ?? '');
    descCtrl = TextEditingController(text: widget.company?.description ?? '');
    locationCtrl = TextEditingController(text: widget.company?.location ?? '');
    websiteCtrl = TextEditingController(text: widget.company?.website ?? '');
    logoUrlCtrl = TextEditingController(text: widget.company?.logo_url ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    deptCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    websiteCtrl.dispose();
    logoUrlCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _saveCompany() async {
    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company name is required'), backgroundColor: AppTheme.bad),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.company != null) {
        // UPDATE
        await _firestore.collection('internships').doc(widget.company!.id).update({
          'company_name': nameCtrl.text,
          'department': deptCtrl.text,
          'description': descCtrl.text,
          'location': locationCtrl.text,
          'website': websiteCtrl.text,
          'logo_url': logoUrlCtrl.text,
          'updated_at': _formatTimestamp(DateTime.now()),
        });
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
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.company != null ? 'Company updated successfully' : 'Company added successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.bad),
        );
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightYellow,
      appBar: const CustomHeader(showBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Company Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 24),
              
              // Company Name
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Company Name',
                  labelStyle: const TextStyle(color: AppTheme.head3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.white,
                ),
              ),
              const SizedBox(height: 16),

              // Department / Field
              TextField(
                controller: deptCtrl,
                decoration: InputDecoration(
                  labelText: 'Department / Field',
                  labelStyle: const TextStyle(color: AppTheme.head3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.white,
                ),
              ),
              const SizedBox(height: 16),

              // Location
              TextField(
                controller: locationCtrl,
                decoration: InputDecoration(
                  labelText: 'Location',
                  labelStyle: const TextStyle(color: AppTheme.head3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.white,
                ),
              ),
              const SizedBox(height: 16),

              // Website
              TextField(
                controller: websiteCtrl,
                decoration: InputDecoration(
                  labelText: 'Website',
                  labelStyle: const TextStyle(color: AppTheme.head3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.white,
                ),
              ),
              const SizedBox(height: 16),

              // Logo URL
              TextField(
                controller: logoUrlCtrl,
                decoration: InputDecoration(
                  labelText: 'Logo URL',
                  labelStyle: const TextStyle(color: AppTheme.head3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.white,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: descCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: AppTheme.head3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.white,
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveCompany,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: AppTheme.white)
                      : Text(
                          widget.company != null ? 'Update Company' : 'Save Company',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
