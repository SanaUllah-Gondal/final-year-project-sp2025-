import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plumber_project/pages/users/controllers/user_dashboard_controller.dart';

import 'appointments_screen.dart';

final Color darkBlue = Color(0xFF003E6B);
final Color tealBlue = Color(0xFF00A8A8);

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: tealBlue,
        title: Row(
          children: [
            // Service selection button with red dot indicator
            Obx(() => Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.room_service, color: Colors.black, size: 28),
                  onPressed: () => controller.showServiceSelectionDialog(context),
                  tooltip: 'Select Service Type',
                ),
                if (controller.hasPendingAppointments.value)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            )),
            SizedBox(width: 8),
            Text(
              "Skill-Link",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Spacer(),
            // Calendar icon with red dot indicator
            Obx(() => Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserAppointmentsScreen()),
                    );
                  },
                  tooltip: 'My Appointments',
                ),
                if (controller.hasPendingAppointments.value)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            )),
            Spacer(),
            // Location display
            Obx(() => controller.isLoadingLocation.value
                ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : IconButton(
              icon: Icon(Icons.location_on, color: Colors.white),
              onPressed: controller.refreshLocation,
              tooltip: controller.userLocation.value,
            )),
          ],
        ),
        elevation: 0,
        actions: [
          // More options with red dot indicator
          Obx(() => Stack(
            children: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'booking-request') {
                    Get.to(() => UserAppointmentsScreen());
                  } else if (value == 'refresh-appointments') {
                    controller.refreshAppointmentStatus();
                    Get.snackbar(
                      'Refreshed',
                      'Appointment status updated',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'booking-request',
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Icon(Icons.request_page, color: Colors.black),
                            if (controller.hasPendingAppointments.value)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 8,
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: 8),
                        Text('Booking Request'),
                        if (controller.hasPendingAppointments.value)
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text('• Pending', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'refresh-appointments',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Refresh Status'),
                      ],
                    ),
                  ),
                ],
              ),
              if (controller.hasPendingAppointments.value)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
            ],
          )),
        ],
      ),
      body: _buildHomeScreen(context),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          backgroundColor: Colors.blue,
          currentIndex: controller.selectedIndex.value,
          selectedItemColor: Colors.yellow,
          unselectedItemColor: Colors.white,
          onTap: (index) => controller.onTabSelected(index, context),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency, color: Colors.red),
              label: 'Emergency',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
            children: [
              // Pending appointments banner
              Obx(() => controller.hasPendingAppointments.value
                  ? Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have pending appointments. Please check your appointments screen.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserAppointmentsScreen()),
                        );
                      },
                      child: Text(
                        'View',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : SizedBox.shrink()),

              Obx(() => Align(
                alignment: Alignment.centerRight,
                child: controller.showSearchBar.value
                    ? AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(
                    controller: controller.searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search services...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: controller.toggleSearchBar,
                      ),
                    ),
                    onChanged: controller.filterServices,
                  ),
                )
                    : IconButton(
                  icon: Icon(Icons.search, color: Colors.cyan),
                  onPressed: controller.toggleSearchBar,
                  tooltip: 'Search Services',
                ),
              )),
              SizedBox(height: 20),
              // Service selection prompt
              Card(
                color: tealBlue.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Find Service Providers Near You',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the service icon in the app bar to select a service type and see nearby providers on the map',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Obx(() => controller.hasPendingAppointments.value
                          ? Text(
                        '⚠ You have ongoing appointments. Please complete them before booking new services.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                          : SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Obx(() => ListView.builder(
                  itemCount: controller.filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = controller.filteredServices[index];
                    String imagePath;

                    switch (service["type"]) {
                      case "plumber":
                        imagePath = "assets/images/pipe_background.jpeg";
                        break;
                      case "electrician":
                        imagePath = "assets/images/electric_background.jpeg";
                        break;
                      case "cleaner":
                        imagePath = "assets/images/cleaner_background.jpeg";
                        break;
                      default:
                        imagePath = "assets/images/default_service.jpeg";
                    }

                    return GestureDetector(
                      onTap: () => controller.onServiceCardClicked(service["title"], context),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            )
                          ],
                          image: DecorationImage(
                            image: AssetImage(imagePath),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            children: [
                              Icon(
                                service["icon"],
                                size: 40,
                                color: Colors.yellow,
                              ),
                              SizedBox(width: 20),
                              Text(
                                service["title"],
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                      color: Colors.black,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )),
              ),
            ],
        ),
        );
    }
}