import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/widgets/app_color.dart';
import 'package:plumber_project/notification/send_notification.dart';

import '../../../services/stripe.dart';


class UserAppointmentsController extends GetxController {
  final ApiService _apiService = Get.find();
  final StripePaymentService _stripeService = StripePaymentService.instance;

  final List<String> tabs = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];
  final selectedTab = 0.obs;
  final isLoading = false.obs;
  final isProcessingPayment = false.obs;
  final appointments = [].obs;
  final filteredAppointments = [].obs;

  // Cache for Firebase provider data
  final Map<String, Map<String, dynamic>> _providerCache = {};

  @override
  void onInit() {
    super.onInit();
    loadUserAppointments();
  }

  Future<void> loadUserAppointments() async {
    try {
      isLoading.value = true;

      // Load appointments from all service types
      final List<Future> futures = [
        _apiService.getCleanerAppointments(),
        _apiService.getPlumberAppointments(),
        _apiService.getElectricianAppointments(),
      ];

      final results = await Future.wait(futures);

      // Combine all appointments
      List<dynamic> allAppointments = [];
      for (var result in results) {
        if (result['success'] && result['data'] != null) {
          final appointmentsData = result['data']['data'] ?? [];
          final serviceType = _getServiceTypeFromResult(result);

          // Enhance appointments with Firebase data
          final enhancedAppointments = await _enhanceAppointmentsWithFirebaseData(
              appointmentsData,
              serviceType
          );

          allAppointments.addAll(enhancedAppointments);
        }
      }

      // Sort by date (newest first)
      allAppointments.sort((a, b) {
        final dateA = DateTime.parse(a['appointment_date']);
        final dateB = DateTime.parse(b['appointment_date']);
        return dateB.compareTo(dateA);
      });

      appointments.value = allAppointments;
      filterAppointments();

    } catch (e) {
      print('Error loading user appointments: $e');
      Get.snackbar('Error', 'Failed to load appointments');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<dynamic>> _enhanceAppointmentsWithFirebaseData(
      List<dynamic> appointments,
      String serviceType
      ) async {
    final enhancedAppointments = <dynamic>[];

    for (var appointment in appointments) {
      try {
        // Add service type
        appointment['service_type'] = serviceType;

        // Get provider data from Firebase using provider role and email
        final provider = appointment['provider'];
        if (provider != null && provider['email'] != null) {
          final providerEmail = provider['email'];
          final providerRole = provider['role']; // electrician, plumber, cleaner

          // Get provider data from Firebase based on their role
          final providerData = await _getProviderDataFromFirebase(providerEmail, providerRole);

          if (providerData != null) {
            // Merge Firebase data with API provider data
            appointment['provider'] = {
              ...provider, // Keep original provider data
              'phone_number': providerData['contactNumber'] ?? providerData['phone_number'] ?? 'Not available',
              'profile_image': providerData['profileImage'] ?? providerData['profile_image'],
              'firebase_uid':provider['email'] , // Add Firebase document ID for chat
            };
          } else {
            // Fallback to API provider data only
            appointment['provider'] = {
              ...provider,
              'phone_number': 'Not available',
              'profile_image': null,
              'firebase_uid': null,
            };
          }
        } else {
          // No provider data in API response
          appointment['provider'] = {
            'name': 'Unknown Provider',
            'email': 'Not available',
            'role': 'unknown',
            'phone_number': 'Not available',
            'profile_image': null,
            'firebase_uid': null,
          };
        }

        // Get problem image from API (it's already in the response)
        final problemImage = appointment['problem_image'];
        if (problemImage != null) {
          // Convert relative path to full URL if needed
          appointment['problem_image_url'] = _getFullImageUrl(problemImage);
        }

        enhancedAppointments.add(appointment);
      } catch (e) {
        print('Error enhancing appointment: $e');
        // Add basic appointment data even if enhancement fails
        appointment['service_type'] = serviceType;
        final provider = appointment['provider'] ?? {};
        appointment['provider'] = {
          'name': provider['name'] ?? 'Unknown Provider',
          'email': provider['email'] ?? 'Not available',
          'role': provider['role'] ?? 'unknown',
          'phone_number': 'Not available',
          'profile_image': null,
          'firebase_uid': null,
        };
        enhancedAppointments.add(appointment);
      }
    }

    return enhancedAppointments;
  }

  Future<Map<String, dynamic>?> _getProviderDataFromFirebase(
      String email,
      String role
      ) async {
    // Check cache first
    final cacheKey = '$email-$role';
    if (_providerCache.containsKey(cacheKey)) {
      return _providerCache[cacheKey];
    }

    try {
      String collectionName = _getFirebaseCollectionName(role);

      print('Fetching provider data from Firebase: collection=$collectionName, email=$email');

      final querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();

        print('Found provider data in Firebase: $data');

        // Cache the provider data
        _providerCache[cacheKey] = data;

        return data;
      } else {
        print('No provider found in Firebase for email: $email in collection: $collectionName');
      }
    } catch (e) {
      print('Error fetching provider data from Firebase: $e');
    }

    return null;
  }

  String _getServiceTypeFromResult(Map<String, dynamic> result) {
    final url = result['request_url']?.toString() ?? '';
    if (url.contains('cleaner')) return 'Cleaner';
    if (url.contains('plumber')) return 'Plumber';
    if (url.contains('electrician')) return 'Electrician';
    return 'Unknown';
  }

  String _getFirebaseCollectionName(String role) {
    switch (role.toLowerCase()) {
      case 'electrician':
        return 'electrician';
      case 'plumber':
        return 'plumber';
      case 'cleaner':
        return 'cleaner';
      case 'user':
        return 'user';
      default:
        return role.toLowerCase() + 's';
    }
  }

  String _getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    } else {
      // Replace with your actual base URL
      return 'http://192.168.100.26:8000/storage/$imagePath';
    }
  }

  void filterAppointments() {
    if (selectedTab.value == 0) {
      // Show all appointments
      filteredAppointments.value = appointments;
    } else {
      // Filter by status
      final status = tabs[selectedTab.value].toLowerCase();
      filteredAppointments.value = appointments.where((appt) =>
      appt['status'] == status).toList();
    }
  }

  Future<void> cancelAppointment(String appointmentId, String serviceType) async {
    try {
      isLoading.value = true;
      print('Cancelling appointment: $appointmentId, service: $serviceType');

      // Use the updateAppointmentStatus API with 'cancelled' status
      final response = await _apiService.updateAppointmentStatus(
        serviceType.toLowerCase(),
        appointmentId,
        'cancelled',
      );

      if (response['success']) {
        // Get appointment details for notification
        final appointment = _findAppointmentById(appointmentId);
        if (appointment != null) {
          // Send notification to provider (non-blocking)
          _sendStatusUpdateNotification(
            appointment: appointment,
            newStatus: 'cancelled',
            serviceType: serviceType,
          );
        }

        Get.snackbar(
          'Success',
          'Appointment cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successColor,
          colorText: Colors.white,
        );
        await loadUserAppointments(); // Refresh the list
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to cancel appointment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel appointment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeBooking(
      String appointmentId,
      String serviceType,
      String paymentMethod,
      double amount,
      ) async {
    try {
      isProcessingPayment.value = true;
      print('Completing booking: $appointmentId, payment: $paymentMethod, amount: $amount');

      // Process payment if online
      bool paymentSuccess = true;
      if (paymentMethod == 'online') {
        paymentSuccess = await _processStripePayment(amount);
        if (!paymentSuccess) {
          Get.snackbar(
            'Payment Failed',
            'Please try again with a different payment method',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white,
          );
          return;
        }
      }

      // Update appointment status to completed with payment method
      final response = await _apiService.completeAppointmentWithPayment(
        serviceType.toLowerCase(),
        appointmentId,
        paymentMethod,
        amount,
      );

      if (response['success']) {
        // Get appointment details for notification
        final appointment = _findAppointmentById(appointmentId);
        if (appointment != null) {
          // Send notification to provider (non-blocking)
          _sendStatusUpdateNotification(
            appointment: appointment,
            newStatus: 'completed',
            serviceType: serviceType,
          );
        }

        Get.snackbar(
          'Success',
          paymentMethod == 'online'
              ? 'Payment successful and booking completed!'
              : 'Booking marked as completed with cash payment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successColor,
          colorText: Colors.white,
        );
        await loadUserAppointments(); // Refresh the list
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to complete booking',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete booking: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isProcessingPayment.value = false;
    }
  }
  Future<bool> _processStripePayment(double amount) async {
    try {
      print('🔄 Starting Stripe payment process for amount: $amount');

      // Test the setup first
      final setupValid = await _stripeService.validateSetup();
      if (!setupValid) {
        throw Exception('Stripe setup validation failed');
      }

      // Process payment
      print('🔄 Processing payment of \$${amount.toStringAsFixed(2)}...');
      final success = await _stripeService.makePayment(amount.toInt());

      if (!success) {
        throw Exception('Payment processing failed - returned false');
      }

      print('✅ Payment processed successfully');
      return true;
    } on StripeException catch (e) {
      print('❌ StripeException: ${e.error.localizedMessage}');
      String errorMessage = 'Payment failed: ';

      switch (e.error.code) {
        case FailureCode.Canceled:
          errorMessage += 'Payment was cancelled';
          break;
        case FailureCode.Failed:
          errorMessage += 'Payment failed. Please try again';
          break;
        case FailureCode.Timeout:
          errorMessage += 'Payment timed out. Please check your connection';
          break;
        default:
          errorMessage += e.error.localizedMessage ?? 'Unknown error occurred';
      }

      Get.snackbar(
        'Payment Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return false;
    } on DioException catch (e) {
      print('❌ Network Error: ${e.message}');
      String errorMessage = 'Network error: ';

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage += 'Request timed out. Please check your internet connection';
          break;
        case DioExceptionType.connectionError:
          errorMessage += 'No internet connection';
          break;
        default:
          errorMessage += 'Please check your internet connection and try again';
      }

      Get.snackbar(
        'Network Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      print('❌ Stripe payment error: $e');
      Get.snackbar(
        'Payment Error',
        'Failed to process payment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<double> calculateBookingAmount(String appointmentId) async {
    try {
      // In a real app, you would calculate this from your backend
      // For now, we'll use the price from the appointment
      final appointment = _findAppointmentById(appointmentId);
      if (appointment != null) {
        final price = appointment['price'];
        if (price is String) {
          return double.tryParse(price) ?? 0.0;
        } else if (price is int) {
          return price.toDouble();
        } else if (price is double) {
          return price;
        }
      }
      return 0.0;
    } catch (e) {
      print('Error calculating booking amount: $e');
      return 0.0;
    }
  }

  // Helper method to find appointment by ID
  Map<String, dynamic>? _findAppointmentById(String appointmentId) {
    try {
      return appointments.firstWhere(
            (appt) => appt['id'].toString() == appointmentId,
      );
    } catch (e) {
      print('Appointment not found: $appointmentId');
      return null;
    }
  }

  // Send notification to provider about status update
  Future<void> _sendStatusUpdateNotification({
    required Map<String, dynamic> appointment,
    required String newStatus,
    required String serviceType,
  }) async {
    try {
      print('🔔 Sending status update notification...');

      final provider = appointment['provider'];
      if (provider == null) {
        print('❌ No provider data found for notification');
        return;
      }

      final providerId = provider['id']?.toString() ?? provider['provider_id']?.toString();
      final providerEmail = provider['email'];

      if (providerId == null && providerEmail == null) {
        print('❌ No provider ID or email found for notification');
        return;
      }

      // Get provider device token
      final providerToken = await _getProviderDeviceToken(providerId, providerEmail);
      if (providerToken == null) {
        print('❌ No provider device token found');
        return;
      }

      print('📱 Provider token obtained, sending notification...');

      // Prepare notification content based on status
      final statusMessages = {
        'cancelled': {
          'title': '❌ Appointment Cancelled',
          'body': 'Your appointment has been cancelled by the customer',
        },
        'completed': {
          'title': '✅ Appointment Completed',
          'body': 'The customer marked the appointment as completed',
        },
      };

      final message = statusMessages[newStatus];
      if (message == null) {
        print('❌ No message template for status: $newStatus');
        return;
      }

      // Prepare notification data
      final notificationData = {
        'screen': 'appointments',
        'appointment_id': appointment['id'].toString(),
        'service_type': serviceType.toLowerCase(),
        'status': newStatus,
        'type': 'status_update',
      };

      // Send notification
      await SendNotificationService.sendNotification(
        token: providerToken,
        title: message['title']!,
        body: message['body']!,
        data: notificationData,
      );

      print('✅ Status update notification sent successfully');
    } catch (e) {
      print('❌ Error sending status update notification: $e');
      // Don't rethrow - notification failure shouldn't block the main flow
    }
  }

  // Get provider device token from Firebase
  Future<String?> _getProviderDeviceToken(String? providerId, String? providerEmail) async {
    try {
      print('🔍 Looking for provider device token...');

      // Try by email first (most reliable)
      if (providerEmail != null) {
        print('📧 Searching by email: $providerEmail');
        final tokenDoc = await FirebaseFirestore.instance
            .collection('userTokens')
            .doc(providerEmail)
            .get();

        if (tokenDoc.exists) {
          final token = tokenDoc.data()?['deviceToken'] as String?;
          if (token != null && token.isNotEmpty) {
            print('✅ Token found by email');
            return token;
          }
        }
      }

      // Try by user ID
      if (providerId != null) {
        print('🆔 Searching by user ID: $providerId');
        final querySnapshot = await FirebaseFirestore.instance
            .collection('tokens')
            .where('userId', isEqualTo: providerId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final token = querySnapshot.docs.first.data()['deviceToken'] as String?;
          if (token != null && token.isNotEmpty) {
            print('✅ Token found by user ID');
            return token;
          }
        }
      }

      // Try alternative collections
      final alternativeCollections = ['fcm_tokens', 'device_tokens', 'notifications'];
      for (final collection in alternativeCollections) {
        try {
          final querySnapshot = await FirebaseFirestore.instance
              .collection(collection)
              .where('email', isEqualTo: providerEmail)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            final data = querySnapshot.docs.first.data();
            final token = data['token'] ?? data['deviceToken'] ?? data['fcm_token'];
            if (token != null && token is String && token.isNotEmpty) {
              print('✅ Token found in $collection collection');
              return token;
            }
          }
        } catch (e) {
          print('⚠️ Error searching in $collection: $e');
        }
      }

      print('❌ No device token found for provider');
      return null;
    } catch (e) {
      print('❌ Error getting provider device token: $e');
      return null;
    }
  }

  // Helper method to format price safely
  String formatPrice(dynamic price) {
    if (price == null) return '\$0.00';

    if (price is String) {
      final numericValue = double.tryParse(price);
      if (numericValue != null) {
        return '\$${numericValue.toStringAsFixed(2)}';
      }
      return '\$$price';
    } else if (price is int) {
      return '\$${price.toDouble().toStringAsFixed(2)}';
    } else if (price is double) {
      return '\$${price.toStringAsFixed(2)}';
    }

    return '\$0.00';
  }

  // Navigate to chat screen
  void navigateToChat(Map<String, dynamic> appointment) {
    final provider = appointment['provider'];
    if (provider == null || provider['firebase_uid'] == null) {
      Get.snackbar(
        'Error',
        'Cannot start chat: Provider information not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    // Navigate to chat screen with provider details
    Get.toNamed('/chat', arguments: {
      'providerId': provider['firebase_uid'],
      'providerName': provider['name'] ?? 'Provider',
      'appointmentId': appointment['id'],
      'serviceType': appointment['service_type'],
    });
  }
}