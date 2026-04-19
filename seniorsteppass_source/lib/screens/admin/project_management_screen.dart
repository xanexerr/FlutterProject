import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  late List<ProjectModel> _projects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProjectsFromFirestore();
  }

  Future<void> _loadProjectsFromFirestore() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('projects')
          .get();
      
      final projects = snapshot.docs
          .map((doc) => ProjectModel.fromJson(doc.data(), doc.id))
          .toList();
      
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading projects: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _showProjectModal([ProjectModel? project]) {
    final isEditing = project != null;
    final titleCtrl = TextEditingController(text: project?.title ?? '');
    final descCtrl = TextEditingController(text: project?.description ?? '');
    final authorCtrl = TextEditingController(text: project?.owner_id ?? '');
    String selectedStatus = project?.status ?? 'Pending';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Project' : 'Add New Project',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
              ),
              content: SizedBox(
                width: 400,
      
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleCtrl, 
                        decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: authorCtrl, 
                        decoration: const InputDecoration(labelText: 'Author', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descCtrl, 
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        isDense: true,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'Pending', child: Text('Pending', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Approved', child: Text('Approved', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Hidden', child: Text('Hidden', overflow: TextOverflow.ellipsis)),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      )
                    ],
                  ),
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
                        // Update existing project in Firestore
                        await FirebaseFirestore.instance
                            .collection('projects')
                            .doc(project.id)
                            .update({
                          'name': titleCtrl.text,
                          'description': descCtrl.text,
                          'owner_id': authorCtrl.text,
                          'status': selectedStatus,
                          'updated_at': FieldValue.serverTimestamp(),
                        });
                      } else {
                        // Add new project to Firestore
                        await FirebaseFirestore.instance
                            .collection('projects')
                            .add({
                          'name': titleCtrl.text,
                          'description': descCtrl.text,
                          'owner_id': authorCtrl.text,
                          'image_urls': [],
                          'tags': [],
                          'links': [],
                          'members': {},
                          'stage': 'Developing',
                          'status': selectedStatus,
                          'views': 0,
                          'likes': 0,
                          'created_at': FieldValue.serverTimestamp(),
                          'updated_at': FieldValue.serverTimestamp(),
                        });
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Project updated successfully' : 'Project added successfully')),
                      );
                      _loadProjectsFromFirestore();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving project: $e')),
                      );
                    }
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

  void _confirmDelete(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project', style: TextStyle(color: AppTheme.bad)),
        content: Text('Are you sure you want to delete "${project.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.head3)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('projects')
                    .doc(project.id)
                    .delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project deleted successfully')),
                );
                _loadProjectsFromFirestore();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting project: $e')),
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
        onPressed: () => _showProjectModal(),
        backgroundColor: AppTheme.primaryTeal,
        icon: const Icon(Icons.add, color: AppTheme.white),
        label: const Text('Add Project', style: TextStyle(color: AppTheme.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? const Center(child: Text('No projects found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _projects.length,
                    itemBuilder: (context, index) {
            final project = _projects[index];
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
                    // ID and Title Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.head,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${project.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryTeal,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Description Preview
                    if (project.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          project.description,
                          style: const TextStyle(color: AppTheme.head2, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    
                    // Owner and Metadata Row
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: AppTheme.head3),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Owner: ${project.owner_id}',
                            style: const TextStyle(color: AppTheme.head2, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Tags
                    if (project.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                          spacing: 6,
                          children: project.tags.map((tag) => Chip(
                            label: Text(tag, style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                          )).toList(),
                        ),
                      ),
                    
                    // Views and Likes
                    Row(
                      children: [
                        const Icon(Icons.visibility, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${project.views}', style: const TextStyle(fontSize: 12, color: AppTheme.head2)),
                        const SizedBox(width: 16),
                        const Icon(Icons.favorite, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('${project.likes}', style: const TextStyle(fontSize: 12, color: AppTheme.head2)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    const Divider(color: Colors.black12),
                    
                    // Status and Actions Row
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: project.status == 'Approved' ? AppTheme.success.withOpacity(0.2) : 
                                     project.status == 'Pending' ? Colors.orange.withOpacity(0.2) :
                                     Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              project.status, 
                              style: TextStyle(
                                fontSize: 12,
                                color: project.status == 'Approved' ? AppTheme.success : 
                                       project.status == 'Pending' ? Colors.orange.shade700 :
                                       Colors.grey.shade700,
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: AppTheme.info, size: 20),
                            onPressed: () => _showProjectModal(project),
                            tooltip: 'Edit',
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: AppTheme.bad, size: 20),
                            onPressed: () => _confirmDelete(project),
                            tooltip: 'Delete',
                            padding: EdgeInsets.zero,
                          ),
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