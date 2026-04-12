import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../models/mock_data.dart';
import '../../theme/app_theme.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // Use a local copy of mockUsers to allow editing/deleting in memory
  late List<UserModel> _users;

  @override
  void initState() {
    super.initState();
    _users = List.from(mockUsers); // Copy dummy list
  }

  void _showUserModal([UserModel? user]) {
    final isEditing = user != null;
    final nameCtrl = TextEditingController(text: user?.full_name ?? '');
    final studentIdCtrl = TextEditingController(text: user?.student_id ?? '');
    final facultyCtrl = TextEditingController(text: user?.faculty ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    String selectedRole = user?.role ?? 'User';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit User' : 'Add New User',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl, 
                      decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                      
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: studentIdCtrl, 
                      decoration: const InputDecoration(labelText: 'Student ID', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: facultyCtrl, 
                      decoration: const InputDecoration(labelText: 'Faculty', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl, 
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
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
                      decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
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
                    // Update state
                    setState(() {
                      if (isEditing) {
                        int index = _users.indexWhere((u) => u.id == user.id);
                        if (index != -1) {
                          final updatedUser = UserModel(
                            id: user.id,
                            full_name: nameCtrl.text,
                            student_id: studentIdCtrl.text,
                            faculty: facultyCtrl.text,
                            role: selectedRole,
                            email: emailCtrl.text,
                          );
                          _users[index] = updatedUser;

                          // Update global mock data so changes persist in session
                          int mockIndex = mockUsers.indexWhere((u) => u.id == user.id);
                          if (mockIndex != -1) mockUsers[mockIndex] = updatedUser;
                        }
                      } else {
                        final newUser = UserModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          full_name: nameCtrl.text,
                          student_id: studentIdCtrl.text,
                          faculty: facultyCtrl.text,
                          role: selectedRole,
                          email: emailCtrl.text,
                        );
                        _users.add(newUser);
                        
                        // Update global mock data so changes persist in session
                        mockUsers.add(newUser);
                      }
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'User updated successfully' : 'User added successfully')),
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

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User', style: TextStyle(color: AppTheme.bad)),
        content: Text('Are you sure you want to delete ${user.full_name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.head3)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _users.removeWhere((u) => u.id == user.id);
                // Remove from global mock data so changes persist in session
                mockUsers.removeWhere((u) => u.id == user.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted successfully')),
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
        onPressed: () => _showUserModal(),
        backgroundColor: AppTheme.primaryTeal,
        icon: const Icon(Icons.add, color: AppTheme.white),
        label: const Text('Add User', style: TextStyle(color: AppTheme.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
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
                    // Row 1: Id/uid & Name
                    Row(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.full_name,
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
        ),
      ),
    );
  }
}
