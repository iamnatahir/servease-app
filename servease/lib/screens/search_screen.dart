import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../widgets/service_card.dart';
import 'service_detail_screen.dart';
import '../loginpages/login.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final bool isGuestMode;
  final VoidCallback? onLoginRequired;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.isGuestMode = false,
    this.onLoginRequired,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allServices = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  final List<Map<String, String>> _serviceCategories = [
    {'name': 'Electrician', 'icon': '⚡', 'color': 'FFE4B5'},
    {'name': 'Dog Walker', 'icon': '🐕', 'color': 'FFFACD'},
    {'name': 'Doctor', 'icon': '👩‍⚕️', 'color': 'E6E6FA'},
    {'name': 'Tutor', 'icon': '👨‍🏫', 'color': 'F0F8FF'},
    {'name': 'Baby Sitter', 'icon': '👶', 'color': 'B0E0E6'},
    {'name': 'Pest Control', 'icon': '🐛', 'color': 'FFEFD5'},
    {'name': 'Handyman', 'icon': '🔧', 'color': 'F5F5DC'},
    {'name': 'Home Cleaner', 'icon': '🏠', 'color': 'FFF8DC'},
    {'name': 'Plumber', 'icon': '🔧', 'color': 'E0F6FF'},
    {'name': 'Barber', 'icon': '💇‍♂️', 'color': 'F0F8FF'},
    {'name': 'Carpenter', 'icon': '🔨', 'color': 'F5F5DC'},
    {'name': 'Massage', 'icon': '💆‍♀️', 'color': 'FFF0F5'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
    _loadAllServices();
  }

  Future<void> _loadAllServices() async {
    try {
      final response = await ApiService.getAllServices();
      if (response['success'] == true && response['services'] != null) {
        setState(() {
          _allServices = List<Map<String, dynamic>>.from(
              response['services'].map((service) {
                final providerId = service['providerId'] ?? {};
                final providerName = providerId is Map ? providerId['name'] ?? 'Unknown Provider' : 'Unknown Provider';
                final providerIdValue = providerId is Map ? providerId['_id'] ?? '' : '';

                return {
                  'id': service['_id'] ?? '',
                  'name': service['title'] ?? 'Unnamed Service',
                  'provider': providerName,
                  'providerId': providerIdValue,
                  'rating': (service['rating'] ?? 4.5).toDouble(),
                  'price': '\$${service['price'] ?? '0'}/${service['priceType'] ?? 'hr'}',
                  'image': _getCategoryImage(service['category'] ?? 'other'),
                  'category': service['category'] ?? 'Other',
                  'description': service['description'] ?? 'No description available',
                };
              })
          );
        });
      }
    } catch (e) {
      print('Error loading all services: $e');
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

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final response = await ApiService.getAllServices(search: query);
      if (response['success'] == true && response['services'] != null) {
        final services = response['services'];
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(
              services.map((service) {
                final providerId = service['providerId'] ?? {};
                final providerName = providerId is Map ? providerId['name'] ?? 'Unknown Provider' : 'Unknown Provider';
                final providerIdValue = providerId is Map ? providerId['_id'] ?? '' : '';

                // Extract provider image URL from the response
                final providerImageUrl = providerId is Map
                    ? ApiService.getImageUrl(providerId['profilePicture'])
                    : '';

                // Extract service image URL
                final serviceImageUrl = ApiService.getImageUrl(service['imageUrl']);

                return {
                  'id': service['_id'] ?? '',
                  'name': service['title'] ?? 'Unnamed Service',
                  'provider': providerName,
                  'providerId': providerIdValue,
                  'rating': (service['rating'] ?? 4.5).toDouble(),
                  'price': '\$${service['price'] ?? '0'}/${service['priceType'] ?? 'hr'}',
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
          _searchResults = [];
        });
      }
    } catch (e) {
      print('Error searching services: $e');
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Services'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Search for services',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : _searchResults.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try different keywords',
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
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final service = _searchResults[index];
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
                    if (widget.isGuestMode && widget.onLoginRequired != null) {
                      widget.onLoginRequired!();
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
        ],
      ),
    );
  }
}
