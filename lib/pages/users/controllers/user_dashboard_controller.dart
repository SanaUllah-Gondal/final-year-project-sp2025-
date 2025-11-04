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
import '../appointments_screen.dart';
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
  final NotificationService notificationService = Get.find<NotificationService>();
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

  // Enhanced appointment checking variables
  var hasPendingAppointments = false.obs;
  var ongoingAppointments = <Map<String, dynamic>>[].obs;
  var isLoadingAppointments = false.obs;
  var allUserAppointments = <Map<String, dynamic>>[].obs;
  var pendingServices = <String>[].obs; // Track which services have pending appointments

  Timer? _appointmentTimer;
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> services = [
    {
      "icon": Icons.cleaning_services,
      "title": "Professional Cleaning",
      "type": "cleaner",
      "description": "Spotless cleaning services for your home or office",
      "color": Color(0xFF4CAF50)
    },
    {
      "icon": Icons.plumbing,
      "title": "Expert Plumbing",
      "type": "plumber",
      "description": "Fix leaks, installations, and plumbing emergencies",
      "color": Color(0xFF2196F3)
    },
    {
      "icon": Icons.electrical_services,
      "title": "Electrical Solutions",
      "type": "electrician",
      "description": "Wiring, repairs, and electrical safety checks",
      "color": Color(0xFFFF9800)
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeController();
    _startAppointmentTimer();
  }

  @override
  void onClose() {
    _appointmentTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _startAppointmentTimer() {
    // Check appointments every 5 seconds
    _appointmentTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!isLoadingAppointments.value) {
        checkForPendingAppointments();
      }
    });
  }

  Future<void> _initializeController() async {
    try {
      debugPrint('[HomeController] Initializing...');
      await _loadUserData();
      filteredServices.assignAll(services);
      await _initializeDeviceToken();
      await fetchUserLocation();
      await loadSavedLocations();
      await checkForPendingAppointments();
      debugPrint('[HomeController] Initialization complete');
    } catch (e) {
      debugPrint('[HomeController] Error during initialization: $e');
    }
  }

  // Enhanced appointment checking method
  Future<void> checkForPendingAppointments() async {
    try {
      isLoadingAppointments.value = true;
      final response = await _apiService.getUserAppointments();

      if (response['success'] == true) {
        final appointments = List<Map<String, dynamic>>.from(response['data'] ?? []);
        allUserAppointments.assignAll(appointments);

        final pendingAppointments = appointments.where((appointment) =>
        appointment['status'] == 'pending' ||
            appointment['status'] == 'confirmed' ||
            appointment['status'] == 'accepted'
        ).toList();

        hasPendingAppointments.value = pendingAppointments.isNotEmpty;
        ongoingAppointments.assignAll(pendingAppointments);

        // Update pending services list
        final servicesSet = <String>{};
        for (var appointment in pendingAppointments) {
          final serviceType = appointment['service_type']?.toString().toLowerCase() ?? 'unknown';
          if (serviceType != 'unknown') {
            servicesSet.add(serviceType);
          }
        }
        pendingServices.assignAll(servicesSet.toList());

        // Log all pending appointments
        for (var appointment in pendingAppointments) {
          final serviceType = appointment['service_type']?.toString() ?? 'unknown';
          final status = appointment['status']?.toString() ?? 'unknown';
          debugPrint('[HomeController] Pending appointment - Service: $serviceType, Status: $status');
        }

        debugPrint('[HomeController] Found ${pendingAppointments.length} pending appointments across ${servicesSet.length} services: ${servicesSet.join(', ')}');
      }
    } catch (e) {
      debugPrint('[HomeController] Error checking pending appointments: $e');
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  // Enhanced method to check if a specific service can be booked
  Future<bool> canBookService(String serviceType) async {
    try {
      debugPrint('[HomeController] Checking if can book $serviceType');

      // Check if this service type has any pending appointments
      final hasPendingForService = pendingServices.any((service) => service == serviceType.toLowerCase());

      if (hasPendingForService) {
        debugPrint('[HomeController] Blocking booking - found pending appointments for service: $serviceType');
        return false;
      }

      debugPrint('[HomeController] Allowing booking - no pending appointments for service: $serviceType');
      return true;
    } catch (e) {
      debugPrint('[HomeController] Error checking if can book service: $e');
      return true; // Allow booking if there's an error
    }
  }

  // Enhanced dialog to show all pending services
  Future<void> showOngoingAppointmentDialog(BuildContext context, String serviceType) async {
    final pendingForThisService = ongoingAppointments.where((appointment) {
      final appointmentService = appointment['service_type']?.toString().toLowerCase() ?? '';
      return appointmentService == serviceType.toLowerCase();
    }).toList();

    if (pendingForThisService.isNotEmpty) {
      final firstAppointment = pendingForThisService.first;
      final appointmentStatus = firstAppointment['status']?.toString() ?? 'pending';
      final count = pendingForThisService.length;

      String message = 'You have $count ongoing $serviceType appointment${count > 1 ? 's' : ''} (Status: ${appointmentStatus.toUpperCase()}).\n\n';
      message += 'Please complete or cancel your existing $serviceType appointment${count > 1 ? 's' : ''} before booking a new one.';

      await _showModernDialog(
        context,
        title: 'Ongoing $serviceType Appointment${count > 1 ? 's' : ''}',
        content: message,
        actions: [
          _DialogAction(
            text: 'OK',
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
          _DialogAction(
            text: 'View Appointments',
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => UserAppointmentsScreen());
            },
            isPrimary: true,
          ),
        ],
      );
    }
  }

  // Modern dialog method
  Future<void> _showModernDialog(
      BuildContext context, {
        required String title,
        required String content,
        required List<_DialogAction> actions,
      }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24),
                // Improved button layout with proper spacing
                if (actions.length == 1)
                  actions.first.build(), // Single button takes full width
                if (actions.length > 1)
                  Row(
                    children: [
                      Expanded(
                        child: actions[0].build(),
                      ),
                      SizedBox(width: 12), // Proper spacing between buttons
                      Expanded(
                        child: actions[1].build(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // Modern loading dialog
  void showModernLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF667eea).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Please wait while we find the best professionals...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern no providers found dialog
  void showModernNoProvidersDialog(BuildContext context, String serviceType, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFFFF6B6B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_search,
                  size: 40,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'No Providers Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                errorMessage.isNotEmpty
                    ? errorMessage
                    : 'No ${serviceType.capitalizeFirst} providers are currently available in your area.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _DialogAction(
                      text: 'Try Again',
                      onPressed: () {
                        Navigator.pop(context);
                        onServiceSelected(serviceType, context);
                      },
                      isPrimary: true,
                    ).build(),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _DialogAction(
                      text: 'OK',
                      onPressed: () => Navigator.pop(context),
                      isPrimary: false,
                    ).build(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated service selection with modern loading
  Future<void> onServiceSelected(String serviceType, BuildContext context) async {
    debugPrint('[HomeController] Service selected: $serviceType');

    // Check if user can book this specific service type
    final canBook = await canBookService(serviceType);

    if (!canBook) {
      await showOngoingAppointmentDialog(context, serviceType);
      return;
    }

    selectedServiceType.value = serviceType;

    // Show modern loading dialog
    showModernLoadingDialog(context, 'Finding Nearby Providers');

    await getNearbyProviders(serviceType);

    // Close loading dialog
    Navigator.of(context).pop();

    if (nearbyProviders.isEmpty) {
      showModernNoProvidersDialog(context, serviceType, apiError.value);
    } else {
      Get.to(() => MapScreen(
        serviceType: serviceType,
        userLocation: userCoordinates.value,
        providers: nearbyProviders.toList(),
      ));
    }
  }

  // Rest of your existing methods remain the same...
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

      debugPrint('[HomeController] User data loaded - Email: ${userEmail.value}');
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _initializeDeviceToken() async {
    try {
      debugPrint('[HomeController] Getting device token...');
      final token = await notificationService.getDeviceToken();
      deviceToken.value = token;
      debugPrint('[HomeController] Device token obtained: $token');

      FcmService.firebaseInit();
      notificationService.firebaseInit();
      notificationService.setupInteractMessage();

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

      if (email.isEmpty || token.isEmpty) {
        debugPrint('Email or token is empty, skipping token save');
        return;
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference tokensCollection = firestore.collection('userTokens');

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
      debugPrint('[HomeController] Got coordinates: ${position.latitude}, ${position.longitude}');

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
      debugPrint('[HomeController] Fetching nearby providers for: $serviceType');
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
          final providers = List<Map<String, dynamic>>.from(data['providers'] ?? []);
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Select Service Type',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ...services.map((service) {
                  return ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: service['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(service['icon'], color: service['color']),
                    ),
                    title: Text(
                      service['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(service['description']),
                    onTap: () {
                      debugPrint('[HomeController] Selected service: ${service['type']}');
                      Navigator.pop(context);
                      onServiceSelected(service['type'], context);
                    },
                  );
                }).toList(),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
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

/// Helper class for modern dialog actions
class _DialogAction {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  _DialogAction({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
  });

  Widget build() {
    return Container(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Color(0xFF667eea) : Colors.grey[300],
          foregroundColor: isPrimary ? Colors.white : Colors.grey[700],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}