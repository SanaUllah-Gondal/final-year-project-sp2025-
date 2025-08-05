// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:plumber_project/pages/authentication/login.dart';
import 'package:plumber_project/pages/authentication/signup_screen.dart';
import 'package:plumber_project/pages/electrition/electrition_dashboard.dart';
import 'package:plumber_project/pages/plumber/plumber_dashboard.dart';
import 'package:plumber_project/pages/setting.dart';
import 'package:plumber_project/pages/users/dashboard.dart';
import 'package:plumber_project/pages/users/profile.dart';

import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../pages/authentication/auth_wrapper.dart';
import 'lifecycle_management.dart';

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
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.INITIAL,
      page: () => LifecycleManager(child: AuthWrapper()),
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => SignUpScreen(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.PLUMBER_DASHBOARD,
      page: () => PlumberDashboard(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.ELECTRICIAN_DASHBOARD,
      page: () => ElectricianDashboard(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => SettingsScreen(),
    ),
  ];
}
