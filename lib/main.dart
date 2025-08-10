import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plumber_project/pages/theme.dart';
import 'package:plumber_project/routes/app_pages.dart';
import 'package:plumber_project/services/storage_service.dart';
import 'app_binding.dart';
import 'controllers/theme_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize StorageService for persisting login state
    final storageService = StorageService();
    await storageService.init();
    Get.put<StorageService>(storageService, permanent: true);

    // Initialize ThemeController
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // Decide initial route based on stored login state
    String initialRoute = AppRoutes.INITIAL; // default to login/signup
    final token = storageService.getToken();
    final role = storageService.getRole();

    if (token != null && token.isNotEmpty) {
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
      }
    }

    runApp(MyApp(initialRoute: initialRoute));
  } catch (e, stack) {
    debugPrint('Initialization error: $e');
    debugPrint(stack.toString());
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Initialization failed: ${e.toString()}'),
          ),
        ),
      ),
    );
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
