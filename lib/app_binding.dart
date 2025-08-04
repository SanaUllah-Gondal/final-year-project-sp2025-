// app_binding.dart
import 'package:get/get.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/controllers/theme_controller.dart';
import 'package:plumber_project/pages/authentication/auth_service.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/storage_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize ThemeController first as permanent
    Get.put(ThemeController(), permanent: true);

    // Services
    Get.lazyPut(() => StorageService());
    Get.lazyPut(() => ApiService());
    Get.lazyPut(() => AuthService());

    // Controllers
    Get.lazyPut(() => AuthController(), fenix: true);
  }
}