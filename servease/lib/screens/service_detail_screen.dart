import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'booking_request_screen.dart';
import 'view_reviews_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ServiceDetailScreen({
    super.key,
    required this.service,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _providerDetails;

  @override
  void initState() {
    super.initState();
    _fetchProviderDetails();
    // Debug log to check service data
    print('Service data: ${widget.service}');

    // Debug log to check image URLs
    print('Service image URL: ${widget.service['serviceImageUrl']}');
    print('Provider image URL: ${widget.service['providerImageUrl']}');
    print('Category image: ${widget.service['image']}');
  }

  Future<void> _fetchProviderDetails() async {
    if (widget.service['providerId'] == null || widget.service['providerId'].isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Make an actual API call to get provider details
      final response = await ApiService.getProviderDetails(widget.service['providerId']);

      print('Provider API response: $response'); // Debug log

      if (response['success'] == true && response['provider'] != null) {
        setState(() {
          _providerDetails = response['provider'];

          // If some fields are missing in the API response, provide defaults
          if (_providerDetails!['totalBookings'] == null) {
            _providerDetails!['totalBookings'] = 0;
          }

          if (_providerDetails!['experience'] == null) {
            _providerDetails!['experience'] = 'New';
          }

          // Make sure we have the profile picture
          if (_providerDetails!['profilePicture'] == null &&
              widget.service['providerImageUrl'] != null) {
            _providerDetails!['profilePicture'] = widget.service['providerImageUrl'];
          }
        });
      } else {
        // Fallback to basic info if API call fails
        setState(() {
          _providerDetails = {
            'id': widget.service['providerId'],
            'name': widget.service['provider'],
            'rating': widget.service['rating'],
            'totalBookings': 0,
            'experience': 'New',
            'profilePicture': widget.service['providerImageUrl'],
          };
        });
        print('API call succeeded but no provider data returned');
      }
    } catch (e) {
      print('Error fetching provider details: $e');
      // Fallback to basic info if API call fails
      setState(() {
        _providerDetails = {
          'id': widget.service['providerId'],
          'name': widget.service['provider'],
          'rating': widget.service['rating'],
          'totalBookings': 0,
          'experience': 'New',
          'profilePicture': widget.service['providerImageUrl'],
        };
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service['name'] ?? 'Service Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image with improved display
            _buildServiceImageHeader(),

            // Service Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.service['name'] ?? 'Unnamed Service',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.service['price'] ?? '\$0/hr',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.service['category'] ?? 'Other',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.service['description'] ?? 'No description available',
                    style: TextStyle(
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Service Provider Details
                  const Text(
                    'Service Provider',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildProviderCard(),

                  const SizedBox(height: 24),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingRequestScreen(
                              service: widget.service,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the service image header
  Widget _buildServiceImageHeader() {
    // Add null checks for all properties
    final String? serviceImageUrl = widget.service['serviceImageUrl'];
    final String? providerImageUrl = widget.service['providerImageUrl'];
    final String categoryImage = widget.service['image'] ?? 'assets/icons/service.png';

    print('Building service image header:');
    print('Service image URL: $serviceImageUrl');
    print('Provider image URL: $providerImageUrl');
    print('Category image: $categoryImage');

    return Stack(
      children: [
        // Service Image
        Container(
          height: 250,
          width: double.infinity,
          child: serviceImageUrl != null && serviceImageUrl.isNotEmpty
              ? Image.network(
            ApiService.getImageUrl(serviceImageUrl),
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('Error loading service image: $error');
              // Try provider image as fallback
              if (providerImageUrl != null && providerImageUrl.isNotEmpty) {
                return Image.network(
                  ApiService.getImageUrl(providerImageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading provider image: $error');
                    // Use category icon as final fallback
                    return Container(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Center(
                        child: Image.asset(
                          categoryImage,
                          height: 100,
                          width: 100,
                        ),
                      ),
                    );
                  },
                );
              } else {
                // Use category icon as fallback
                return Container(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Center(
                    child: Image.asset(
                      categoryImage,
                      height: 100,
                      width: 100,
                    ),
                  ),
                );
              }
            },
          )
              : providerImageUrl != null && providerImageUrl.isNotEmpty
              ? Image.network(
            ApiService.getImageUrl(providerImageUrl),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading provider image: $error');
              // Use category icon as fallback
              return Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Center(
                  child: Image.asset(
                    categoryImage,
                    height: 100,
                    width: 100,
                  ),
                ),
              );
            },
          )
              : Container(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Center(
              child: Image.asset(
                categoryImage,
                height: 100,
                width: 100,
              ),
            ),
          ),
        ),
        // Gradient overlay for better text visibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard() {
    if (_providerDetails == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Provider information not available'),
        ),
      );
    }

    final String? profilePicture = _providerDetails!['profilePicture'];
    print('Provider profile picture: $profilePicture');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Provider Avatar - Now using network image with fallback
            ClipOval(
              child: SizedBox(
                width: 60,
                height: 60,
                child: profilePicture != null && profilePicture.isNotEmpty
                    ? Image.network(
                  ApiService.getImageUrl(profilePicture),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading provider image: $error');
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _providerDetails!['name'] ?? 'Unknown Provider',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_providerDetails!['rating'] ?? 0.0} Rating',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.work,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_providerDetails!['totalBookings'] ?? 0} Bookings',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      if (_providerDetails!['experience'] != null) ...[
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.access_time,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _providerDetails!['experience'],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


