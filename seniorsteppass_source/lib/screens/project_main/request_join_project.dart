import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/common_buttons.dart';
import '../../services/current_user_service.dart';

class RequestJoinProjectScreen extends StatefulWidget {
  final dynamic project;

  const RequestJoinProjectScreen({
    super.key,
    required this.project,
  });

  @override
  State<RequestJoinProjectScreen> createState() =>
      _RequestJoinProjectScreenState();
}

class _RequestJoinProjectScreenState extends State<RequestJoinProjectScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CurrentUserService _userService = CurrentUserService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer the team questions')),
      );
      return;
    }

    if (_positionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify your position')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get current user info
      final currentUserEmail = _userService.getCurrentUserEmail();
      if (currentUserEmail == null) {
        throw Exception('User not authenticated');
      }

      // Fetch current user data
      final currentUserQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      if (currentUserQuery.docs.isEmpty) {
        throw Exception('Current user not found');
      }

      final currentUserData = currentUserQuery.docs.first.data();
      final currentUserStudentId = currentUserData['student_id'] as String? ?? '';
      final currentUserName = currentUserData['full_name'] as String? ?? 'Unknown';

      if (currentUserStudentId.isEmpty) {
        throw Exception('Current user student_id not found');
      }

      // Get project owner info
      final ownerStudentId = widget.project.owner_id as String? ?? '';
      if (ownerStudentId.isEmpty) {
        throw Exception('Project owner info not found');
      }

      // Get owner's user doc ID
      final ownerQuery = await _firestore
          .collection('users')
          .where('student_id', isEqualTo: ownerStudentId)
          .limit(1)
          .get();

      if (ownerQuery.docs.isEmpty) {
        throw Exception('Project owner not found');
      }

      final ownerDocId = ownerQuery.docs.first.id;

      // Save request to Firestore
      await _firestore
          .collection('users')
          .doc(ownerDocId)
          .collection('project_requests')
          .doc(currentUserStudentId)
          .set({
        'team_question': _questionController.text.trim(),
        'position': _positionController.text.trim(),
        'requester_name': currentUserName,
        'requester_student_id': currentUserStudentId,
        'project_id': widget.project.id,
        'project_title': widget.project.title,
        'requested_at': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1B6A68),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Request to Join Team!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Team Questions
                const Text(
                  'Team Questions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _questionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'Please answer the questions',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Position
                const Text(
                  'Position',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _positionController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      hintText: 'position you want to do',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
