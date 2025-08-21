import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/controllers/dashboard_controller.dart';
import 'package:plumber_project/pages/authentication/auth_service.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/storage_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Services are already initialized in main() with permanent: true
    // We just need to ensure they are available in GetX dependency injection

    // Get existing instances that were created in main()
    Get.put(Get.find<ApiService>(), permanent: true);
    Get.put(Get.find<AuthService>(), permanent: true);
    Get.put(Get.find<StorageService>(), permanent: true);

    // Controllers are also already initialized in main() with permanent: true
    // Just ensure they are available in GetX dependency injection
    Get.put(Get.find<AuthController>(), permanent: true);

    // Initialize DashboardController lazily since it might not be needed immediately
    Get.lazyPut(() => DashboardController(), fenix: true);

    // Call completeInitialization after the app is fully loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AuthController>().completeInitialization();
    });
  }
}