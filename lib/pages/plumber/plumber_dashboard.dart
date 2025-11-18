import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/dashboard_controller.dart';
import 'package:plumber_project/pages/chat_list.dart';
import 'package:plumber_project/pages/users/profile.dart';
import 'package:plumber_project/pages/notification.dart';
import 'package:plumber_project/pages/plumber/plumber_appointment_list.dart';
import 'controllers/plumber_dashboard_controller.dart';
import 'plumber_widgets/plumber_dashboard_card.dart';

// Color Constants
final Color darkBlue = Color(0xFF003E6B);
final Color tealColor = Color(0xFF008080);
final Color onlineColor = Color(0xFF4CAF50);
final Color offlineColor = Color(0xFFF44336);
final Color workingColor = Color(0xFFFF9800);
final Color accentYellow = Color(0xFFFFD700);
final Color verifiedColor = Color(0xFF4CAF50); // Green for verified status
final Color unverifiedColor = Color(0xFFFF9800); // Orange for unverified

class PlumberDashboard extends StatelessWidget {
  final DashboardController _dashboardController = Get.find();
  final PlumberDashboardController _plumberController = Get.find();

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
          SizedBox(width: 8),
          Obx(() => _buildFaceVerificationIndicator()),
          SizedBox(width: 8),
          // Refresh button for manual check
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _plumberController.manuallyCheckRequests,
            tooltip: 'Check for new requests',
          ),
        ],
      ),
      body: Obx(() => _pages[_dashboardController.selectedIndex.value]),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      margin: EdgeInsets.only(right: 0),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _plumberController.isWorking.value
            ? workingColor
            : _plumberController.isOnline.value
            ? onlineColor
            : offlineColor,
        borderRadius: BorderRadius.circular(16),
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
            _plumberController.isWorking.value
                ? Icons.work
                : _plumberController.isOnline.value
                ? Icons.wifi
                : Icons.wifi_off,
            size: 14,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            _plumberController.isWorking.value
                ? 'Working'
                : _plumberController.isOnline.value
                ? 'Online'
                : 'Offline',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceVerificationIndicator() {
    return GestureDetector(
      onTap: () {
        if (!_plumberController.isFaceVerified.value) {
          Get.defaultDialog(
            title: 'Identity Verification Required',
            content: Text('You need to verify your identity to go online and receive job requests.'),
            textConfirm: 'Verify Now',
            textCancel: 'Later',
            onConfirm: () {
              Get.back();
              _plumberController.verifyUserIdentity();
            },
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _plumberController.isFaceVerified.value
              ? verifiedColor
              : unverifiedColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _plumberController.isFaceVerified.value
                  ? Icons.verified_user
                  : Icons.face_unlock_outlined,
              size: 12,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              _plumberController.isFaceVerified.value
                  ? 'Verified'
                  : 'Verify',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
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
              icon: Icon(Icons.chat),
              activeIcon: Icon(Icons.chat),
              label: 'Chat',
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
    PlumberHomeContent(),
    ChatListScreen(), // Changed from NotificationsScreen to ChatListScreen
    ProfileScreen(),
  ];

  void _onItemTapped(int index, BuildContext context) {
    _dashboardController.updateTabIndex(index);
  }
}

class PlumberHomeContent extends StatelessWidget {
  final PlumberDashboardController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Face Verification Status - ADD THIS
          Obx(() => _buildFaceVerificationBanner()),
          SizedBox(height: 12),

          // Online/Offline Toggle Button
          Obx(() => _buildStatusToggleButton()),
          SizedBox(height: 16),

          // Last checked time
          Obx(() => _buildLastCheckedTime()),
          SizedBox(height: 8),

          // Dashboard Cards Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _controller.refreshData();
              },
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
                padding: EdgeInsets.zero,
                children: [
                  Obx(() => PlumberDashboardCard(
                    title: "New Requests",
                    icon: Icons.plumbing,
                    gradientColors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlumberAppointmentList()),
                      );
                    },
                    showBadge: _controller.hasPendingRequests.value,
                    badgeCount: _controller.pendingRequestCount.value,
                  )),
                  PlumberDashboardCard(
                    title: "Ongoing Jobs",
                    icon: Icons.work,
                    gradientColors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
                    onTap: () {
                      _controller.updateWorkingStatus(true);
                    },
                  ),
                  PlumberDashboardCard(
                    title: "Completed Jobs",
                    icon: Icons.check_circle,
                    gradientColors: [Color(0xFF76B852), Color(0xFF8DC26F)],
                    onTap: () {
                      _controller.updateWorkingStatus(false);
                    },
                  ),
                  PlumberDashboardCard(
                    title: "Earnings",
                    icon: Icons.attach_money,
                    gradientColors: [Color(0xFFDA22FF), Color(0xFF9733EE)],
                    onTap: () {
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
          ),
        ],
      ),
    );
  }

  // ADD THIS: Face verification banner
  Widget _buildFaceVerificationBanner() {
    if (_controller.isFaceVerified.value) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: verifiedColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: verifiedColor),
        ),
        child: Row(
          children: [
            Icon(Icons.verified_user, color: verifiedColor, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identity Verified',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'You can go online and receive job requests',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _controller.verifyUserIdentity(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: unverifiedColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: unverifiedColor),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: unverifiedColor, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify Your Identity',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Tap to verify your identity and go online',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: unverifiedColor, size: 16),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLastCheckedTime() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            color: Colors.white70,
            size: 14,
          ),
          SizedBox(width: 8),
          Text(
            'Last checked: ${_formatTime(_controller.lastCheckedTime.value)}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildStatusToggleButton() {
    return GestureDetector(
      onTap: () {
        if (!_controller.isFaceVerified.value && !_controller.isOnline.value) {
          Get.snackbar(
            'Verification Required',
            'Please verify your identity first to go online',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
        _controller.toggleOnlineStatus();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _controller.isOnline.value
                ? [offlineColor, Colors.redAccent]
                : _controller.isFaceVerified.value
                ? [onlineColor, Colors.greenAccent]
                : [Colors.grey, Colors.grey.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _controller.isOnline.value
                  ? offlineColor.withOpacity(0.4)
                  : _controller.isFaceVerified.value
                  ? onlineColor.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.4),
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
                _controller.isOnline.value
                    ? Icons.wifi_off
                    : _controller.isFaceVerified.value
                    ? Icons.wifi
                    : Icons.lock,
                key: ValueKey('${_controller.isOnline.value}_${_controller.isFaceVerified.value}'),
                color: Colors.white,
                size: 24,
              ),
            )),
            SizedBox(width: 12),
            Obx(() => Text(
              _controller.isOnline.value
                  ? 'Go Offline'
                  : _controller.isFaceVerified.value
                  ? 'Go Online'
                  : 'Verify to Go Online',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            )),
            Obx(() => _controller.isLoading.value || _controller.isVerifyingFace.value
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