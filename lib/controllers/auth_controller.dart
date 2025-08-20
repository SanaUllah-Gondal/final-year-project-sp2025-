// lib/controllers/auth_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plumber_project/pages/authentication/auth_service.dart';
import 'package:plumber_project/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/Apis.dart';
import '../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find();
  final StorageService _storageService = Get.find();

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString role = ''.obs;
  final RxBool hasProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<dynamic> getRequest(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Handle token expiration
        await refreshToken();
        final newToken = await _storageService.getToken();
        if (newToken != null && newToken.isNotEmpty) {
          final newHeaders = {
            ...?headers,
            'Authorization': 'Bearer $newToken',
          };
          return await getRequest(url, headers: newHeaders);
        }
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed request: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentToken = prefs.getString('bearer_token');
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final newToken = responseData['access_token'];
        await prefs.setString('bearer_token', newToken);
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      throw Exception('Token refresh error: $e');
    }
  }

  Future<void> _checkLoginStatus() async {
    debugPrint('[AuthController] Checking login status...');
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token') ?? '';
      final storedRole = prefs.getString('role')?.toLowerCase() ?? '';
      final storedHasProfile = prefs.getBool('hasProfile') ?? false;
      final storedEmail = prefs.getString('email') ?? '';

      debugPrint('[AuthController] Stored token: ${token.isNotEmpty ? "exists" : "missing"}');
      debugPrint('[AuthController] Stored role: $storedRole');
      debugPrint('[AuthController] Stored hasProfile: $storedHasProfile');
      debugPrint('[AuthController] Stored email: $storedEmail');

      // Check if we have valid stored credentials
      if (token.isNotEmpty && storedRole.isNotEmpty && storedEmail.isNotEmpty) {
        debugPrint('[AuthController] Found stored credentials, restoring state...');

        // Restore state from SharedPreferences
        isLoggedIn.value = true;
        role.value = storedRole;
        hasProfile.value = storedHasProfile;

        // Verify Firebase auth state matches
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          debugPrint('[AuthController] Firebase user missing but token exists, attempting to restore Firebase session...');
          try {
            // Try to sign in with stored email (this is a simplified approach)
            // In production, you'd need to store password securely or use token-based auth
            debugPrint('[AuthController] Cannot automatically restore Firebase session. User needs to login again.');
            await _clearStoredData(prefs);
            return;
          } catch (e) {
            debugPrint('[AuthController] Error restoring Firebase session: $e');
            await _clearStoredData(prefs);
            return;
          }
        } else {
          debugPrint('[AuthController] Firebase user found, session is valid');
          navigateBasedOnRole();
          return;
        }
      }

      // If no stored credentials, check Firebase auth state
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        debugPrint('[AuthController] Firebase user found but no stored credentials, checking profile...');

        if (token.isEmpty) {
          debugPrint('[AuthController] No token found with Firebase user');
          // User is logged into Firebase but not Laravel - need to re-login
          await FirebaseAuth.instance.signOut();
          await _clearStoredData(prefs);
          return;
        }

        try {
          // Check profile status
          await _checkProfileStatus(token, prefs);
          navigateBasedOnRole();
        } catch (e) {
          debugPrint('[AuthController] Error checking profile: $e');
          await _clearStoredData(prefs);
        }
      } else {
        debugPrint('[AuthController] No active session found');
        await _clearStoredData(prefs);
      }
    } catch (e) {
      debugPrint('[AuthController] Error checking login status: $e');
      await _clearStoredData(await SharedPreferences.getInstance());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _clearStoredData(SharedPreferences prefs) async {
    isLoggedIn.value = false;
    role.value = '';
    hasProfile.value = false;
    await prefs.setBool('hasProfile', false);
    await prefs.setString('role', '');
    await prefs.setString('bearer_token', '');
    await prefs.setString('email', '');
    await prefs.setString('user_id', '');
    await prefs.setString('name', '');
    debugPrint('[AuthController] Cleared all stored data');
  }

  Future<void> _checkProfileStatus(String token, SharedPreferences prefs) async {
    try {
      final storedRole = prefs.getString('role')?.toLowerCase();
      debugPrint('[AuthController] Checking profile for role: $storedRole');

      if (storedRole == null || storedRole.isEmpty) {
        throw Exception('No role available for profile check');
      }

      String endpoint;
      switch (storedRole) {
        case 'plumber':
          endpoint = '$baseUrl/api/profiles/check-plumber';
          break;
        case 'electrician':
          endpoint = '$baseUrl/api/profiles/check-electrician';
          break;
        case 'cleaner':
          endpoint = '$baseUrl/api/cleaner/profile/check';
          break;
        default:
          throw Exception('Unsupported role: $storedRole');
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('[AuthController] Profile check response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final profileData = data['data'] ?? data;

          hasProfile.value = profileData['exists'] ?? false;
          role.value = storedRole;

          await prefs.setBool('hasProfile', hasProfile.value);
          await prefs.setString('role', role.value);

          debugPrint('[AuthController] Profile exists: ${hasProfile.value}, Role: ${role.value}');
        } else {
          throw Exception(data['message'] ?? 'Profile check failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('[AuthController] Error checking profile status: $e');
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    if (isLoading.value) {
      debugPrint('[AuthController] Login already in progress, skipping duplicate call.');
      return;
    }

    try {
      isLoading.value = true;
      // 1) Laravel backend login
      final laravelResponse = await _authService.loginWithLaravel(email, password);
      debugPrint('[AuthController] Laravel response: $laravelResponse');

      // Extract user data safely
      final userData = laravelResponse['user'];
      if (userData == null || userData is! Map<String, dynamic>) {
        throw 'Invalid user data in Laravel response';
      }

      final userRole = userData['role']?.toString().toLowerCase() ?? '';
      debugPrint('[AuthController] User role: $userRole');

      if (userRole.isEmpty) {
        throw 'Missing role from Laravel response';
      }

      // 2) Firebase login
      await _authService.loginWithFirebase(email, password);
      debugPrint('[AuthController] Firebase login success');

      // 3) Save user data locally
      await _storageService.saveUserData(
        token: laravelResponse['access_token'],
        role: userRole,
        userId: userData['id'],
        name: userData['name'],
        email: userData['email'],
      );

      // 4) Check profile existence (backend)
      final profileExists = await _checkProfileAfterLogin(laravelResponse['access_token'], userRole);

      hasProfile.value = profileExists;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasProfile', profileExists);

      // 5) update state & navigate
      isLoggedIn.value = true;
      role.value = userRole;
      navigateBasedOnRole();
    } catch (e, st) {
      debugPrint('[AuthController] Login error: $e\n$st');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _checkProfileAfterLogin(String token, String userRole) async {
    try {
      String endpoint;
      switch (userRole) {
        case 'plumber':
          endpoint = '$baseUrl/api/profiles/check-plumber';
          break;
        case 'electrician':
          endpoint = '$baseUrl/api/profiles/check-electrician';
          break;
        case 'cleaner':
          endpoint = '$baseUrl/api/cleaner/profile/check';
          break;
        default:
          return false;
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true && (data['data']?['exists'] ?? data['exists'] ?? false);
      }
      return false;
    } catch (e) {
      debugPrint('[AuthController] Error checking profile after login: $e');
      return false;
    }
  }

  void navigateBasedOnRole() {
    final currentRole = role.value.toLowerCase();
    String route = AppRoutes.LOGIN;

    debugPrint('[AuthController] navigateBasedOnRole role=$currentRole hasProfile=${hasProfile.value}');

    switch (currentRole) {
      case 'plumber':
        route = hasProfile.value ? AppRoutes.PLUMBER_DASHBOARD : AppRoutes.PLUMBER_PROFILE;
        break;
      case 'electrician':
        route = hasProfile.value ? AppRoutes.ELECTRICIAN_DASHBOARD : AppRoutes.ELECTRICIAN_PROFILE;
        break;
      case 'cleaner':
        route = hasProfile.value ? AppRoutes.CLEANER_DASHBOARD : AppRoutes.CLEANER_PROFILE;
        break;
      case 'user':
        route = hasProfile.value ? AppRoutes.HOME : AppRoutes.USER_PROFILE;
        break;
      default:
        route = AppRoutes.LOGIN;
    }

    debugPrint('[AuthController] Redirecting to $route');
    Get.offAllNamed(route);
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.logout();
      await _storageService.clearAll();
      isLoggedIn.value = false;
      role.value = '';
      hasProfile.value = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasProfile', false);
      await prefs.setString('role', '');
      await prefs.setString('bearer_token', '');
      await prefs.setString('email', '');
      await prefs.setString('user_id', '');
      await prefs.setString('name', '');

      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      debugPrint('[AuthController] logout error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}