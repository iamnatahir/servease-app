import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'add_review_screen.dart';
import 'view_reviews_screen.dart';
import 'track_booking_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  List<dynamic> allBookings = [];
  List<dynamic> pendingBookings = [];
  List<dynamic> acceptedBookings = [];
  List<dynamic> completedBookings = [];

  // Map to track which bookings have reviews
  Map<String, bool> bookingHasReview = {};

  bool isLoading = true;
  String? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await ApiService.getCustomerBookings();
      print('Customer bookings response: $response'); // Debug log

      if (response['success'] == true) {
        setState(() {
          allBookings = response['bookings'] ?? [];
          pendingBookings = allBookings.where((booking) =>
          (booking['status'] ?? '').toString().toLowerCase() == 'pending').toList();
          acceptedBookings = allBookings.where((booking) =>
              ['accepted', 'ongoing'].contains((booking['status'] ?? '').toString().toLowerCase())).toList();
          completedBookings = allBookings.where((booking) =>
          (booking['status'] ?? '').toString().toLowerCase() == 'completed').toList();
          isLoading = false;
        });

        // Check for reviews for completed bookings
        _checkForExistingReviews();
      } else {
        setState(() {
          error = response['error'] ?? 'Failed to load bookings';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading bookings: $e');
      setState(() {
        error = 'Network error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  // Check if reviews exist for completed bookings
  Future<void> _checkForExistingReviews() async {
    try {
      for (var booking in completedBookings) {
        final bookingId = booking['_id'];
        if (bookingId != null) {
          final response = await ApiService.checkReviewExists(bookingId);
          if (response['success'] == true) {
            setState(() {
              bookingHasReview[bookingId] = response['exists'] ?? false;
            });
          }
        }
      }
    } catch (e) {
      print('Error checking for reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadBookings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E7D32),
          tabs: [
            Tab(text: 'All (${allBookings.length})'),
            Tab(text: 'Pending (${pendingBookings.length})'),
            Tab(text: 'Active (${acceptedBookings.length})'),
            Tab(text: 'Completed (${completedBookings.length})'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text('Loading your bookings...'),
          ],
        ),
      )
          : error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadBookings,
        color: const Color(0xFF2E7D32),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBookingsList(allBookings, 'all'),
            _buildBookingsList(pendingBookings, 'pending'),
            _buildBookingsList(acceptedBookings, 'active'),
            _buildBookingsList(completedBookings, 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<dynamic> bookings, String type) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'pending' ? Icons.schedule :
              type == 'active' ? Icons.work :
              type == 'completed' ? Icons.check_circle :
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'pending' ? 'No pending bookings' :
              type == 'active' ? 'No active bookings' :
              type == 'completed' ? 'No completed bookings' :
              'No bookings found',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'pending' ? 'Your new bookings will appear here' :
              type == 'active' ? 'Accepted bookings will appear here' :
              type == 'completed' ? 'Completed bookings will appear here' :
              'Book a service to get started',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    // Safely extract booking data with null checks
    final status = (booking['status'] ?? 'Unknown').toString();
    final bookingId = (booking['_id'] ?? 'N/A').toString();
    final displayBookingId = (booking['bookingId'] ?? booking['_id'] ?? 'N/A').toString();
    final providerName = _getNestedValue(booking, ['providerId', 'name']) ?? 'Unknown Provider';
    final serviceName = _getNestedValue(booking, ['serviceId', 'title']) ?? 'Unknown Service';
    final serviceType = (booking['serviceType'] ?? 'N/A').toString();
    final date = (booking['date'] ?? 'No date').toString();
    final time = (booking['time'] ?? 'No time').toString();
    final address = (booking['address'] ?? 'No address').toString();
    final price = (booking['price'] ?? 0).toString();
    final description = (booking['description'] ?? '').toString();
    final createdAt = (booking['createdAt'] ?? '').toString();

    // Check if this booking has a review
    final hasReview = bookingHasReview[bookingId] ?? false;

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'accepted':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case 'ongoing':
        statusColor = Colors.purple;
        statusIcon = Icons.play_circle;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Booking #$displayBookingId',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'Provider: $providerName'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.build, 'Service: $serviceName'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.category, 'Type: $serviceType'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, '$date at $time'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, address),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.currency_rupee_sharp, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Rs. $price',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Description: $description',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Created: ${_formatDate(createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),

            // Action Buttons Row
            Row(
              children: [
                // Track Button - Always show for all bookings
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _trackBooking(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.track_changes, size: 18),
                    label: const Text('Track'),
                  ),
                ),

                // Add Review Button - Only for completed bookings
                if (status.toLowerCase() == 'completed') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => hasReview ? _viewReview(booking) : _addReview(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasReview ? Colors.blue : const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(hasReview ? Icons.rate_review : Icons.star, size: 18),
                      label: Text(hasReview ? 'View Review' : 'Add Review'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper method to safely get nested values
  dynamic _getNestedValue(Map<String, dynamic> map, List<String> keys) {
    dynamic current = map;
    for (String key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> _trackBooking(dynamic booking) async {
    final bookingId = booking['_id'] ?? booking['id'];
    if (bookingId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrackBookingScreen(bookingId: bookingId.toString()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot track booking: Missing booking ID')),
      );
    }
  }

  Future<void> _addReview(dynamic booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(booking: booking),
      ),
    );

    if (result == true) {
      // Review was submitted successfully, refresh the bookings
      _loadBookings();
    }
  }

  Future<void> _viewReview(dynamic booking) async {
    final providerId = _getNestedValue(booking, ['providerId', '_id']);
    final providerName = _getNestedValue(booking, ['providerId', 'name']);

    if (providerId != null && providerName != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewReviewsScreen(
            providerId: providerId.toString(),
            providerName: providerName.toString(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot view review: Missing provider information')),
      );
    }
  }
}
