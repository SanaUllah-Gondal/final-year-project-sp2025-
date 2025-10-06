import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:plumber_project/pages/users/user_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:plumber_project/pages/Apis.dart';
import '../../../notification/fcm_service.dart';
import '../../../notification/notification_service.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../profile.dart';
import '../../emergency.dart';

class HomeController extends GetxController {
  var showSearchBar = false.obs;
  var selectedIndex = 0.obs;
  var userLocation = 'Fetching location...'.obs;
  var userEmail = ''.obs;
  var phoneNumber = ''.obs;
  var profileImage = ''.obs;
  var deviceToken = ''.obs;
  var userId = 0.obs;
  final NotificationService notificationService = Get.find<
      NotificationService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();

  var userCoordinates = Position(
    latitude: 0.0,
    longitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    altitudeAccuracy: 1.0,
    headingAccuracy: 1.0,
  ).obs;

  var savedLocations = <String>[].obs;
  var selectedLocation = ''.obs;
  var filteredServices = <Map<String, dynamic>>[].obs;
  var isLoadingLocation = false.obs;
  var nearbyProviders = <Map<String, dynamic>>[].obs;
  var selectedServiceType = ''.obs;
  var isLoadingProviders = false.obs;
  var apiError = ''.obs;

  // New variables for appointment checking
  var hasPendingAppointments = false.obs;
  var ongoingAppointment = <String, dynamic>{}.obs;
  var isLoadingAppointments = false.obs;
  var allUserAppointments = <Map<String, dynamic>>[].obs;

  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> services = [
    {"icon": Icons.cleaning_services, "title": "Cleaner", "type": "cleaner"},
    {"icon": Icons.tap_and_play, "title": "Plumber", "type": "plumber"},
    {
      "icon": Icons.electrical_services,
      "title": "Electrician",
      "type": "electrician"
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeController();
    refreshAppointmentStatus();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _initializeController() async {
    try {
      debugPrint('[HomeController] Initializing...');

      // Load user data first
      await _loadUserData();

      // Initialize services
      filteredServices.assignAll(services);

      // Get device token and save it
      await _initializeDeviceToken();

      // Load other data
      await fetchUserLocation();
      await loadSavedLocations();

      // Check for pending appointments
      await checkForPendingAppointments();

      debugPrint('[HomeController] Initialization complete');
    } catch (e) {
      debugPrint('[HomeController] Error during initialization: $e');
    }
  }

  // Check for pending appointments periodically
  Future<void> checkForPendingAppointments() async {
    try {
      isLoadingAppointments.value = true;
      final response = await _apiService.getUserAppointments();

      if (response['success'] == true) {
        final appointments = List<Map<String, dynamic>>.from(
            response['data'] ?? []);
        allUserAppointments.assignAll(appointments);

        // Check if there are any pending or confirmed appointments
        final pendingAppointments = appointments.where((appointment) =>
        appointment['status'] == 'pending' ||
            appointment['status'] == 'confirmed' ||
            appointment['status'] == 'accepted'
        ).toList();

        hasPendingAppointments.value = pendingAppointments.isNotEmpty;

        if (pendingAppointments.isNotEmpty) {
          ongoingAppointment.value = pendingAppointments.first;
        }

        debugPrint('[HomeController] Found ${pendingAppointments
            .length} pending appointments');
      }
    } catch (e) {
      debugPrint('[HomeController] Error checking pending appointments: $e');
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  // Enhanced appointment checking methods
  Future<Map<String, dynamic>> checkOngoingAppointmentsForService(
      String serviceType) async {
    try {
      debugPrint(
          '[HomeController] Checking ongoing appointments for: $serviceType');

      // First check local pending appointments
      if (hasPendingAppointments.value && ongoingAppointment.isNotEmpty) {
        final currentService = ongoingAppointment['service_type']
            ?.toString()
            .toLowerCase() ?? '';
        if (currentService == serviceType.toLowerCase()) {
          return {
            'hasOngoing': true,
            'serviceType': currentService,
            'appointment': ongoingAppointment,
            'message': 'You already have an ongoing $currentService appointment'
          };
        }
      }

      // Then check with API
      final response = await _apiService.checkOngoingAppointments(serviceType);
      return response;
    } catch (e) {
      debugPrint('[HomeController] Error checking ongoing appointments: $e');
      return {
        'hasOngoing': false,
        'message': 'Error checking appointments: $e'
      };
    }
  }

  // Check if user can book a new service
  Future<bool> canBookService(String serviceType) async {
    try {
      debugPrint('[HomeController] Checking if can book $serviceType');

      // First check local pending appointments
      if (hasPendingAppointments.value) {
        final currentService = ongoingAppointment['service_type']
            ?.toString()
            .toLowerCase() ?? '';
        if (currentService.isNotEmpty) {
          return false;
        }
      }

      // Then check with API for specific service type
      final response = await _apiService.checkOngoingAppointments(serviceType);

      if (response['success'] == true && response['hasOngoing'] == true) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('[HomeController] Error checking if can book service: $e');
      return true; // Allow booking if there's an error in checking
    }
  }

  // Show ongoing appointment dialog
  Future<void> showOngoingAppointmentDialog(BuildContext context,
      String serviceType) async {
    String message = 'You already have an ongoing appointment. ';
    String currentService = ongoingAppointment['service_type']
        ?.toString()
        .toLowerCase() ?? 'service';

    if (currentService == serviceType.toLowerCase()) {
      message = 'You already have an ongoing $currentService appointment. ';
    } else {
      message = 'You already have an ongoing $currentService appointment. ';
    }

    message +=
    'Please complete or cancel your existing appointment before booking a new one.';

    await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Ongoing Appointment'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to appointments screen
                  // Get.to(() => UserAppointmentsScreen());
                },
                child: Text('View Appointments'),
              ),
            ],
          ),
    );
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

