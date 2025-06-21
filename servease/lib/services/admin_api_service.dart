import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AdminApiService {
  // Helper method to get auth token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Helper method to create headers with auth token
  static Future<Map<String, String>> getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Clear stored data
  static Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userRole');
    await prefs.remove('userId');
  }

  // Test connection (no auth)
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.adminPath}/test';
      print('🧪 Testing connection to: $url');

      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 10));

      print('🧪 Test connection response: ${response.statusCode}');
      print('🧪 Test connection body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Connection failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🧪 Connection test failed: $e');
      return {
        'success': false,
        'error': 'Connection test error: $e',
      };
    }
  }

  // Test connection with auth
  static Future<Map<String, dynamic>> testConnectionWithAuth() async {
    try {
      final headers = await getHeaders();
      final url = '${ApiConfig.baseUrl}${ApiConfig.adminPath}/test-auth';

      print('🔐 Testing auth connection to: $url');
      print('🔐 Headers: $headers');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('🔐 Test auth response: ${response.statusCode}');
      print('🔐 Test auth body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Auth test failed: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('🔐 Auth test failed: $e');
      return {
        'success': false,
        'error': 'Auth test error: $e',
      };
    }
  }

  // Debug endpoint
  static Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final headers = await getHeaders();
      final url = '${ApiConfig.baseUrl}${ApiConfig.adminPath}/debug';

      print('🔍 Getting debug info from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      print('🔍 Debug response: ${response.statusCode}');
      print('🔍 Debug body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Debug failed: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('🔍 Debug error: $e');
      return {
        'success': false,
        'error': 'Debug error: $e',
      };
    }
  }

  // Dashboard Stats
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      print('📊 === GETTING DASHBOARD STATS ===');

      // First test basic connection
      final connectionTest = await testConnection();
      if (connectionTest['success'] != true) {
        return {
          'success': false,
          'error': 'Basic connection failed: ${connectionTest['error']}',
        };
      }
      print('✅ Basic connection test passed');

      // Test auth connection
      final authTest = await testConnectionWithAuth();
      if (authTest['success'] != true) {
        return {
          'success': false,
          'error': 'Authentication failed: ${authTest['error']}',
        };
      }
      print('✅ Auth connection test passed');

      // Get debug info
      final debugInfo = await getDebugInfo();
      if (debugInfo['success'] == true) {
        print('🔍 Debug info received:');
        print('  - Database: ${debugInfo['debug']['database']['stateText']}');
        print('  - Users: ${debugInfo['debug']['counts']['users']}');
        print('  - Services: ${debugInfo['debug']['counts']['services']}');
        print('  - Bookings: ${debugInfo['debug']['counts']['bookings']}');
      }

      final headers = await getHeaders();
      final url = '${ApiConfig.baseUrl}${ApiConfig.adminPath}/dashboard/stats';

      print('📊 Making dashboard request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('📊 Dashboard stats response status: ${response.statusCode}');
      print('📊 Dashboard stats response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Dashboard data received successfully');
        return data;
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': 'Access denied. Admin privileges required.',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Authentication failed. Please login again.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Admin dashboard endpoint not found. Please check server configuration.',
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('📊 Error loading dashboard stats: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // User Management
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      print('👥 === GETTING ALL USERS ===');

      final headers = await getHeaders();
      final url = '${ApiConfig.baseUrl}${ApiConfig.adminPath}/users';

      print('👥 Making users request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('👥 Get all users response: ${response.statusCode}');
      print('👥 Get all users body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'], // Use 'data' field from response
          'count': data['count'],
        };
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('👥 Error loading users: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Create sample data
  static Future<Map<String, dynamic>> createSampleData() async {
    try {
      print('🚀 === CREATING SAMPLE DATA ===');

      final headers = await getHeaders();
      final url = '${ApiConfig.baseUrl}${ApiConfig.adminPath}/create-sample-data';

      print('🚀 Making sample data request to: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('🚀 Create sample data response: ${response.statusCode}');
      print('🚀 Create sample data body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create sample data: ${response.statusCode}');
      }
    } catch (e) {
      print('🚀 Error creating sample data: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> verifyProvider(String providerId) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/users/$providerId/verify'),
        headers: headers,
      );

      print('Verify provider response: ${response.statusCode}');
      print('Verify provider body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to verify provider: ${response.statusCode}');
      }
    } catch (e) {
      print('Error verifying provider: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updateUserStatus(String userId, bool isActive) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/users/$userId/status'),
        headers: headers,
        body: json.encode({'isActive': isActive}),
      );

      print('Update user status response: ${response.statusCode}');
      print('Update user status body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update user status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user status: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/users/$userId'),
        headers: headers,
      );

      print('Delete user response: ${response.statusCode}');
      print('Delete user body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting user: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Category Management
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/categories'),
        headers: headers,
      );

      print('Get categories response: ${response.statusCode}');
      print('Get categories body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading categories: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/categories'),
        headers: headers,
        body: json.encode(categoryData),
      );

      print('Create category response: ${response.statusCode}');
      print('Create category body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating category: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updateCategory(String categoryId, Map<String, dynamic> categoryData) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/categories/$categoryId'),
        headers: headers,
        body: json.encode(categoryData),
      );

      print('Update category response: ${response.statusCode}');
      print('Update category body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating category: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updateCategoryStatus(String categoryId, bool isActive) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/categories/$categoryId/status'),
        headers: headers,
        body: json.encode({'isActive': isActive}),
      );

      print('Update category status response: ${response.statusCode}');
      print('Update category status body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update category status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating category status: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> deleteCategory(String categoryId) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/categories/$categoryId'),
        headers: headers,
      );

      print('Delete category response: ${response.statusCode}');
      print('Delete category body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting category: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Platform Monitoring
  static Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/platform/stats'),
        headers: headers,
      );

      print('Platform stats response: ${response.statusCode}');
      print('Platform stats body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load platform stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading platform stats: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getRecentTransactions() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/platform/transactions'),
        headers: headers,
      );

      print('Recent transactions response: ${response.statusCode}');
      print('Recent transactions body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading transactions: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getDisputes() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/platform/disputes'),
        headers: headers,
      );

      print('Disputes response: ${response.statusCode}');
      print('Disputes body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load disputes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading disputes: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getSystemLogs() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/platform/logs'),
        headers: headers,
      );

      print('System logs response: ${response.statusCode}');
      print('System logs body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load system logs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading system logs: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> resolveDispute(String disputeId) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/platform/disputes/$disputeId/resolve'),
        headers: headers,
      );

      print('Resolve dispute response: ${response.statusCode}');
      print('Resolve dispute body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to resolve dispute: ${response.statusCode}');
      }
    } catch (e) {
      print('Error resolving dispute: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Content Management
  static Future<Map<String, dynamic>> getTermsOfService() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/content/terms'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load terms of service: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getPrivacyPolicy() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/content/privacy'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load privacy policy: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getAnnouncements() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/content/announcements'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load announcements: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/content/notifications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updateTermsOfService(Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/content/terms'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update terms of service: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updatePrivacyPolicy(Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/content/privacy'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update privacy policy: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> createAnnouncement(Map<String, dynamic> announcementData) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/content/announcements'),
        headers: headers,
        body: json.encode(announcementData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create announcement: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updateAnnouncement(String announcementId, Map<String, dynamic> announcementData) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/content/announcements/$announcementId'),
        headers: headers,
        body: json.encode(announcementData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update announcement: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updateAnnouncementStatus(String announcementId, bool isActive) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/content/announcements/$announcementId/status'),
        headers: headers,
        body: json.encode({'isActive': isActive}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update announcement status: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> deleteAnnouncement(String announcementId) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/content/announcements/$announcementId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete announcement: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> sendNotification(Map<String, dynamic> notificationData) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/content/notifications/send'),
        headers: headers,
        body: json.encode(notificationData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send notification: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Reports
  static Future<Map<String, dynamic>> generateReport(String reportType, String timeframe) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/reports/$reportType?timeframe=$timeframe'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate report: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getServicesByCategory(String categoryName) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminPath}/categories/$categoryName/services'),
        headers: headers,
      );

      print('Get services by category response: ${response.statusCode}');
      print('Get services by category body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading services by category: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
