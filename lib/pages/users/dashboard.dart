import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plumber_project/pages/users/controllers/user_dashboard_controller.dart';
import 'package:plumber_project/pages/users/widgets/appointment_banner.dart';
import 'package:plumber_project/pages/users/widgets/welcome_header.dart';
import 'package:plumber_project/pages/users/widgets/search_widget.dart';


import '../../widgets/service_card.dart';
import 'appointments_screen.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf8f9fa),
      appBar: _buildAppBar(),
      body: _buildHomeScreen(context),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          // Logo and brand
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "SkillLink",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Spacer(),

          // Service selection button
          Obx(() => Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.home_repair_service, color: Color(0xFF667eea), size: 24),
                  onPressed: () => controller.showServiceSelectionDialog(Get.context!),
                  tooltip: 'Select Service',
                ),
              ),
              if (controller.hasPendingAppointments.value)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          )),

          SizedBox(width: 8),

          // Appointments button
          Obx(() => Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.calendar_today, color: Color(0xFF667eea), size: 22),
                  onPressed: () {
                    Get.to(() => UserAppointmentsScreen());
                  },
                  tooltip: 'My Appointments',
                ),
              ),
              if (controller.hasPendingAppointments.value)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    return Column(
      children: [
        // Welcome Header
        WelcomeHeader(controller: controller),

        // Appointment Banner
        AppointmentBanner(controller: controller),

        // Search Widget
        SearchWidget(controller: controller),

        // Services List
        Expanded(
          child: Obx(() => ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 20),
            itemCount: controller.filteredServices.length,
            itemBuilder: (context, index) {
              final service = controller.filteredServices[index];
              return ServiceCard(
                service: service,
                onTap: () => controller.onServiceCardClicked(service["title"], context),
                pendingServices: controller.pendingServices,
              );
            },
          )),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() => BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: controller.selectedIndex.value,
        selectedItemColor: Color(0xFF667eea),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        onTap: (index) => controller.onTabSelected(index, Get.context!),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            activeIcon: Icon(Icons.emergency_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      )),
    );
  }
}