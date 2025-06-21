import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/banner_card.dart';
import '../widgets/section_header.dart';
import '../widgets/category_item.dart';
import '../widgets/navigation_menu.dart';
import '../widgets/service_card.dart';
import '../services/api_services.dart';
import 'categories_page.dart';
import 'service_detail_screen.dart';
import 'my_bookings_screen.dart';
import 'user_profile_screen.dart';
import 'search_screen.dart';
import 'all_services_screen.dart';
import '../loginpages/login.dart';
import 'request_service_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  final bool isGuestMode;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
    this.isGuestMode = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  late bool _isGuestMode;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _isGuestMode = widget.isGuestMode;
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await ApiService.getToken();
    if (token != null) {
      setState(() {
        _isGuestMode = false;
      });
    }
  }

  void _handleNavigation(int index) {
    // If in guest mode and trying to access restricted sections
    if (_isGuestMode && (index == 1 || index == 3)) {
      _showLoginRequiredDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You need to login to access this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeContent(isGuestMode: _isGuestMode, onLoginRequired: _showLoginRequiredDialog),
       MyBookingsScreen(),
      SearchScreen(isGuestMode: _isGuestMode, onLoginRequired: _showLoginRequiredDialog),
      const UserProfileScreen(),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _handleNavigation,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final bool isGuestMode;
  final VoidCallback onLoginRequired;

  const HomeContent({
    super.key,
    this.isGuestMode = false,
    required this.onLoginRequired,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String _userName = 'Guest';

  // Define the categories to show on home page (only 4)
  final List<Map<String, String>> _homeCategories = [
    {'title': 'Plumbing', 'iconPath': 'assets/icons/plumber.png'},
    {'title': 'Carpentry', 'iconPath': 'assets/icons/carpenter.png'},
    {'title': 'Electrical', 'iconPath': 'assets/icons/electrician.png'},
    {'title': 'Mechanic', 'iconPath': 'assets/icons/mechanic.png'},
  ];

  @override
  void initState() {
    super.initState();
    if (!widget.isGuestMode) {
      _loadUserProfile();
    }
    _fetchServices();
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await ApiService.getUserProfile();
      if (response['success'] == true) {
        setState(() {
          _userName = response['user']['name'] ?? 'User';
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getAllServices();
      print('API Response: ${response['services']}'); // Debug log for entire response

      if (response['success'] == true && response['services'] != null) {
        final services = response['services'];
        setState(() {
          _services = List<Map<String, dynamic>>.from(
              services.take(10).map((service) { // Limit to 10 recent services
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
                print('Raw imageUrl from API: $rawImageUrl');

                final serviceImageUrl = ApiService.getImageUrl(rawImageUrl);
                print('Processed serviceImageUrl: $serviceImageUrl');

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
                  'providerImageUrl': providerImageUrl, // Add provider image URL
                  'serviceImageUrl': serviceImageUrl, // Add service image URL
                };
              })
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching services: $e');
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
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchServices,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Show login button in guest mode
                    if (widget.isGuestMode)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Login'),
                      )
                    else
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_outlined),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline),
                            onPressed: () {},
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(
                          isGuestMode: widget.isGuestMode,
                          onLoginRequired: widget.onLoginRequired,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Search for services',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const BannerCard(
                  title: 'GET YOUR',
                  subtitle: 'NEEDED SERVICES',
                  imageUrl: 'assets/icons/drill.png',
                ),
                const SizedBox(height: 24),
                // Modified navigation menu for guest mode
                widget.isGuestMode
                    ? GuestNavigationMenu(onLoginRequired: widget.onLoginRequired)
                    : NavigationMenu(
                  onAddCircleOutlineTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RequestServiceScreen(category: '')),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Categories',
                  subtitle: 'All categories of tools',
                  onSeeAllPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CategoriesPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Show only 4 categories on home page
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _homeCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 20),
                    itemBuilder: (context, index) {
                      final category = _homeCategories[index];
                      return CategoryItem(
                        title: category['title']!,
                        iconPath: category['iconPath']!,
                        onTap: () => _filterServicesByCategory(category['title']!),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Available Services',
                  subtitle: 'Book services from providers',
                  onSeeAllPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllServicesScreen(
                          isGuestMode: widget.isGuestMode,
                          onLoginRequired: widget.onLoginRequired,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _services.isEmpty
                    ? Center(
                  child: Column(
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
                    ],
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                      serviceImageUrl: service['serviceImageUrl'], // Pass the service image URL
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _filterServicesByCategory(String category) async {
    // Navigate to the RequestServiceScreen instead of just filtering
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestServiceScreen(category: category),
      ),
    );
  }
}

// New widget for guest mode navigation menu
class GuestNavigationMenu extends StatelessWidget {
  final VoidCallback onLoginRequired;

  const GuestNavigationMenu({
    super.key,
    required this.onLoginRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NavigationMenuItem(
          icon: Icons.add_circle_outline,
          label: 'Request Service',
          color: Color(0xFF2196F3),
          onTap: onLoginRequired,
        ),
        NavigationMenuItem(
          icon: Icons.calendar_today,
          label: 'My Bookings',
          color: Color(0xFFFF9800),
          onTap: onLoginRequired,
        ),
        NavigationMenuItem(
          icon: Icons.person,
          label: 'Profile',
          color: Color(0xFF4CAF50),
          onTap: onLoginRequired,
        ),
        NavigationMenuItem(
          icon: Icons.star,
          label: 'Featured',
          color: Color(0xFF9C27B0),
          onTap: onLoginRequired,
        ),
      ],
    );
  }
}
