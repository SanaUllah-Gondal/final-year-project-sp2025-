// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:plumber_project/pages/authentication/login.dart';
import 'package:plumber_project/pages/authentication/signup_screen.dart';
import 'package:plumber_project/pages/setting.dart';
import 'package:plumber_project/pages/users/dashboard.dart';
import 'package:plumber_project/pages/users/profile.dart';

import '../controllers/auth_controller.dart';
import '../pages/authentication/auth_wrapper.dart';

abstract class AppRoutes {
  static const INITIAL = '/';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const HOME = '/home';
  static const PROFILE = '/profile';
  static const SETTINGS = '/settings';
  static const PLUMBER_DASHBOARD = '/plumber/dashboard';
  static const PLUMBER_PROFILE = '/plumber/profile';
  static const ELECTRICIAN_DASHBOARD = '/electrician/dashboard';
  static const ELECTRICIAN_PROFILE = '/electrician/profile';
  static const PLUMBER_REQUESTS = '/plumber/requests';
  static const PLUMBER_SERVICES = '/plumber/services';
  static const ELECTRICIAN_SERVICES = '/electrician/services';
  static const BOOKING_REQUEST = '/booking/request';
  static const NOTIFICATIONS = '/notifications';
  static const EMERGENCY = '/emergency';
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.INITIAL,
      page: () => AuthWrapper(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => SignUpScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => SettingsScreen(),
      binding: SettingsBinding(),
    ),
    // Add other routes similarly
  ];
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => DashboardController());
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => SettingsController());
  }
}