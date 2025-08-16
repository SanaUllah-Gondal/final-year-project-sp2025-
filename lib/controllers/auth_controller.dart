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
      final currentUser = FirebaseAuth.instance.currentUser;
      isLoggedIn.value = currentUser != null;

      if (isLoggedIn.value) {
        debugPrint('[AuthController] Firebase user found, checking profile...');

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('bearer_token') ?? '';

        if (token.isEmpty) {
          debugPrint('[AuthController] No token found');
          isLoggedIn.value = false;
          return;
        }

        try {
          // First try the unified endpoint
          final response = await http.get(
            Uri.parse('$baseUrl/api/check-profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          debugPrint('[AuthController] Profile check response: ${response.statusCode} ${response.body}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['success'] == true) {
              final profileData = data['data'];

              // Handle type conversion safely
              hasProfile.value = profileData['exists'] ?? false;
              role.value = (profileData['role']?.toString().toLowerCase() ?? '');

              // Save to shared preferences
              await prefs.setBool('hasProfile', hasProfile.value);
              await prefs.setString('role', role.value);

              debugPrint('[AuthController] Profile exists: ${hasProfile.value}, Role: ${role.value}');
            } else {
              throw Exception(data['message'] ?? 'Profile check failed');
            }
          } else if (response.statusCode == 404) {
            // Fallback to role-specific endpoints if unified endpoint not found
            await _checkProfileUsingRoleSpecificEndpoints(token, prefs);
          } else {
            throw Exception('HTTP ${response.statusCode}: ${response.body}');
          }
        } catch (e) {
          debugPrint('[AuthController] Error checking profile: $e');
          hasProfile.value = false;
          role.value = '';
          await prefs.setBool('hasProfile', false);
          await prefs.setString('role', '');
        }

        navigateBasedOnRole();
      } else {
        debugPrint('[AuthController] No Firebase user found');
        hasProfile.value = false;
        role.value = '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasProfile', false);
        await prefs.setString('role', '');
      }
    } catch (e) {
      debugPrint('[AuthController] Error checking login status: $e');
      hasProfile.value = false;
      role.value = '';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasProfile', false);
      await prefs.setString('role', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkProfileUsingRoleSpecificEndpoints(String token, SharedPreferences prefs) async {
    try {
      // Get the user's role from token or previous storage
      final storedRole = prefs.getString('role')?.toLowerCase();
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
          endpoint = '$baseUrl/api/profiles/check-cleaner';
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          hasProfile.value = true ?? false;
          role.value = storedRole;
          await prefs.setBool('hasProfile', hasProfile.value);
          await prefs.setString('role', role.value);
        }
      }
    } catch (e) {
      debugPrint('[AuthController] Error in role-specific profile check: $e');
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

      final userRole = laravelResponse['user']['role']?.toString().toLowerCase() ?? '';
      if (userRole.isEmpty) throw 'Missing role from Laravel response';

      // 2) Firebase login
      await _authService.loginWithFirebase(email, password);
      debugPrint('[AuthController] Firebase login success');

      // 3) Save user data locally
      await _storageService.saveUserData(
        token: laravelResponse['access_token'],
        role: userRole,
        userId: laravelResponse['user']['id'],
        name: laravelResponse['user']['name'],
        email: laravelResponse['user']['email'],
      );

      // 4) Check profile existence (backend)
      final profileExists = await _authService.checkProfileExists();

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

      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      debugPrint('[AuthController] logout error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
