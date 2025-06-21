import 'package:flutter/material.dart';
import '../screens/request_service_screen.dart';
import '../screens/my_bookings_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/all_services_screen.dart';

class NavigationMenu extends StatelessWidget {
  final VoidCallback? onAddCircleOutlineTap;

  const NavigationMenu({
    Key? key,
    this.onAddCircleOutlineTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NavigationMenuItem(
          icon: Icons.add_circle_outline,
          label: 'Request',
          color: Color(0xFF2196F3),
          onTap: onAddCircleOutlineTap ?? () {
            // Default behavior - navigate to request service screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RequestServiceScreen(category: '')),
            );
          },
        ),
        NavigationMenuItem(
          icon: Icons.calendar_today,
          label: 'My Bookings',
          color: Color(0xFFFF9800),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyBookingsScreen()),
            );
          },
        ),
        NavigationMenuItem(
          icon: Icons.person,
          label: 'Profile',
          color: Color(0xFF4CAF50),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          },
        ),
        NavigationMenuItem(
          icon: Icons.star,
          label: 'Featured',
          color: Color(0xFF9C27B0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllServicesScreen(
                  isGuestMode: false,
                  onLoginRequired: () {},
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class NavigationMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const NavigationMenuItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
