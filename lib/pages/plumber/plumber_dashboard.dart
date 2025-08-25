import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/dashboard_controller.dart';
import 'package:plumber_project/pages/plumber/controllers/plumber_dashboard_controller.dart';
import 'package:plumber_project/pages/plumber/plumberrequest.dart';
import 'package:plumber_project/pages/plumber/plumber_widgets/plumber_dashboard_card.dart';
import 'package:plumber_project/pages/users/profile.dart';
import 'package:plumber_project/pages/notification.dart';

final Color darkBlue = Color(0xFF003E6B);
final Color tealBlue = Color(0xFF00A8A8);
final Color onlineColor = Color(0xFF4CAF50);
final Color offlineColor = Color(0xFFF44336);
final Color workingColor = Color(0xFFFF9800);

class PlumberDashboard extends StatelessWidget {
  final DashboardController _dashboardController = Get.find();
  final PlumberDashboardController _plumberController = Get.put(PlumberDashboardController());

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
        actions: [
          Obx(() => _buildStatusIndicator()),
        ],
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

  Widget _buildStatusIndicator() {
    return Container(
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _plumberController.isWorking.value
            ? workingColor
            : _plumberController.isOnline.value
            ? onlineColor
            : offlineColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(() => Text(
        _plumberController.isWorking.value
            ? 'Working'
            : _plumberController.isOnline.value
            ? 'Online'
            : 'Offline',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      )),
    );
  }

  final List<Widget> _pages = [
    HomeContent(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index, BuildContext context) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationsScreen()),
      );
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
  final PlumberDashboardController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Online/Offline Toggle Button
          Obx(() => _buildStatusToggleButton()),
          SizedBox(height: 20),
          Expanded(
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
                  onTap: () {
                    // Handle ongoing jobs tap
                    _controller.updateWorkingStatus(true);
                  },
                ),
                DashboardCard(
                  title: "Completed Jobs",
                  icon: Icons.check_circle,
                  gradientColors: [Color(0xFF00b09b), Color(0xFF96c93d)],
                  onTap: () {
                    // Handle completed jobs tap
                    _controller.updateWorkingStatus(false);
                  },
                ),
                DashboardCard(
                  title: "Earnings",
                  icon: Icons.attach_money,
                  gradientColors: [Color(0xFFF953C6), Color(0xFFB91D73)],
                  onTap: () {
                    // Handle earnings tap
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggleButton() {
    return GestureDetector(
      onTap: _controller.toggleOnlineStatus,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _controller.isOnline.value
                ? [offlineColor, Colors.redAccent]
                : [onlineColor, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _controller.isOnline.value
                  ? offlineColor.withOpacity(0.4)
                  : onlineColor.withOpacity(0.4),
              offset: Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Icon(
              _controller.isOnline.value ? Icons.wifi_off : Icons.wifi,
              color: Colors.white,
              size: 24,
            )),
            SizedBox(width: 10),
            Obx(() => Text(
              _controller.isOnline.value ? 'Go Offline' : 'Go Online',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )),
            Obx(() => _controller.isLoading.value
                ? Padding(
              padding: EdgeInsets.only(left: 10),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            )
                : SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}