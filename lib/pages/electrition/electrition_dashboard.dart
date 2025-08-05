// lib/pages/electrition/electrition_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/dashboard_controller.dart';
import 'package:plumber_project/pages/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/pages/emergency.dart';
import 'package:plumber_project/pages/electrition/electrition_widgets/electrition_cards.dart';
import 'package:plumber_project/pages/users/profile.dart';

class ElectricianDashboard extends StatelessWidget {
  final DashboardController _dashboardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Obx(() => Text(
                "Welcome, ${_dashboardController.userRole.value.isNotEmpty ?
                _dashboardController.userRole.value[0].toUpperCase() +
                    _dashboardController.userRole.value.substring(1) : "User"}!",
                style: TextStyle(color: Colors.white, fontSize: 20),
              )),
              decoration: BoxDecoration(color: Colors.indigo),
            ),
            ListTile(leading: Icon(Icons.dashboard), title: Text("Dashboard")),
            ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
            ListTile(leading: Icon(Icons.logout), title: Text("Logout")),
          ],
        ),
      ),
      appBar: AppBar(title: Text("Electrician Dashboard")),
      body: Obx(() => _pages[_dashboardController.selectedIndex.value]),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex: _dashboardController.selectedIndex.value,
          onTap: (index) => _onItemTapped(index, context),
          selectedItemColor: Colors.indigo,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning),
              label: 'Emergency',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  final List<Widget> _pages = [
    HomeContent(),
    EmergencyScreen(),
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
            title: "New Jobs",
            icon: Icons.assignment,
            color: Colors.orange,
          ),
          DashboardCard(
            title: "Ongoing Work",
            icon: Icons.electrical_services,
            color: Colors.blue,
          ),
          DashboardCard(
            title: "Completed Tasks",
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          DashboardCard(
            title: "Earnings",
            icon: Icons.attach_money,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}