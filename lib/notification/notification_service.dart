import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

class NotificationService extends GetxService {
  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription = 'This channel is used for important notifications';

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  // Initialize local notifications
  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null) {
          handleNotificationTap(details.payload!);
        }
      },
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await createNotificationChannel();
    }
  }

  // Create notification channel for Android
  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      showBadge: true,
    );

    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  // Request notification permissions
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }

  // Fetch FCM Token
  Future<String> getDeviceToken() async {
    requestNotificationPermission();
    String? token = await messaging.getToken();
    print("token=> $token");
    return token!;
  }

  // Initialize Firebase messaging
  void firebaseInit() {
    requestNotificationPermission();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Foreground notification received:");
        print("Title: ${message.notification?.title}");
        print("Body: ${message.notification?.body}");
        print('Data: ${message.data.toString()}');
      }

      showNotification(message);
    });

    // Configure foreground notification presentation for iOS
    if (Platform.isIOS) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage() async {
    // When app is opened from terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    // When app is in background and opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(message);
    });
  }

  // Function to show notification - SIMPLIFIED VERSION
  Future<void> showNotification(RemoteMessage message) async {
    try {
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true, // This will use default system sound
        enableVibration: true,
        autoCancel: true,
        showWhen: true,
        // NO custom sound reference here
      );

      DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? 'New message',
        notificationDetails,
        payload: message.data.toString(),
      );

      print('Notification shown successfully');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // Handle notification message
  void handleMessage(RemoteMessage message) {
    if (kDebugMode) {
      print("Handling message: ${message.data}");
    }

    final data = message.data;

    if (data.containsKey('screen')) {
      String screen = data['screen'];
      switch (screen) {
        case 'home':
          if (_context != null) {
            Get.toNamed(AppRoutes.HOME);
          }
          break;
        case 'appointments':
        // Navigate to appointments screen
          break;
        default:
          Get.toNamed(AppRoutes.HOME);
      }
    } else {
      Get.toNamed(AppRoutes.HOME);
    }
  }

  // Handle notification tap
  void handleNotificationTap(String payload) {
    if (kDebugMode) {
      print("Notification tapped with payload: $payload");
    }

    try {
      Get.toNamed(AppRoutes.HOME);
    } catch (e) {
      if (kDebugMode) {
        print("Error handling notification tap: $e");
      }
    }
  }
}