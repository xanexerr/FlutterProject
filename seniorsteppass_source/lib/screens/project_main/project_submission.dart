import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cloudinary_service.dart';
import '../../services/current_user_service.dart';

typedef ImagePickerCallback = Future<List<XFile>> Function();

class ProjectSubmissionScreen extends StatefulWidget {
  const ProjectSubmissionScreen({super.key});

  @override
  State<ProjectSubmissionScreen> createState() =>
      _ProjectSubmissionScreenState();
}

class _ProjectSubmissionScreenState extends State<ProjectSubmissionScreen> {
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController detailedController = TextEditingController();

  final List<XFile> _imageFiles = []; // XFile supports web, mobile, desktop
  final List<String> projectImages = [];
  final List<String> projectLinks = [];
  final Map<String, String> projectMembers = {}; // student_id: role
  final List<String> selectedTags = [];
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  String selectedStage = 'Developing';
  bool _isLoading = false;

  final List<String> stages = ['Developing', 'Complete'];
  
  final List<String> categories = [
    'Software Engineer',
    'Data Science',
    'Internet Of Thing',
    'Cyber Security',
  ];

  Future<void> _pickImages() async {
    try {
      final List<XFile> selectedImages = await _imagePicker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() {
          _imageFiles.addAll(selectedImages);
          for (var image in selectedImages) {
            projectImages.add(image.name);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  // Upload images to Cloudinary and get URLs
  Future<void> _submitData() async {
    if (projectNameController.text.isEmpty ||
        detailedController.text.isEmpty ||
        _imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all fields and select at least one image',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user ID from Firestore
      final currentUserService = CurrentUserService();
      await currentUserService.fetchCurrentUserData();
      final userId = currentUserService.getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload all images to Cloudinary
      final List<String> uploadedImageUrls = [];
      for (var imageFile in _imageFiles) {
        final imageUrl = await _cloudinaryService.uploadImage(imageFile);
        if (imageUrl != null) {
          uploadedImageUrls.add(imageUrl);
        }
      }

      if (uploadedImageUrls.isEmpty) {
        throw Exception('Failed to upload images');
      }

      // Save project data to Firestore with PENDING status
      await FirebaseFirestore.instance.collection('projects').add({
        'name': projectNameController.text.trim(),
        'description': detailedController.text.trim(),
        'owner_id': userId,
        'image_urls': uploadedImageUrls,
        'links': projectLinks,
        'members': projectMembers,
        'tags': selectedTags,
        'stage': selectedStage,
        'status': 'Pending', // Waiting for admin approval
        'views': 0,
        'likes': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project submitted! Waiting for admin approval...'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text('Error submitting project: $e'),
          backgroundColor: AppTheme.bad,
        ));
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
          'Project Submission',
          style: TextStyle(
            color: AppTheme.head,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Name
                const Text(
                  'Project Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: projectNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter project name',
                    filled: true,
                    fillColor: AppTheme.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Project Detailed
                const Text(
                  'Project Detailed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: detailedController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter project details',
                    filled: true,
                    fillColor: AppTheme.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Images
                const Text(
                  'Image',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select prototype or presentation overview images',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImages(),
                        icon: const Icon(Icons.add),
                        label: const Text('Choose File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightGrey,
                          foregroundColor: AppTheme.head,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          projectImages.isNotEmpty
                              ? '${projectImages.length} image(s) selected'
                              : 'No image selected',
                          style: TextStyle(color: AppTheme.head2, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                if (projectImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      children: projectImages.map((image) {
                        return Chip(
                          label: Text(image),
                          onDeleted: () {
                            setState(() => projectImages.remove(image));
                          },
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 20),

                // Project Link
                const Text(
                  'Project Link',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 8),
                ...projectLinks.asMap().entries.map((entry) {
                  int index = entry.key;
                  String link = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              link,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() => projectLinks.removeAt(index));
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                ElevatedButton.icon(
                  onPressed: () => _showAddLinkDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Link'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightGrey,
                    foregroundColor: AppTheme.head,
                  ),
                ),
                const SizedBox(height: 20),

                // Project Member
                const Text(
                  'Project Member',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 8),
                ...projectMembers.entries.map((entry) {
                  String studentId = entry.key;
                  String role = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentId,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  role,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() => projectMembers.remove(studentId));
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                ElevatedButton.icon(
                  onPressed: () => _showAddMemberDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Member'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightGrey,
                    foregroundColor: AppTheme.head,
                  ),
                ),
                const SizedBox(height: 20),

                // Project Stage
                const Text(
                  'Project Stage',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: stages.map((stage) {
                      bool isSelected = selectedStage == stage;
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedStage = stage);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.second
                                : AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            stage,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppTheme.head,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Project Tag
                const Text(
                  'Project Tag',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      bool isSelected = selectedTags.contains(category);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedTags.remove(category);
                            } else {
                              selectedTags.add(category);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.second
                                : AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppTheme.head,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  void _showAddLinkDialog() {
    final TextEditingController linkController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Project Link'),
        content: TextField(
          controller: linkController,
          decoration: const InputDecoration(
            hintText: 'Enter project URL',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (linkController.text.isNotEmpty) {
                setState(() => projectLinks.add(linkController.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final TextEditingController studentIdController = TextEditingController();
    String selectedRole = 'Frontend';
    final List<String> roles = ['Frontend', 'Backend', 'UI/UX', 'QA', 'Project Manager'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Project Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    hintText: 'Enter member student ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedRole = value ?? 'Frontend');
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (studentIdController.text.isNotEmpty) {
                  this.setState(() {
                    projectMembers[studentIdController.text] = selectedRole;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    projectNameController.dispose();
    detailedController.dispose();
    super.dispose();
  }
}
