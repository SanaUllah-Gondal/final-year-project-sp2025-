import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/widgets/app_color.dart';
import 'package:plumber_project/notification/send_notification.dart';
import '../../../services/stripe.dart';
import '../../chat_screen.dart';

class UserAppointmentsController extends GetxController {
  final ApiService _apiService = Get.find();
  final StripePaymentService _stripeService = StripePaymentService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> tabs = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];
  final selectedTab = 0.obs;
  final isLoading = false.obs;
  final isProcessingPayment = false.obs;
  final appointments = [].obs;
  final filteredAppointments = [].obs;

  // Cache for Firebase provider data
  final Map<String, Map<String, dynamic>> _providerCache = {};
  final Map<String, Map<String, dynamic>> _ratingsCache = {};
  final Map<String, Map<String, dynamic>> _reviewsCache = {};

  @override
  void onInit() {
    super.onInit();
    loadUserAppointments();
  }

  Future<void> loadUserAppointments() async {
    try {
      isLoading.value = true;

      final List<Future> futures = [
        _apiService.getCleanerAppointments(),
        _apiService.getPlumberAppointments(),
        _apiService.getElectricianAppointments(),
      ];

      final results = await Future.wait(futures);

      List<dynamic> allAppointments = [];
      for (var result in results) {
        if (result['success'] && result['data'] != null) {
          final appointmentsData = result['data']['data'] ?? [];
          final serviceType = _getServiceTypeFromResult(result);
          final enhancedAppointments = await _enhanceAppointmentsWithFirebaseData(
              appointmentsData, serviceType);
          allAppointments.addAll(enhancedAppointments);
        }
      }

      allAppointments.sort((a, b) {
        final dateA = DateTime.parse(a['appointment_date']);
        final dateB = DateTime.parse(b['appointment_date']);
        return dateB.compareTo(dateA);
      });

      appointments.value = allAppointments;
      await _loadRatingsAndReviews();
      filterAppointments();

    } catch (e) {
      print('Error loading user appointments: $e');
      Get.snackbar('Error', 'Failed to load appointments');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadRatingsAndReviews() async {
    try {
      final completedAppointments = appointments.where((appt) =>
      appt['status'] == 'completed').toList();

      for (var appointment in completedAppointments) {
        final appointmentId = appointment['id'].toString();
        await _fetchRatingAndReview(appointmentId);
      }
    } catch (e) {
      print('Error loading ratings and reviews: $e');
    }
  }

  Future<void> _fetchRatingAndReview(String appointmentId) async {
    try {
      final ratingQuery = await _firestore
          .collection('ratings')
          .where('appointment_id', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (ratingQuery.docs.isNotEmpty) {
        _ratingsCache[appointmentId] = _convertDynamicMap(ratingQuery.docs.first.data());
      }

      final reviewQuery = await _firestore
          .collection('reviews')
          .where('appointment_id', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (reviewQuery.docs.isNotEmpty) {
        _reviewsCache[appointmentId] = _convertDynamicMap(reviewQuery.docs.first.data());
      }
    } catch (e) {
      debugPrint('Error fetching rating and review: $e');
    }
  }

  // Check if user has already rated this appointment
  bool hasUserRated(String appointmentId) {
    return _ratingsCache.containsKey(appointmentId);
  }

  // Check if user has already reviewed this appointment
  bool hasUserReviewed(String appointmentId) {
    return _reviewsCache.containsKey(appointmentId);
  }

  // Get rating for an appointment
  Map<String, dynamic>? getRating(String appointmentId) {
    return _ratingsCache[appointmentId];
  }

  // Get review for an appointment
  Map<String, dynamic>? getReview(String appointmentId) {
    return _reviewsCache[appointmentId];
  }

  // Check if appointment has any rating (for display)
  bool hasRating(String appointmentId) {
    return _ratingsCache.containsKey(appointmentId);
  }

  // Check if appointment has any review (for display)
  bool hasReview(String appointmentId) {
    return _reviewsCache.containsKey(appointmentId);
  }

  // Submit rating and review
  Future<void> submitRatingReview({
    required String appointmentId,
    required String providerId,
    required String providerName,
    required String serviceType,
    required double rating,
    required String review,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userEmail = user.email!;

      // 🔥 Get user name from Firestore
      final userQuery = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      String userName = "Unknown User";
      if (userQuery.docs.isNotEmpty) {
        userName = userQuery.docs.first['fullName'] ?? "Unknown User";
      }

      // Check if already rated
      if (hasUserRated(appointmentId)) {
        Get.snackbar(
          'Already Rated',
          'You have already rated this appointment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warningColor,
          colorText: Colors.white,
        );
        return;
      }

      // Save rating
      if (rating > 0) {
        await _firestore.collection('ratings').doc('$appointmentId-$userEmail').set({
          'appointment_id': appointmentId,
          'provider_id': providerId,
          'provider_name': providerName.isNotEmpty ? providerName : "Name",
          'user_email': userEmail,
          'user_name': userName, // 🔥 fixed
          'rating': rating,
          'service_type': serviceType.toLowerCase(),
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      // Save review
      if (review.isNotEmpty) {
        await _firestore.collection('reviews').doc('$appointmentId-$userEmail').set({
          'appointment_id': appointmentId,
          'provider_id': providerId,
          'provider_name': providerName.isNotEmpty ? providerName : "Name",
          'user_email': userEmail,
          'user_name': userName, // 🔥 fixed
          'review': review,
          'service_type': serviceType.toLowerCase(),
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      // Update cache
      await _fetchRatingAndReview(appointmentId);
      update();

      Get.snackbar(
        'Success',
        'Rating & Review submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit rating & review: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  Future<void> openOrCreateChat({
    required String providerEmail,
    required String providerName,
    String? providerImage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Please sign in to start chat');
        return;
      }

      final userEmail = user.email!;
      final userName = user.displayName ?? 'User';

      await _firestore
          .collection('messages')
          .doc(userEmail)
          .collection('chats')
          .doc(providerEmail)
          .set({
        'otherUserName': providerName,
        'otherUserImage': providerImage,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'isOnline': false,
      }, SetOptions(merge: true));

      await _firestore
          .collection('messages')
          .doc(providerEmail)
          .collection('chats')
          .doc(userEmail)
          .set({
        'otherUserName': userName,
        'otherUserImage': user.photoURL,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'isOnline': false,
      }, SetOptions(merge: true));

      Get.to(
            () => ChatScreen(
          otherUserEmail: providerEmail,
          otherUserName: providerName,
          otherUserImage: providerImage,
        ),
      );

    } catch (e) {
      print('Error creating chat: $e');
      Get.snackbar(
        'Error',
        'Failed to start chat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    }
  }

  // Add this method to safely convert dynamic maps
  Map<String, dynamic> _convertDynamicMap(Map<dynamic, dynamic> dynamicMap) {
    final Map<String, dynamic> convertedMap = {};
    dynamicMap.forEach((key, value) {
      if (value is Map<dynamic, dynamic>) {
        convertedMap[key.toString()] = _convertDynamicMap(value);
      } else {
        convertedMap[key.toString()] = value;
      }
    });
    return convertedMap;
  }

// Updated enhancement method
  Future<List<dynamic>> _enhanceAppointmentsWithFirebaseData(
      List<dynamic> appointments, String serviceType) async {
    final enhancedAppointments = <dynamic>[];

    for (var appointment in appointments) {
      try {
        // Convert the entire appointment to string map first
        Map<String, dynamic> convertedAppointment;
        if (appointment is Map<dynamic, dynamic>) {
          convertedAppointment = _convertDynamicMap(appointment);
        } else if (appointment is Map<String, dynamic>) {
          convertedAppointment = appointment;
        } else {
          convertedAppointment = {'id': appointment.toString()};
        }

        convertedAppointment['service_type'] = serviceType;
        final provider = convertedAppointment['provider'];

        if (provider != null && provider is Map) {
          // Convert provider to string map
          Map<String, dynamic> convertedProvider;
          if (provider is Map<dynamic, dynamic>) {
            convertedProvider = _convertDynamicMap(provider);
          } else {
            convertedProvider = Map<String, dynamic>.from(provider);
          }

          final providerEmail = convertedProvider['email']?.toString();
          final providerRole = convertedProvider['role']?.toString();

          if (providerEmail != null) {
            final providerData = await _getProviderDataFromFirebase(providerEmail, providerRole ?? '');

            if (providerData != null) {
              convertedAppointment['provider'] = {
                ...convertedProvider,
                'phone_number': providerData['contactNumber'] ?? providerData['phone_number'] ?? providerEmail,
                'profile_image': providerData['profileImage'] ?? providerData['profile_image'],
                'firebase_uid': providerEmail,
              };
            } else {
              // Use basic provider data from API
              convertedAppointment['provider'] = {
                ...convertedProvider,
                'phone_number': providerEmail,
                'profile_image': null,
                'firebase_uid': providerEmail,
              };
            }
          } else {
            convertedAppointment['provider'] = {
              ...convertedProvider,
              'phone_number': 'Not available',
              'profile_image': null,
              'firebase_uid': null,
            };
          }
        } else {
          // Handle case where provider data is missing
          convertedAppointment['provider'] = {
            'name': 'Unknown Provider',
            'email': 'Not available',
            'role': 'unknown',
            'phone_number': 'Not available',
            'profile_image': null,
            'firebase_uid': null,
          };
        }

        enhancedAppointments.add(convertedAppointment);
      } catch (e) {
        print('Error enhancing appointment: $e');
        // Provide fallback data with safe conversion
        Map<String, dynamic> fallbackAppointment;
        if (appointment is Map<dynamic, dynamic>) {
          fallbackAppointment = _convertDynamicMap(appointment);
        } else if (appointment is Map<String, dynamic>) {
          fallbackAppointment = appointment;
        } else {
          fallbackAppointment = {'id': appointment.toString()};
        }

        fallbackAppointment['service_type'] = serviceType;
        final provider = fallbackAppointment['provider'] ?? {};

        Map<String, dynamic> convertedProvider;
        if (provider is Map<dynamic, dynamic>) {
          convertedProvider = _convertDynamicMap(provider);
        } else if (provider is Map<String, dynamic>) {
          convertedProvider = provider;
        } else {
          convertedProvider = {};
        }

        fallbackAppointment['provider'] = {
          'name': convertedProvider['name'] ?? 'Unknown Provider',
          'email': convertedProvider['email'] ?? 'Not available',
          'role': convertedProvider['role'] ?? 'unknown',
          'phone_number': convertedProvider['email'] ?? 'Not available',
          'profile_image': null,
          'firebase_uid': convertedProvider['email'],
        };
        enhancedAppointments.add(fallbackAppointment);
      }
    }

    return enhancedAppointments;
  }


  Future<Map<String, dynamic>?> _getProviderDataFromFirebase(String email, String role) async {
    final cacheKey = '$email-$role';
    if (_providerCache.containsKey(cacheKey)) {
      return _providerCache[cacheKey];
    }

    try {
      String collectionName = _getFirebaseCollectionName(role);
      final querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final convertedData = _convertDynamicMap(data);
        _providerCache[cacheKey] = convertedData;
        return convertedData;
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
      case 'electrician': return 'electrician';
      case 'plumber': return 'plumber';
      case 'cleaner': return 'cleaner';
      case 'user': return 'user';
      default: return role.toLowerCase() + 's';
    }
  }

  String _getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    return 'http://192.168.100.26:8000/storage/$imagePath';
  }

  void filterAppointments() {
    if (selectedTab.value == 0) {
      filteredAppointments.value = appointments;
    } else {
      final status = tabs[selectedTab.value].toLowerCase();
      filteredAppointments.value = appointments.where((appt) =>
      appt['status'] == status).toList();
    }
  }

  Future<void> cancelAppointment(String appointmentId, String serviceType) async {
    try {
      isLoading.value = true;
      final response = await _apiService.updateAppointmentStatus(
          serviceType.toLowerCase(), appointmentId, 'cancelled');

      if (response['success']) {
        final appointment = _findAppointmentById(appointmentId);
        if (appointment != null) {
          _sendStatusUpdateNotification(
              appointment: appointment, newStatus: 'cancelled', serviceType: serviceType);
        }

        Get.snackbar('Success', 'Appointment cancelled successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successColor, colorText: Colors.white);
        await loadUserAppointments();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to cancel appointment',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorColor, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel appointment: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmModifiedAppointment(String appointmentId, String serviceType) async {
    try {
      isLoading.value = true;
      print('Cancelling appointment: $appointmentId, service: $serviceType');

      // Use the updateAppointmentStatus API with 'cancelled' status
      final response = await _apiService.updateAppointmentStatus(
        serviceType.toLowerCase(),
        appointmentId,
        'confirmed',
      );

      if (response['success']) {
        // Get appointment details for notification
        final appointment = _findAppointmentById(appointmentId);
        if (appointment != null) {
          // Send notification to provider (non-blocking)
          _sendStatusUpdateNotification(
            appointment: appointment,
            newStatus: 'confirmed',
            serviceType: serviceType,
          );
        }

        Get.snackbar(
          'Success',
          'Appointment confirmed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successColor,
          colorText: Colors.white,
        );
        await loadUserAppointments(); // Refresh the list
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to confirmed appointment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to confirmed appointment: $e',
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
      final response = await _apiService.updateAppointmentStatus(
        serviceType.toLowerCase(),
        appointmentId,
        'completed',
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
    if (price == null) return "RPS:0.00";

    if (price is String) {
      final numericValue = double.tryParse(price);
      if (numericValue != null) {
        return 'RPS:${numericValue.toStringAsFixed(2)}';
      }
      return 'RPS:$price';
    } else if (price is int) {
      return 'RPS:${price.toDouble().toStringAsFixed(2)}';
    } else if (price is double) {
      return 'RPS:${price.toStringAsFixed(2)}';
    }

    return 'RPS:0.00';
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