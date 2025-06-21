import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servease/serviceproviderScreens/sp_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loginpages/login.dart';
import '../services/api_services.dart';
import 'bottom-navigation-bar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  List<String> skills = [];
  String newSkill = '';
  bool isLoading = true;
  Map<String, dynamic>? userData;

  // Add image picker variables
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _currentProfilePicture;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Image picker method
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
              if (_selectedImage != null || _currentProfilePicture != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _currentProfilePicture = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.getUserProfile();

      if (response['success']) {
        setState(() {
          userData = response['user'];

          // Set controller values
          nameController.text = userData?['name'] ?? '';
          phoneController.text = userData?['phone'] ?? '';
          emailController.text = userData?['email'] ?? '';
          addressController.text = userData?['address'] ?? '';
          bioController.text = userData?['bio'] ?? '';
          _currentProfilePicture = userData?['profilePicture'];

          // Set skills
          if (userData?['skills'] != null && userData!['skills'] is List) {
            skills = List<String>.from(userData!['skills']);
          }

          isLoading = false;
        });

        print('✅ Profile data loaded successfully: ${userData?['name']}');
      } else {
        print('❌ Failed to load profile: ${response['error']}');
        setState(() {
          isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${response['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Exception loading profile: $e');
      setState(() {
        isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final profileData = {
        'name': nameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'bio': bioController.text,
        'skills': skills,
      };

      final response = await ApiService.updateUserProfile(profileData, profileImage: _selectedImage);

      setState(() {
        isLoading = false;
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload profile to get updated image URL
        _loadUserProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${response['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ServEase green colors
    final Color primaryGreen = Theme.of(context).colorScheme.primary;
    const Color lighterGreen = Color(0xFFD7F0DB);

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: primaryGreen,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background curved shapes
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 180,
              height: 200,
              decoration: const BoxDecoration(
                color: lighterGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Bottom right corner shape
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: lighterGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile picture
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: primaryGreen.withOpacity(0.2),
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (_currentProfilePicture != null && _currentProfilePicture!.isNotEmpty)
                              ? NetworkImage(ApiService.getImageUrl(_currentProfilePicture!))
                              : null,
                          child: (_selectedImage == null && (_currentProfilePicture == null || _currentProfilePicture!.isEmpty))
                              ? Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: primaryGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Form fields
                  _buildTextField(
                    context,
                    'Full Name',
                    nameController,
                    Icons.person_outline,
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    context,
                    'Phone Number',
                    phoneController,
                    Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    context,
                    'Email',
                    emailController,
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    enabled: false,
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    context,
                    'Address',
                    addressController,
                    Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    context,
                    'Bio',
                    bioController,
                    Icons.info_outline,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 30),

                  // Skills section
                  Text(
                    'Skills',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Skills chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...skills.map((skill) => Chip(
                        label: Text(skill),
                        backgroundColor: lighterGreen,
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 16,
                        ),
                        onDeleted: () {
                          setState(() {
                            skills.remove(skill);
                          });
                        },
                      )),
                      // Add skill chip
                      InputChip(
                        label: const Text('Add Skill'),
                        avatar: const Icon(Icons.add),
                        backgroundColor: Colors.grey.shade200,
                        onPressed: () {
                          _showAddSkillDialog(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () => _handleLogout(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProviderBottomNav(currentIndex: 3),
    );
  }

  Widget _buildTextField(
      BuildContext context,
      String label,
      TextEditingController controller,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        bool enabled = true,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Skill'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter skill',
            ),
            onChanged: (value) {
              newSkill = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newSkill.isNotEmpty) {
                  setState(() {
                    skills.add(newSkill);
                    newSkill = '';
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Clear stored token and user role
                await ApiService.clearToken();
                await ApiService.clearUserRole();

                // Navigate to login screen and clear all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Login()),
                      (Route<dynamic> route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}