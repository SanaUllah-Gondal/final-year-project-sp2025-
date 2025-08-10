
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plumber_project/services/storage_service.dart';
import '../pages/authentication/auth_service.dart';
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

  /// 🔍 Check login state on app startup
  Future<void> _checkLoginStatus() async {
    debugPrint("🔍 [AuthController] Checking login status on startup...");
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      isLoggedIn.value = currentUser != null;

      debugPrint("🟢 Firebase currentUser: ${currentUser?.email ?? 'null'}");
      debugPrint("🟢 isLoggedIn: ${isLoggedIn.value}");

      if (isLoggedIn.value) {
        role.value = _storageService.getRole()?.toLowerCase() ?? '';
        hasProfile.value = _storageService.getHasProfile() ?? false;

        debugPrint("💾 Loaded from StorageService:");
        debugPrint("    bearer_token: ${_storageService.getToken()}");
        debugPrint("    role: ${role.value}");
        debugPrint("    user_id: ${_storageService.getUserId()}");
        debugPrint("    email: ${_storageService.getEmail()}");
        debugPrint("    has_profile: ${hasProfile.value}");

        Future.microtask(() {
          if (role.value.isNotEmpty) {
            navigateBasedOnRole();
          } else {
            debugPrint("⚠️ No stored role found, redirecting to login");
            Get.offAllNamed(AppRoutes.LOGIN);
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔑 Perform login
  Future<void> login(String email, String password) async {
    debugPrint("🚀 [AuthController] Login started for $email");
    try {
      isLoading.value = true;

      // 1️⃣ Laravel login
      final laravelResponse = await _authService.loginWithLaravel(email, password);
      debugPrint("✅ Laravel login response: $laravelResponse");

      final userRole = laravelResponse['user']['role']?.toString().toLowerCase() ?? '';
      if (userRole.isEmpty) throw 'Role missing from Laravel response';
      debugPrint("🎭 User role: $userRole");

      // 2️⃣ Firebase login
      await _authService.loginWithFirebase(email, password);
      debugPrint("✅ Firebase login success");

      // 3️⃣ Save data locally
      await _storageService.saveUserData(
        token: laravelResponse['access_token'],
        role: userRole,
        userId: laravelResponse['user']['id'],
        name: laravelResponse['user']['name'],
        email: email,
      );

      // Confirm saved data
      debugPrint("💾 Verifying saved StorageService data after login:");
      debugPrint("    bearer_token: ${_storageService.getToken()}");
      debugPrint("    role: ${_storageService.getRole()}");
      debugPrint("    user_id: ${_storageService.getUserId()}");
      debugPrint("    email: ${_storageService.getEmail()}");
      debugPrint("    name: ${_storageService.getName()}");

      // 4️⃣ Check profile existence
      final profileExists = await _authService.checkProfileExists();
      hasProfile.value = profileExists;
      await _storageService.setHasProfile(profileExists);

      debugPrint("📋 Profile exists: ${hasProfile.value}");

      // 5️⃣ Update state
      isLoggedIn.value = true;
      role.value = userRole;

      // 6️⃣ Navigate
      navigateBasedOnRole();
    } catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// 📍 Navigate user to correct dashboard/profile
  void navigateBasedOnRole() {
    final currentRole = role.value.toLowerCase();
    String route;

    debugPrint("🛣️ Navigating for role: $currentRole, hasProfile: ${hasProfile.value}");

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
      default:
        route = hasProfile.value ? AppRoutes.HOME : AppRoutes.USER_PROFILE;
    }

    debugPrint("➡️ Redirecting to route: $route");
    Get.offAllNamed(route);
  }

  /// 🚪 Logout
  Future<void> logout() async {
    debugPrint("🚪 Logging out...");
    try {
      isLoading.value = true;
      await _authService.logout();
      await _storageService.clearAll();
      isLoggedIn.value = false;
      role.value = '';
      hasProfile.value = false;
      Get.offAllNamed(AppRoutes.LOGIN);
      debugPrint("✅ Logout complete and storage cleared");
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
