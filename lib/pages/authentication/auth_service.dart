// lib/pages/authentication/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Apis.dart';

class AuthService extends GetxService {
  final ApiService _apiService = Get.find();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final StorageService _storageService = Get.find();


  Future<dynamic> getRequest(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers, // can be null
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed request: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> loginWithLaravel(String email, String password) async {
    try {
      final url = '$baseUrl/api/login';
      debugPrint('🔐 Attempting Laravel login to: $url');
      debugPrint('📧 Email: $email');
      debugPrint('🔑 Password: ${'*' * password.length} (length: ${password.length})');

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'email': email, 'password': password});

      debugPrint('📦 Request body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      debugPrint('🔄 Response status: ${response.statusCode}');
      debugPrint('📄 Response body: ${response.body}');

      // Handle different response scenarios
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          if (data['access_token'] == null) {
            debugPrint('❌ No access token in response');
            throw 'Authentication failed: No access token received';
          }

          debugPrint('✅ Login successful');
          debugPrint('🔑 Access token: ${data['access_token']?.substring(0, 10)}...');
          debugPrint('👤 User data: ${data['user']}');

          return data;
        } catch (e) {
          debugPrint('❌ JSON parsing error: $e');
          throw 'Failed to parse server response';
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Handle client errors
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['error'] ??
              errorData['message'] ??
              'Login failed (${response.statusCode})';
          debugPrint('❌ Client error: $errorMessage');
          throw errorMessage;
        } catch (e) {
          debugPrint('❌ Error parsing error response: $e');
          throw 'Login failed with status code: ${response.statusCode}';
        }
      } else {
        // Handle server errors
        debugPrint('❌ Server error: ${response.statusCode}');
        throw 'Server error occurred (${response.statusCode})';
      }
    } on TimeoutException {
      debugPrint('⏱️ Request timed out');
      throw 'Connection timed out. Please try again.';
    } on http.ClientException catch (e) {
      debugPrint('🌐 Network error: $e');
      throw 'Network error occurred. Please check your connection.';
    } on FormatException catch (e) {
      debugPrint('📝 Response format error: $e');
      throw 'Invalid server response format';
    } catch (e) {
      debugPrint('❗ Unexpected error: $e');
      throw 'An unexpected error occurred during login';
    }
  }

  Future<UserCredential> loginWithFirebase(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _firebaseErrorToMessage(e);
    } catch (e) {
      throw 'Failed to login with Firebase: ${e.toString()}';
    }
  }

  Future<bool> checkProfileExists() async {
    try {
      final token = _storageService.getToken();
      final userId = _storageService.getUserId();
      final role = _storageService.getRole();


      if (token == null || userId == null || role == null) {
        return false;
      }
      final prefs= await SharedPreferences.getInstance();
      final profileId= prefs.getString('user_id') ?? '';

      final response = await _authenticatedRequest(
        '$baseUrl/profiles/plumber/$profileId',
      ).timeout(const Duration(seconds: 10));


      // Expect response to contain profile_exists boolean:
      if (response ==200) {
        await _storageService.setHasProfile(true);
        return true;
      }

      await _storageService.setHasProfile(false);
      return false;
    } catch (e) {
      debugPrint('Error checking profile: $e');
      // keep stored value consistent
      await _storage_service_setFalseSafe();
      return false;
    }
  }
  Future<http.Response> _authenticatedRequest(
      String url, {
        String method = 'GET',
        Map<String, dynamic>? body,
        List<http.MultipartFile>? files,
      }) async {
    try {
      final prefs= await SharedPreferences.getInstance();
      final bearerToken = prefs.getString('bearer_token') ?? '';
      final headers = {
        'Authorization': 'Bearer ${bearerToken}',
        'Accept': 'application/json',
      };

      if (files != null || method == 'POST' || method == 'PUT') {
        // Always use multipart for create/update requests
        final request = http.MultipartRequest(method, Uri.parse(url));
        request.headers.addAll(headers);

        // Add text fields
        if (body != null) {
          body.forEach((key, value) {
            if (value != null) {
              request.fields[key] = value.toString();
            }
          });
        }

        // Add files
        if (files != null) {
          request.files.addAll(files);
        }

        final streamed = await request.send();
        return await http.Response.fromStream(streamed);
      } else {
        // For GET requests
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

  Future<void> _storage_service_setFalseSafe() async {
    try {
      await _storageService.setHasProfile(false);
    } catch (e) {
      debugPrint('Failed to set has_profile to false: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _storageService.clearAll();
    } catch (e) {
      debugPrint('Error during logout: $e');
      throw 'Failed to logout: ${e.toString()}';
    }
  }

  String _firebaseErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
