import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/storage_service.dart';
import 'package:plumber_project/models/user_location.dart';
import '../../../notification/fcm_service.dart';
import '../../../notification/notification_service.dart';

class ElectricianDashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final NotificationService notificationService = Get.find<NotificationService>();

  // Observable variables
  var isOnline = false.obs;
  var isWorking = false.obs;
  var isLoading = false.obs;
  var isLocationLoading = false.obs;
  var errorMessage = ''.obs;
  var userId = 0.obs;
  var userEmail = ''.obs;
  var phoneNumber = ''.obs;
  var profileImage = ''.obs;
  var deviceToken = ''.obs;
  var providerStats = <String, dynamic>{}.obs;
  var availableJobs = [].obs;
  var hasPendingRequests = false.obs;
  var appointments = [].obs;
  var pendingRequestCount = 0.obs;

  // Location variables
  var userLocation = UserLocation(
    latitude: 0.0,
    longitude: 0.0,
    address: 'Location not available',
  ).obs;

  var currentAddressName = 'Location not available'.obs;
  var currentLatitude = 0.0.obs;
  var currentLongitude = 0.0.obs;

  // Location stream
  StreamSubscription<Position>? _positionStreamSubscription;
  var isTrackingLocation = false.obs;

  // Real-time monitoring
  Timer? _requestMonitorTimer;
  var lastCheckedTime = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _stopLocationTracking();
    _stopRequestMonitoring();
    super.onClose();
  }

  Future<void> _initializeController() async {
    try {
      debugPrint('[ElectricianDashboardController] Initializing...');

      // Load user data first
      await _loadUserData();

      // Initialize device token and FCM services
      await _initializeDeviceToken();

      // Load initial status and appointments
      await _loadInitialStatus();
      await loadAppointments();

      // Start real-time request monitoring
      _startRequestMonitoring();

      debugPrint('[ElectricianDashboardController] Initialization complete');
    } catch (e) {
      debugPrint('[ElectricianDashboardController] Error initializing: $e');
    }
  }

  void _startRequestMonitoring() {
    // Check every 30 seconds for new requests
    _requestMonitorTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (isOnline.value && !isWorking.value) {
        _checkForNewRequests();
      }
    });
  }

  void _stopRequestMonitoring() {
    _requestMonitorTimer?.cancel();
    _requestMonitorTimer = null;
  }

  Future<void> _checkForNewRequests() async {
    try {
      final previousCount = pendingRequestCount.value;
      await loadAppointments();

      // Show notification if new requests arrived
      if (pendingRequestCount.value > previousCount) {
        _showNewRequestNotification();
      }

      lastCheckedTime.value = DateTime.now();
    } catch (e) {
      debugPrint('Error checking for new requests: $e');
    }
  }

  void _showNewRequestNotification() {
    Get.snackbar(
      'New Request!',
      'You have ${pendingRequestCount.value} new service request${pendingRequestCount.value > 1 ? 's' : ''}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.notifications_active, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  Future<void> _initializeDeviceToken() async {
    try {
      debugPrint('[ElectricianDashboardController] Getting device token...');

      final token = await notificationService.getDeviceToken();
      deviceToken.value = token;
      debugPrint('[ElectricianDashboardController] Device token obtained: $token');

      // Initialize FCM services
      FcmService.firebaseInit();
      notificationService.firebaseInit();
      notificationService.setupInteractMessage();

      // Save token to Firebase
      await saveDeviceToken();

    } catch (e) {
      debugPrint('[ElectricianDashboardController] Error initializing device token: $e');
    }
  }

  Future<void> saveDeviceToken() async {
    try {
      final email = userEmail.value;
      final token = deviceToken.value;
      final id = userId.value;

      if (email.isEmpty) {
        debugPrint('Email is empty, skipping token save');
        return;
      }

      if (token.isEmpty) {
        debugPrint('Device token is empty, skipping save');
        return;
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference tokensCollection = firestore.collection('userTokens');

      await tokensCollection.doc(email).set({
        'email': email,
        'deviceToken': token,
        'userId': id,
        'userType': 'electrician',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ Device token saved for electrician: $email');
    } catch (e) {
      debugPrint('❌ Error saving device token: $e');
    }
  }

  void _checkPendingRequests() {
    final pendingApps = appointments.where((appt) =>
    appt['status'] == 'pending' &&
        DateTime.parse(appt['appointment_date']).isAfter(DateTime.now()));

    hasPendingRequests.value = pendingApps.isNotEmpty;
    pendingRequestCount.value = pendingApps.length;

    debugPrint('Pending requests: ${pendingRequestCount.value}');
  }

  Future<void> loadAppointments() async {
    try {
      final response = await _apiService.getElectricianAppointments();

      if (response['success']) {
        appointments.value = response['data']?['data'] ?? [];
        _checkPendingRequests();
      }
    } catch (e) {
      debugPrint('Error loading appointments: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final storedUserId = await _storageService.getUserId();
      final storedUserEmail = await _storageService.getEmail();
      final storedPhoneNumber = await _storageService.getPhoneNumber();
      final storedProfileImage = await _storageService.getProfileImage();

      userId.value = storedUserId ?? 0;
      userEmail.value = storedUserEmail ?? '';
      phoneNumber.value = storedPhoneNumber ?? '';
      profileImage.value = storedProfileImage ?? '';

      debugPrint('[ElectricianDashboardController] User data loaded - Email: ${userEmail.value}');
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> getLiveLocation() async {
    try {
      isLocationLoading.value = true;
      errorMessage.value = '';

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permissions are denied");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are permanently denied");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      String addressName = placemarks.isNotEmpty
          ? _formatAddressName(placemarks.first)
          : 'Current Location';

      userLocation.value = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: addressName,
      );

      currentAddressName.value = addressName;
      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;

      if (isOnline.value) {
        await _updateLocationOnServer(
            addressName,
            position.latitude,
            position.longitude
        );
      }

    } catch (e) {
      errorMessage.value = "Error getting location: $e";
    } finally {
      isLocationLoading.value = false;
    }
  }

  String _formatAddressName(Placemark placemark) {
    final parts = [
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
    ].where((part) => part != null && part!.isNotEmpty).toList();

    return parts.isNotEmpty ? parts.join(', ') : 'Current Location';
  }

  Future<void> startLocationTracking() async {
    try {
      await getLiveLocation();

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      ).listen((Position position) async {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          String addressName = placemarks.isNotEmpty
              ? _formatAddressName(placemarks.first)
              : 'Tracking...';

          userLocation.value = UserLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            address: addressName,
          );

          currentAddressName.value = addressName;
          currentLatitude.value = position.latitude;
          currentLongitude.value = position.longitude;

          if (isOnline.value) {
            await _updateLocationOnServer(
                addressName,
                position.latitude,
                position.longitude
            );
          }
        } catch (e) {
          debugPrint('Error in location stream: $e');
        }
      });

      isTrackingLocation.value = true;

    } catch (e) {
      errorMessage.value = "Error starting location tracking: $e";
    }
  }

  void _stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    isTrackingLocation.value = false;
  }

  Future<void> _updateLocationOnServer(String addressName, double latitude, double longitude) async {
    try {
      await _apiService.updateProviderLocation(
        providerType: 'electrician',
        addressName: addressName,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      debugPrint('Error updating location on server: $e');
    }
  }

  Future<void> toggleOnlineStatus() async {
    try {
      isLoading.value = true;

      if (!isOnline.value) {
        await getLiveLocation();
        await startLocationTracking();
        _startRequestMonitoring(); // Start monitoring when going online
      } else {
        _stopLocationTracking();
        _stopRequestMonitoring(); // Stop monitoring when going offline
      }

      final response = await _apiService.toggleOnlineStatus(
        providerType: 'electrician',
        isOnline: !isOnline.value,
        addressName: currentAddressName.value,
        latitude: currentLatitude.value,
        longitude: currentLongitude.value,
      );

      if (response['success']) {
        isOnline.value = response['is_online'];
        isWorking.value = response['is_working'] ?? false;

        Get.snackbar(
          'Success',
          response['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (!isOnline.value) {
        _stopLocationTracking();
        _stopRequestMonitoring();
      }

      Get.snackbar(
        'Error',
        'Failed to update status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateWorkingStatus(bool working) async {
    try {
      isLoading.value = true;

      final response = await _apiService.updateWorkingStatus(
        providerType: 'electrician',
        isWorking: working,
      );

      if (response['success']) {
        isWorking.value = working;

        // Adjust request monitoring based on working status
        if (working) {
          _stopRequestMonitoring();
        } else if (isOnline.value) {
          _startRequestMonitoring();
        }

        Get.snackbar(
          'Success',
          response['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update working status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadInitialStatus() async {
    try {
      isLoading.value = true;

      final profileResponse = await _apiService.getMyElectricianProfile();
      if (!profileResponse['success']) {
        throw Exception('No electrician profile found');
      }

      final response = await _apiService.getProviderStatus('electrician');

      if (response['success']) {
        final providerData = response['data'];
        isOnline.value = providerData['is_online'] ?? false;
        isWorking.value = providerData['is_working'] ?? false;
        currentAddressName.value = providerData['address_name'] ?? 'Location not available';
        currentLatitude.value = providerData['latitude']?.toDouble() ?? 0.0;
        currentLongitude.value = providerData['longitude']?.toDouble() ?? 0.0;

        if (providerData['phone_number'] != null) {
          phoneNumber.value = providerData['phone_number'];
          await _storageService.savePhoneNumber(phoneNumber.value);
        }
        if (providerData['profile_image'] != null) {
          profileImage.value = providerData['profile_image'];
          await _storageService.saveProfileImage(profileImage.value);
        }

        userLocation.value = UserLocation(
          latitude: currentLatitude.value,
          longitude: currentLongitude.value,
          address: currentAddressName.value,
        );

        if (isOnline.value && !isWorking.value) {
          await startLocationTracking();
          _startRequestMonitoring();
        }
      }
    } catch (e) {
      debugPrint('Error loading initial status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await _loadInitialStatus();
    await loadAppointments();
  }

  // Manual check for new requests
  Future<void> manuallyCheckRequests() async {
    await _checkForNewRequests();
    Get.snackbar(
      'Refreshed',
      'Checked for new requests',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 1),
    );
  }
}