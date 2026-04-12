import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../models/mock_data.dart';
import '../../theme/app_theme.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  late List<ProjectModel> _projects;

  @override
  void initState() {
    super.initState();
    _projects = List.from(mockProjects);
  }

  void _showProjectModal([ProjectModel? project]) {
    final isEditing = project != null;
    final titleCtrl = TextEditingController(text: project?.title ?? '');
    final descCtrl = TextEditingController(text: project?.description ?? '');
    final authorCtrl = TextEditingController(text: project?.owner_id ?? '');
    String selectedStatus = project?.status ?? 'Active';

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
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl, 
                      decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: authorCtrl, 
                      decoration: const InputDecoration(labelText: 'Author', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl, 
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'Archived', child: Text('Archived')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateModal(() {
                            selectedStatus = val;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.head3)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (isEditing) {
                        int index = _projects.indexWhere((p) => p.id == project.id);
                        if (index != -1) {
                          final updatedProject = ProjectModel(
                            id: project.id,
                            title: titleCtrl.text,
                            description: descCtrl.text,
                            owner_id: authorCtrl.text,
                            image_url: project.image_url,
                            tags: project.tags,
                            categories: project.categories,
                            members: project.members,
                            timestamp: project.timestamp,
                            status: selectedStatus,
                            views: project.views,
                            likes: project.likes,
                          );
                          _projects[index] = updatedProject;

                          int mockIndex = mockProjects.indexWhere((p) => p.id == project.id);
                          if (mockIndex != -1) mockProjects[mockIndex] = updatedProject;
                        }
                      } else {
                        final newProject = ProjectModel(
                          id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleCtrl.text,
                          description: descCtrl.text,
                          owner_id: authorCtrl.text,
                          image_url: 'https://via.placeholder.com/300x200',
                          tags: ['Flutter'],
                          categories: ['App'],
                          members: [],
                          timestamp: DateTime.now(),
                          status: selectedStatus,
                          views: 0,
                          likes: 0,
                        );
                        _projects.add(newProject);
                        mockProjects.add(newProject);
                      }
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Project updated successfully' : 'Project added successfully')),
                    );
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
            onPressed: () {
              setState(() {
                _projects.removeWhere((p) => p.id == project.id);
                mockProjects.removeWhere((p) => p.id == project.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project deleted successfully')),
              );
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
      body: Padding(
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                        const Icon(Icons.person, size: 16, color: AppTheme.head3),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            project.owner_id,
                            style: const TextStyle(color: AppTheme.head2, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.black12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: project.status == 'Active' ? AppTheme.success.withOpacity(0.2) : 
                                   project.status == 'Completed' ? AppTheme.info.withOpacity(0.2) :
                                   Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            project.status, 
                            style: TextStyle(
                              fontSize: 12,
                              color: project.status == 'Active' ? AppTheme.success : 
                                     project.status == 'Completed' ? AppTheme.info :
                                     Colors.grey.shade700,
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.info, size: 22),
                          onPressed: () => _showProjectModal(project),
                          tooltip: 'Edit',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.bad, size: 22),
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
            );
          },
        ),
      ),
    );
  }
}