// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plumber_project/pages/authentication/auth_service.dart';
import 'package:plumber_project/services/storage_service.dart';
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

  Future<void> _checkLoginStatus() async {
    debugPrint('[AuthController] Checking login status...');
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      isLoggedIn.value = currentUser != null;

      if (isLoggedIn.value) {
        role.value = (_storageService.getRole() ?? '').toLowerCase();
        hasProfile.value = _storageService.getHasProfile();

        debugPrint('[AuthController] Found stored token & role: ${role.value}');
        navigateBasedOnRole();
      } else {
        debugPrint('[AuthController] No firebase user found');
      }
    } catch (e) {
      debugPrint('[AuthController] Error checking login status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Prevent concurrent login calls with a guard:
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
      await _storageService.setHasProfile(profileExists);

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
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      debugPrint('[AuthController] logout error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
