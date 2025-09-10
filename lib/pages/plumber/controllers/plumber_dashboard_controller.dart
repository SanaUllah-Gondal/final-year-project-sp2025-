import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/storage_service.dart';
import 'package:plumber_project/models/user_location.dart';

class PlumberDashboardController extends GetxController {
  final ApiService _apiService = Get.find();
  final StorageService _storageService = Get.find();

  // Observable variables
  var isOnline = false.obs;
  var isWorking = false.obs;
  var isLoading = false.obs;
  var isLocationLoading = false.obs;
  var errorMessage = ''.obs;
  var userId = 0.obs;
  var userEmail = ''.obs;
  var phoneNumber = ''.obs; // Added phone number
  var profileImage = ''.obs; // Added profile image
  var providerStats = <String, dynamic>{}.obs;
  var availableJobs = [].obs;

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

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _stopLocationTracking();
    super.onClose();
  }

  // Initialize controller
  Future<void> _initializeController() async {
    try {
      await _loadUserData();
      await _loadInitialStatus();
    } catch (e) {
      debugPrint('Error initializing controller: $e');
    }
  }

  // Load user ID, email, phone, and image from storage
  Future<void> _loadUserData() async {
    try {
      final storedUserId = await _storageService.getUserId();
      final storedUserEmail = await _storageService.getEmail();
      final storedPhoneNumber = await _storageService.getPhoneNumber();
      final storedProfileImage = await _storageService.getProfileImage();

      if (storedUserId != null) {
        userId.value = storedUserId;
        debugPrint('User ID from storage: ${userId.value}');
      } else {
        throw Exception('User ID not found in storage');
      }

      if (storedUserEmail != null) {
        userEmail.value = storedUserEmail;
        debugPrint('User email from storage: ${userEmail.value}');
      }

      if (storedPhoneNumber != null) {
        phoneNumber.value = storedPhoneNumber;
        debugPrint('Phone number from storage: ${phoneNumber.value}');
      }

      if (storedProfileImage != null) {
        profileImage.value = storedProfileImage;
        debugPrint('Profile image from storage: ${profileImage.value}');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      rethrow;
    }
  }

  // Get live current location with proper error handling
  Future<void> getLiveLocation() async {
    try {
      isLocationLoading.value = true;
      errorMessage.value = '';

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled. Please enable them.");
      }

      // Check location permissions
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

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      // Format address name
      String addressName = placemarks.isNotEmpty
          ? _formatAddressName(placemarks.first)
          : 'Current Location';

      // Update location values
      userLocation.value = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: addressName,
      );

      currentAddressName.value = addressName;
      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;

      // If online, automatically update location on server
      if (isOnline.value) {
        await _updateLocationOnServer(
            addressName,
            position.latitude,
            position.longitude
        );
      }

    } catch (e) {
      errorMessage.value = "Error getting location: $e";
      Get.snackbar(
        'Location Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLocationLoading.value = false;
    }
  }

  // Format address name from placemark
  String _formatAddressName(Placemark placemark) {
    final parts = [
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
    ].where((part) => part != null && part!.isNotEmpty).toList();

    return parts.isNotEmpty ? parts.join(', ') : 'Current Location';
  }

  // Start continuous location tracking
  Future<void> startLocationTracking() async {
    try {
      // First get initial location
      await getLiveLocation();

      // Set up location stream for continuous updates
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      ).listen((Position position) async {
        try {
          // Get address for new position
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

          // Update server if online
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

  // Stop location tracking
  void _stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    isTrackingLocation.value = false;
  }

  // Update location on server
  Future<void> _updateLocationOnServer(String addressName, double latitude, double longitude) async {
    try {
      await _apiService.updateProviderLocation(
        providerType: 'plumber',
        addressName: addressName,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      debugPrint('Error updating location on server: $e');
    }
  }

  // Toggle online/offline status with live location
  Future<void> toggleOnlineStatus() async {
    try {
      isLoading.value = true;

      // Get live location before going online
      if (!isOnline.value) {
        await getLiveLocation();

        // Start tracking when going online
        await startLocationTracking();
      } else {
        // Stop tracking when going offline
        _stopLocationTracking();
      }

      final response = await _apiService.toggleOnlineStatus(
        providerType: 'plumber',
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
      // Revert UI state if API call fails
      if (!isOnline.value) {
        _stopLocationTracking();
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

  // Update working status
  Future<void> updateWorkingStatus(bool working) async {
    try {
      isLoading.value = true;

      final response = await _apiService.updateWorkingStatus(
        providerType: 'plumber',
        isWorking: working,
      );

      if (response['success']) {
        isWorking.value = working;
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

  // Load initial status from API - UPDATED to handle phone and image
  Future<void> _loadInitialStatus() async {
    try {
      isLoading.value = true;

      // First check if user has a plumber profile
      final profileResponse = await _apiService.getMyPlumberProfile();
      debugPrint('Profile response: ${jsonEncode(profileResponse)}');

      if (!profileResponse['success']) {
        throw Exception('No plumber profile found. Please create a profile first.');
      }

      final response = await _apiService.getProviderStatus('plumber');
      debugPrint('Provider status response: ${jsonEncode(response)}');

      if (response['success']) {
        final providerData = response['data'];
        isOnline.value = providerData['is_online'] ?? false;
        isWorking.value = providerData['is_working'] ?? false;
        currentAddressName.value = providerData['address_name'] ?? 'Location not available';
        currentLatitude.value = providerData['latitude']?.toDouble() ?? 0.0;
        currentLongitude.value = providerData['longitude']?.toDouble() ?? 0.0;

        // Update phone and image from status if available
        if (providerData['phone_number'] != null) {
          phoneNumber.value = providerData['phone_number'];
          await _storageService.savePhoneNumber(phoneNumber.value);
        }
        if (providerData['profile_image'] != null) {
          profileImage.value = providerData['profile_image'];
          await _storageService.saveProfileImage(profileImage.value);
        }

        // Update user location object
        userLocation.value = UserLocation(
          latitude: currentLatitude.value,
          longitude: currentLongitude.value,
          address: currentAddressName.value,
        );

        // Start tracking if already online
        if (isOnline.value) {
          await startLocationTracking();
        }
      }
    } catch (e) {
      debugPrint('Error loading initial status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get available jobs - UPDATED to handle phone and image in providers
  Future<void> loadAvailableJobs() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getAvailableProviders('plumber');

      if (response['success']) {
        availableJobs.value = response['providers'] ?? [];
        debugPrint('Available jobs loaded: ${availableJobs.length}');

        // Log the first provider to verify phone and image data
        if (availableJobs.isNotEmpty) {
          debugPrint('First provider data: ${jsonEncode(availableJobs.first)}');
        }
      }
    } catch (e) {
      debugPrint('Error loading available jobs: $e');
      availableJobs.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await _loadInitialStatus();
    await loadAvailableJobs();
  }

  // Getters
  bool get getIsOnline => isOnline.value;
  bool get getIsWorking => isWorking.value;
  int get getUserId => userId.value;
  String get getEmail => userEmail.value;
  String get getPhoneNumber => phoneNumber.value;
  String get getProfileImage => profileImage.value;
  String get getCurrentAddressName => currentAddressName.value;
  double get getCurrentLatitude => currentLatitude.value;
  double get getCurrentLongitude => currentLongitude.value;
  bool get getIsLoading => isLoading.value;
  bool get getIsLocationLoading => isLocationLoading.value;
  Map<String, dynamic> get getProviderStats => providerStats.value;
  List get getAvailableJobs => availableJobs.value;
  UserLocation get getUserLocation => userLocation.value;
  bool get getIsTrackingLocation => isTrackingLocation.value;
  String get getErrorMessage => errorMessage.value;
}