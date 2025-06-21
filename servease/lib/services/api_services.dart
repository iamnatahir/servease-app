import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // Helper method to get full image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return '${ApiConfig.baseUrl}$imagePath';
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Store token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Store user role
  static Future<void> storeUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  // Clear token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Clear user role
  static Future<void> clearUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userRole');
  }

  // Clear stored data
  static Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userRole');
  }

  // Get headers with auth token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getCurrentEndpoint('/register')),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in registerUser: $e');
      throw Exception('Failed to register user: $e');
    }
  }

  static Future<Map<String, dynamic>> loginUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getCurrentEndpoint('/login')),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in loginUser: $e');
      throw Exception('Failed to login user: $e');
    }
  }

  // Dashboard APIs
  static Future<Map<String, dynamic>> getProviderDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print("Token used for dashboard: $token");

    if (token == null) {
      return {'success': false, 'error': 'No token found'};
    }

    final url = Uri.parse(ApiConfig.getCurrentEndpoint('/dashboard/provider'));

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed with status ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Exception occurred: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCustomerDashboard() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse(ApiConfig.getCurrentEndpoint('/dashboard/customer')),
      headers: headers,
    );
    return json.decode(response.body);
  }

  // Service APIs
  static Future<Map<String, dynamic>> getMyServices() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse(ApiConfig.getCurrentEndpoint('/services/my-services')),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getAllServices({String? category, String? search, String? sortBy}) async {
    String url = ApiConfig.getCurrentEndpoint('/services');
    List<String> queryParams = [];

    if (category != null) queryParams.add('category=$category');
    if (search != null) queryParams.add('search=$search');
    if (sortBy != null) queryParams.add('sortBy=$sortBy');

    if (queryParams.isNotEmpty) {
      url += '?' + queryParams.join('&');
    }

    final response = await http.get(Uri.parse(url));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getServiceById(String serviceId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getCurrentEndpoint('/services/$serviceId')),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load service: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getServiceById: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> addService(Map<String, dynamic> serviceData, {
    File? serviceImage,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'No authentication token found'};
      }

      final uri = Uri.parse(ApiConfig.getCurrentEndpoint('/services'));
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      serviceData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add image file if provided
      if (serviceImage != null) {
        final imageFile = await http.MultipartFile.fromPath(
          'imageUrl',
          serviceImage.path,
        );
        request.files.add(imageFile);
      }

      print('📤 Sending add service request...');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.length} file(s)');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Add service response status: ${response.statusCode}');
      print('Add service response body: ${response.body}');

      return json.decode(response.body);
    } catch (e) {
      print('Error in addService: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateService(
      String serviceId,
      Map<String, dynamic> serviceData, {
        File? serviceImage,
      }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'No authentication token found'};
      }

      final uri = Uri.parse(ApiConfig.getCurrentEndpoint('/services/$serviceId'));
      final request = http.MultipartRequest('PUT', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      serviceData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add image file if provided
      if (serviceImage != null) {
        final imageFile = await http.MultipartFile.fromPath(
          'imageUrl',
          serviceImage.path,
        );
        request.files.add(imageFile);
      }

      print('📤 Sending update service request...');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.length} file(s)');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update service response status: ${response.statusCode}');
      print('Update service response body: ${response.body}');

      return json.decode(response.body);
    } catch (e) {
      print('Error in updateService: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteService(String serviceId) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse(ApiConfig.getCurrentEndpoint('/services/$serviceId')),
      headers: headers,
    );
    return json.decode(response.body);
  }

  // Booking APIs
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final headers = await getHeaders();
      print('Creating booking with headers: $headers'); // Debug log
      print('Booking data: $bookingData'); // Debug log

      final response = await http.post(
        Uri.parse(ApiConfig.getCurrentEndpoint('/bookings')),
        headers: headers,
        body: json.encode(bookingData),
      );

      print('Booking response status: ${response.statusCode}'); // Debug log
      print('Booking response body: ${response.body}'); // Debug log

      return json.decode(response.body);
    } catch (e) {
      print('Error in createBooking API call: $e'); // Debug log
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getUserBookings() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getCurrentEndpoint('/bookings/user')),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load user bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserBookings: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> getCustomerBookings({String? status}) async {
    final headers = await getHeaders();
    String url = ApiConfig.getCurrentEndpoint('/bookings/customer');
    if (status != null) url += '?status=$status';

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getProviderBookings({String? status}) async {
    final headers = await getHeaders();
    String url = ApiConfig.getCurrentEndpoint('/bookings/provider');
    if (status != null) url += '?status=$status';

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateBookingStatus(String bookingId, String status) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse(ApiConfig.getCurrentEndpoint('/bookings/$bookingId/status')),
      headers: headers,
      body: json.encode({'status': status}),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse(ApiConfig.getCurrentEndpoint('/bookings/$bookingId')),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateBooking(String bookingId, Map<String, dynamic> bookingData) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getCurrentEndpoint('/bookings/$bookingId')),
        headers: await getHeaders(),
        body: json.encode(bookingData),
      );

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in updateBooking: $e');
      throw Exception('Failed to update booking: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteBooking(String bookingId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getCurrentEndpoint('/bookings/$bookingId')),
        headers: await getHeaders(),
      );

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in deleteBooking: $e');
      throw Exception('Failed to delete booking: $e');
    }
  }

  // Review APIs
  static Future<Map<String, dynamic>> getProviderReviews(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getCurrentEndpoint('/reviews/provider/$providerId')),
      );

      print('Get provider reviews response: ${response.statusCode}');
      print('Get provider reviews body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch reviews: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error in getProviderReviews: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> addReview(Map<String, dynamic> reviewData) async {
    try {
      final headers = await getHeaders();
      print('Adding review with headers: $headers');
      print('Review data: $reviewData');

      final response = await http.post(
        Uri.parse(ApiConfig.getCurrentEndpoint('/reviews')),
        headers: headers,
        body: json.encode(reviewData),
      );

      print('Add review response status: ${response.statusCode}');
      print('Add review response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Review added successfully',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to add review',
          'message': errorData['message'] ?? 'Unknown error occurred',
        };
      }
    } catch (e) {
      print('Error in addReview API call: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
        'message': 'Failed to connect to server',
      };
    }
  }

  // Check if review exists for a booking
  static Future<Map<String, dynamic>> checkReviewExists(String bookingId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getCurrentEndpoint('/reviews/booking/$bookingId/exists')),
        headers: headers,
      );

      print('Check review exists response: ${response.statusCode}');
      print('Check review exists body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'exists': false,
          'error': 'Failed to check review existence',
        };
      }
    } catch (e) {
      print('Error in checkReviewExists: $e');
      return {
        'success': false,
        'exists': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Profile APIs
  static Future<Map<String, dynamic>> getUserProfile() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse(ApiConfig.getCurrentEndpoint('/profile')),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> profileData, {
        File? profileImage,
      }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'No authentication token found'};
      }

      final uri = Uri.parse(ApiConfig.getCurrentEndpoint('/profile'));
      final request = http.MultipartRequest('PUT', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      profileData.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            request.fields[key] = json.encode(value);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      if (profileImage != null) {
        final imageFile = await http.MultipartFile.fromPath(
          'profilePicture',
          profileImage.path,
        );
        request.files.add(imageFile);
      }

      print('📤 Sending profile update request...');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.length} file(s)');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Profile update response status: ${response.statusCode}');
      print('Profile update response body: ${response.body}');

      return json.decode(response.body);
    } catch (e) {
      print('Error in updateUserProfile: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse(ApiConfig.getCurrentEndpoint('/profile/change-password')),
      headers: headers,
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    return json.decode(response.body);
  }

  // Provider Details API
  static Future<Map<String, dynamic>> getProviderDetails(String providerId) async {
    try {
      print('Fetching provider details for ID: $providerId');

      if (providerId.isEmpty) {
        print('Error: Empty provider ID');
        return {
          'success': false,
          'error': 'Provider ID is empty',
        };
      }

      final url = Uri.parse(ApiConfig.getCurrentEndpoint('/providers/$providerId'));
      print('Provider details URL: $url');

      final headers = await getHeaders();
      print('Headers for provider details: $headers');

      final response = await http.get(url, headers: headers);

      print('Provider details response status: ${response.statusCode}');
      print('Provider details response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['provider'] != null) {
          // Process provider image URL if present
          final provider = responseData['provider'];
          if (provider['profilePicture'] != null && provider['profilePicture'].isNotEmpty) {
            provider['profilePicture'] = getImageUrl(provider['profilePicture']);
          }

          return responseData;
        } else {
          return {
            'success': false,
            'error': responseData['message'] ?? 'Failed to get provider details',
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Provider not found',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error in getProviderDetails: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}
