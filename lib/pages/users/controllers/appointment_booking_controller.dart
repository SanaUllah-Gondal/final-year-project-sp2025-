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

  // Services
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = Get.find<StorageService>();

  AppointmentBookingController({
    required this.provider,
    required this.serviceType,
    required this.userLocation,
    required this.basePrice,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    print('🎯 AppointmentBookingController initialized');
  }

  void _initializeData() {
    addressController.text = provider['address_name'] ?? '';
    selectedServiceType = _getDefaultServiceType();
    _calculatePrice();
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

  // Price calculation
  void _calculatePrice() {
    finalPrice = appointmentType == 'emergency' ? basePrice * 1.2 : basePrice;
    update();
  }

  void updateAppointmentType(String type) {
    appointmentType = type;
    _calculatePrice();
  }

  void updateServiceType(String? type) {
    selectedServiceType = type;
    update();
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

  // Date/Time handling
  Future<void> selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );

      if (picked != null && picked != selectedDate) {
        selectedDate = picked;
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
        update();
        print('📅 Date selected: $picked');
      }
    } catch (e) {
      print('❌ Error selecting date: $e');
      setError('Error selecting date: $e');
    }
  }

  Future<void> selectTime(BuildContext context) async {
    try {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (picked != null) {
        selectedTime = picked;
        timeController.text = picked.format(context);
        update();
        print('⏰ Time selected: $picked');
      }
    } catch (e) {
      print('❌ Error selecting time: $e');
      setError('Error selecting time: $e');
    }
  }

  // Validation
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

      // Fields
      request.fields.addAll({
        'provider_id': providerId,
        'appointment_type': appointmentType,
        'sub_service_type': selectedServiceType!,
        'description': descriptionController.text,
        'appointment_date': appointmentDateTime.toIso8601String(),
        'address': addressController.text,
        'base_price': basePrice.toString(),
        'latitude': userLocation.latitude.toString(),
        'longitude': userLocation.longitude.toString(),
      });

      print('📦 Request fields: ${request.fields}');

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

      // Build data
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
        'final_price': finalPrice,
        'latitude': userLocation.latitude,
        'longitude': userLocation.longitude,
        'problem_image': base64Image,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      print('📊 Firebase data prepared, saving...');
      await FirebaseFirestore.instance.collection(collectionName).add(appointmentData);
      print('✅ Firebase save completed successfully in $collectionName');
    } catch (e) {
      print('❌ Firebase save error: $e');
      // Don't rethrow - Firebase failure shouldn't block the main flow
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
      };

      print('📨 Sending notification via API...');
      await SendNotificationService.sendNotification(
        token: providerToken,
        title: '📅 New Appointment Request',
        body: '$userName booked a $appointmentType $serviceType appointment on $formattedDate',
        data: notificationData,
      );

      print('✅ Notification sent successfully');
    } catch (e) {
      print('❌ Notification error: $e');
      // Don't rethrow - notification failure shouldn't block the main flow
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
            Text(
              'Total amount: \$${finalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
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