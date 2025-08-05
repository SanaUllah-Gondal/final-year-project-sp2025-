// lib/pages/plumber/plumber_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/dashboard_controller.dart';
import 'package:plumber_project/pages/emergency.dart';
import 'package:plumber_project/pages/plumber/plumberrequest.dart';
import 'package:plumber_project/pages/plumber/plumber_dashboard_card.dart';
import 'package:plumber_project/pages/users/profile.dart';
import 'package:plumber_project/pages/notification.dart';

final Color darkBlue = Color(0xFF003E6B);
final Color tealBlue = Color(0xFF00A8A8);

class PlumberDashboard extends StatelessWidget {
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
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() => _pages[_dashboardController.selectedIndex.value]),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex: _dashboardController.selectedIndex.value,
          onTap: (index) => _onItemTapped(index, context),
          selectedItemColor: Colors.yellow,
          unselectedItemColor: Colors.white,
          backgroundColor: tealBlue,
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
    HomeContent(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index, BuildContext context) {
    if (index == 1) {
      if (_dashboardController.userRole.value == 'plumber' ||
          _dashboardController.userRole.value == 'electrician') {
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

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          DashboardCard(
            title: "New Requests",
            icon: Icons.assignment,
            gradientColors: [Color(0xFFF7971E), Color(0xFFFFD200)],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppointmentList()),
              );
            },
          ),
          DashboardCard(
            title: "Ongoing Jobs",
            icon: Icons.work,
            gradientColors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
          ),
          DashboardCard(
            title: "Completed Jobs",
            icon: Icons.check_circle,
            gradientColors: [Color(0xFF00b09b), Color(0xFF96c93d)],
          ),
          DashboardCard(
            title: "Earnings",
            icon: Icons.attach_money,
            gradientColors: [Color(0xFFF953C6), Color(0xFFB91D73)],
          ),
        ],
      ),
    );
  }
}