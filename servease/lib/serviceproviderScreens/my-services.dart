import 'package:flutter/material.dart';
import 'package:servease/serviceproviderScreens/add-service-sp.dart';
import 'package:servease/serviceproviderScreens/sp_dashboard.dart';
import 'package:servease/services/api_services.dart';

import 'bottom-navigation-bar.dart';

class MyServicesPage extends StatefulWidget {
  const MyServicesPage({super.key});

  @override
  State<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends State<MyServicesPage> {
  List<Map<String, dynamic>> services = [];
  bool isLoading = true;

  // Filter and sort state
  bool _showAvailable = true;
  bool _showUnavailable = true;
  List<String> _selectedCategories = ['Plumbing'];
  String _sortOption = 'price_asc';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final response = await ApiService.getMyServices();
      if (response['success']) {
        setState(() {
          services = List<Map<String, dynamic>>.from(response['services']);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading services: $e');
    }
  }

  void _navigateBackToDashboard() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  Future<void> _deleteService(String serviceId) async {
    try {
      final response = await ApiService.deleteService(serviceId);
      if (response['success']) {
        setState(() {
          services.removeWhere((service) => service['_id'] == serviceId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete service'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleServiceAvailability(String serviceId, bool isAvailable) async {
    try {
      final response = await ApiService.updateService(serviceId, {'isAvailable': !isAvailable});
      if (response['success']) {
        setState(() {
          final index = services.indexWhere((service) => service['_id'] == serviceId);
          if (index != -1) {
            services[index]['isAvailable'] = !isAvailable;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !isAvailable ? 'Service is now available' : 'Service is now unavailable',
            ),
            backgroundColor: !isAvailable ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update service'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'My Services',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Services count and add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${services.length} Services',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      // Quick add button
                      if (services.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>AddServicePage())).then((_) => _loadServices());
                          },
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                          label: Text(
                            'Add New',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Services list
                  Expanded(
                    child: services.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return _buildServiceCard(context, service);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddServicePage())).then((_) => _loadServices());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
      bottomNavigationBar: ProviderBottomNav(currentIndex: 2),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_repair_service,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No services added yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start adding your services to get bookings from customers',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddServicePage())).then((_) => _loadServices());
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Your First Service',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          // Service details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: service['imageUrl'] != null && service['imageUrl'].isNotEmpty
                        ? Image.network(
                      ApiService.getImageUrl(service['imageUrl']),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.home_repair_service,
                          color: Theme.of(context).colorScheme.primary,
                          size: 40,
                        );
                      },
                    )
                        : Icon(
                      Icons.home_repair_service,
                      color: Theme.of(context).colorScheme.primary,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Service info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              service['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: service['isAvailable']
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              service['isAvailable'] ? 'Available' : 'Unavailable',
                              style: TextStyle(
                                fontSize: 12,
                                color: service['isAvailable']
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['category'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Rs. ${service['price']}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ' / ${service['priceType']}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          // Stats
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${service['totalBookings'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${service['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            color: Colors.grey.shade200,
            height: 1,
          ),

          // Action buttons
          Row(
            children: [
              // Toggle availability button
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    _toggleServiceAvailability(service['_id'], service['isAvailable']);
                  },
                  icon: Icon(
                    service['isAvailable'] ? Icons.visibility : Icons.visibility_off,
                    color: service['isAvailable'] ? Theme.of(context).colorScheme.primary : Colors.grey,
                    size: 18,
                  ),
                  label: Text(
                    service['isAvailable'] ? 'Hide' : 'Show',
                    style: TextStyle(
                      color: service['isAvailable'] ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                  ),
                ),
              ),

              // Vertical divider
              Container(
                height: 24,
                width: 1,
                color: Colors.grey.shade200,
              ),

              // Edit button
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    // Navigate to edit service page with service data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddServicePage(service: service),
                      ),
                    ).then((_) => _loadServices());
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  label: Text(
                    'Edit',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),

              // Vertical divider
              Container(
                height: 24,
                width: 1,
                color: Colors.grey.shade200,
              ),

              // Delete button
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    _showDeleteDialog(context, service);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 18,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Service'),
          content: Text('Are you sure you want to delete "${service['title']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteService(service['_id']);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Keep the existing filter and sort methods unchanged
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Availability filter
                  const Text(
                    'Availability',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _showAvailable,
                        onChanged: (value) {
                          setModalState(() {
                            _showAvailable = value!;
                          });
                        },
                      ),
                      const Text('Available'),
                      const SizedBox(width: 16),
                      Checkbox(
                        value: _showUnavailable,
                        onChanged: (value) {
                          setModalState(() {
                            _showUnavailable = value!;
                          });
                        },
                      ),
                      const Text('Unavailable'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category filter
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildCategoryFilterChip(setModalState, 'Plumbing'),
                      _buildCategoryFilterChip(setModalState, 'Electrical'),
                      _buildCategoryFilterChip(setModalState, 'Cleaning'),
                      _buildCategoryFilterChip(setModalState, 'Painting'),
                      _buildCategoryFilterChip(setModalState, 'Carpentry'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Apply filters
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryFilterChip(StateSetter setModalState, String category) {
    return FilterChip(
      label: Text(category),
      selected: _selectedCategories.contains(category),
      onSelected: (selected) {
        setModalState(() {
          if (selected) {
            _selectedCategories.add(category);
          } else {
            _selectedCategories.remove(category);
          }
        });
      },
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sort Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sort options
                  RadioListTile(
                    title: const Text('Price: Low to High'),
                    value: 'price_asc',
                    groupValue: _sortOption,
                    onChanged: (value) {
                      setModalState(() {
                        _sortOption = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Price: High to Low'),
                    value: 'price_desc',
                    groupValue: _sortOption,
                    onChanged: (value) {
                      setModalState(() {
                        _sortOption = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Rating: High to Low'),
                    value: 'rating_desc',
                    groupValue: _sortOption,
                    onChanged: (value) {
                      setModalState(() {
                        _sortOption = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Apply sorting
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Sorting',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
