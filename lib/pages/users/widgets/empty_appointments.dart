import 'package:flutter/material.dart';
import 'package:plumber_project/widgets/app_color.dart';
import 'package:plumber_project/widgets/app_text_style.dart';

class EmptyAppointments extends StatelessWidget {
  final int selectedTab;

  const EmptyAppointments({super.key, required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    final tabNames = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];
    final currentTab = tabNames[selectedTab].toLowerCase();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today,
                size: 48,
                color: AppColors.primaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              selectedTab == 0 ? 'No Appointments' : 'No $currentTab appointments',
              style: AppTextStyles.heading6.copyWith(color: AppColors.darkColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              selectedTab == 0
                  ? 'Book services to see your appointments here'
                  : 'You don\'t have any $currentTab appointments at the moment',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.greyColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}