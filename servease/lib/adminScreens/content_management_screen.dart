import 'package:flutter/material.dart';
import 'package:servease/services/admin_api_service.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> termsOfService = {};
  Map<String, dynamic> privacyPolicy = {};
  List<Map<String, dynamic>> announcements = [];
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadContentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadContentData() async {
    setState(() => isLoading = true);
    try {
      final responses = await Future.wait([
        AdminApiService.getTermsOfService(),
        AdminApiService.getPrivacyPolicy(),
        AdminApiService.getAnnouncements(),
        AdminApiService.getNotifications(),
      ]);

      setState(() {
        termsOfService = responses[0]['data'] ?? {};
        privacyPolicy = responses[1]['data'] ?? {};
        announcements = List<Map<String, dynamic>>.from(responses[2]['data'] ?? []);
        notifications = List<Map<String, dynamic>>.from(responses[3]['data'] ?? []);
      });
    } catch (e) {
      print('Error loading content data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF0C7210),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh,color: Colors.white),
            onPressed: _loadContentData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Terms of Service'),
            Tab(text: 'Privacy Policy'),
            Tab(text: 'Announcements'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildTermsOfServiceTab(),
          _buildPrivacyPolicyTab(),
          _buildAnnouncementsTab(),
          _buildNotificationsTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 2: // Announcements
        return FloatingActionButton(
          onPressed: () => _showAddAnnouncementDialog(),
          backgroundColor: const Color(0xFF0C7210),
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 3: // Notifications
        return FloatingActionButton(
          onPressed: () => _showSendNotificationDialog(),
          backgroundColor: const Color(0xFF0C7210),
          child: const Icon(Icons.send, color: Colors.white),
        );
      default:
        return null;
    }
  }

  Widget _buildTermsOfServiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _editTermsOfService(),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C7210),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
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
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Last updated: ${_formatDate(termsOfService['lastUpdated'])}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  termsOfService['content'] ?? 'No terms of service content available. Click Edit to add content.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _editPrivacyPolicy(),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C7210),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
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
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Last updated: ${_formatDate(privacyPolicy['lastUpdated'])}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  privacyPolicy['content'] ?? 'No privacy policy content available. Click Edit to add content.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return RefreshIndicator(
      onRefresh: _loadContentData,
      child: announcements.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No announcements yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to create your first announcement',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          return _buildAnnouncementCard(announcement);
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    final isActive = announcement['isActive'] ?? true;
    final priority = announcement['priority'] ?? 'normal';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.campaign,
                    color: _getPriorityColor(priority),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            announcement['title'] ?? 'Untitled Announcement',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Inactive',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _formatDate(announcement['createdAt']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                      color: _getPriorityColor(priority),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAnnouncementAction(value, announcement),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: isActive ? 'deactivate' : 'activate',
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.visibility_off : Icons.visibility,
                            size: 16,
                            color: isActive ? Colors.orange : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement['content'] ?? 'No content',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (announcement['targetAudience'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.group, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Target: ${announcement['targetAudience']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return RefreshIndicator(
      onRefresh: _loadContentData,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSendNotificationDialog(),
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Send Notification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C7210),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showBulkNotificationDialog(),
                    icon: const Icon(Icons.group_add, size: 16),
                    label: const Text('Bulk Send'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0C7210),
                      side: const BorderSide(color: Color(0xFF0C7210)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications sent yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final status = notification['status'] ?? 'sent';
    final recipientCount = notification['recipientCount'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: _getStatusColor(status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] ?? 'Untitled Notification',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(notification['sentAt']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notification['message'] ?? 'No message',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$recipientCount recipients',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  notification['targetAudience'] ?? 'All users',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    try {
      if (date == null) return 'Unknown';
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _editTermsOfService() {
    final controller = TextEditingController(text: termsOfService['content'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Terms of Service'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter terms of service content...',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
            expands: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _saveTermsOfService(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C7210),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editPrivacyPolicy() {
    final controller = TextEditingController(text: privacyPolicy['content'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Privacy Policy'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter privacy policy content...',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
            expands: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _savePrivacyPolicy(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C7210),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddAnnouncementDialog() {
    _showAnnouncementDialog();
  }

  void _showAnnouncementDialog({Map<String, dynamic>? announcement}) {
    final isEditing = announcement != null;
    final titleController = TextEditingController(text: announcement?['title'] ?? '');
    final contentController = TextEditingController(text: announcement?['content'] ?? '');
    String selectedPriority = announcement?['priority'] ?? 'normal';
    String selectedAudience = announcement?['targetAudience'] ?? 'all';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Announcement' : 'Create Announcement'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: ['low', 'normal', 'medium', 'high'].map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedPriority = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedAudience,
                    decoration: const InputDecoration(
                      labelText: 'Target Audience',
                      border: OutlineInputBorder(),
                    ),
                    items: ['all', 'customers', 'providers', 'admins'].map((audience) {
                      return DropdownMenuItem(
                        value: audience,
                        child: Text(audience.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedAudience = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveAnnouncement(
                isEditing,
                announcement?['_id'],
                titleController.text,
                contentController.text,
                selectedPriority,
                selectedAudience,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C7210),
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSendNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedAudience = 'all';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Send Notification'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedAudience,
                    decoration: const InputDecoration(
                      labelText: 'Send To',
                      border: OutlineInputBorder(),
                    ),
                    items: ['all', 'customers', 'providers', 'admins'].map((audience) {
                      return DropdownMenuItem(
                        value: audience,
                        child: Text(audience.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedAudience = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _sendNotification(
                titleController.text,
                messageController.text,
                selectedAudience,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C7210),
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkNotificationDialog() {
    // Implementation for bulk notification sending
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bulk notification feature coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleAnnouncementAction(String action, Map<String, dynamic> announcement) {
    switch (action) {
      case 'edit':
        _showAnnouncementDialog(announcement: announcement);
        break;
      case 'activate':
        _toggleAnnouncementStatus(announcement, true);
        break;
      case 'deactivate':
        _toggleAnnouncementStatus(announcement, false);
        break;
      case 'delete':
        _deleteAnnouncement(announcement);
        break;
    }
  }

  Future<void> _saveTermsOfService(String content) async {
    try {
      final response = await AdminApiService.updateTermsOfService({'content': content});
      if (response['success'] == true) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terms of Service updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadContentData();
      } else {
        throw Exception(response['error'] ?? 'Failed to update terms of service');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _savePrivacyPolicy(String content) async {
    try {
      final response = await AdminApiService.updatePrivacyPolicy({'content': content});
      if (response['success'] == true) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Privacy Policy updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadContentData();
      } else {
        throw Exception(response['error'] ?? 'Failed to update privacy policy');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveAnnouncement(
      bool isEditing,
      String? announcementId,
      String title,
      String content,
      String priority,
      String targetAudience,
      ) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and content are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final announcementData = {
      'title': title.trim(),
      'content': content.trim(),
      'priority': priority,
      'targetAudience': targetAudience,
    };

    try {
      final response = isEditing
          ? await AdminApiService.updateAnnouncement(announcementId!, announcementData)
          : await AdminApiService.createAnnouncement(announcementData);

      if (response['success'] == true) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Announcement updated successfully' : 'Announcement created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadContentData();
      } else {
        throw Exception(response['error'] ?? 'Failed to save announcement');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleAnnouncementStatus(Map<String, dynamic> announcement, bool isActive) async {
    try {
      final response = await AdminApiService.updateAnnouncementStatus(announcement['_id'], isActive);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Announcement ${isActive ? 'activated' : 'deactivated'} successfully'),
            backgroundColor: isActive ? Colors.green : Colors.orange,
          ),
        );
        _loadContentData();
      } else {
        throw Exception(response['error'] ?? 'Failed to update announcement status');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAnnouncement(Map<String, dynamic> announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: Text('Are you sure you want to delete "${announcement['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await AdminApiService.deleteAnnouncement(announcement['_id']);
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Announcement deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
          _loadContentData();
        } else {
          throw Exception(response['error'] ?? 'Failed to delete announcement');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendNotification(String title, String message, String targetAudience) async {
    if (title.trim().isEmpty || message.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and message are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final notificationData = {
      'title': title.trim(),
      'message': message.trim(),
      'targetAudience': targetAudience,
    };

    try {
      final response = await AdminApiService.sendNotification(notificationData);
      if (response['success'] == true) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadContentData();
      } else {
        throw Exception(response['error'] ?? 'Failed to send notification');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
