import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/storage_service.dart';
import 'package:plumber_project/models/user_location.dart';

class ElectricianDashboardController extends GetxController {
  final ApiService _apiService = Get.find();
  final StorageService _storageService = Get.find();

  // Observable variables
  var isOnline = false.obs;
  var isWorking = false.obs;
  var isLoading = false.obs;
  var isLocationLoading = false.obs;
  var errorMessage = ''.obs;
  var userId = 0.obs;
  var providerStats = <String, dynamic>{}.obs;
  var availableJobs = [].obs;

  // Location variables
  var userLocation = UserLocation(
    latitude: 0.0,
    longitude: 0.0,
    address: 'Location not available',
  ).obs;

  var currentLocation = 'Location not available'.obs;

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
      await _loadUserId();
      await _loadInitialStatus();
    } catch (e) {
      debugPrint('Error initializing controller: $e');
    }
  }

  // Load user ID from storage
  Future<void> _loadUserId() async {
    try {
      final storedUserId = await _storageService.getUserId();
      if (storedUserId != null) {
        userId.value = storedUserId;
        debugPrint('Electrician User ID from storage: ${userId.value}');
      } else {
        throw Exception('User ID not found in storage');
      }
    } catch (e) {
      debugPrint('Error loading user ID: $e');
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

      // Format address
      String address = placemarks.isNotEmpty
          ? [
        placemarks.first.street ?? '',
        placemarks.first.subLocality ?? '',
        placemarks.first.locality ?? '',
        placemarks.first.administrativeArea ?? '',
      ].where((part) => part.isNotEmpty).join(', ')
          : 'Unknown Location';

      // Update location values
      userLocation.value = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      currentLocation.value = address;

      // If online, automatically update location on server
      if (isOnline.value) {
        await _updateLocationOnServer(address, position.latitude, position.longitude);
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

          String address = placemarks.isNotEmpty
              ? [
            placemarks.first.street ?? '',
            placemarks.first.subLocality ?? '',
            placemarks.first.locality ?? '',
          ].where((part) => part.isNotEmpty).join(', ')
              : 'Tracking...';

          userLocation.value = UserLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            address: address,
          );

          currentLocation.value = address;

          // Update server if online
          if (isOnline.value) {
            await _updateLocationOnServer(address, position.latitude, position.longitude);
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
  Future<void> _updateLocationOnServer(String address, double latitude, double longitude) async {
    try {
      await _apiService.updateProviderLocation(
        providerType: 'electrician',
        location: address,
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
        providerType: 'electrician',
        isOnline: !isOnline.value,
        location: currentLocation.value,
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
        providerType: 'electrician',
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

  // Load initial status from API
  Future<void> _loadInitialStatus() async {
    try {
      isLoading.value = true;

      // First check if user has an electrician profile
      final profileResponse = await _apiService.getMyElectricianProfile();
      debugPrint('Electrician Profile response: ${jsonEncode(profileResponse)}');

      if (!profileResponse['success']) {
        throw Exception('No electrician profile found. Please create a profile first.');
      }

      final response = await _apiService.getProviderStatus('electrician');
      debugPrint('Electrician Provider status response: ${jsonEncode(response)}');

      if (response['success']) {
        final providerData = response['data'];
        isOnline.value = providerData['is_online'] ?? false;
        isWorking.value = providerData['is_working'] ?? false;
        currentLocation.value = providerData['current_location'] ?? 'Location not available';

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

  // Get available jobs
  Future<void> loadAvailableJobs() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getAvailableProviders('electrician');

      if (response['success']) {
        availableJobs.value = response['providers'] ?? [];
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
  String get getCurrentLocation => currentLocation.value;
  bool get getIsLoading => isLoading.value;
  bool get getIsLocationLoading => isLocationLoading.value;
  Map<String, dynamic> get getProviderStats => providerStats.value;
  List get getAvailableJobs => availableJobs.value;
  UserLocation get getUserLocation => userLocation.value;
  bool get getIsTrackingLocation => isTrackingLocation.value;
  String get getErrorMessage => errorMessage.value;
}