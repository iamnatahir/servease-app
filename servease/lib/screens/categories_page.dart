import 'package:flutter/material.dart';
import '../widgets/category_item.dart';
import 'request_service_screen.dart';
import 'home.dart';
import 'my_bookings_screen.dart';
import 'search_screen.dart';
import 'user_profile_screen.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              CategoryItem(
                title: 'Plumber',
                iconPath: 'assets/icons/plumber.png',
                onTap: () => _navigateToServicesByCategory(context, 'Plumber'),
              ),
              CategoryItem(
                title: 'Carpenter',
                iconPath: 'assets/icons/carpenter.png',
                onTap: () => _navigateToServicesByCategory(context, 'Carpenter'),
              ),
              CategoryItem(
                title: 'Welder',
                iconPath: 'assets/icons/welder.png',
                onTap: () => _navigateToServicesByCategory(context, 'Welder'),
              ),
              CategoryItem(
                title: 'Contractor',
                iconPath: 'assets/icons/contractor.png',
                onTap: () => _navigateToServicesByCategory(context, 'Contractor'),
              ),
              CategoryItem(
                title: 'Electrician',
                iconPath: 'assets/icons/electrician.png',
                onTap: () => _navigateToServicesByCategory(context, 'Electrician'),
              ),
              CategoryItem(
                title: 'Painter',
                iconPath: 'assets/icons/painter.png',
                onTap: () => _navigateToServicesByCategory(context, 'Painter'),
              ),
              CategoryItem(
                title: 'Laundry',
                iconPath: 'assets/icons/laundry.png',
                onTap: () => _navigateToServicesByCategory(context, 'Laundry'),
              ),
              CategoryItem(
                title: 'Mechanic',
                iconPath: 'assets/icons/mechanic.png',
                onTap: () => _navigateToServicesByCategory(context, 'Mechanic'),
              ),
              CategoryItem(
                title: 'Cleaner',
                iconPath: 'assets/icons/cleaner.png',
                onTap: () => _navigateToServicesByCategory(context, 'Cleaner'),
              ),
              CategoryItem(
                title: 'AC Repair',
                iconPath: 'assets/icons/air.jpg',
                onTap: () => _navigateToServicesByCategory(context, 'AC Repair'),
              ),
              CategoryItem(
                title: 'Drain Unclogging',
                iconPath: 'assets/icons/pipe.jpg',
                onTap: () => _navigateToServicesByCategory(context, 'Drain Unclogging'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  MyBookingsScreen())
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen(
                  isGuestMode: false,
                  onLoginRequired: () {},
                )),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfileScreen()),
              );
              break;
          }
        },
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

  void _navigateToServicesByCategory(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestServiceScreen(category: category),
      ),
    );
  }
}
