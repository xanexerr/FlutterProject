import 'package:flutter/material.dart';
import 'package:seniorsteppass_source/services/database_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

import 'user_management_screen.dart';
import 'project_management_screen.dart';
import 'company_management_screen.dart';
import 'review_moderation_screen.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _OverviewScreen(),
    const UserManagementScreen(),
    const ProjectManagementScreen(),
    const CompanyManagementScreen(),
    const ReviewModerationScreen(),
  ];

  final List<String> _titles = [
    'Dashboard Overview',
    'User Management',
    'Project Management',
    'Company Management',
    'Review Moderation',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AppTheme.white, size: 28),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
          ),
        ),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: AppTheme.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.primaryTeal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: AppTheme.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Portal Admin',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Text('seniorsteppass_source', style: TextStyle(color: AppTheme.third)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Overview'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Project Management'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Company Management'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Review Moderation'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() => _selectedIndex = 4);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.bad),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppTheme.bad),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

class _OverviewScreen extends StatelessWidget {
  const _OverviewScreen();

  @override
  Widget build(BuildContext context) {
    final DatabaseService _dbService = DatabaseService();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<Map<String, int>>(
        future:
            Future.wait([
              _dbService.getTotalUsersCount(),
              _dbService.getPendingProjectsCount(),
              _dbService.getTotalCompaniesCount(),
              _dbService.getTotalReviewsCount(),
            ]).then(
              (values) => {
                'users': values[0],
                'pending': values[1],
                'companies': values[2],
                'reviews': values[3],
              },
            ),
        builder: (context, snapshot) {
          final data =
              snapshot.data ??
              {'users': 0, 'pending': 0, 'companies': 0, 'reviews': 0};
          final bool isLoading =
              snapshot.connectionState == ConnectionState.waiting;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Users',
                      isLoading ? '...' : '${data['users']}',
                      Icons.people,
                      AppTheme.info,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Pending Projects',
                      isLoading ? '...' : '${data['pending']}',
                      Icons.pending_actions,
                      AppTheme.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Companies',
                      isLoading ? '...' : '${data['companies']}',
                      Icons.business,
                      AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'New Reviews',
                      isLoading ? '...' : '${data['reviews']}',
                      Icons.rate_review,
                      AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.head,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: AppTheme.head2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
