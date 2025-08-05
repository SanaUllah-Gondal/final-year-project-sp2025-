// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plumber_project/pages/theme.dart';
import 'package:plumber_project/routes/app_pages.dart';
import 'app_binding.dart';
import 'controllers/theme_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Make sure you have this configured
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Skill-Link',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeController().themeMode,
      initialRoute: AppRoutes.INITIAL,
      getPages: AppPages.routes,
      initialBinding: AppBindings(),
      defaultTransition: Transition.fadeIn,
    );
  }
}
// Add this to your main widget (or create a new widget for it)
