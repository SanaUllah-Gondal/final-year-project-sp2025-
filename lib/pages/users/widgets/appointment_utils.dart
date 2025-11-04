import 'package:flutter/material.dart';
import 'package:plumber_project/widgets/app_color.dart';

class AppointmentUtils {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warningColor;
      case 'confirmed':
        return AppColors.successColor;
      case 'completed':
        return AppColors.infoColor;
      case 'cancelled':
        return AppColors.errorColor;
      default:
        return AppColors.greyColor;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  static Color getServiceColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'cleaner':
        return Colors.blue;
      case 'plumber':
        return Colors.orange;
      case 'electrician':
        return Colors.purple;
      default:
        return AppColors.primaryColor;
    }
  }

  static IconData getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'cleaner':
        return Icons.cleaning_services;
      case 'plumber':
        return Icons.plumbing;
      case 'electrician':
        return Icons.electrical_services;
      default:
        return Icons.home_repair_service;
    }
  }
}