import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:email_validator/email_validator.dart';

import '../../../controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';

import '../../../services/face_recognization_service.dart';
import '../../Apis.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final String address;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class CleanerProfileController extends GetxController {
  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  // State variables
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString bearerToken = ''.obs;
  final Rx<UserLocation?> userLocation = Rx<UserLocation?>(null);
  final RxString locationToken = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool profileExists = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxString debugLog = ''.obs;

  // Face recognition variables
  final FaceRecognitionService faceService = Get.find<FaceRecognitionService>();
  final RxList<double> faceEmbedding = <double>[].obs;
  final RxBool isFaceDetected = false.obs;
  final RxString faceStatus = ''.obs;
  final RxList<FaceAnalysisResult> faceResults = <FaceAnalysisResult>[].obs;
  final RxMap<String, dynamic> faceDetails = <String, dynamic>{}.obs;

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  // Constants
  final Color darkBlue = const Color(0xFF003E6B);
  final Color tealBlue = const Color(0xFF00A8A8);

  @override
  void onInit() {
    super.onInit();
    _logDebug('Controller initialized');
    initializeData();
  }

  @override
  void onClose() {
    super.onClose();
    _logDebug('Controller disposed');
  }

  void _logDebug(String message) {
    debugLog.value = '$message\n${debugLog.value}';
    debugPrint(message);
  }

  Future<void> initializeData() async {
    try {
      isLoading.value = true;
      _logDebug('Initializing data...');

      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      roleController.text = prefs.getString('role') ?? 'cleaner';
      nameController.text = prefs.getString('name') ?? '';
      emailController.text = user?.email ?? prefs.getString('email') ?? '';
      bearerToken.value = prefs.getString('bearer_token') ?? '';
      locationToken.value = prefs.getString('location_token') ?? '';

      await checkExistingProfile();
    } catch (e) {
      errorMessage.value = 'Initialization error: ${e.toString()}';
      _logDebug(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================
  // 🔹 Centralized HTTP Helper
  // ==========================
  Future<http.Response> _authenticatedRequest(
      String url, {
        String method = 'GET',
        Map<String, dynamic>? body,
        List<http.MultipartFile>? files,
      }) async {
    try {
      final headers = {
        'Authorization': 'Bearer ${bearerToken.value}',
        'Accept': 'application/json',
      };

      if (files != null || method == 'POST' || method == 'PUT') {
        final request = http.MultipartRequest(method, Uri.parse(url));
        request.headers.addAll(headers);

        if (body != null) {
          body.forEach((key, value) {
            if (value != null) {
              request.fields[key] = value.toString();
            }
          });
        }

        if (files != null) {
          request.files.addAll(files);
        }

        final streamed = await request.send();
        return await http.Response.fromStream(streamed);
      } else {
        return await http.get(
          Uri.parse(url),
          headers: headers,
        );
      }
    } on SocketException {
      throw Exception("No internet connection");
    } on TimeoutException {
      throw Exception("Request timed out");
    } catch (e) {
      throw Exception("Request failed: ${e.toString()}");
    }
  }

  Future<void> checkExistingProfile() async {
    try {
      _logDebug('Checking for existing profile...');

      if (bearerToken.isEmpty) {
        await refreshToken();
        if (bearerToken.isEmpty) return;
      }

      isLoading.value = true;
      final response = await _authenticatedRequest(
        '$baseUrl/api/cleaner/profile/check',
      ).timeout(const Duration(seconds: 10));

      _logDebug('Response status: ${response.statusCode}');
      _logDebug('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['exists'] == true) {
          profileExists.value = true;
          await loadExistingProfile(data['profile_id']);
        }
      }
    } catch (e) {
      errorMessage.value = 'Profile check error: $e';
      _logDebug(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getLiveLocation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled. Please enable them.");
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

      String address = placemarks.isNotEmpty
          ? [
        placemarks.first.street,
        placemarks.first.subLocality,
        placemarks.first.locality,
        placemarks.first.administrativeArea,
        placemarks.first.postalCode,
        placemarks.first.country
      ].where((part) => part != null && part.isNotEmpty).join(', ')
          : 'Unknown Location';

      userLocation.value = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      areaController.text = address;
    } catch (e) {
      errorMessage.value = "Error getting location: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadExistingProfile(String profileId) async {
    try {
      _logDebug('Loading existing profile for ID: $profileId');
      isLoading.value = true;

      final response = await _authenticatedRequest(
        '$baseUrl/api/cleaner/profile/$profileId',
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        nameController.text = data['full_name'] ?? '';
        emailController.text = data['email'] ?? '';
        experienceController.text = data['experience'] ?? '';
        skillsController.text = data['skill'] ?? '';
        areaController.text = data['service_area'] ?? '';
        rateController.text = data['hourly_rate']?.toString() ?? '';
        contactController.text = data['contact_number'] ?? '';

        userLocation.value = UserLocation(
          latitude: (data['location']?['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (data['location']?['longitude'] as num?)?.toDouble() ?? 0.0,
          address: data['location']?['address'] ?? '',
        );

        locationToken.value = data['location_token'] ?? locationToken.value;
      }
    } catch (e) {
      errorMessage.value = 'Load profile error: $e';
      _logDebug(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Updated pickImage method with camera support
  Future<void> pickImage() async {
    try {
      // Show option dialog for camera or gallery
      Get.dialog(
        AlertDialog(
          title: Text('Choose Image Source'),
          content: Text('Select where to get your profile picture from'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                _pickImageFromGallery();
              },
              child: Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _pickImageFromCamera();
              },
              child: Text('Camera'),
            ),
          ],
        ),
      );
    } catch (e) {
      errorMessage.value = "Image pick error: $e";
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        await processProfileImageForFace();
      }
    } catch (e) {
      errorMessage.value = "Gallery pick error: $e";
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        await processProfileImageForFace();
      }
    } catch (e) {
      errorMessage.value = "Camera error: $e";
    }
  }

  Future<void> processProfileImageForFace() async {
    try {
      if (profileImage.value == null) return;

      faceStatus.value = 'Analyzing facial features...';

      final results = await faceService.analyzeFaces(profileImage.value!);

      if (results.isEmpty) {
        faceStatus.value = 'No face detected in the image';
        isFaceDetected.value = false;
        return;
      }

      if (results.length > 1) {
        faceStatus.value = 'Multiple faces detected. Please use an image with only one face.';
        isFaceDetected.value = false;
        return;
      }

      final result = results.first;
      faceResults.value = results;
      faceDetails.value = faceService.getFaceDetails(result);

      // Use basic embedding from face geometry
      faceEmbedding.value = result.embedding;
      isFaceDetected.value = true;

      faceStatus.value = _generateFaceStatusMessage(result);

      _logDebug('Face analysis completed: ${result.features.length} features detected');

    } catch (e) {
      faceStatus.value = 'Face analysis failed: $e';
      isFaceDetected.value = false;
      _logDebug('Face analysis error: $e');
    }
  }


  String _generateFaceStatusMessage(FaceAnalysisResult result) {
    final buffer = StringBuffer();
    buffer.writeln('✅ Face detected and analyzed');

    if (result.expressions['smiling'] != null) {
      final smileProb = result.expressions['smiling']!;
      buffer.writeln('${smileProb > 0.5 ? '😊' : '😐'} Smiling: ${(smileProb * 100).toStringAsFixed(1)}%');
    }

    if (result.expressions['left_eye_open'] != null && result.expressions['right_eye_open'] != null) {
      final leftEye = result.expressions['left_eye_open']!;
      final rightEye = result.expressions['right_eye_open']!;
      buffer.writeln('👀 Eyes open: L${(leftEye * 100).toStringAsFixed(0)}% R${(rightEye * 100).toStringAsFixed(0)}%');
    }

    buffer.writeln('📊 Features detected: ${result.features.length}');

    return buffer.toString();
  }

  Future<void> submitProfile() async {
    try {
      _logDebug('Submitting profile...');
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final errors = validateProfileFields();
      if (errors.isNotEmpty) {
        throw Exception(errors.values.join("\n"));
      }

      // Only require face detection for new profiles
      if (!profileExists.value && !isFaceDetected.value) {
        throw Exception('Please upload a clear photo with your face for identity verification');
      }

      if (bearerToken.isEmpty) {
        await refreshToken();
        if (bearerToken.isEmpty) {
          throw Exception('Authentication required. Please login again.');
        }
      }

      final isUpdate = profileExists.value;
      final url = isUpdate ? '$baseUrl/api/cleaner/profile' : '$baseUrl/api/cleaner/profile';
      final method = isUpdate ? 'PUT' : 'POST';

      final fields = {
        'full_name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'experience': experienceController.text.trim(),
        'skill': skillsController.text.trim(),
        'service_area': areaController.text.trim(),
        'hourly_rate': rateController.text.trim(),
        'contact_number': contactController.text.trim(),
        if (userLocation.value != null) ...{
          'latitude': userLocation.value!.latitude.toString(),
          'longitude': userLocation.value!.longitude.toString(),
          'address': userLocation.value!.address,
        },
      };

      final files = <http.MultipartFile>[];
      if (profileImage.value != null) {
        final mimeType = lookupMimeType(profileImage.value!.path) ?? 'image/jpeg';
        files.add(await http.MultipartFile.fromPath(
          'cleaner_image',
          profileImage.value!.path,
          contentType: MediaType.parse(mimeType),
        ));
      }

      final response = await _authenticatedRequest(
        url,
        method: method,
        body: fields,
        files: files,
      ).timeout(const Duration(seconds: 30));

      _logDebug('Response status: ${response.statusCode}');
      _logDebug('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        successMessage.value = responseData['message'] ??
            (isUpdate ? 'Profile updated successfully' : 'Profile created successfully');

        try {
          await saveCleanerProfileToCloud();
          if (isFaceDetected.value && faceEmbedding.isNotEmpty) {
            await saveFaceDataToFirebase();
          }
        } catch (e) {
          _logDebug('Firebase backup failed: $e');
        }

        Get.toNamed(AppRoutes.CLEANER_DASHBOARD);
        final authController = Get.find<AuthController>();
        authController.hasProfile.value = true;

        if (!isUpdate && responseData['location_token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('location_token', responseData['location_token']);
          locationToken.value = responseData['location_token'];
          profileExists.value = true;
        }
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        final errorMessages = [];

        if (errorData['errors'] != null) {
          errorData['errors'].forEach((key, messages) {
            errorMessages.addAll(messages);
          });
        }

        throw Exception(errorMessages.join('\n'));
      } else {
        final errorData = json.decode(response.body);
        final errorMsg = errorData['message'] ?? 'Failed with status ${response.statusCode}';
        throw Exception(errorMsg);
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      _logDebug('Profile submission error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveFaceDataToFirebase() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) throw Exception('User not authenticated');
      if (faceResults.isEmpty) return;

      final result = faceResults.first;
      final userEmail = emailController.text.trim();

      final faceData = {
        'userId': user.uid,
        'userEmail': userEmail,
        'faceEmbedding': faceEmbedding,
        'facialFeatures': _serializeFeatures(result.features),
        'expressions': result.expressions,
        'faceDetails': faceDetails.value,
        'fullName': nameController.text.trim(),
        'profileImageUrl': '',
        'analysisTimestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'verificationStatus': 'pending',
      };

      await firestore.collection('faces').doc(userEmail).set(faceData, SetOptions(merge: true));

      _logDebug('Face data saved to Firebase successfully for user: $userEmail');

    } catch (e) {
      _logDebug('Error saving face data to Firebase: $e');
      throw Exception('Failed to save face data: $e');
    }
  }

  Map<String, dynamic> _serializeFeatures(Map<String, FacialFeature> features) {
    return features.map((key, feature) => MapEntry(key, {
      'points': feature.points.map((point) => {'x': point.x, 'y': point.y}).toList(),
      'centerPoint': feature.centerPoint != null ?
      {'x': feature.centerPoint!.x, 'y': feature.centerPoint!.y} : null,
    }));
  }

  Future<bool> verifyFace(File imageFile) async {
    try {
      final results = await faceService.analyzeFaces(imageFile);
      if (results.isEmpty) return false;

      final newResult = results.first;

      final firestore = FirebaseFirestore.instance;
      final userEmail = emailController.text.trim();

      final doc = await firestore.collection('faces').doc(userEmail).get();
      if (!doc.exists) return false;

      final storedData = doc.data()!;
      final storedEmbedding = List<double>.from(storedData['faceEmbedding'] as List);

      final similarity = faceService.calculateSimilarity(newResult.embedding, storedEmbedding);

      final isMatch = similarity > 0.7;

      _logDebug('Face verification: similarity=$similarity, match=$isMatch');

      return isMatch;
    } catch (e) {
      _logDebug('Face verification failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getFaceDataByEmail(String email) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('faces').doc(email).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      _logDebug('Error getting face data: $e');
      return null;
    }
  }

  Map<String, String> validateProfileFields() {
    final errors = <String, String>{};

    if (nameController.text.isEmpty) {
      errors['name'] = 'Name is required';
    } else if (nameController.text.length > 25) {
      errors['name'] = 'Name must be less than 25 characters';
    }

    if (emailController.text.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!EmailValidator.validate(emailController.text)) {
      errors['email'] = 'Please enter a valid email';
    }

    if (experienceController.text.isEmpty) {
      errors['experience'] = 'Experience is required';
    } else if (experienceController.text.length > 50) {
      errors['experience'] = 'Experience must be less than 50 characters';
    }

    if (skillsController.text.isEmpty) {
      errors['skills'] = 'Skills are required';
    } else if (skillsController.text.length > 100) {
      errors['skills'] = 'Skills must be less than 100 characters';
    }

    if (areaController.text.isEmpty) {
      errors['area'] = 'Service Area is required';
    } else if (areaController.text.length > 255) {
      errors['area'] = 'Service Area must be less than 255 characters';
    }

    final hourlyRate = double.tryParse(rateController.text);
    if (rateController.text.isEmpty) {
      errors['rate'] = 'Hourly rate is required';
    } else if (hourlyRate == null) {
      errors['rate'] = 'Please enter a valid number';
    } else if (hourlyRate < 0 || hourlyRate > 999999.99) {
      errors['rate'] = 'Hourly rate must be between 0 and 999,999.99';
    }

    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(contactController.text)) {
      errors['contact'] = 'Please enter a valid 10-11 digit contact number';
    }

    if (profileImage.value == null && !profileExists.value) {
      errors['profileImage'] = 'Profile image is required';
    }

    return errors;
  }

  Future<void> refreshToken() async {
    try {
      _logDebug('Refreshing token...');
      final prefs = await SharedPreferences.getInstance();
      final currentToken = prefs.getString('bearer_token');

      if (currentToken == null) {
        bearerToken.value = '';
        return;
      }

      final response = await http
          .post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 12));

      _logDebug('Refresh response status: ${response.statusCode}');
      _logDebug('Refresh response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final newToken = responseData['access_token'];
        await prefs.setString('bearer_token', newToken);
        bearerToken.value = newToken;
        _logDebug('Token refreshed successfully');
      } else {
        bearerToken.value = '';
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      bearerToken.value = '';
      throw Exception('Token refresh error: $e');
    }
  }

  Future<void> saveCleanerProfileToCloud() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      String? imageBase64;
      if (profileImage.value != null) {
        final imageBytes = await profileImage.value!.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
      }

      final cleanerData = {
        'userId': user.uid,
        'fullName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'experience': experienceController.text.trim(),
        'skills': skillsController.text.trim(),
        'serviceArea': areaController.text.trim(),
        'hourlyRate': double.tryParse(rateController.text.trim()) ?? 0.0,
        'contactNumber': contactController.text.trim(),
        'profileImage': imageBase64,
        'location': userLocation.value != null ? {
          'latitude': userLocation.value!.latitude,
          'longitude': userLocation.value!.longitude,
          'address': userLocation.value!.address,
        } : null,
        'faceEmbedding': isFaceDetected.value ? faceEmbedding : null,
        'hasFaceData': isFaceDetected.value,
        'updatedAt': FieldValue.serverTimestamp(),
        'role': 'cleaner',
      };

      // Check if document already exists for this email
      final querySnapshot = await firestore
          .collection('cleaner')
          .where('email', isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Document exists - update it
        final existingDoc = querySnapshot.docs.first;
        await firestore
            .collection('cleaner')
            .doc(existingDoc.id)
            .set(cleanerData, SetOptions(merge: true));

        _logDebug('Cleaner profile updated in Firebase for email: ${emailController.text.trim()}');
      } else {
        // Document doesn't exist - create new with user ID as document ID
        cleanerData['createdAt'] = FieldValue.serverTimestamp();
        await firestore
            .collection('cleaner')
            .doc(user.uid)
            .set(cleanerData, SetOptions(merge: true));

        _logDebug('New cleaner profile created in Firebase for user: ${user.uid}');
      }

    } catch (e) {
      _logDebug('Error saving to Firebase: $e');
      throw Exception('Failed to save profile to Firebase: $e');
    }
  }

  Future<String> _getToken() async {
    if (bearerToken.isNotEmpty) return bearerToken.value;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearer_token') ?? '';
  }
}