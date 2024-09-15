// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/controllers/dashboard_controller.dart';
import 'package:plumber_project/pages/authentication/auth_wrapper.dart';
import 'package:plumber_project/pages/authentication/login.dart';
import 'package:plumber_project/pages/authentication/signup_screen.dart';
import 'package:plumber_project/pages/cleaner/cleaner_dashboard.dart';
import 'package:plumber_project/pages/cleaner/cleaner_profile.dart';
import 'package:plumber_project/pages/electrition/electrition_dashboard.dart';
import 'package:plumber_project/pages/electrition/electrition_profile.dart';
import 'package:plumber_project/pages/plumber/plumber_dashboard.dart';
import 'package:plumber_project/pages/plumber/plumber_profile.dart';
import 'package:plumber_project/pages/plumber/plumberrequest.dart';
import 'package:plumber_project/pages/setting.dart';
import 'package:plumber_project/pages/users/dashboard.dart';
import 'package:plumber_project/pages/users/profile.dart';

import '../pages/authentication/auth_service.dart';
import '../pages/cleaner/cleaner_appointment_list.dart';
import '../pages/electrition/electrician_appointment_list.dart';
import '../pages/plumber/plumber_appointment_list.dart';
import '../pages/users/user_profile.dart';
import '../services/storage_service.dart';

abstract class AppRoutes {
  static const INITIAL = '/';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const HOME = '/user/dashboard';
  static const USER_PROFILE = '/user/profile';
  static const SETTINGS = '/settings';
  static const PlumberAppointments = '/plumber/plumber_appointment_list';
  static const ElectricianAppointments = '/electrician/electrician_appointment_list';
  static const CleanerAppointments = '/cleaner/cleaner_appointment_list';
  static const PLUMBER_DASHBOARD = '/plumber/dashboard';
  static const PLUMBER_PROFILE = '/plumber/profile';
  static const ELECTRICIAN_DASHBOARD = '/electrician/dashboard';
  static const ELECTRICIAN_PROFILE = '/electrician/profile';
  static const CLEANER_DASHBOARD = '/cleaner/dashboard';
  static const CLEANER_PROFILE = '/cleaner/profile';
}

class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.INITIAL,
      page: () => AuthWrapper(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginScreen(),
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
      name: AppRoutes.USER_PROFILE,
      page: () => UserProfilePage(),
    ),
    GetPage(
      name: AppRoutes.PLUMBER_DASHBOARD,
      page: () => PlumberDashboard(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.PLUMBER_PROFILE,
      page: () => PlumberProfilePage(),
    ),
    GetPage(
      name: AppRoutes.ELECTRICIAN_DASHBOARD,
      page: () => ElectricianDashboard(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.ELECTRICIAN_PROFILE,
      page: () => ElectricianProfilePage(),
    ),
    GetPage(
      name: AppRoutes.CLEANER_DASHBOARD,
      page: () => CleanerDashboard(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.CLEANER_PROFILE,
      page: () => CleanerProfilePage(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => SettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.CleanerAppointments,
      page: () => CleanerAppointmentList(),
    ),
    GetPage(
      name: AppRoutes.PlumberAppointments,
      page: () => PlumberAppointmentList(),
    ),
    GetPage(
      name: AppRoutes.ElectricianAppointments,
      page: () => ElectricianAppointmentList(),
    ),

  ];
}




class AuthBinding implements Bindings {
  @override
  void dependencies() {
    // Make sure StorageService was initialized by AppBindings or initialize it here if necessary.
    if (!Get.isRegistered<StorageService>()) {
      Get.putAsync<StorageService>(() async {
        final s = StorageService();
        return await s.init();
      }, permanent: true);
    }

    // Services
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut(() => AuthService());
    }

    // Controllers
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut(() => AuthController());
    }
  }
}
