import 'package:flutter/material.dart';
import 'package:servease/services/admin_api_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    try {
      final response = await AdminApiService.getCategories();
      if (response['success'] == true) {
        setState(() {
          categories = List<Map<String, dynamic>>.from(response['data'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF0C7210),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add,color: Colors.white,),
            onPressed: () => _showAddCategoryDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildCategoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search categories...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildCategoryList() {
    final filteredCategories = categories.where((category) {
      final name = (category['name'] ?? '').toString().toLowerCase();
      final description = (category['description'] ?? '').toString().toLowerCase();
      return name.contains(searchQuery) || description.contains(searchQuery);
    }).toList();

    if (filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty ? 'No categories found' : 'No matching categories',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (searchQuery.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddCategoryDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add First Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C7210),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredCategories.length,
        itemBuilder: (context, index) {
          final category = filteredCategories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final isActive = category['isActive'] ?? true;
    final serviceCount = category['serviceCount'] ?? 0;

    return GestureDetector(
      onTap: () => _showCategoryServices(category),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C7210).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category['icon'] ?? 'category'),
                      color: const Color(0xFF0C7210),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              category['name'] ?? 'Unknown Category',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Inactive',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (category['description'] != null)
                          Text(
                            category['description'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '$serviceCount services',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleCategoryAction(value, category),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: isActive ? 'deactivate' : 'activate',
                        child: Row(
                          children: [
                            Icon(
                              isActive ? Icons.visibility_off : Icons.visibility,
                              size: 16,
                              color: isActive ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(isActive ? 'Deactivate' : 'Activate'),
                          ],
                        ),
                      ),
                      if (serviceCount == 0)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (category['subcategories'] != null && (category['subcategories'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Subcategories:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: (category['subcategories'] as List).map((sub) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sub.toString(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'gardening':
        return Icons.grass;
      case 'painting':
        return Icons.format_paint;
      case 'carpentry':
        return Icons.carpenter;
      case 'appliance':
        return Icons.home_repair_service;
      case 'beauty':
        return Icons.face;
      case 'tutoring':
        return Icons.school;
      case 'fitness':
        return Icons.fitness_center;
      default:
        return Icons.category;
    }
  }

  void _handleCategoryAction(String action, Map<String, dynamic> category) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(category);
        break;
      case 'activate':
        _toggleCategoryStatus(category, true);
        break;
      case 'deactivate':
        _toggleCategoryStatus(category, false);
        break;
      case 'delete':
        _deleteCategory(category);
        break;
    }
  }

  void _showAddCategoryDialog() {
    _showCategoryDialog();
  }

  void _showEditCategoryDialog(Map<String, dynamic> category) {
    _showCategoryDialog(category: category);
  }

  void _showCategoryDialog({Map<String, dynamic>? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?['name'] ?? '');
    final descriptionController = TextEditingController(text: category?['description'] ?? '');
    final subcategoriesController = TextEditingController(
      text: category?['subcategories']?.join(', ') ?? '',
    );
    String selectedIcon = category?['icon'] ?? 'category';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Category' : 'Add Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subcategoriesController,
                  decoration: const InputDecoration(
                    labelText: 'Subcategories (comma separated)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Residential, Commercial, Emergency',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedIcon,
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'category',
                    'plumbing',
                    'electrical',
                    'cleaning',
                    'gardening',
                    'painting',
                    'carpentry',
                    'appliance',
                    'beauty',
                    'tutoring',
                    'fitness',
                  ].map((icon) {
                    return DropdownMenuItem(
                      value: icon,
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(icon), size: 20),
                          const SizedBox(width: 8),
                          Text(icon.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedIcon = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveCategory(
                isEditing,
                category?['_id'],
                nameController.text,
                descriptionController.text,
                subcategoriesController.text,
                selectedIcon,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C7210),
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategory(
      bool isEditing,
      String? categoryId,
      String name,
      String description,
      String subcategoriesText,
      String icon,
      ) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final subcategories = subcategoriesText
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final categoryData = {
      'name': name.trim(),
      'description': description.trim(),
      'subcategories': subcategories,
      'icon': icon,
    };

    try {
      final response = isEditing
          ? await AdminApiService.updateCategory(categoryId!, categoryData)
          : await AdminApiService.createCategory(categoryData);

      if (response['success'] == true) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Category updated successfully' : 'Category added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCategories();
      } else {
        throw Exception(response['error'] ?? 'Failed to save category');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleCategoryStatus(Map<String, dynamic> category, bool isActive) async {
    try {
      final response = await AdminApiService.updateCategoryStatus(category['_id'], isActive);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category ${isActive ? 'activated' : 'deactivated'} successfully'),
            backgroundColor: isActive ? Colors.green : Colors.orange,
          ),
        );
        _loadCategories();
      } else {
        throw Exception(response['error'] ?? 'Failed to update category status');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${category['name']}"?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await AdminApiService.deleteCategory(category['_id']);
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
          _loadCategories();
        } else {
          throw Exception(response['error'] ?? 'Failed to delete category');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCategoryServices(Map<String, dynamic> category) async {
    try {
      final response = await AdminApiService.getServicesByCategory(category['name']);
      if (response['success'] == true) {
        final services = List<Map<String, dynamic>>.from(response['data'] ?? []);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${category['name']} Services'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: services.isEmpty
                  ? const Center(child: Text('No services found'))
                  : ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ListTile(
                    title: Text(service['title'] ?? 'Unknown Service'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service['description'] ?? ''),
                        Text('Provider: ${service['provider']['name'] ?? 'Unknown'}'),
                        Text('Price: \$${service['price'] ?? 0}'),
                      ],
                    ),
                    trailing: Icon(
                      service['isActive'] == true ? Icons.check_circle : Icons.cancel,
                      color: service['isActive'] == true ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
