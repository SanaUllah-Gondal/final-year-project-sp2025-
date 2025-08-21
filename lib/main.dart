// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/pages/authentication/auth_service.dart';
import 'package:plumber_project/pages/theme.dart';
import 'package:plumber_project/routes/app_pages.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/storage_service.dart';
import 'app_binding.dart';
import 'controllers/theme_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // create instances
    final storageService = StorageService();
    await storageService.init(); // MUST init prefs before using
    Get.put<StorageService>(storageService, permanent: true);

    // Core services
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);

    // Controllers
    final authController = AuthController();
    Get.put<AuthController>(authController, permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // Decide initial route from storage only (do NOT rely on controller fields that may not be ready)
    String initialRoute = AppRoutes.INITIAL;
    final token = storageService.getToken();
    final role = storageService.getRole()?.toLowerCase() ?? '';
    final hasProfile = storageService.getHasProfile();

    if (token != null && token.isNotEmpty) {
      if (hasProfile) {
        switch (role) {
          case 'user':
            initialRoute = AppRoutes.HOME;
            break;
          case 'plumber':
            initialRoute = AppRoutes.PLUMBER_DASHBOARD;
            break;
          case 'electrician':
            initialRoute = AppRoutes.ELECTRICIAN_DASHBOARD;
            break;
          case 'cleaner':
            initialRoute = AppRoutes.CLEANER_DASHBOARD;
            break;
          default:
            initialRoute = AppRoutes.HOME;
        }
      } else {
        // token exists but profile incomplete
        switch (role) {
          case 'user':
            initialRoute = AppRoutes.USER_PROFILE;
            break;
          case 'plumber':
            initialRoute = AppRoutes.PLUMBER_PROFILE;
            break;
          case 'electrician':
            initialRoute = AppRoutes.ELECTRICIAN_PROFILE;
            break;
          case 'cleaner':
            initialRoute = AppRoutes.CLEANER_PROFILE;
            break;
          default:
            initialRoute = AppRoutes.USER_PROFILE;
        }
      }
    }

    runApp(MyApp(initialRoute: initialRoute));
  } catch (e, st) {
    debugPrint('Initialization error: $e\n$st');
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Init failed: $e')))));
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Skill-Link',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Get.find<ThemeController>().themeMode,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      initialBinding: AppBindings(),
      defaultTransition: Transition.fadeIn,
    );
  }
}