import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../../../notification/send_notification.dart';
import '../../../services/storage_service.dart';
import '../../Apis.dart';
import '../services/appointment_service.dart';
import '../widgets/map_utils.dart';

class AppointmentBookingController extends GetxController {
  // Input parameters
  final Map<String, dynamic> provider;
  final String serviceType;
  final Position userLocation;
  final double basePrice;
  final double? distance;

  // Form controllers
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // State variables
  File? problemImage;
  String? selectedServiceType;
  String appointmentType = 'normal';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double finalPrice = 0.0;
  bool isLoading = false;
  String? errorMessage;

  // New bid-related variables
  bool isFormValid = false;
  double userBidPrice = 0.0;

  // Services
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = Get.find<StorageService>();

  AppointmentBookingController({
    required this.provider,
    required this.serviceType,
    required this.userLocation,
    required this.basePrice,
    this.distance,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    print('🎯 AppointmentBookingController initialized');
    print('💰 Base Price: Rs. $basePrice');
    print('📍 Distance: ${distance?.toStringAsFixed(1)} km');

    // Initialize user bid price with base price
    userBidPrice = basePrice;
    finalPrice = basePrice;
  }

  void _initializeData() {
    addressController.text = provider['address_name'] ?? '';
    selectedServiceType = _getDefaultServiceType();
    _checkFormValidity();
  }

  String _getDefaultServiceType() {
    switch (serviceType.toLowerCase()) {
      case 'cleaner':
        return 'regular';
      case 'plumber':
        return 'leak_fix';
      case 'electrician':
        return 'wiring';
      default:
        return 'general';
    }
  }

  // Getters
  Color get providerColor => getColorForProviderType(
    provider['provider_type']?.toString().toLowerCase() ?? serviceType.toLowerCase(),
  );

  // Form validation check
  void _checkFormValidity() {
    final isValid = selectedDate != null &&
        selectedTime != null &&
        selectedServiceType != null &&
        selectedServiceType!.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        addressController.text.isNotEmpty;

    if (isValid != isFormValid) {
      isFormValid = isValid;
      update();
    }
  }

  // Update methods that trigger form validation
  void updateAppointmentType(String type) {
    appointmentType = type;
    _calculatePrice();
    _checkFormValidity();
    update();
  }

  void updateServiceType(String? type) {
    selectedServiceType = type;
    _checkFormValidity();
    update();
  }

  void updateSelectedDateTime(DateTime dateTime) {
    selectedDate = dateTime;
    selectedTime = TimeOfDay.fromDateTime(dateTime);

    dateController.text = _formatDate(dateTime);
    timeController.text = _formatTime(dateTime);

    _checkFormValidity();
    update();
    print('📅 DateTime selected: $dateTime');
  }

  void updateDescription(String text) {
    descriptionController.text = text;
    _checkFormValidity();
    update();
  }

  void updateAddress(String text) {
    addressController.text = text;
    _checkFormValidity();
    update();
  }

  // Bid price methods
  void updateBidPrice(double newPrice) {
    userBidPrice = newPrice;
    update();
    print('💰 Bid updated: Rs. $newPrice');
  }

  void confirmBidAndBook() {
    finalPrice = userBidPrice;
    _calculatePrice();
    submitAppointment();
  }

  void _calculatePrice() {
    double calculatedPrice = userBidPrice;

    if (appointmentType == 'emergency') {
      calculatedPrice = userBidPrice * 1.2;
    }

    finalPrice = calculatedPrice;
    update();
  }

  // Get rate calculation information
  String get rateCalculationInfo {
    switch (serviceType.toLowerCase()) {
      case 'plumber':
        return 'Rs. 50 per km (Minimum: Rs. 500)';
      case 'cleaner':
        return 'Rs. 30 per km (Minimum: Rs. 300)';
      case 'electrician':
        return 'Rs. 60 per km (Minimum: Rs. 600)';
      default:
        return 'Rs. 50 per km (Minimum: Rs. 500)';
    }
  }

  // Image handling
  Future<void> pickImage() async {
    try {
      print('📸 Starting image picker...');
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('✅ Image selected: ${image.path}');
        problemImage = File(image.path);
        update();
      } else {
        print('ℹ️ No image selected');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      setError('Error selecting image: $e');
    }
  }

  void removeImage() {
    problemImage = null;
    update();
  }

  // Form validation
  bool validateForm() {
    if (selectedDate == null || selectedTime == null) {
      setError('Please select both date and time');
      return false;
    }

    if (selectedServiceType == null || selectedServiceType!.isEmpty) {
      setError('Please select a service type');
      return false;
    }

    if (descriptionController.text.isEmpty) {
      setError('Please describe the problem');
      return false;
    }

    if (addressController.text.isEmpty) {
      setError('Please enter the service address');
      return false;
    }

    clearError();
    return true;
  }

  // Main submission method
  Future<void> submitAppointment() async {
    print("🎯 Starting appointment submission process...");

    if (!validateForm()) {
      print("❌ Form validation failed");
      return;
    }

    setLoading(true);
    clearError();

    try {
      // Step 1: Get authentication token
      print("🔑 Step 1: Getting auth token...");
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication failed. Please login again.');
      }

      // Step 2: Prepare appointment data
      print("📦 Step 2: Preparing appointment data...");
      final appointmentDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final providerId = provider['provider_id'] ?? provider['id'];
      print('👤 Provider ID: $providerId, Date: $appointmentDateTime');

      // Step 3: Send API request
      print("🌐 Step 3: Sending API request...");
      final response = await _sendAppointmentRequest(
        token: token,
        providerId: providerId.toString(),
        appointmentDateTime: appointmentDateTime,
      );

      // Step 4: Process response
      print("📥 Step 4: Processing response...");
      if (response['success']) {
        print('✅ Appointment created successfully');

        // Step 5: Save to Firebase (non-blocking)
        print("🔥 Step 5: Saving to Firebase...");
        _saveToFirebase(providerId.toString(), appointmentDateTime);

        // Step 6: Send notification (non-blocking)
        print("🔔 Step 6: Sending notification...");
        _sendNotification(providerId.toString(), appointmentDateTime);

        // Step 7: Show success
        _showSuccessDialog();
      } else {
        throw Exception(response['message'] ?? 'Failed to create appointment');
      }
    } catch (e) {
      print('❌ Appointment submission failed: $e');
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // API Request
  Future<Map<String, dynamic>> _sendAppointmentRequest({
    required String token,
    required String providerId,
    required DateTime appointmentDateTime,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/appointments/${serviceType.toLowerCase()}'),
      );

      // Headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Fields - Updated for distance-based pricing
      request.fields.addAll({
        'provider_id': providerId,
        'appointment_type': appointmentType,
        'sub_service_type': selectedServiceType!,
        'description': descriptionController.text,
        'appointment_date': appointmentDateTime.toIso8601String(),
        'address': addressController.text,
        'base_price': basePrice.toString(),
        'final_price': finalPrice.toString(),
        'distance_km': distance?.toString() ?? '0',
        'latitude': userLocation.latitude.toString(),
        'longitude': userLocation.longitude.toString(),
        'rate_calculation_info': rateCalculationInfo,
      });

      print('📦 Request fields: ${request.fields}');
      print('💰 Price Details - Base: Rs. $basePrice, Final: Rs. $finalPrice, Distance: ${distance?.toStringAsFixed(1)} km');

      // Image file
      if (problemImage != null) {
        print('🖼️ Adding image to request...');
        var fileStream = http.ByteStream(problemImage!.openRead());
        var length = await problemImage!.length();

        var multipartFile = http.MultipartFile(
          'problem_image',
          fileStream,
          length,
          filename: path.basename(problemImage!.path),
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      // Send request
      print('🚀 Sending request to: ${request.url}');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      var response = await http.Response.fromStream(streamedResponse);
      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      var result = json.decode(response.body);

      return {
        'success': response.statusCode == 201,
        'message': result['message'] ?? 'Unknown error',
        'data': result,
      };
    } catch (e) {
      print('❌ API request error: $e');
      rethrow;
    }
  }


  // Firebase saving
  Future<void> _saveToFirebase(String providerId, DateTime appointmentDateTime) async {
    try {
      print('🔥 Starting Firebase save...');

      String collectionName = '${serviceType.toLowerCase()}_appointment';
      print('📁 Firebase collection: $collectionName');

      // Prepare image data
      String? base64Image;
      if (problemImage != null) {
        try {
          final bytes = await problemImage!.readAsBytes();
          base64Image = base64Encode(bytes);
          print('🖼️ Image encoded to base64');
        } catch (e) {
          print('❌ Error encoding image: $e');
        }
      }

      // Get user info
      final userEmail = _storageService.getEmail() ?? 'Unknown User';
      final userName = _storageService.getName() ?? 'Customer';
      print('👤 User: $userName ($userEmail)');

      // Build data - Updated for bid pricing
      final appointmentData = {
        'provider_id': providerId,
        'provider_name': provider['name'] ?? 'Unknown Provider',
        'provider_email': provider['email'] ?? '',
        'user_email': userEmail,
        'user_name': userName,
        'appointment_type': appointmentType,
        'sub_service_type': selectedServiceType,
        'description': descriptionController.text,
        'appointment_date': appointmentDateTime.toIso8601String(),
        'address': addressController.text,
        'base_price': basePrice,
        'user_bid_price': userBidPrice,
        'final_price': finalPrice,
        'distance_km': distance,
        'rate_calculation_info': rateCalculationInfo,
        'latitude': userLocation.latitude,
        'longitude': userLocation.longitude,
        'problem_image': base64Image,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'currency': 'PKR',
        'service_type': serviceType,
      };

      print('📊 Firebase data prepared, saving...');
      await FirebaseFirestore.instance.collection(collectionName).add(appointmentData);
      print('✅ Firebase save completed successfully in $collectionName');
    } catch (e) {
      print('❌ Firebase save error: $e');
    }
  }

  // Notification sending
  Future<void> _sendNotification(String providerId, DateTime appointmentDateTime) async {
    try {
      print('🔔 Starting notification process...');

      // Get provider token
      final providerToken = await _getProviderDeviceToken(providerId);
      if (providerToken == null) {
        print('❌ No provider token found');
        return;
      }
      print('📱 Provider token obtained: ${providerToken.substring(0, 20)}...');

      // Prepare notification data
      final userName = _storageService.getName() ?? 'Customer';
      final formattedDate = _formatDateTime(appointmentDateTime);

      final notificationData = {
        'screen': 'appointments',
        'appointment_id': providerId,
        'service_type': serviceType.toLowerCase(),
        'appointment_date': appointmentDateTime.toIso8601String(),
        'type': 'new_appointment',
        'booking_rate': finalPrice.toString(),
        'user_bid_price': userBidPrice.toString(),
        'distance': distance?.toStringAsFixed(1) ?? '0',
      };

      print('📨 Sending notification via API...');
      await SendNotificationService.sendNotification(
        token: providerToken,
        title: '📅 New Appointment Request',
        body: '$userName booked a $appointmentType $serviceType appointment on $formattedDate - Bid: Rs. $userBidPrice',
        data: notificationData,
      );

      print('✅ Notification sent successfully');
    } catch (e) {
      print('❌ Notification error: $e');
    }
  }

  // Helper methods
  Future<String?> _getAuthToken() async {
    try {
      final token = await AppointmentService.getToken();
      if (token == null || token.isEmpty) {
        print('❌ Token is null or empty');
        return null;
      }
      print('🔑 Token obtained successfully');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  Future<String?> _getProviderDeviceToken(String providerId) async {
    try {
      print('🔍 Looking for provider token...');

      // Try by email first
      final providerEmail = provider['email'];
      if (providerEmail != null) {
        print('📧 Searching by email: $providerEmail');
        final tokenDoc = await FirebaseFirestore.instance
            .collection('userTokens')
            .doc(providerEmail)
            .get();

        if (tokenDoc.exists) {
          final token = tokenDoc.data()?['deviceToken'] as String?;
          print('✅ Token found by email');
          return token;
        }
      }

      // Try by user ID
      print('🆔 Searching by user ID: $providerId');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('tokens')
          .where('userId', isEqualTo: providerId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final token = querySnapshot.docs.first.data()['deviceToken'] as String?;
        print('✅ Token found by user ID');
        return token;
      }

      print('❌ No token found for provider');
      return null;
    } catch (e) {
      print('❌ Error getting provider device token: $e');
      return null;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  List<String> getServiceTypeOptions() {
    switch (serviceType.toLowerCase()) {
      case 'cleaner':
        return ['regular', 'deep', 'office', 'move_in_out', 'other'];
      case 'plumber':
        return ['leak_fix', 'installation', 'drain_cleaning', 'water_heater', 'other'];
      case 'electrician':
        return ['wiring', 'installation', 'repair', 'lighting', 'other'];
      default:
        return ['general', 'repair', 'installation', 'other'];
    }
  }

  String formatServiceType(String type) {
    return type.split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // State management
  void setLoading(bool loading) {
    isLoading = loading;
    update();
  }

  void setError(String message) {
    errorMessage = message;
    update();
  }

  void clearError() {
    errorMessage = null;
    update();
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('🎉 Appointment Request Sent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your $appointmentType appointment request has been sent to ${provider['name'] ?? 'the provider'}.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (distance != null)
              Text(
                'Distance: ${distance!.toStringAsFixed(1)} km',
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 5),
            Text(
              'Your Bid: Rs. ${userBidPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Total amount: Rs. ${finalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              rateCalculationInfo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(result: true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    addressController.dispose();
    super.dispose();
  }
}