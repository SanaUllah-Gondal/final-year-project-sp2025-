import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/pages/users/widgets/appointment_card.dart';
import 'package:plumber_project/pages/users/widgets/appointment_tabs.dart';
import 'package:plumber_project/pages/users/widgets/empty_appointments.dart';
import 'package:plumber_project/pages/users/widgets/loading_shimmer_list.dart';

import 'package:plumber_project/widgets/app_color.dart';
import 'package:plumber_project/widgets/app_text_style.dart';

import 'controllers/user_appointment_controller.dart';

class UserAppointmentsScreen extends StatelessWidget {
  final UserAppointmentsController controller = Get.put(UserAppointmentsController());

  UserAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: AppTextStyles.heading6.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.loadUserAppointments,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          AppointmentTabs(controller: controller),

          // Appointments List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingShimmerList();
              }

              if (controller.filteredAppointments.isEmpty) {
                return EmptyAppointments(
                  selectedTab: controller.selectedTab.value,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadUserAppointments,
                backgroundColor: AppColors.primaryColor,
                color: Colors.white,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredAppointments.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final appointment = controller.filteredAppointments[index];
                    return AppointmentCard(appointment: appointment);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}