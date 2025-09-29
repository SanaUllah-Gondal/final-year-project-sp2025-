import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/widgets/app_color.dart';

import '../controllers/user_appointment_controller.dart';

class AppointmentTabs extends StatelessWidget {
  final UserAppointmentsController controller;

  const AppointmentTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(controller.tabs.length, (index) {
            final isSelected = controller.selectedTab.value == index;

            return InkWell(
              onTap: () {
                controller.selectedTab.value = index;
                controller.filterAppointments();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.primaryColor : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  controller.tabs[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryColor : AppColors.greyColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),
        ),
      )),
    );
  }
}