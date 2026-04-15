import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/current_user_service.dart';

class RequestWorkplaceScreen extends StatefulWidget {
  const RequestWorkplaceScreen({super.key});

  @override
  State<RequestWorkplaceScreen> createState() => _RequestWorkplaceScreenState();
}

class _RequestWorkplaceScreenState extends State<RequestWorkplaceScreen> {
  final TextEditingController _workplaceNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  final CurrentUserService _userService = CurrentUserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _workplaceNameController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_workplaceNameController.text.isEmpty ||
        _companyController.text.isEmpty ||
        _positionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.bad,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userEmail = _userService.getCurrentUserEmail();
      print('DEBUG: userEmail = $userEmail');
      if (userEmail == null) {
        throw Exception('User not logged in');
      }

      // Get current user data
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      print('DEBUG: userQuery.docs.length = ${userQuery.docs.length}');
      if (userQuery.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userData = userQuery.docs.first.data();
      final userDocId = userQuery.docs.first.id;
      final requesterId = userData['student_id'] as String? ?? '';
      final requesterName = userData['full_name'] as String? ?? 'Unknown';

      print('DEBUG: Submitting request...');
      print('DEBUG: userDocId = $userDocId');
      print('DEBUG: requesterId = $requesterId');
      print('DEBUG: requesterName = $requesterName');

      // Create workplace request
      await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('workplace_requests')
          .add({
        'workplace_name': _workplaceNameController.text.trim(),
        'company': _companyController.text.trim(),
        'position': _positionController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requester_name': requesterName,
        'requester_student_id': requesterId,
        'requester_uid': userDocId,
        'requested_at': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      print('DEBUG: Request submitted successfully!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workplace request submitted successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('DEBUG: Error occurred: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.bad,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleYellow,
      appBar: AppBar(
        backgroundColor: AppTheme.paleYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request New Workplace',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Workplace',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in the details to request a new workplace. Admin will review and approve.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.head2,
                ),
              ),
              const SizedBox(height: 24),

              // Workplace Name Field
              const Text(
                'Workplace Name *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.head,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _workplaceNameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Tech Hub Bangkok',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Company Field
              const Text(
                'Company *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.head,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _companyController,
                decoration: InputDecoration(
                  hintText: 'e.g., ABC Company',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Position Field
              const Text(
                'Position *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.head,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _positionController,
                decoration: InputDecoration(
                  hintText: 'e.g., Internship - Mobile Developer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Description Field
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.head,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell us more about this workplace opportunity...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
