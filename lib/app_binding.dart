import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/controllers/dashboard_controller.dart';
import 'package:plumber_project/pages/authentication/auth_service.dart';
import 'package:plumber_project/pages/cleaner/controllers/cleaner_dashboard_controller.dart';
import 'package:plumber_project/pages/electrition/controllers/electrician_dashboard_controller.dart';
import 'package:plumber_project/pages/plumber/controllers/plumber_dashboard_controller.dart';
import 'package:plumber_project/pages/users/controllers/user_dashboard_controller.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/face_recognization_service.dart';
import 'package:plumber_project/services/storage_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {

    // Get existing instances that were created in main()
    _registerExistingServices();

    // Initialize DashboardController lazily since they might not be needed immediately
    _registerLazyControllers();

    // Call completeInitialization after the app is fully loaded
    _schedulePostFrameCallback();
  }

  void _registerExistingServices() {
    try {
      // Check if services are already registered and register them properly
      if (Get.isRegistered<ApiService>()) {
        Get.put(Get.find<ApiService>(), permanent: true);
      } else {
        debugPrint('ApiService not found in GetX, initializing new instance');
        Get.put<ApiService>(ApiService(), permanent: true);
      }

      if (Get.isRegistered<AuthService>()) {
        Get.put(Get.find<AuthService>(), permanent: true);
      } else {
        debugPrint('AuthService not found in GetX, initializing new instance');
        Get.put<AuthService>(AuthService(), permanent: true);
      }

      if (Get.isRegistered<StorageService>()) {
        Get.put(Get.find<StorageService>(), permanent: true);
      } else {
        debugPrint('StorageService not found in GetX, initializing new instance');
        Get.put<StorageService>(StorageService(), permanent: true);
      }

      if (Get.isRegistered<AuthController>()) {
        Get.put(Get.find<AuthController>(), permanent: true);
      } else {
        debugPrint('AuthController not found in GetX, initializing new instance');
        Get.put<AuthController>(AuthController(), permanent: true);
      }
    } catch (e) {
      debugPrint('Error registering existing services: $e');
      // Fallback: initialize new instances
      _initializeFallbackServices();
    }
  }

  void _initializeFallbackServices() {
    try {
      Get.put<ApiService>(ApiService(), permanent: true);
      Get.put<AuthService>(AuthService(), permanent: true);
      Get.put<StorageService>(StorageService(), permanent: true);
      Get.put<AuthController>(AuthController(), permanent: true);

    } catch (e) {
      debugPrint('Error in fallback service initialization: $e');
    }
  }

  void _registerLazyControllers() {
    try {
      Get.lazyPut(() => DashboardController(), fenix: true);
      Get.lazyPut(() => PlumberDashboardController(), fenix: true);
      Get.lazyPut(() => CleanerDashboardController(), fenix: true);
      Get.lazyPut(() => ElectricianDashboardController(), fenix: true);
      Get.lazyPut(() => HomeController(), fenix: true);
      Get.lazyPut(() => FaceRecognitionService(), fenix: true);
    } catch (e) {
      debugPrint('Error registering lazy controllers: $e');
    }
  }

  void _schedulePostFrameCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (Get.isRegistered<AuthController>()) {
          final authController = Get.find<AuthController>();
          // Use try-catch to safely call completeInitialization
          if (_hasCompleteInitializationMethod(authController)) {
            authController.completeInitialization();
          } else {
            debugPrint('completeInitialization method not found in AuthController');
          }
        } else {
          debugPrint('AuthController not registered for post-frame callback');
        }
      } catch (e) {
        debugPrint('Error in post-frame callback: $e');
      }
    });
  }

  bool _hasCompleteInitializationMethod(AuthController controller) {
    try {
      // Try to call the method to check if it exists
      controller.completeInitialization();
      return true;
    } catch (e) {
      return false;
    }
  }
}