import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/pages/users/controllers/user_dashboard_controller.dart';

import '../appointments_screen.dart';

class AppointmentBanner extends StatelessWidget {
  final HomeController controller;

  const AppointmentBanner({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.hasPendingAppointments.value
        ? Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.schedule, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Service Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Obx(() {
                  if (controller.pendingServices.isNotEmpty) {
                    final servicesText = controller.pendingServices
                        .map((service) => service.capitalizeFirst)
                        .join(', ');
                    final totalCount = controller.ongoingAppointments.length;

                    return Text(
                      'You have $totalCount pending request${totalCount > 1 ? 's' : ''} for $servicesText. Tap to manage.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                    );
                  }
                  return Text(
                    'You have active service requests. Tap to manage.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onPressed: () {
                Get.to(() => UserAppointmentsScreen());
              },
            ),
          ),
        ],
      ),
    )
        : SizedBox.shrink());
  }
}