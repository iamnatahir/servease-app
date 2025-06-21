import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../widgets/service_card.dart';
import 'service_detail_screen.dart';

class RequestServiceScreen extends StatefulWidget {
  final String category;

  const RequestServiceScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String _selectedCategory = '';
  final List<String> _categories = [
    'All',
    'Plumbing',
    'Carpentry',
    'Electrical',
    'Gardening',
    'Mechanic',
    'Welder',
    'Appliance Repair',
    'Painting',
    'Cleaning',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category.isNotEmpty ? widget.category : 'All';
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getAllServices(
        category: _selectedCategory == 'All' ? '' : _selectedCategory,
      );

      if (response['success'] == true && response['services'] != null) {
        final services = response['services'];
        setState(() {
          _services = List<Map<String, dynamic>>.from(
            services.map((service) {
              final providerId = service['providerId'] ?? {};
              final providerName = providerId is Map ? providerId['name'] ?? 'Unknown Provider' : 'Unknown Provider';
              final providerIdValue = providerId is Map ? providerId['_id'] ?? '' : '';

              final providerImageUrl = providerId is Map
                  ? ApiService.getImageUrl(providerId['profilePicture'])
                  : '';

              final rawImageUrl = service['imageUrl'];
              final serviceImageUrl = ApiService.getImageUrl(rawImageUrl);

              return {
                'id': service['_id'] ?? '',
                'name': service['title'] ?? 'Unnamed Service',
                'provider': providerName,
                'providerId': providerIdValue,
                'rating': (service['rating'] ?? 4.5).toDouble(),
                'price': 'Rs. ${service['price'] ?? '0'}/${service['priceType'] ?? 'hr'}',
                'image': _getCategoryImage(service['category'] ?? 'other'),
                'category': service['category'] ?? 'Other',
                'description': service['description'] ?? 'No description available',
                'providerImageUrl': providerImageUrl,
                'serviceImageUrl': serviceImageUrl,
              };
            }),
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _services = [];
        });
      }
    } catch (e) {
      print('Error fetching services: $e');
      setState(() {
        _isLoading = false;
        _services = [];
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
      case 'ac repair':
        return 'assets/icons/ac_repair.png';
      case 'drain unclogging':
        return 'assets/icons/drain.png';
      case 'painting':
        return 'assets/icons/painting.png';
      case 'cleaning':
        return 'assets/icons/cleaning.png';
      default:
        return 'assets/icons/service.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Service${_selectedCategory != 'All' ? ' - $_selectedCategory' : ''}'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _fetchServices();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Services list
          Expanded(
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
                    'No services available for $_selectedCategory',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailScreen(
                          service: service,
                        ),
                      ),
                    );
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
