import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plumber_project/widgets/app_color.dart';
import 'package:plumber_project/widgets/app_text_style.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../controllers/user_appointment_controller.dart';
import 'appointment_utils.dart';

class AppointmentDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final UserAppointmentsController controller = Get.find();

  AppointmentDetailsBottomSheet({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final appointmentDate = DateTime.parse(appointment['appointment_date']);
    final formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(appointmentDate);
    final formattedTime = DateFormat('hh:mm a').format(appointmentDate);
    final status = appointment['status'];

    final providerData = appointment['provider'] ?? {};
    final providerName = providerData['name'] ?? 'Unknown Provider';
    final serviceType = _getServiceType(providerData['role'], appointment['service_type']);
    final providerPhone = providerData['phone_number'] ?? 'Not available';
    final providerEmail = providerData['email'] ?? 'Not available';
    final providerImage = providerData['profile_image'];

    // Use controller's safe price formatting
    final price = controller.formatPrice(appointment['price']);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                _buildProviderAvatar(providerImage, providerName, serviceType),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceType,
                        style: AppTextStyles.heading6.copyWith(
                          color: AppColors.darkColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'with $providerName',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppointmentUtils.getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppointmentUtils.getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppointmentUtils.getStatusColor(status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appointment Details Section
                  _buildSectionTitle('Appointment Details'),
                  const SizedBox(height: 16),
                  _buildDetailItem('Date', formattedDate),
                  _buildDetailItem('Time', formattedTime),
                  _buildDetailItem('Address', appointment['address'] ?? 'Not specified'),
                  _buildDetailItem('Price', price),
                  _buildDetailItem(
                    'Status',
                    status.toUpperCase(),
                    valueColor: AppointmentUtils.getStatusColor(status),
                  ),
                  _buildDetailItem(
                    'Service Type',
                    serviceType,
                    valueColor: AppointmentUtils.getServiceColor(serviceType),
                  ),

                  const SizedBox(height: 24),

                  // Provider Contact Section
                  _buildSectionTitle('Provider Contact'),
                  const SizedBox(height: 16),
                  _buildDetailItem('Name', providerName),
                  _buildDetailItem('Phone', providerPhone),
                  _buildDetailItem('Email', providerEmail),

                  // Chat Button (for confirmed appointments)
                  if (status == 'confirmed') ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close bottom sheet
                          controller.navigateToChat(appointment);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Chat with Provider',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Problem Description
                  if (appointment['description'] != null) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Problem Description'),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Text(
                        appointment['description'],
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],

                  // Problem Image
                  if (appointment['problem_image_url'] != null) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Problem Image'),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.lightBackground,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          appointment['problem_image_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, color: AppColors.greyColor),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Action Buttons for confirmed appointments
          if (status == 'confirmed') ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelConfirmation(serviceType),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorColor,
                        side: BorderSide(color: AppColors.errorColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel Appointment'),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Complete Button
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isProcessingPayment.value
                          ? null
                          : () => _showCompleteBookingDialog(serviceType),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isProcessingPayment.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text('Complete Booking'),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getServiceType(String? providerRole, String? apiServiceType) {
    // Use provider role first, then fallback to API service type
    if (providerRole != null && providerRole != 'unknown') {
      // Capitalize first letter
      return providerRole[0].toUpperCase() + providerRole.substring(1);
    }

    if (apiServiceType != null && apiServiceType != 'Unknown') {
      return apiServiceType;
    }

    return 'Unknown Service';
  }

  Widget _buildProviderAvatar(String? profileImage, String providerName, String serviceType) {
    final serviceColor = AppointmentUtils.getServiceColor(serviceType);

    if (profileImage != null && profileImage.isNotEmpty) {
      if (profileImage.startsWith('data:image/') || profileImage.length > 100) {
        try {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: serviceColor.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: Image.memory(
                _decodeBase64Image(profileImage),
                fit: BoxFit.cover,
              ),
            ),
          );
        } catch (e) {
          return _buildFallbackAvatar(providerName, serviceColor, 60);
        }
      } else if (profileImage.startsWith('http')) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: serviceColor.withOpacity(0.3), width: 2),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: profileImage,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildFallbackAvatar(providerName, serviceColor, 60),
              errorWidget: (context, url, error) => _buildFallbackAvatar(providerName, serviceColor, 60),
            ),
          ),
        );
      }
    }

    return _buildFallbackAvatar(providerName, serviceColor, 60);
  }

  Widget _buildFallbackAvatar(String providerName, Color serviceColor, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: serviceColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: serviceColor.withOpacity(0.3), width: 2),
      ),
      child: Icon(
        Icons.person,
        color: serviceColor,
        size: size * 0.5,
      ),
    );
  }

  Uint8List _decodeBase64Image(String base64String) {
    if (base64String.startsWith('data:image/')) {
      final base64Data = base64String.split(',').last;
      return base64.decode(base64Data);
    } else {
      return base64.decode(base64String);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subtitle1.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.darkColor,
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.greyColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? AppColors.darkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(String providerType) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Navigator.pop(Get.context!); // Close bottom sheet
              controller.cancelAppointment(
                appointment['id'].toString(),
                providerType,
              );
            },
            child: Text(
              'Yes, Cancel',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCompleteBookingDialog(String providerType) async {
    final amount = await controller.calculateBookingAmount(appointment['id'].toString());

    if (amount <= 0) {
      Get.snackbar(
        'Error',
        'Invalid booking amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    final paymentMethod = await _showPaymentMethodDialog(amount);
    if (paymentMethod == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Complete Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount: ${controller.formatPrice(amount)}'),
            Text('Payment Method: ${paymentMethod == 'online' ? 'Online Payment' : 'Cash'}'),
            const SizedBox(height: 8),
            const Text('Are you sure you want to complete this booking?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result:false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.pop(Get.context!); // Close bottom sheet
      await controller.completeBooking(
        appointment['id'].toString(),
        providerType,
        paymentMethod,
        amount,
      );
    }
  }

  Future<String?> _showPaymentMethodDialog(double amount) async {
    return await Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Payment Method',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Total Amount: ${controller.formatPrice(amount)}',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 20),

              _buildPaymentOption(
                icon: Icons.credit_card,
                title: 'Pay Online',
                subtitle: 'Secure payment with Stripe',
                value: 'online',
              ),

              const SizedBox(height: 12),

              _buildPaymentOption(
                icon: Icons.money,
                title: 'Pay with Cash',
                subtitle: 'Pay directly to the provider',
                value: 'cash',
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.back(result: value),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.greyColor),
            ],
          ),
        ),
      ),
    );
  }
}