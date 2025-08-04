// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/storage_service.dart';

import '../Apis.dart';

class AuthService extends GetxService {
  final ApiService _apiService = Get.find();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final StorageService _storageService = Get.find();

  Future<Map<String, dynamic>> loginWithLaravel(
      String email,
      String password
      ) async {
    try {
      final response = await _apiService.post(
        '/api/login',
        {'email': email, 'password': password},
      );

      if (response['access_token'] == null) {
        throw 'Login failed: No access token received';
      }

      return response;
    } catch (e) {
      throw 'Failed to login with Laravel: ${e.toString()}';
    }
  }

  Future<UserCredential> loginWithFirebase(
      String email,
      String password
      ) async {
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

  Future<bool> checkUserProfile(
      String token,
      int userId,
      String role,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileUrl = '${baseUrl}/api/check-profile/$userId';

      if (kDebugMode) {
        print('Checking profile at: $profileUrl');
      }

      final profileResponse = await http.get(
        Uri.parse(profileUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Profile check status: ${profileResponse.statusCode}');
        print('Profile response: ${profileResponse.body}');
      }

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);
        final profile = profileData['profile'] ?? {};

        bool hasProfile = false;
        switch (role) {
          case 'plumber':
            if (profile['plumber_profile'] != null) {
              await prefs.setInt('plumber_profile_id', profile['plumber_profile']['id']);
              hasProfile = true;
            }
            break;
          case 'electrician':
            if (profile['electrician_profile'] != null) {
              await prefs.setInt('electrician_profile_id', profile['electrician_profile']['id']);
              hasProfile = true;
            }
            break;
          case 'user':
            if (profile['user_profile'] != null) {
              await prefs.setInt('user_profile_id', profile['user_profile']['id']);
              hasProfile = true;
            }
            break;
        }

        await prefs.setString('profile_data', jsonEncode(profile));
        return hasProfile;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking profile: $e');
      }
      return false;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  String _firebaseErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}