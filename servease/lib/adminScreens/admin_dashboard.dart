import 'package:flutter/material.dart';
import 'package:servease/adminScreens/user_management_screen.dart';
import 'package:servease/adminScreens/category_management_screen.dart';
import 'package:servease/adminScreens/platform_monitoring_screen.dart';
import 'package:servease/adminScreens/content_management_screen.dart';
import 'package:servease/adminScreens/reports_screen.dart';
import 'package:servease/services/admin_api_service.dart';
import '../loginpages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic> dashboardStats = {};
  bool isLoading = true;
  String? errorMessage;
  bool showFallbackData = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userRole = prefs.getString('userRole');

      print('Token exists: ${token != null}');
      print('User role: $userRole');

      if (token == null) {
        _showError('No authentication token found. Please login again.');
        return;
      }

      if (userRole?.toLowerCase() != 'admin') {
        _showError('Access denied. Admin privileges required.');
        return;
      }

      await _loadDashboardStats();
    } catch (e) {
      print('Auth check error: $e');
      _showError('Authentication error: $e');
    }
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      showFallbackData = false;
    });

    try {
      print('Starting dashboard stats load...');

      final response = await AdminApiService.getDashboardStats()
          .timeout(const Duration(seconds: 30));

      print('Dashboard response received: $response');

      if (response['success'] == true) {
        setState(() {
          dashboardStats = response['data'] ?? {};
          isLoading = false;
        });
        print('Dashboard stats loaded successfully');
        print('Dashboard data: $dashboardStats');
      } else {
        print('API returned error: ${response['error']}');
        _showFallbackData(response['error'] ?? 'Failed to load dashboard data');
      }
    } catch (e) {
      print('Error loading dashboard stats: $e');
      _showFallbackData('Network error: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
      isLoading = false;
      showFallbackData = false;
    });
  }

  void _showFallbackData(String error) {
    setState(() {
      errorMessage = error;
      isLoading = false;
      showFallbackData = true;
      dashboardStats = {
        'totalUsers': 0,
        'totalProviders': 0,
        'activeBookings': 0,
        'totalRevenue': 0,
        'recentActivities': [],
      };
    });
  }

  Future<void> _testConnection() async {
    try {
      final result = await AdminApiService.testConnectionWithAuth();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                result['success'] == true
                    ? 'Connection successful! User: ${result['user']}'
                    : 'Connection failed: ${result['error']}'
            ),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Connection test error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createSampleData() async {
    try {
      final result = await AdminApiService.createSampleData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                result['success'] == true
                    ? 'Sample data created successfully!'
                    : 'Failed: ${result['error']}'
            ),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          ),
        );

        if (result['success'] == true) {
          // Reload dashboard data
          await _loadDashboardStats();
        }
      }
    } catch (e) {
      print('Error creating sample data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating sample data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0C7210),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.white),
            onPressed: _testConnection,
            tooltip: 'Test Connection',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white),
            onPressed: _createSampleData,
            tooltip: 'Create Sample Data',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDashboardStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF0C7210),
            ),
            SizedBox(height: 16),
            Text('Loading dashboard data...'),
            SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      )
          : errorMessage != null && !showFallbackData
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loadDashboardStats,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C7210),
                  ),
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _createSampleData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Create Sample Data'),
                ),
              ],
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadDashboardStats,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showFallbackData)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Running in offline mode. Data may not be current.',
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                      ),
                      TextButton(
                        onPressed: _createSampleData,
                        child: const Text('Add Sample Data'),
                      ),
                    ],
                  ),
                ),
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              _buildStatsGrid(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0C7210),
            const Color(0xFF388E3C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Administrator',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your ServEase platform efficiently',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Last login: ${DateTime.now().toString().substring(0, 16)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'Total Users',
        'value': dashboardStats['totalUsers']?.toString() ?? '0',
        'icon': Icons.people,
        'color': Colors.blue,
        'change': '+12%',
      },
      {
        'title': 'Service Providers',
        'value': dashboardStats['totalProviders']?.toString() ?? '0',
        'icon': Icons.work,
        'color': Colors.green,
        'change': '+8%',
      },
      {
        'title': 'Active Bookings',
        'value': dashboardStats['activeBookings']?.toString() ?? '0',
        'icon': Icons.calendar_today,
        'color': Colors.orange,
        'change': '+15%',
      },
      {
        'title': 'Total Revenue',
        'value': '\$${dashboardStats['totalRevenue']?.toString() ?? '0'}',
        'icon': Icons.attach_money,
        'color': Colors.purple,
        'change': '+22%',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 24,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stat['change'] as String,
                      style: TextStyle(
                        color: stat['color'] as Color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                stat['value'] as String,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat['title'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'User Management',
        'subtitle': 'Manage user accounts',
        'icon': Icons.people_outline,
        'color': Colors.blue,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserManagementScreen()),
        ),
      },
      {
        'title': 'Category Management',
        'subtitle': 'Manage service categories',
        'icon': Icons.category_outlined,
        'color': Colors.green,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CategoryManagementScreen()),
        ),
      },
      {
        'title': 'Platform Monitoring',
        'subtitle': 'Monitor platform activity',
        'icon': Icons.monitor_outlined,
        'color': Colors.orange,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlatformMonitoringScreen()),
        ),
      },
      {
        'title': 'Content Management',
        'subtitle': 'Manage platform content',
        'icon': Icons.content_paste_outlined,
        'color': Colors.purple,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ContentManagementScreen()),
        ),
      },
      {
        'title': 'Reports',
        'subtitle': 'Generate platform reports',
        'icon': Icons.analytics_outlined,
        'color': Colors.red,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportsScreen()),
        ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: action['color'] as Color,
                    size: 24,
                  ),
                ),
                title: Text(
                  action['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  action['subtitle'] as String,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: action['onTap'] as VoidCallback,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = dashboardStats['recentActivities'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: activities.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No recent activity',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF0C7210).withOpacity(0.1),
                  child: Icon(
                    _getActivityIcon(activity['type'] ?? ''),
                    color: const Color(0xFF0C7210),
                    size: 20,
                  ),
                ),
                title: Text(
                  activity['title'] ?? 'Unknown Activity',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  activity['description'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  _formatTime(activity['timestamp'] ?? ''),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return Icons.person_add;
      case 'booking':
        return Icons.calendar_today;
      case 'service':
        return Icons.work;
      case 'review':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout',),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Clear stored data
                await AdminApiService.clearStoredData();
                // Navigate to login screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Login()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout',style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }
}
