import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/dashboard_controller.dart';
import 'package:plumber_project/pages/users/profile.dart';
import 'package:plumber_project/pages/notification.dart';


import 'controllers/electrician_dashboard_controller.dart';
import 'electrician_appointment_list.dart';
import 'electrition_widgets/electrition_cards.dart';

// Color Constants
final Color darkBlue = Color(0xFF003E6B);
final Color tealColor = Color(0xFF008080);
final Color onlineColor = Color(0xFF4CAF50);
final Color offlineColor = Color(0xFFF44336);
final Color workingColor = Color(0xFFFF9800);
final Color accentYellow = Color(0xFFFFD700);

class ElectricianDashboard extends StatelessWidget {
  final DashboardController _dashboardController = Get.find();
  final ElectricianDashboardController _electricianController = Get.find();

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
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          Obx(() => _buildStatusIndicator()),
          SizedBox(width: 16),
        ],
      ),
      body: Obx(() => _pages[_dashboardController.selectedIndex.value]),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _electricianController.isWorking.value
            ? workingColor
            : _electricianController.isOnline.value
            ? onlineColor
            : offlineColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _electricianController.isWorking.value
                ? Icons.work
                : _electricianController.isOnline.value
                ? Icons.wifi
                : Icons.wifi_off,
            size: 16,
            color: Colors.white,
          ),
          SizedBox(width: 6),
          Text(
            _electricianController.isWorking.value
                ? 'Working'
                : _electricianController.isOnline.value
                ? 'Online'
                : 'Offline',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
            () => BottomNavigationBar(
          currentIndex: _dashboardController.selectedIndex.value,
          onTap: (index) => _onItemTapped(index, context),
          selectedItemColor: accentYellow,
          unselectedItemColor: Colors.white70,
          backgroundColor: tealColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  final List<Widget> _pages = [
    ElectricianHomeContent(),
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

class ElectricianHomeContent extends StatelessWidget {
  final ElectricianDashboardController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Online/Offline Toggle Button
          Obx(() => _buildStatusToggleButton()),
          SizedBox(height: 24),

          // Dashboard Cards Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
              padding: EdgeInsets.zero,
              children: [
                Obx(() => ElectricianDashboardCard(
                  title: "New Requests",
                  icon: Icons.electrical_services,
                  gradientColors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ElectricianAppointmentList()),
                    );
                  },
                  showBadge: _controller.hasPendingRequests.value,
                  badgeCount: _controller.pendingRequestCount.value,
                )),
                ElectricianDashboardCard(
                  title: "Ongoing Jobs",
                  icon: Icons.work,
                  gradientColors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
                  onTap: () {
                    _controller.updateWorkingStatus(true);
                  },
                ),
                ElectricianDashboardCard(
                  title: "Completed Jobs",
                  icon: Icons.check_circle,
                  gradientColors: [Color(0xFF76B852), Color(0xFF8DC26F)],
                  onTap: () {
                    _controller.updateWorkingStatus(false);
                  },
                ),
                ElectricianDashboardCard(
                  title: "Earnings",
                  icon: Icons.attach_money,
                  gradientColors: [Color(0xFFDA22FF), Color(0xFF9733EE)],
                  onTap: () {
                    // Handle earnings tap
                    Get.snackbar(
                      'Coming Soon',
                      'Earnings feature will be available soon!',
                      snackPosition: SnackPosition.BOTTOM,
                    );
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
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
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
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Icon(
                _controller.isOnline.value ? Icons.wifi_off : Icons.wifi,
                key: ValueKey(_controller.isOnline.value),
                color: Colors.white,
                size: 24,
              ),
            )),
            SizedBox(width: 12),
            Obx(() => Text(
              _controller.isOnline.value ? 'Go Offline' : 'Go Online',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            )),
            Obx(() => _controller.isLoading.value
                ? Padding(
              padding: EdgeInsets.only(left: 12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
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