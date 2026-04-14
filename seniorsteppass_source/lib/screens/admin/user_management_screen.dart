import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seniorsteppass_source/services/cloudinary_service.dart';
import '../../models/index.dart';
import '../../theme/app_theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // Use a local copy of mockUsers to allow editing/deleting in memory

  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  Widget _buildImageSection(
    File? localFile,
    String? networkUrl,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: localFile != null
                  ? Image.file(localFile, fit: BoxFit.cover)
                  : (networkUrl != null && networkUrl.isNotEmpty
                        ? Image.network(networkUrl, fit: BoxFit.cover)
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          )),
            ),
          ),
          CircleAvatar(
            backgroundColor: AppTheme.primaryTeal,
            radius: 14,
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  void _showUserModal([UserModel? user]) {
    final isEditing = user != null;
    final nameCtrl = TextEditingController(text: user?.full_name ?? '');
    final studentIdCtrl = TextEditingController(text: user?.student_id ?? '');
    final facultyCtrl = TextEditingController(text: user?.faculty ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    File? localSelectedImage;
    String selectedRole = user?.role ?? 'User';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit User' : 'Add New User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // upload picture
                    _buildImageSection(
                      localSelectedImage,
                      user?.profilePic,
                      () async {
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null)
                          setStateModal(
                            () => localSelectedImage = File(image.path),
                          );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: studentIdCtrl,
                      readOnly: isEditing,
                      decoration: InputDecoration(
                        labelText: 'Student ID',
                        border: OutlineInputBorder(),
                      fillColor: isEditing ? Colors.black.withOpacity(0.1) : null,
                      filled: isEditing,
                      helperText: isEditing ? 'Can\'t change Student ID' : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: facultyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Faculty',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      readOnly: isEditing,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        fillColor: isEditing ? Colors.black.withOpacity(0.1) : null,
                        filled: isEditing,
                        helperText: isEditing ? 'Can\'t change Email' : null,
                      ),
                    ),

                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: const [
                        DropdownMenuItem(value: 'User', child: Text('User')),
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateModal(() {
                            selectedRole = val;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Role',
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

                    String? finalImageUrl = user?.profilePic;

                    try {
                      if (localSelectedImage != null) {
                        finalImageUrl = await _cloudinaryService.uploadImage(
                          localSelectedImage!,
                          'SeniorPassStep_Users',
                        );
                      }

                      final userData = {
                        'full_name': nameCtrl.text,
                        'student_id': studentIdCtrl.text,
                        'faculty': facultyCtrl.text,
                        'role': selectedRole,
                        'email': emailCtrl.text,
                        'profilePic': finalImageUrl ?? '',
                      };

                      if (isEditing) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.id)
                            .update(userData);
                      } else {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(studentIdCtrl.text)
                            .set(userData);
                      }

                      if (!mounted) return;
                      navigator.pop();

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'User updated successfully'
                                : 'User added!',
                          ),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to save user: $e'),
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

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User', style: TextStyle(color: AppTheme.bad)),
        content: Text(
          'Are you sure you want to delete ${user.full_name}? This action cannot be undone.',
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
              try {
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .where('student_id', isEqualTo: user.student_id)
                    .get();

                for (var doc in querySnapshot.docs) {
                  await doc.reference.delete();
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete user: $e')),
                  );
                }
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
        onPressed: () => _showUserModal(),
        backgroundColor: AppTheme.primaryTeal,
        icon: const Icon(Icons.add, color: AppTheme.white),
        label: const Text('Add User', style: TextStyle(color: AppTheme.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: StreamBuilder<QuerySnapshot>(
          // collect user data in real-time from Firestore
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Center(child: Text('Error!'));
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final usersFromFirebase = snapshot.data!.docs
                .map(
                  (doc) => UserModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ),
                )
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: usersFromFirebase.length,
              itemBuilder: (context, index) {
                final user = usersFromFirebase[index];

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
                        // Row 1: Profile Image & Name/ID
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child:
                                    (user.profilePic != null &&
                                        user.profilePic!.isNotEmpty)
                                    ? Image.network(
                                        user.profilePic!, // absolutely not null
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.grey,
                                                ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.student_id.isNotEmpty
                                        ? user.student_id
                                        : user.id,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.head,
                                    ),
                                  ),
                                  Text(
                                    user.full_name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.head,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Row 2: Faculty
                        Row(
                          children: [
                            const Icon(
                              Icons.school,
                              size: 16,
                              color: AppTheme.head3,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user.faculty,
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
                        // Row 3: Role & Actions
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: user.role == 'Admin'
                                    ? AppTheme.info.withOpacity(0.2)
                                    : AppTheme.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.role,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: user.role == 'Admin'
                                      ? AppTheme.info
                                      : AppTheme.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppTheme.info,
                                size: 22,
                              ),
                              onPressed: () => _showUserModal(user),
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
                              onPressed: () => _confirmDelete(user),
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
