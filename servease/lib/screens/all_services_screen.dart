import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../widgets/service_card.dart';
import 'service_detail_screen.dart';
import '../loginpages/login.dart';

class AllServicesScreen extends StatefulWidget {
  final bool isGuestMode;
  final VoidCallback onLoginRequired;

  const AllServicesScreen({
    super.key,
    this.isGuestMode = false,
    required this.onLoginRequired,
  });

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Plumbing',
    'Carpentry',
    'Electrical',
    'Painting',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllServices();
  }

  Future<void> _fetchAllServices({String? category}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getAllServices(
        category: category == 'All' ? null : category,
      );

      // Debug log for API response
      print('All Services API Response: ${response['services']}');

      if (response['success'] == true && response['services'] != null) {
        final services = response['services'];
        setState(() {
          _services = List<Map<String, dynamic>>.from(
              services.map((service) {
                final providerId = service['providerId'] ?? {};
                final providerName = providerId is Map ? providerId['name'] ?? 'Unknown Provider' : 'Unknown Provider';
                final providerIdValue = providerId is Map ? providerId['_id'] ?? '' : '';

                // Extract provider image URL from the response
                final providerImageUrl = providerId is Map
                    ? ApiService.getImageUrl(providerId['profilePicture'])
                    : '';

                // Debug log for service image URL
                final rawImageUrl = service['imageUrl'];
                print('Service ID: ${service['_id']}');
                print('Raw service imageUrl from API: $rawImageUrl');

                final serviceImageUrl = ApiService.getImageUrl(rawImageUrl);
                print('Processed serviceImageUrl: $serviceImageUrl');

                return {
                  'id': service['_id'] ?? '',
                  'name': service['title'] ?? 'Unnamed Service',
                  'provider': providerName,
                  'providerId': providerIdValue,
                  'rating': (service['rating'] ?? 4.5).toDouble(),
                  'price': 'Rs.${service['price'] ?? '0'}/${service['priceType'] ?? 'hr'}',
                  'image': _getCategoryImage(service['category'] ?? 'other'),
                  'category': service['category'] ?? 'Other',
                  'description': service['description'] ?? 'No description available',
                  'providerImageUrl': providerImageUrl,
                  'serviceImageUrl': serviceImageUrl,
                };
              })
          );
        });
      } else {
        setState(() {
          _services = [];
        });
      }
    } catch (e) {
      print('Error fetching services: $e');
      setState(() {
        _services = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getCategoryImage(String category) {
    switch (category.toLowerCase()) {
      case 'plumber':
        return 'assets/icons/plumber.png';
      case 'carpenter':
        return 'assets/icons/carpenter.png';
      case 'electrician':
        return 'assets/icons/electrician.png';
      case 'mechanic':
        return 'assets/icons/mechanic.png';
      case 'welder':
        return 'assets/icons/welder.png';
      default:
        return 'assets/icons/service.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Services'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // Add login button for guest mode
        actions: [
          if (widget.isGuestMode)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Login'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _fetchAllServices(category: category);
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Services List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchAllServices(category: _selectedCategory),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _services.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.handyman_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No services available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try selecting a different category',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return ServiceCard(
                    title: service['name'],
                    provider: service['provider'],
                    rating: service['rating'],
                    price: service['price'],
                    imageUrl: service['image'],
                    providerImageUrl: service['providerImageUrl'],
                    serviceImageUrl: service['serviceImageUrl'],
                    onTap: () {
                      // If in guest mode, show login dialog
                      if (widget.isGuestMode) {
                        widget.onLoginRequired();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailScreen(
                              service: service,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
