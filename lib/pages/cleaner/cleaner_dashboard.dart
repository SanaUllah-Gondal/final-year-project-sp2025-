import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/dashboard_controller.dart';
import 'package:plumber_project/pages/emergency.dart';
import 'package:plumber_project/pages/users/profile.dart';
import 'package:plumber_project/pages/notification.dart';

import 'cleaner_appointment.dart';
import 'cleaner_widgets/cleaner_card.dart';

final Color darkBlue = Color(0xFF003E6B);
final Color tealColor = Color(0xFF008080); // Cleaner-specific teal color

class CleanerDashboard extends StatelessWidget {
  final DashboardController _dashboardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text(
          'Skill-Link',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white, // Changed to white for better visibility
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() => _pages[_dashboardController.selectedIndex.value]),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex: _dashboardController.selectedIndex.value,
          onTap: (index) => _onItemTapped(index, context),
          selectedItemColor: Colors.yellow,
          unselectedItemColor: Colors.white,
          backgroundColor: tealColor, // Using cleaner-specific teal color
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  final List<Widget> _pages = [
    CleanerHomeContent(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index, BuildContext context) {
    if (index == 1) {
      if (_dashboardController.userRole.value == 'cleaner') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmergencyScreen()),
        );
      }
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } else {
      _dashboardController.updateTabIndex(index);
    }
  }
}

class CleanerHomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          CleanerDashboardCard(
            title: "New Requests",
            icon: Icons.cleaning_services, // Cleaner-specific icon
            gradientColors: [Color(0xFF00B4DB), Color(0xFF0083B0)], // Ocean blue gradient
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CleanerAppointmentList()),
              );
            },
          ),
          CleanerDashboardCard(
            title: "Ongoing Jobs",
            icon: Icons.work,
            gradientColors: [Color(0xFF56CCF2), Color(0xFF2F80ED)], // Light blue gradient
            onTap: () {
              // Navigate to ongoing jobs
            },
          ),
          CleanerDashboardCard(
            title: "Completed Jobs",
            icon: Icons.check_circle,
            gradientColors: [Color(0xFF76B852), Color(0xFF8DC26F)], // Green gradient
            onTap: () {
              // Navigate to completed jobs
            },
          ),
          CleanerDashboardCard(
            title: "Earnings",
            icon: Icons.attach_money,
            gradientColors: [Color(0xFFDA22FF), Color(0xFF9733EE)], // Purple gradient
            onTap: () {
              // Navigate to earnings
            },
          ),
        ],
      ),
    );
  }
}