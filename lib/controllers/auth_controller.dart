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
  final RxBool _initialCheckComplete = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't check login status here - let main() handle initial route
    // We'll complete initialization after app starts
  }

  // Call this method after app starts to complete initialization
  Future<void> completeInitialization() async {
    if (_initialCheckComplete.value) return;

    debugPrint('[AuthController] Completing initialization...');
    await _verifyAndSyncSession();
    _initialCheckComplete.value = true;
  }

  Future<void> _verifyAndSyncSession() async {
    debugPrint('[AuthController] Verifying and syncing session...');
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

      // If we have valid stored credentials, restore state
      if (token.isNotEmpty && storedRole.isNotEmpty && storedEmail.isNotEmpty) {
        debugPrint('[AuthController] Found stored credentials, restoring state...');

        isLoggedIn.value = true;
        role.value = storedRole;
        hasProfile.value = storedHasProfile;

        // Verify Firebase auth state matches
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null || currentUser.email != storedEmail) {
          debugPrint('[AuthController] Firebase session mismatch, signing out...');
          await FirebaseAuth.instance.signOut();
          await _clearStoredData(prefs);
          return;
        }

        debugPrint('[AuthController] Session is valid, user is logged in');

        // If we have a profile, make sure we're on the right screen
        if (storedHasProfile && Get.currentRoute != _getDashboardRoute(storedRole)) {
          Get.offAllNamed(_getDashboardRoute(storedRole));
        } else if (!storedHasProfile && !Get.currentRoute.endsWith('profile')) {
          Get.offAllNamed(_getProfileRoute(storedRole));
        }

        return;
      }

      // If no stored credentials but Firebase user exists, clear both
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        debugPrint('[AuthController] Firebase user found but no stored credentials, cleaning up...');
        await FirebaseAuth.instance.signOut();
        await _clearStoredData(prefs);
        return;
      }

      debugPrint('[AuthController] No active session found');
      await _clearStoredData(prefs);

    } catch (e) {
      debugPrint('[AuthController] Error verifying session: $e');
      await _clearStoredData(await SharedPreferences.getInstance());
    } finally {
      isLoading.value = false;
    }
  }

  String _getDashboardRoute(String role) {
    switch (role) {
      case 'plumber':
        return AppRoutes.PLUMBER_DASHBOARD;
      case 'electrician':
        return AppRoutes.ELECTRICIAN_DASHBOARD;
      case 'cleaner':
        return AppRoutes.CLEANER_DASHBOARD;
      default:
        return AppRoutes.HOME;
    }
  }

  String _getProfileRoute(String role) {
    switch (role) {
      case 'plumber':
        return AppRoutes.PLUMBER_PROFILE;
      case 'electrician':
        return AppRoutes.ELECTRICIAN_PROFILE;
      case 'cleaner':
        return AppRoutes.CLEANER_PROFILE;
      default:
        return AppRoutes.USER_PROFILE;
    }
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
        Uri.parse('$baseUrl/api/auth/refresh'),
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
        name: userData['name']?.toString() ?? '',
        email: userData['email']?.toString() ?? email,
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
          endpoint = '$baseUrl/api/electrician/profile/check';
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