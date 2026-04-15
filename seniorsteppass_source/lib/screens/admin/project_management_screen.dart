import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seniorsteppass_source/services/cloudinary_service.dart';
import '../../models/index.dart';
import '../../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() =>
      _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  Stream<String> _getOwnerName(String ownerID) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('student_id', isEqualTo: ownerID)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs.first.get('full_name') ?? ownerID;
          }
          return ownerID;
        });
  }

  void _showProjectModal([ProjectModel? project]) {
    List<String> statusList = ['Active', 'Completed', 'Archived'];
    String selectedStatus = statusList.contains(project?.status)
        ? project!.status
        : 'Active';

    final isEditing = project != null;
    final titleCtrl = TextEditingController(text: project?.title ?? '');
    final descCtrl = TextEditingController(text: project?.description ?? '');
    final ownerIdCtrl = TextEditingController(text: project?.owner_id ?? '');
    final linkCtrl = TextEditingController(text: project?.links);

    File? localSelectedImage;
    String? currentNetworkImage = project?.image_url;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Project' : 'Add New Project',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setStateModal(
                            () => localSelectedImage = File(image.path),
                          );
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: localSelectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  localSelectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (currentNetworkImage != null &&
                                      currentNetworkImage.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        currentNetworkImage,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        Text(
                                          'Select Project Image',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    )),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ownerIdCtrl,
                      readOnly: isEditing,
                      decoration: InputDecoration(
                        labelText: 'Owner ID (Student ID)',
                        border: const OutlineInputBorder(),
                        fillColor: isEditing
                            ? Colors.black.withOpacity(0.1)
                            : null,
                        filled: isEditing,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: linkCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Project Link',
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
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(
                          value: 'Active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'Completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'Archived',
                          child: Text('Archived'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateModal(() {
                            selectedStatus = val;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Status',
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
                      String finalImageUrl = currentNetworkImage ?? '';
                      if (localSelectedImage != null) {
                        final uploadUrl = await _cloudinaryService.uploadImage(
                          localSelectedImage!,
                          'SeniorPassStep_Projects', // แยกโฟลเดอร์ให้ชัดเจน
                        );
                        if (uploadUrl != null) finalImageUrl = uploadUrl;
                      }
                      final data = {
                        'title': titleCtrl.text,
                        'description': descCtrl.text,
                        'owner_id': ownerIdCtrl.text,
                        'links': linkCtrl.text,
                        'image_url': finalImageUrl,
                        'status': selectedStatus,
                        'timestamp': FieldValue.serverTimestamp(),
                        'members':
                            project?.members.map((e) => e.toJson()).toList() ??
                            [],
                        'tags': project?.tags ?? [],
                        'categories': project?.categories ?? [],
                        'likes': project?.likes ?? 0,
                        'views': project?.views ?? 0,
                      };

                      if (isEditing) {
                        await FirebaseFirestore.instance
                            .collection('projects')
                            .doc(project.id)
                            .update(data);
                      } else {
                        await FirebaseFirestore.instance
                            .collection('projects')
                            .add(data);
                      }

                      navigator.pop(); // close loading
                      if (!mounted) return;
                      navigator.pop(); // close main modal
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Project updated successfully'
                                : 'Project added successfully',
                          ),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      navigator.pop();
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  void _confirmDelete(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Project',
          style: TextStyle(color: AppTheme.bad),
        ),
        content: Text('Are you sure you want to delete "${project.title}"?'),
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
                    .collection('projects')
                    .doc(project.id)
                    .delete();

                if (!mounted) return;

                navigator.pop(context);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Project deleted successfully'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete project: $e'),
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
        onPressed: () => _showProjectModal(),
        backgroundColor: AppTheme.primaryTeal,
        icon: const Icon(Icons.add, color: AppTheme.white),
        label: const Text(
          'Add Project',
          style: TextStyle(color: AppTheme.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('projects')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return const Center(child: Text('Error loading projects'));
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final projects = snapshot.data!.docs.map((doc) {
              return ProjectModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();

            if (projects.isEmpty) {
              return const Center(child: Text('No projects found.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (project.image_url.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ), // โค้งแค่ด้านบน
                          child: Image.network(
                            project.image_url,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            // if can't load img
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 160,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   project.id,
                                //   style: const TextStyle(
                                //     fontWeight: FontWeight.bold,
                                //     color: AppTheme.primaryTeal,
                                //     fontSize: 14,
                                //   ),
                                // ),
                                // const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    project.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.head,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: AppTheme.head3,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: StreamBuilder<String>(
                                    stream: _getOwnerName(
                                      project.owner_id,
                                    ), 
                                    builder: (context, nameSnapshot) {
                                      final displayName =
                                          nameSnapshot.data ?? project.owner_id;
                                      return Text(
                                        displayName,
                                        style: const TextStyle(
                                          color: AppTheme.head2,
                                          fontSize: 14,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: Colors.black12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: project.status == 'Active'
                                        ? AppTheme.success.withOpacity(0.2)
                                        : project.status == 'Completed'
                                        ? AppTheme.info.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    project.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: project.status == 'Active'
                                          ? AppTheme.success
                                          : project.status == 'Completed'
                                          ? AppTheme.info
                                          : Colors.grey.shade700,
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
                                  onPressed: () => _showProjectModal(project),
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
                                  onPressed: () => _confirmDelete(project),
                                  tooltip: 'Delete',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
