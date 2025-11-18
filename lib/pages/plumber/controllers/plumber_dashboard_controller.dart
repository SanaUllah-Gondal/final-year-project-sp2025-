import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/storage_service.dart';
import 'package:plumber_project/models/user_location.dart';
import 'package:plumber_project/services/face_recognization_service.dart'; // Add this import
import '../../../notification/fcm_service.dart';
import '../../../notification/notification_service.dart';
import '../../../widgets/app_color.dart';
import '../../chat_screen.dart';

class PlumberDashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final FaceRecognitionService _faceService = Get.find<FaceRecognitionService>(); // Add this
  final NotificationService notificationService = Get.find<NotificationService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker(); // Add this

  // Observable variables
  var isOnline = false.obs;
  var isWorking = false.obs;
  var isLoading = false.obs;
  var isLocationLoading = false.obs;
  var isVerifyingFace = false.obs; // Add this
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

  // Face verification variables - ADD THESE
  var faceVerificationStatus = ''.obs;
  var isFaceVerified = false.obs;
  var faceVerificationScore = 0.0.obs;

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
      debugPrint('[PlumberDashboardController] Initializing...');

      // Load user data first
      await _loadUserData();

      // Initialize device token and FCM services
      await _initializeDeviceToken();

      // Load initial status and appointments
      await _loadInitialStatus();
      await loadAppointments();

      // Check face verification status
      await checkFaceVerificationStatus();

      // Start real-time request monitoring
      _startRequestMonitoring();

      debugPrint('[PlumberDashboardController] Initialization complete');
    } catch (e) {
      debugPrint('[PlumberDashboardController] Error initializing: $e');
    }
  }

  // ADD FACE VERIFICATION METHODS
  Future<bool> verifyUserIdentity() async {
    try {
      isVerifyingFace.value = true;
      faceVerificationStatus.value = 'Starting identity verification...';

      // Show image source selection
      final imageSource = await _showImageSourceDialog();
      if (imageSource == null) {
        faceVerificationStatus.value = 'Verification cancelled';
        return false;
      }

      // Capture image
      final verificationImage = await _captureVerificationImage(imageSource);
      if (verificationImage == null) {
        faceVerificationStatus.value = 'No image selected';
        return false;
      }

      // Analyze face in the image
      faceVerificationStatus.value = 'Analyzing facial features...';
      final results = await _faceService.analyzeFaces(verificationImage);

      if (results.isEmpty) {
        faceVerificationStatus.value = 'No face detected. Please try again.';
        return false;
      }

      if (results.length > 1) {
        faceVerificationStatus.value = 'Multiple faces detected. Please use an image with only your face.';
        return false;
      }

      // Get stored face data from Firebase
      final storedFaceData = await _getStoredFaceData();
      if (storedFaceData == null) {
        faceVerificationStatus.value = 'No face data found in system. Please update your profile.';
        return false;
      }

      // Compare faces
      faceVerificationStatus.value = 'Comparing with stored profile...';
      final verificationResult = results.first;
      final storedEmbedding = List<double>.from(storedFaceData['faceEmbedding'] as List);
      final currentEmbedding = verificationResult.embedding;

      final similarity = _faceService.calculateSimilarity(currentEmbedding, storedEmbedding);
      faceVerificationScore.value = similarity;

      // Set threshold for verification (adjust as needed)
      final verificationThreshold = 0.7;
      final isVerified = similarity >= verificationThreshold;

      if (isVerified) {
        faceVerificationStatus.value = 'Identity verified successfully!';
        isFaceVerified.value = true;

        // Log verification event
        await _logVerificationEvent(true, similarity);

        Get.snackbar(
          'Verification Successful',
          'Identity verified with ${(similarity * 100).toStringAsFixed(1)}% match',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        faceVerificationStatus.value = 'Identity verification failed. Please try again.';
        isFaceVerified.value = false;

        // Log verification event
        await _logVerificationEvent(false, similarity);

        Get.snackbar(
          'Verification Failed',
          'Face match only ${(similarity * 100).toStringAsFixed(1)}%. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return isVerified;
    } catch (e) {
      faceVerificationStatus.value = 'Verification error: $e';
      debugPrint('Face verification error: $e');
      return false;
    } finally {
      isVerifyingFace.value = false;
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.dialog<ImageSource>(
      AlertDialog(
        title: Text('Identity Verification'),
        content: Text('Please verify your identity to go online. Choose image source:'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: ImageSource.camera),
            child: Text('Camera'),
          ),
          TextButton(
            onPressed: () => Get.back(result: ImageSource.gallery),
            child: Text('Gallery'),
          ),
          TextButton(
            onPressed: () => Get.back(result: null),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<File?> _captureVerificationImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        preferredCameraDevice: source == ImageSource.camera
            ? CameraDevice.front
            : CameraDevice.rear,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getStoredFaceData() async {
    try {
      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) return null;

      final doc = await _firestore.collection('faces').doc(userEmail).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting stored face data: $e');
      return null;
    }
  }

  Future<void> _logVerificationEvent(bool success, double score) async {
    try {
      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) return;

      await _firestore.collection('verification_logs').add({
        'userEmail': userEmail,
        'success': success,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'plumber_app',
        'role': 'plumber',
      });
    } catch (e) {
      debugPrint('Error logging verification: $e');
    }
  }

  Future<bool> checkFaceVerificationStatus() async {
    try {
      final storedFaceData = await _getStoredFaceData();
      isFaceVerified.value = storedFaceData != null;
      return isFaceVerified.value;
    } catch (e) {
      debugPrint('Error checking face verification status: $e');
      return false;
    }
  }

  Future<void> openOrCreateChat({
    required String userEmail,
    required String userName,
    String? userImage,
  }) async {
    try {
      final currentUser =  _auth.currentUser!;
      final currentUserEmail = currentUser.email!;
      final currentUserName = currentUser.displayName ?? 'Plumber';

      // Create chat documents
      await _firestore
          .collection('messages')
          .doc(currentUserEmail)
          .collection('chats')
          .doc(userEmail)
          .set({
        'otherUserName': userName,
        'otherUserImage': userImage,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'isOnline': false,
      }, SetOptions(merge: true));

      await _firestore
          .collection('messages')
          .doc(userEmail)
          .collection('chats')
          .doc(currentUserEmail)
          .set({
        'otherUserName': currentUserName,
        'otherUserImage': currentUser.photoURL,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'isOnline': false,
      }, SetOptions(merge: true));

      // Navigate to chat screen
      Get.to(
            () => ChatScreen(
          otherUserEmail: userEmail,
          otherUserName: userName,
          otherUserImage: userImage,
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
      'New Plumbing Request!',
      'You have ${pendingRequestCount.value} new service request${pendingRequestCount.value > 1 ? 's' : ''}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.plumbing, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  Future<void> _initializeDeviceToken() async {
    try {
      debugPrint('[PlumberDashboardController] Getting device token...');

      final token = await notificationService.getDeviceToken();
      deviceToken.value = token;
      debugPrint('[PlumberDashboardController] Device token obtained: $token');

      // Initialize FCM services
      FcmService.firebaseInit();
      notificationService.firebaseInit();
      notificationService.setupInteractMessage();

      // Save token to Firebase
      await saveDeviceToken();

    } catch (e) {
      debugPrint('[PlumberDashboardController] Error initializing device token: $e');
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
        'userType': 'plumber',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ Device token saved for plumber: $email');
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

    debugPrint('Pending plumbing requests: ${pendingRequestCount.value}');
  }

  Future<void> loadAppointments() async {
    try {
      final response = await _apiService.getPlumberAppointments();

      if (response['success']) {
        appointments.value = response['data']?['data'] ?? [];
        _checkPendingRequests();
      }
    } catch (e) {
      debugPrint('Error loading plumber appointments: $e');
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

      debugPrint('[PlumberDashboardController] User data loaded - Email: ${userEmail.value}');
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
        providerType: 'plumber',
        addressName: addressName,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      debugPrint('Error updating location on server: $e');
    }
  }

  // UPDATED toggleOnlineStatus with face verification
  Future<void> toggleOnlineStatus() async {
    try {
      isLoading.value = true;

      // If going online, verify identity first
      if (!isOnline.value) {
        final isVerified = await verifyUserIdentity();
        if (!isVerified) {
          isLoading.value = false;
          Get.snackbar(
            'Verification Required',
            'Please verify your identity to go online',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }

        await getLiveLocation();
        await startLocationTracking();
        _startRequestMonitoring(); // Start monitoring when going online
      } else {
        _stopLocationTracking();
        _stopRequestMonitoring(); // Stop monitoring when going offline
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
        providerType: 'plumber',
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

      final profileResponse = await _apiService.getMyPlumberProfile();
      if (!profileResponse['success']) {
        throw Exception('No plumber profile found');
      }

      final response = await _apiService.getProviderStatus('plumber');

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
    await checkFaceVerificationStatus();
  }

  // Manual check for new requests
  Future<void> manuallyCheckRequests() async {
    await _checkForNewRequests();
    Get.snackbar(
      'Refreshed',
      'Checked for new plumbing requests',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 1),
    );
  }

  // Method to reset face verification (for testing or re-verification)
  void resetFaceVerification() {
    isFaceVerified.value = false;
    faceVerificationScore.value = 0.0;
    faceVerificationStatus.value = '';
  }
}