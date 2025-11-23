import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/user_appointment_controller.dart';
import 'appointment_detail_ sheet.dart';
import 'appointment_utils.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final UserAppointmentsController controller = Get.find();

  AppointmentCard({super.key, required this.appointment});

  // Helper method to safely convert dynamic maps to String keys
  Map<String, dynamic> _convertDynamicMap(Map<dynamic, dynamic> dynamicMap) {
    final Map<String, dynamic> convertedMap = {};
    dynamicMap.forEach((key, value) {
      convertedMap[key.toString()] = value;
    });
    return convertedMap;
  }

  // Safe provider data extraction
  Map<String, dynamic> get _safeProviderData {
    final provider = appointment['provider'];
    if (provider == null) return {};

    if (provider is Map<dynamic, dynamic>) {
      return _convertDynamicMap(provider);
    } else if (provider is Map<String, dynamic>) {
      return provider;
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final appointmentDate = DateTime.parse(appointment['appointment_date'].toString());
    final formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDate);
    final formattedTime = DateFormat('hh:mm a').format(appointmentDate);
    final status = appointment['status'].toString();

    // Safely extract provider data using the helper method
    final providerData = _safeProviderData;
    final providerName = providerData['name']?.toString() ?? 'Unknown Provider';
    final providerRole = providerData['role']?.toString() ?? '';
    final providerEmail = providerData['email']?.toString() ?? '';
    final providerPhone = providerData['phone_number']?.toString() ?? providerEmail;
    final providerImage = providerData['profile_image']?.toString() ?? providerData['profileImage']?.toString();

    final price = controller.formatPrice(appointment['price']);
    final serviceType = _getServiceType(providerRole, appointment['service_type']?.toString());

    // Check if user has already rated this appointment
    final appointmentId = appointment['id'].toString();
    final hasUserRated = controller.hasUserRated(appointmentId);
    final hasUserReviewed = controller.hasUserReviewed(appointmentId);
    final ratingData = controller.getRating(appointmentId);
    final reviewData = controller.getReview(appointmentId);
    final existingRating = ratingData?['rating']?.toDouble() ?? 0.0;
    final existingReview = reviewData?['review']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
                _buildHeader(providerImage, providerName, providerPhone, status, serviceType),
                const SizedBox(height: 20),
                const Divider(),
                _buildDetail(icon: Icons.calendar_today, text: formattedDate),
                _buildDetail(icon: Icons.access_time, text: formattedTime),
                _buildDetail(icon: Icons.attach_money, text: price),
                const SizedBox(height: 10),

                // ⭐ RATING SECTION - Only show for completed appointments
                if (status == "completed")
                  _buildRatingSection(hasUserRated, hasUserReviewed, existingRating, existingReview),

                // ⭐ RATE NOW BUTTON - Only show if not already rated
                if (status == "completed" && !hasUserRated)
                  _buildRateNowButton(appointmentId, providerData, serviceType),

                if (status == "pending") _buildCancelButton(serviceType),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic image, String name, String phone, String status, String serviceType) {
    return Row(
      children: [
        _buildAvatar(image),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(serviceType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text("with $name", style: const TextStyle(color: Colors.grey)),
              Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppointmentUtils.getStatusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(status.toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  color: AppointmentUtils.getStatusColor(status),
                  fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildDetail({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildRatingSection(bool hasRated, bool hasReviewed, double rating, String review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        // Show "Already Rated" message if user has rated
        if (hasRated)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text("You've already rated this service",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
              ],
            ),
          ),

        // Show rating stars if available
        if (rating > 0) ...[
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
                  (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 22,
              ),
            ),
          ),
        ],

        // Show review if available
        if (review.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(review, style: const TextStyle(fontSize: 13)),
          ),
        ]
      ],
    );
  }

  Widget _buildRateNowButton(String appointmentId, Map<String, dynamic> providerData, String serviceType) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.star, size: 18),
        label: const Text("Rate Provider"),
        onPressed: () => _openRatingSheet(appointmentId, providerData, serviceType),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildCancelButton(String providerType) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: ElevatedButton(
        onPressed: () => _showCancelConfirmation(providerType),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Cancel Appointment", style: TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildAvatar(dynamic profileImage) {
    final String? imageString = profileImage?.toString();

    if (imageString != null && imageString.startsWith("http")) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageString,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          errorWidget: (context, url, error) => const CircleAvatar(
            radius: 25,
            child: Icon(Icons.person),
          ),
        ),
      );
    }
    return const CircleAvatar(radius: 25, child: Icon(Icons.person));
  }

  String _getServiceType(String? providerRole, String? apiServiceType) {
    if (providerRole != null && providerRole != "unknown" && providerRole.isNotEmpty) {
      return providerRole[0].toUpperCase() + providerRole.substring(1);
    }
    return apiServiceType ?? "Service";
  }

  void _openRatingSheet(String appointmentId, Map<String, dynamic> providerData, String serviceType) {
    // Check again if user has already rated (double validation)
    if (controller.hasUserRated(appointmentId)) {
      Get.snackbar(
        'Already Rated',
        'You have already rated this appointment',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    double tempRating = 5;
    TextEditingController reviewCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Rate Provider",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Stars
            StatefulBuilder(
              builder: (context, setState) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (i) => IconButton(
                    icon: Icon(i < tempRating ? Icons.star : Icons.star_border,
                        color: Colors.amber, size: 30),
                    onPressed: () => setState(() => tempRating = (i + 1).toDouble()),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),
            TextField(
              controller: reviewCtrl,
              decoration: const InputDecoration(
                labelText: "Write a review...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                if (tempRating == 0) {
                  Get.snackbar('Error', 'Please select a rating',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }

                controller.submitRatingReview(
                  appointmentId: appointmentId,
                  providerId: providerData['id']?.toString() ?? providerData['email'] ?? '',
                  providerName: providerData['name']?.toString() ?? 'Provider',
                  serviceType: providerData['role']?.toString() ?? serviceType.toLowerCase(),
                  rating: tempRating,
                  review: reviewCtrl.text.trim(),
                );
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Submit Review", style: TextStyle(fontSize: 16)),
            )
          ],
        ),
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
              controller.cancelAppointment(appointment['id'].toString(), providerType);
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppointmentDetailsBottomSheet(appointment: appointment),
    );
  }
}