import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plumber_project/widgets/app_color.dart';
import 'package:plumber_project/widgets/app_text_style.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../controllers/user_appointment_controller.dart';
import 'appointment_detail_ sheet.dart';
import 'appointment_utils.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final UserAppointmentsController controller = Get.find();

  AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final appointmentDate = DateTime.parse(appointment['appointment_date']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDate);
    final formattedTime = DateFormat('hh:mm a').format(appointmentDate);
    final status = appointment['status'];
    final providerData = appointment['provider'] ?? {};
    final providerName = providerData['name'] ?? 'Unknown Provider';
    final serviceType = _getServiceType(providerData['role'], appointment['service_type']);
    final providerType = serviceType;
    final providerPhone = providerData['phone_number'] ?? 'Not available';
    final providerImage = providerData['profile_image'];

    final price = controller.formatPrice(appointment['price']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showAppointmentDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    _buildProviderAvatar(providerImage, providerName, serviceType),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceType,
                            style: AppTextStyles.subtitle1.copyWith(
                              fontWeight: FontWeight.w700,
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
                          const SizedBox(height: 4),
                          Text(
                            providerPhone,
                            style: AppTextStyles.caption.copyWith(
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppointmentUtils.getStatusIcon(status),
                            size: 14,
                            color: AppointmentUtils.getStatusColor(status),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppointmentUtils.getStatusColor(status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(color: AppColors.lightGrey),

                _buildDetailRow(icon: Icons.calendar_today, text: formattedDate),
                const SizedBox(height: 8),
                _buildDetailRow(icon: Icons.access_time, text: formattedTime),
                const SizedBox(height: 8),
                _buildDetailRow(
                    icon: Icons.location_on,
                    text: appointment['address'] ?? 'No address provided',
                    maxLines: 2),
                const SizedBox(height: 8),
                _buildDetailRow(
                    icon: Icons.attach_money, text: price, isBold: true),

                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppointmentUtils.getServiceColor(serviceType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppointmentUtils.getServiceIcon(serviceType),
                          size: 14,
                          color: AppointmentUtils.getServiceColor(serviceType)),
                      const SizedBox(width: 6),
                      Text(
                        serviceType.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppointmentUtils.getServiceColor(serviceType),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status-specific Actions
                if (status == 'pending') ...[
                  const SizedBox(height: 16),
                  _buildPendingActionButtons(providerType),
                ],

                if (status == 'confirmed') ...[
                  const SizedBox(height: 16),
                  _buildConfirmedActionButtons(providerType),
                ],

                if (status == 'modified') ...[
                  const SizedBox(height: 16),
                  _buildModifiedActionButtons(providerType),
                ],

                if (status == 'completed' || status == 'cancelled') ...[
                  const SizedBox(height: 16),
                  _buildFinalStatusMessage(status),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ---------- BUTTON SECTIONS ----------

  Widget _buildPendingActionButtons(String providerType) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showCancelConfirmation(providerType),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor.withOpacity(0.1),
              foregroundColor: AppColors.errorColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, size: 16),
                SizedBox(width: 6),
                Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedActionButtons(String providerType) {
    return Column(
      children: [
        _buildChatButton(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showCancelConfirmation(providerType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor.withOpacity(0.1),
                  foregroundColor: AppColors.errorColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, size: 16),
                    SizedBox(width: 6),
                    Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => ElevatedButton(
                onPressed: controller.isProcessingPayment.value
                    ? null
                    : () => _showCompleteBookingDialog(providerType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isProcessingPayment.value
                      ? AppColors.greyColor
                      : AppColors.successColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: controller.isProcessingPayment.value
                    ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 16),
                    SizedBox(width: 6),
                    Text('Complete',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModifiedActionButtons(String providerType) {
    return Column(
      children: [
        _buildChatButton(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.confirmModifiedAppointment(
                      appointment['id'].toString(), providerType);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 16),
                    SizedBox(width: 6),
                    Text('Confirm',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showCancelConfirmation(providerType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor.withOpacity(0.1),
                  foregroundColor: AppColors.errorColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, size: 16),
                    SizedBox(width: 6),
                    Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinalStatusMessage(String status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status == 'completed'
            ? AppColors.successColor.withOpacity(0.1)
            : AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            status == 'completed' ? Icons.verified : Icons.cancel,
            color:
            status == 'completed' ? AppColors.successColor : AppColors.errorColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            status == 'completed'
                ? 'This appointment has been completed'
                : 'This appointment was cancelled',
            style: AppTextStyles.bodyMedium.copyWith(
              color:
              status == 'completed' ? AppColors.successColor : AppColors.errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------- REUSABLE WIDGETS ----------
  Widget _buildChatButton() {
    final providerData = appointment['provider'] ?? {};
    final providerEmail = providerData['email'] ?? '';
    final providerName = providerData['name'] ?? 'Unknown';
    final providerImage = providerData['profile_image'];

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (providerEmail.isNotEmpty) {
            controller.openOrCreateChat(
              providerEmail: providerEmail,
              providerName: providerName,
              providerImage: providerImage,
            );
          } else {
            Get.snackbar('Error', 'Provider email not found',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.redAccent,
                colorText: Colors.white);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
          foregroundColor: AppColors.primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 16),
            SizedBox(width: 6),
            Text('Chat with Provider',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  /// ---------- HELPERS ----------
  String _getServiceType(String? providerRole, String? apiServiceType) {
    if (providerRole != null && providerRole != 'unknown') {
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: serviceColor.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: Image.memory(
                _decodeBase64Image(profileImage),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackAvatar(providerName, serviceColor),
              ),
            ),
          );
        } catch (_) {
          return _buildFallbackAvatar(providerName, serviceColor);
        }
      } else if (profileImage.startsWith('http')) {
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: serviceColor.withOpacity(0.3), width: 2),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: profileImage,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: serviceColor.withOpacity(0.1),
                child: Icon(Icons.person, color: serviceColor),
              ),
              errorWidget: (context, url, error) =>
                  _buildFallbackAvatar(providerName, serviceColor),
            ),
          ),
        );
      }
    }

    return _buildFallbackAvatar(providerName, serviceColor);
  }

  Widget _buildFallbackAvatar(String providerName, Color serviceColor) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: serviceColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: serviceColor.withOpacity(0.3), width: 2),
      ),
      child: Icon(Icons.person, color: serviceColor, size: 24),
    );
  }

  Uint8List _decodeBase64Image(String base64String) {
    final base64Data =
    base64String.startsWith('data:image/') ? base64String.split(',').last : base64String;
    return base64.decode(base64Data);
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    bool isBold = false,
    int maxLines = 1,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkColor,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showAppointmentDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AppointmentDetailsBottomSheet(appointment: appointment),
    );
  }

  void _showCancelConfirmation(String providerType) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
            'Are you sure you want to cancel this appointment? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No, Keep It')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.cancelAppointment(
                appointment['id'].toString(),
                providerType,
              );
            },
            child: Text('Yes, Cancel', style: TextStyle(color: AppColors.errorColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _showCompleteBookingDialog(String providerType) async {
    // Calculate booking amount
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

    // Show payment method selection
    final paymentMethod = await _showPaymentMethodDialog(amount);
    if (paymentMethod == null) return;

    // Show confirmation dialog
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
            onPressed: () => Get.back(result: false),
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
      await controller.completeBooking(
        appointment['id'].toString(),
        providerType,
        paymentMethod,
        amount,
      );
    }
  }
  Future<String?> _showPaymentMethodDialog(double amount) async {
    String? selectedMethod;

    await Get.dialog(
      AlertDialog(
        title: const Text('Select Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Cash'),
              value: 'cash',
              groupValue: selectedMethod,
              onChanged: (value) {
                selectedMethod = value;
                Get.back();
              },
            ),
            RadioListTile<String>(
              title: const Text('Online Payment'),
              value: 'online',
              groupValue: selectedMethod,
              onChanged: (value) {
                selectedMethod = value;
                Get.back();
              },
            ),
          ],
        ),
      ),
    );

    return selectedMethod;
  }
}
