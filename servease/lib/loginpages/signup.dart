import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:servease/loginpages/background.dart';
import 'package:servease/loginpages/header.dart';
import '../config/api_config.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cnicController = TextEditingController();
  final bioController = TextEditingController();

  // Add password visibility state variables
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // Add image picker variables
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  List<String> skills = [];
  String newSkill = '';

  String? selectedRole;

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
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Header(title: 'Create Account'),
                    const SizedBox(height: 40),

                    // Profile Picture Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            backgroundImage:
                            _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : null,
                            child:
                            _selectedImage == null
                                ? Icon(
                              Icons.person,
                              size: 80,
                              color:
                              Theme.of(context).colorScheme.primary,
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
                                  color: Theme.of(context).colorScheme.primary,
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

                    _buildLabel('Full Name'),
                    _buildTextField(
                      nameController,
                      'John Doe',
                      Icons.person_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Email Address'),
                    _buildTextField(
                      emailController,
                      'johndoe@example.com',
                      Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Password'),
                    _buildTextField(
                      passwordController,
                      'Password',
                      Icons.lock_outline,
                      obscureText: !_passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Confirm Password'),
                    _buildTextField(
                      confirmPasswordController,
                      'Confirm Password',
                      Icons.lock_outline,
                      obscureText: !_confirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Phone Number'),
                    _buildTextField(
                      phoneController,
                      '+1 (555) 123-4567',
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 20),
                    _buildLabel('Address'),
                    _buildTextField(
                      addressController,
                      '123 Main St, City, Country',
                      Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 20),
                    _buildLabel('Role'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: _boxDecoration(),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.work_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        value: selectedRole,
                        hint: Text(
                          'Select Role',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        items:
                        ['Customer', 'Service Provider'].map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(
                              role,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRole = newValue;
                          });
                        },
                      ),
                    ),

                    // Show extra fields for service providers
                    if (selectedRole == 'Service Provider') ...[
                      const SizedBox(height: 20),
                      _buildLabel('CNIC Number'),
                      _buildTextField(
                        cnicController,
                        'e.g. 12345-1234567-1',
                        Icons.credit_card,
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 20),
                      _buildLabel('Bio'),
                      _buildTextField(
                        bioController,
                        'Tell us about your experience...',
                        Icons.info_outline,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 20),
                      _buildLabel('Skills'),
                      _buildSkillsSection(),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          backgroundColor:
                          Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();
                          final confirmPassword =
                          confirmPasswordController.text.trim();
                          final phone = phoneController.text.trim();
                          final address = addressController.text.trim();
                          final cnic = cnicController.text.trim();
                          final bio = bioController.text.trim();

                          // Basic validation
                          if (name.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty ||
                              confirmPassword.isEmpty ||
                              phone.isEmpty ||
                              address.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please fill in all required fields",
                                ),
                              ),
                            );
                            return;
                          }

                          if (password != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Passwords do not match")),
                            );
                            return;
                          }

                          final role = selectedRole;
                          if (role == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please select a role")),
                            );
                            return;
                          }

                          // Service provider specific validation
                          if (role == "Service Provider") {
                            if (cnic.isEmpty || bio.isEmpty || skills.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Service providers must provide CNIC, bio, and at least one skill",
                                  ),
                                ),
                              );
                              return;
                            }
                          }

                          try {
                            // Create multipart request for image upload
                            var request = http.MultipartRequest(
                              'POST',
                              Uri.parse(
                                "${ApiConfig.baseUrl}/api/auth/signup",
                              ),
                            );

                            // Add text fields
                            request.fields['name'] = name;
                            request.fields['email'] = email;
                            request.fields['password'] = password;
                            request.fields['phone'] = phone;
                            request.fields['address'] = address;
                            request.fields['role'] = role;

                            if (role == "Service Provider") {
                              request.fields['cnic'] = cnic;
                              request.fields['bio'] = bio;
                              request.fields['skills'] = json.encode(skills);
                            }

                            // Add image if selected
                            if (_selectedImage != null) {
                              request.files.add(
                                await http.MultipartFile.fromPath(
                                  'profilePicture',
                                  _selectedImage!.path,
                                ),
                              );
                            }

                            final response = await request.send();
                            final responseData =
                            await response.stream.bytesToString();
                            final data = json.decode(responseData);

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Signup successful")),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => Login()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    data['error'] ?? "Signup failed",
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Network error. Please try again.",
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text("Sign up"),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => Login()),
                            );
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...skills.map(
                  (skill) => Chip(
                label: Text(skill),
                backgroundColor: const Color(0xFFD7F0DB),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    skills.remove(skill);
                  });
                },
              ),
            ),
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
            decoration: const InputDecoration(hintText: 'Enter skill'),
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
                if (newSkill.isNotEmpty && !skills.contains(newSkill.trim())) {
                  setState(() {
                    skills.add(newSkill.trim());
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

  Widget _buildTextField(
      TextEditingController controller,
      String hintText,
      IconData icon, {
        bool obscureText = false,
        Widget? suffixIcon,
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return Container(
      decoration: _boxDecoration(),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }
}
