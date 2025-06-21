import 'package:flutter/material.dart';
import 'package:servease/serviceproviderScreens/add-service-sp.dart';
import 'package:servease/serviceproviderScreens/bookings-page.dart';
import 'package:servease/serviceproviderScreens/my-services.dart';
import 'package:servease/serviceproviderScreens/sp-reviews.dart';
import 'package:servease/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom-navigation-bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  String userName = 'Service Provider';
  String? profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _checkToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Current Token in Dashboard: $token');
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.getProviderDashboard();
      if (response['success']) {
        setState(() {
          dashboardData = response['data'];
          isLoading = false;
        });
      }

      // Also get user profile for name
      final profileResponse = await ApiService.getUserProfile();
      if (profileResponse['success']) {
        setState(() {
          userName = profileResponse['user']['name'];
          profilePictureUrl = profileResponse['user']['profilePicture'];
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading dashboard data: $e');
    }
  }

  // Add this method to refresh dashboard data
  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
  }

  // Navigate to Add Service page and refresh on return
  void _navigateToAddService() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddServicePage()),
    );

    // If service was added successfully, refresh dashboard
    if (result == true) {
      _refreshDashboard();
    }
  }

  // Navigate to My Services page and refresh on return
  void _navigateToMyServices() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyServicesPage()),
    );

    // Refresh dashboard when returning from My Services
    if (result == true) {
      _refreshDashboard();
    }
  }

  // Navigate to Edit Service page
  void _navigateToEditService(Map<String, dynamic> service) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddServicePage(service: service),
      ),
    );

    // If service was updated successfully, refresh dashboard
    if (result == true) {
      _refreshDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme
                .of(context)
                .colorScheme
                .primary,
          ),
        ),
      );
    }

    final stats = dashboardData?['stats'] ?? {};
    final recentBookings = dashboardData?['recentBookings'] ?? [];
    final services = dashboardData?['services'] ?? [];
    final recentReviews = dashboardData?['recentReviews'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Add refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshDashboard,
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                // Enable pull-to-refresh
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage: profilePictureUrl != null &&
                                profilePictureUrl!.isNotEmpty
                                ? NetworkImage(
                                ApiService.getImageUrl(profilePictureUrl))
                                : null,
                            child: profilePictureUrl == null ||
                                profilePictureUrl!.isEmpty
                                ? Icon(
                              Icons.person,
                              size: 40,
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .primary,
                            )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${stats['avgRating'] ?? 0}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${recentReviews.length} reviews)',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats section
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats cards
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          Icons.calendar_today,
                          '${stats['upcomingBookings'] ?? 0}',
                          'Upcoming',
                          Theme
                              .of(context)
                              .colorScheme
                              .tertiary,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          context,
                          Icons.check_circle,
                          '${stats['completedBookings'] ?? 0}',
                          'Completed',
                          Theme
                              .of(context)
                              .colorScheme
                              .tertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          Icons.star,
                          '${stats['avgRating'] ?? 0}',
                          'Rating',
                          Theme
                              .of(context)
                              .colorScheme
                              .tertiary,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          context,
                          Icons.currency_rupee_sharp,
                          'Rs. ${stats['totalEarnings'] ?? 0}',
                          'Earnings',
                          Theme
                              .of(context)
                              .colorScheme
                              .tertiary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Upcoming bookings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Bookings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => BookingsPage()));
                          },
                          child: Text(
                            'See All',
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Booking cards
                    if (recentBookings.isNotEmpty)
                      ...recentBookings.take(3).map((booking) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildBookingCard(
                              context,
                              booking['customerId']['name'],
                              booking['serviceId']['title'] ?? 'Default Title',
                              '${booking['date']} • ${booking['time']}',
                              '\$${booking['price']}',
                            ),
                          )).toList()
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'No recent bookings',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Services section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToMyServices,
                          // Updated to use new method
                          child: Text(
                            'See All',
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Service cards
                    Container(
                      height: 175,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...services.map((service) =>
                              _buildServiceCard(
                                context,
                                service, // Pass the entire service object
                              )).toList(),
                          // Add service card
                          GestureDetector(
                            onTap: _navigateToAddService,
                            // Updated to use new method
                            child: Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 32,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add Service',
                                    style: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent reviews
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Reviews',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => ReviewsPage()));
                          },
                          child: Text(
                            'See All',
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Review cards
                    if (recentReviews.isNotEmpty)
                      ...recentReviews.take(2).map((review) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildReviewCard(
                              context,
                              review['customerId']['name'],
                              review['comment'],
                              review['rating'],
                              _formatDate(review['createdAt']),
                            ),
                          )).toList()
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'No reviews yet',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ProviderBottomNav(currentIndex: 0),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now
          .difference(date)
          .inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return '1 day ago';
      } else if (difference < 7) {
        return '$difference days ago';
      } else {
        return '${(difference / 7).floor()} week${(difference / 7).floor() > 1
            ? 's'
            : ''} ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String value,
      String label, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, String name, String service,
      String dateTime, String price) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/booking-detail');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.2),
              child: Text(
                name.substring(0, 1),
                style: TextStyle(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateTime,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, String name, String comment,
      int rating, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.2),
                child: Text(
                  name.substring(0, 1),
                  style: TextStyle(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: index < rating ? Colors.amber : Colors.grey.shade400,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Updated _buildServiceCard to accept the full service object and handle navigation
  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {
        _navigateToEditService(service);
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: service['imageUrl'] != null &&
                        service['imageUrl'].isNotEmpty
                        ? Image.network(
                      ApiService.getImageUrl(service['imageUrl']),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.home_repair_service,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          size: 40,
                        );
                      },
                    )
                        : Icon(
                      Icons.home_repair_service,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                      size: 40,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.edit,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              service['title'] ?? 'Service',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Rs.${service['price']}/${service['priceType']?.toLowerCase() ??
                  'hour'}',
              style: TextStyle(
                fontSize: 11,
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}