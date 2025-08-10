// lib/bindings/app_bindings.dart
import 'package:get/get.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/controllers/dashboard_controller.dart';
import 'package:plumber_project/pages/authentication/auth_service.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/storage_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize services
    Get.lazyPut(() => ApiService(), fenix: true);
    Get.lazyPut(() => AuthService(), fenix: true);

    // IMPORTANT: initialize StorageService asynchronously
    // so SharedPreferences instance is ready before controllers use it.
    Get.putAsync<StorageService>(() async {
      final s = StorageService();
      return await s.init();
    }, permanent: true);

    // Initialize controllers that depend on storage/service
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
  }
}