      debugPrint(
          '[HomeController] User data loaded - Email: ${userEmail.value}');
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _initializeDeviceToken() async {
    try {
      debugPrint('[HomeController] Getting device token...');

      // Get device token
      final token = await notificationService.getDeviceToken();
      deviceToken.value = token;
      debugPrint('[HomeController] Device token obtained: $token');

      // Initialize FCM services
      FcmService.firebaseInit();
      notificationService.firebaseInit();
      notificationService.setupInteractMessage();

      // Save token to Firebase
      await saveDeviceToken();
    } catch (e) {
      debugPrint('[HomeController] Error initializing device token: $e');
    }
  }

  Future<void> saveDeviceToken() async {
    try {
      final email = userEmail.value;
      final token = deviceToken.value;
      final id = userId.value;

      // Check if email and token are not empty
      if (email.isEmpty) {
        debugPrint('Email is empty, skipping token save');
        return;
      }

      if (token.isEmpty) {
        debugPrint('Device token is empty, skipping save');
        return;
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference tokensCollection = firestore.collection(
          'userTokens');

      // Use email as document ID for easier management
      await tokensCollection.doc(email).set({
        'email': email,
        'deviceToken': token,
        'userId': id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ Device token saved for user: $email');
    } catch (e) {
      debugPrint('❌ Error saving device token: $e');
    }
  }

  Future<void> fetchUserLocation() async {
    try {
      debugPrint('[HomeController] Fetching user location...');
      isLoadingLocation.value = true;

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('[HomeController] Location permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('[HomeController] Requested permission: $permission');
        if (permission == LocationPermission.denied) {
          userLocation.value = 'Location permission denied';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        userLocation.value = 'Location permission permanently denied';
        return;
      }

      debugPrint('[HomeController] Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userCoordinates.value = position;
      debugPrint(
          '[HomeController] Got coordinates: ${position.latitude}, ${position
              .longitude}');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = placemarks.isNotEmpty
          ? [
        placemarks.first.street ?? '',
        placemarks.first.subLocality ?? '',
        placemarks.first.locality ?? '',
        placemarks.first.administrativeArea ?? '',
      ].where((part) => part.isNotEmpty).join(', ')
          : 'Current Location';

      userLocation.value = address;
      selectedLocation.value = address;
      debugPrint('[HomeController] Address: $address');
    } catch (e) {
      debugPrint('[HomeController] Error getting location: $e');
      userLocation.value = 'Error getting location: $e';
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> getNearbyProviders(String serviceType) async {
    try {
      debugPrint(
          '[HomeController] Fetching nearby providers for: $serviceType');
      isLoadingProviders.value = true;
      apiError.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token');

      debugPrint('[HomeController] Token exists: ${token != null}');

      final url = Uri.parse('$baseUrl/api/providers/available/$serviceType');
      debugPrint('[HomeController] API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('[HomeController] Response status: ${response.statusCode}');
      debugPrint('[HomeController] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('[HomeController] Parsed data: $data');

        if (data['success'] == true) {
          final providers = List<Map<String, dynamic>>.from(
              data['providers'] ?? []);
          debugPrint('[HomeController] Found ${providers.length} providers');

          if (providers.isNotEmpty) {
            for (var provider in providers) {
              debugPrint('[HomeController] Provider: ${provider['name']}, '
                  'Type: ${provider['provider_type']}, '
                  'Lat: ${provider['latitude']}, '
                  'Lng: ${provider['longitude']}, '
                  'Email: ${provider['email']}');
            }
          }

          nearbyProviders.assignAll(providers);
        } else {
          apiError.value = data['message'] ?? 'Failed to fetch providers';
          debugPrint('[HomeController] API error: ${apiError.value}');
        }
      } else {
        apiError.value = 'HTTP Error: ${response.statusCode}';
        debugPrint('[HomeController] HTTP error: ${response.statusCode}');
      }
    } on TimeoutException {
      apiError.value = 'Request timed out';
      debugPrint('[HomeController] Request timed out');
    } catch (e) {
      apiError.value = 'Error: $e';
      debugPrint('[HomeController] Error fetching nearby providers: $e');
      nearbyProviders.clear();
    } finally {
      isLoadingProviders.value = false;
    }
  }

  void showServiceSelectionDialog(BuildContext context) {
    debugPrint('[HomeController] Showing service selection dialog');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Service Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: services.map((service) {
                return ListTile(
                  leading: Icon(service['icon'], color: Colors.blue),
                  title: Text(service['title']),
                  onTap: () {
                    debugPrint(
                        '[HomeController] Selected service: ${service['type']}');
                    Navigator.pop(context);
                    onServiceSelected(service['type'], context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> onServiceSelected(String serviceType,
      BuildContext context) async {
    debugPrint('[HomeController] Service selected: $serviceType');


      // Show detailed dialog about ongoing appointment
      await showOngoingAppointmentDialog(context, serviceType);


    selectedServiceType.value = serviceType;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
      const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finding nearby providers...'),
          ],
        ),
      ),
    );

    await getNearbyProviders(serviceType);

    // Close loading dialog
    Navigator.of(context).pop();

    if (nearbyProviders.isEmpty) {
      // Show error dialog if no providers found
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text('No Providers Found'),
              content: Text(apiError.value.isNotEmpty
                  ? apiError.value
                  : 'No ${serviceType
                  .capitalizeFirst} providers available in your area.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } else {
      // Navigate to map screen if providers found
      Get.to(() =>
          MapScreen(
            serviceType: serviceType,
            userLocation: userCoordinates.value,
            providers: nearbyProviders.toList(),
          ));
    }
  }

  void toggleSearchBar() {
    showSearchBar.value = !showSearchBar.value;
    if (!showSearchBar.value) {
      searchController.clear();
      filteredServices.assignAll(services);
    }
  }

  void filterServices(String query) {
    filteredServices.assignAll(
      services.where((service) =>
          service["title"].toLowerCase().contains(query.toLowerCase()))
          .toList(),
    );
  }

  void onTabSelected(int index, BuildContext context) {
    if (index == 1) {
      Get.to(() => EmergencyScreen());
    } else if (index == 2) {
      Get.to(() => ProfileScreen());
    } else {
      selectedIndex.value = index;
    }
  }

  void onServiceCardClicked(String serviceName, BuildContext context) {
    final service = services.firstWhere(
          (s) => s["title"].toLowerCase() == serviceName.toLowerCase(),
      orElse: () => {},
    );

    if (service.isNotEmpty) {
      onServiceSelected(service['type'], context);
    }
  }

  Future<void> updateUserLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearer_token');
    if (token == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/profile/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({"location": location}),
      );

      if (response.statusCode == 200) {
        userLocation.value = location;
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  Future<void> loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    savedLocations.value = prefs.getStringList('saved_locations') ?? [];
  }

  Future<void> refreshLocation() async {
    await fetchUserLocation();
  }

  // Refresh appointment status
  Future<void> refreshAppointmentStatus() async {
    await checkForPendingAppointments();
  }

}