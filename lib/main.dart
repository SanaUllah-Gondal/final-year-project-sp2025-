import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/pages/authentication/auth_service.dart';
import 'package:plumber_project/pages/theme.dart';
import 'package:plumber_project/routes/app_pages.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/services/firebas_service.dart';
import 'package:plumber_project/services/storage_service.dart';
import '../../../app_binding.dart';
import '../../../controllers/theme_controller.dart';
import '../../../firebase_options.dart';
import '../../../notification/fcm_service.dart';
import '../../../notification/notification_service.dart';



@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Handle background notification
    await NotificationService().showNotification(message);
  } catch (e) {
    debugPrint('Background handler error: $e');
  }
}

// Global error handling
void _setupErrorHandling() {
  FlutterError.onError = (details) {
    debugPrint('FLUTTER ERROR: ${details.exception}');
    debugPrint('STACK TRACE: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PLATFORM ERROR: $error');
    debugPrint('PLATFORM STACK: $stack');
    return true;
  };
}

Future<String> _getInitialRoute(StorageService storageService) async {
  try {
    final token = storageService.getToken();
    final role = storageService.getRole()?.toLowerCase() ?? '';
    final hasProfile = storageService.getHasProfile();

    debugPrint('Initial Route Check - Token: ${token != null ? "exists" : "null"}, Role: $role, HasProfile: $hasProfile');

    if (token != null && token.isNotEmpty) {
      if (hasProfile) {
        switch (role) {
          case 'user':
            return AppRoutes.HOME;
          case 'plumber':
            return AppRoutes.PLUMBER_DASHBOARD;
          case 'electrician':
            return AppRoutes.ELECTRICIAN_DASHBOARD;
          case 'cleaner':
            return AppRoutes.CLEANER_DASHBOARD;
          default:
            return AppRoutes.HOME;
        }
      } else {
        // token exists but profile incomplete
        switch (role) {
          case 'user':
            return AppRoutes.USER_PROFILE;
          case 'plumber':
            return AppRoutes.PLUMBER_PROFILE;
          case 'electrician':
            return AppRoutes.ELECTRICIAN_PROFILE;
          case 'cleaner':
            return AppRoutes.CLEANER_PROFILE;
          default:
            return AppRoutes.USER_PROFILE;
        }
      }
    }
    return AppRoutes.INITIAL;
  } catch (e) {
    debugPrint('Error determining initial route: $e');
    return AppRoutes.INITIAL;
  }
}

void _runErrorApp(Object error, StackTrace stackTrace) {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 20),
              const Text(
                'App Initialization Failed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                'Error: ${error.toString()}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Try to restart the app
                  main();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Restart App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  debugPrint('Full error: $error\n$stackTrace');
                },
                child: const Text('View Detailed Log'),
              ),
            ],
          ),
        ),
      ),
    ),
  ));
}

Future<void> main() async {
  // Set up error handling first
  _setupErrorHandling();

  WidgetsFlutterBinding.ensureInitialized();

  // Add a delay to ensure proper initialization
  await Future.delayed(const Duration(milliseconds: 100));

  try {
    debugPrint('Starting Firebase initialization...');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Firebase initialization timeout');
    });

    debugPrint('Firebase initialized successfully');

    // Initialize Storage Service
    debugPrint('Initializing Storage Service...');
    final storageService = StorageService();
    await storageService.init().catchError((e) {
      debugPrint('Storage service init error: $e');
      // Continue even if storage fails
    });

    // Initialize Notification Service
    debugPrint('Initializing Notification Service...');
    final notificationService = NotificationService();
    try {
      await notificationService.initLocalNotifications().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Notification initialization timeout');
        },
      );
    } catch (e) {
      debugPrint('Notification service init error: $e');
      // Continue without notifications
    }

    // Get device token
    try {
      final newToken = await notificationService.getDeviceToken();
      debugPrint("Device Token: $newToken");
    } catch (e) {
      debugPrint('Error getting device token: $e');
    }

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Register services with GetX
    debugPrint('Registering services...');

    // Register StorageService first as others may depend on it
    Get.put<StorageService>(storageService, permanent: true);
    Get.put<NotificationService>(notificationService, permanent: true);
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put(FirebaseService());

    // Initialize controllers
    debugPrint('Initializing controllers...');
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // Initialize notification services
    debugPrint('Setting up notification services...');
    try {
      notificationService.firebaseInit();
      notificationService.setupInteractMessage();
      FcmService.firebaseInit();
    } catch (e) {
      debugPrint('Notification setup error: $e');
    }

    // Determine initial route
    debugPrint('Determining initial route...');
    final initialRoute = await _getInitialRoute(storageService);
    debugPrint('Initial route: $initialRoute');

    // Add a small delay to ensure everything is ready
    await Future.delayed(const Duration(milliseconds: 500));

    debugPrint('Starting app...');
    runApp(MyApp(initialRoute: initialRoute));

  } catch (e, st) {
    debugPrint('MAIN INITIALIZATION ERROR: $e');
    debugPrint('STACK TRACE: $st');
    _runErrorApp(e, st);
  }
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final notificationService = Get.find<NotificationService>();
        notificationService.setContext(context);
        debugPrint('Notification context set successfully');
      } catch (e) {
        debugPrint('Error setting notification context: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Skill-Link',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(),
      initialRoute: widget.initialRoute,
      getPages: AppPages.routes,
      initialBinding: AppBindings(),
      defaultTransition: Transition.fadeIn,
      navigatorObservers: [GetObserver()],
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Hide keyboard when tapping outside
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: child,
        );
      },
    );
  }

  ThemeMode _getThemeMode() {
    try {
      return Get.find<ThemeController>().themeMode;
    } catch (e) {
      debugPrint('Error getting theme mode: $e');
      return ThemeMode.system;
    }
  }
}