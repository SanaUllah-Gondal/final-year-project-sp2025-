// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plumber_project/services/storage_service.dart';
import 'package:plumber_project/routes/app_pages.dart';

import '../pages/authentication/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find();
  final StorageService _storageService = Get.find();

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString role = ''.obs;
  final RxBool hasProfile = false.obs;
  final RxString token = ''.obs;
  final RxInt userId = 0.obs;

  @override
  void onReady() {
    checkLoginStatus();
    super.onReady();
  }

  Future<void> checkLoginStatus() async {
    try {
      isLoading.value = true;

      // Load from local storage
      await _loadLocalData();

      // Verify Firebase auth
      await _verifyFirebaseAuth();

      // Redirect if logged in
      if (isLoggedIn.value) {
        _redirectBasedOnRole();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to check login status');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadLocalData() async {
    token.value = await _storageService.getToken() ?? '';
    role.value = await _storageService.getRole() ?? '';
    userId.value = await _storageService.getUserId() ?? 0;
    hasProfile.value = await _storageService.getHasProfile() ?? false;
  }

  Future<void> _verifyFirebaseAuth() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    isLoggedIn.value = token.value.isNotEmpty && firebaseUser != null;
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      // Laravel login
      final response = await _authService.loginWithLaravel(email, password);

      // Firebase login
      await _authService.loginWithFirebase(email, password);

      // Save user data
      await _saveUserData(response, email);

      // Check profile status
      await _checkAndUpdateProfileStatus(response);

      // Redirect
      _redirectBasedOnRole();
    } catch (e) {
      Get.snackbar(
        'Login Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> response, String email) async {
    await _storageService.saveUserData(
      token: response['access_token'],
      role: response['user']['role'],
      userId: response['user']['id'],
      email: email,
    );
    await _loadLocalData(); // Refresh local data
  }

  Future<void> _checkAndUpdateProfileStatus(Map<String, dynamic> response) async {
    final profileStatus = await _authService.checkUserProfile(
      response['access_token'],
      response['user']['id'],
      response['user']['role'],
    );
    await _storageService.setHasProfile(profileStatus);
    hasProfile.value = profileStatus;
  }

  void _redirectBasedOnRole() {
    if (!isLoggedIn.value) return;

    String route;
    switch (role.value) {
      case 'plumber':
        route = hasProfile.value
            ? AppRoutes.PLUMBER_DASHBOARD
            : AppRoutes.PLUMBER_PROFILE;
        break;
      case 'electrician':
        route = hasProfile.value
            ? AppRoutes.ELECTRICIAN_DASHBOARD
            : AppRoutes.ELECTRICIAN_PROFILE;
        break;
      default:
        route = hasProfile.value
            ? AppRoutes.HOME
            : AppRoutes.PROFILE;
    }
    Get.offAllNamed(route);
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.logout();
      await _storageService.clearAll();
      isLoggedIn.value = false;
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      Get.snackbar('Logout Error', 'Failed to logout');
    } finally {
      isLoading.value = false;
    }
  }
}