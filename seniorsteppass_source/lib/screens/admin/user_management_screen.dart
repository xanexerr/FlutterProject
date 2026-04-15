import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/index.dart';
import '../../theme/app_theme.dart';
import '../../services/cloudinary_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  void _showUserModal([UserModel? user]) {
    final isEditing = user != null;
    final nameCtrl = TextEditingController(text: user?.full_name ?? '');
    final studentIdCtrl = TextEditingController(text: user?.student_id ?? '');
    final facultyCtrl = TextEditingController(text: user?.faculty ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    String selectedRole = user?.role ?? 'User';
    XFile? selectedImage;
    String? profilePicUrl = user?.profilePic;
    bool isUploading = false;
    final imagePicker = ImagePicker();
    final cloudinaryService = CloudinaryService();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        isEditing ? 'Edit User' : 'Add New User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Profile Picture
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: selectedImage != null || profilePicUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: selectedImage != null
                                        ? FutureBuilder<Uint8List>(
                                            future: selectedImage!.readAsBytes(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Image.memory(
                                                  snapshot.data!,
                                                  fit: BoxFit.cover,
                                                );
                                              }
                                              return const Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            },
                                          )
                                        : Image.network(
                                            profilePicUrl ?? '',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.person, size: 60, color: Colors.grey);
                                            },
                                          ),
                                  )
                                : const Icon(Icons.person, size: 60, color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final image = await imagePicker.pickImage(source: ImageSource.gallery);
                              if (image != null) {
                                setStateModal(() {
                                  selectedImage = image;
                                });
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Name
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.head,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Student ID
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Student ID',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.head,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: studentIdCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter student ID',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Faculty
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Faculty',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.head,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: facultyCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter faculty',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.head,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: emailCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Role
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Role',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.head,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: AppTheme.head,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isUploading
                                  ? null
                                  : () async {
                                      setStateModal(() => isUploading = true);
                                      try {
                                        String? uploadedUrl = profilePicUrl;
                                        if (selectedImage != null) {
                                          uploadedUrl = await cloudinaryService.uploadImage(selectedImage!);
                                        }

                                        final updateData = {
                                          'full_name': nameCtrl.text,
                                          'student_id': studentIdCtrl.text,
                                          'faculty': facultyCtrl.text,
                                          'role': selectedRole,
                                          'email': emailCtrl.text,
                                          'password': studentIdCtrl.text,
                                        };

                                        if (uploadedUrl != null) {
                                          updateData['profilePic'] = uploadedUrl;
                                        }

                                        if (isEditing) {
                                          await _firestore.collection('users').doc(user.id).update(updateData);
                                        } else {
                                          await _firestore.collection('users').add(updateData);
                                        }

                                        if (mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(isEditing ? 'User updated successfully' : 'User added successfully'),
                                              backgroundColor: AppTheme.success,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: AppTheme.bad,
                                            ),
                                          );
                                        }
                                      } finally {
                                        setStateModal(() => isUploading = false);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryTeal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: isUploading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User', style: TextStyle(color: AppTheme.bad)),
        content: Text('Are you sure you want to delete $userName? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.head3)),
          ),
          ElevatedButton(
            onPressed: () async {
              // DELETE operation
              await _firestore.collection('users').doc(userId).delete();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully')),
                );
              }
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
        onPressed: () => _showUserModal(),
        backgroundColor: AppTheme.primaryTeal,
        icon: const Icon(Icons.add, color: AppTheme.white),
        label: const Text('Add User', style: TextStyle(color: AppTheme.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').snapshots(),
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
                  'No users found',
                  style: TextStyle(color: AppTheme.head3, fontSize: 16),
                ),
              );
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final doc = users[index];
                final data = doc.data() as Map<String, dynamic>;
                final user = UserModel(
                  id: doc.id,
                  full_name: data['full_name'] ?? '',
                  student_id: data['student_id'] ?? '',
                  faculty: data['faculty'] ?? '',
                  role: data['role'] ?? 'User',
                  email: data['email'] ?? '',
                  profilePic: data['profilePic'],
                );
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
                    // Row 1: Profile Picture + Id/uid & Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: user.profilePic != null && user.profilePic!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    user.profilePic!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.person, size: 40, color: Colors.grey);
                                    },
                                  ),
                                )
                              : const Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.student_id.isNotEmpty ? user.student_id : user.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
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
                        const Icon(Icons.school, size: 16, color: AppTheme.head3),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user.faculty,
                            style: const TextStyle(color: AppTheme.head2, fontSize: 14),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: user.role == 'Admin' ? AppTheme.info.withOpacity(0.2) : AppTheme.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.role, 
                            style: TextStyle(
                              fontSize: 12,
                              color: user.role == 'Admin' ? AppTheme.info : AppTheme.success,
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.info, size: 22),
                          onPressed: () => _showUserModal(user),
                          tooltip: 'Edit',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.bad, size: 22),
                          onPressed: () => _confirmDelete(user.id, user.full_name),
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
