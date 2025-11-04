// notification_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../routes/app_pages.dart';
import 'get_server_key.dart';

class NotificationService extends GetxService {
  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription = 'This channel is used for important notifications';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final GetServerKey _serverKey = GetServerKey();

  final RxString _fcmToken = ''.obs;
  String get fcmToken => _fcmToken.value;

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  // Initialize local notifications
  Future<void> initLocalNotifications() async {
    try {
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
          _handleNotificationTap(details.payload);
        },
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      print('✅ Local notifications initialized successfully');
    } catch (e) {
      print('❌ Error initializing local notifications: $e');
    }
  }

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        showBadge: true,
        // Remove sound specification here or use default
      );

      await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

      print('✅ Notification channel created successfully');
    } catch (e) {
      print('❌ Error creating notification channel: $e');
    }
  }

  // Request notification permissions
  Future<bool> requestNotificationPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final bool isAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized;

      if (isAuthorized) {
        print('✅ User granted notification permission');
      } else {
        print('❌ User denied notification permission');
      }

      return isAuthorized;
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  // Fetch FCM Token
  Future<String> getDeviceToken() async {
    try {
      await requestNotificationPermission();

      String? token = await _messaging.getToken();

      if (token != null) {
        _fcmToken.value = token;
        print('✅ FCM Token: $token');
        return token;
      } else {
        throw Exception('Failed to get FCM token');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      rethrow;
    }
  }

  // Send FCM v1 Notification
  Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
    required String providerType,
    required int providerId,
    Map<String, dynamic>? customData,
  }) async {
    try {
      final accessToken = await _serverKey.getServerTokenKey();
      print("🔑 Server access token: ${accessToken.substring(0, 50)}...");

      final String url = "https://fcm.googleapis.com/v1/projects/skill-link47/messages:send";

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      // Message payload with proper structure
      Map<String, dynamic> message = {
        "message": {
          "token": token,
          "notification": {
            "title": title,
            "body": body,
          },
          "data": customData ?? {
            'providerType': providerType,
            'providerId': providerId.toString(),
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'screen': 'appointments',
            'type': 'new_appointment',
            'appointment_id': providerId.toString(),
            'service_type': providerType,
          },
          "android": {
            "priority": "HIGH",
            "notification": {
              "channel_id": channelId,
              "sound": "default",
            }
          },
          "apns": {
            "payload": {
              "aps": {
                "alert": {
                  "title": title,
                  "body": body,
                },
                "sound": "default",
                "badge": 1,
              }
            },
            "headers": {
              "apns-priority": "10",
            }
          }
        }
      };

      print('📤 Sending FCM v1 notification...');
      print('📝 Title: $title');
      print('📝 Body: $body');
      print('📊 Data: ${message['message']['data']}');

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(message),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully via FCM v1');
      } else {
        print('📥 Response body: ${response.body}');
        print('❌ Failed to send notification: ${response.statusCode}');
        throw Exception('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
      rethrow;
    }
  }

  // Initialize Firebase messaging
  void firebaseInit() {
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📱 Foreground notification received:');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');

        _showNotification(message);
      });

      // Handle message when app is in background but opened
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      // Configure foreground notification presentation for iOS
      if (Platform.isIOS) {
        _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      print('✅ Firebase messaging initialized successfully');
    } catch (e) {
      print('❌ Error initializing Firebase messaging: $e');
    }
  }

  // Setup interact message for background/terminated state
  Future<void> setupInteractMessage() async {
    try {
      // When app is opened from terminated state
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('🚀 App opened from terminated state with message: ${initialMessage.data}');
        _handleMessage(initialMessage);
      }

      print('✅ Interact message setup completed');
    } catch (e) {
      print('❌ Error setting up interact message: $e');
    }
  }

  // Show notification - FIXED VERSION
  Future<void> _showNotification(RemoteMessage message) async {
    try {
      // FIXED: Use default sound instead of custom sound file
      AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        autoCancel: true,
        showWhen: true,
        // REMOVED: sound: RawResourceAndroidNotificationSound('notification'),
        // This will use the default notification sound
      );

      DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails(
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
        payload: jsonEncode(message.data),
      );

      print('✅ Local notification shown successfully');
    } catch (e) {
      print('❌ Error showing local notification: $e');

      // Fallback: Try without sound if there's an error
      if (e.toString().contains('invalid_sound')) {
        await _showNotificationFallback(message);
      }
    }
  }

  // Fallback method without custom sound
  Future<void> _showNotificationFallback(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: false, // Disable sound as fallback
        enableVibration: true,
        autoCancel: true,
        showWhen: true,
      );

      const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false, // Disable sound as fallback
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? 'New message',
        notificationDetails,
        payload: jsonEncode(message.data),
      );

      print('✅ Local notification shown successfully (fallback mode)');
    } catch (e) {
      print('❌ Error showing local notification (fallback): $e');
    }
  }

  // Public method to show notification
  Future<void> showNotification(RemoteMessage message) async {
    await _showNotification(message);
  }

  // Handle notification message
  void _handleMessage(RemoteMessage message) {
    try {
      print('🔄 Handling message: ${message.data}');

      final data = message.data;

      if (data.containsKey('screen')) {
        String screen = data['screen'];
        _navigateToScreen(screen, data);
      } else {
        _navigateToScreen('home', data);
      }
    } catch (e) {
      print('❌ Error handling message: $e');
    }
  }

  // Navigate to specific screen based on notification data
  void _navigateToScreen(String screen, Map<String, dynamic> data) {
    if (_context == null) {
      print('⚠️ Context not set, using Get navigation');
      _navigateWithGet(screen, data);
      return;
    }

    try {
      switch (screen) {
        case 'home':
          Navigator.of(_context!).pushNamedAndRemoveUntil(
            AppRoutes.HOME,
                (route) => false,
          );
          break;
        case 'appointments':
        // Uncomment and adjust based on your routes
        // Navigator.of(_context!).pushNamed(
        //   AppRoutes.APPOINTMENTS,
        //   arguments: data,
        // );
          break;
        case 'profile':
        // Navigator.of(_context!).pushNamed(
        //   AppRoutes.PROFILE,
        //   arguments: data,
        // );
          break;
        default:
          Navigator.of(_context!).pushNamedAndRemoveUntil(
            AppRoutes.HOME,
                (route) => false,
          );
      }
      print('📍 Navigated to screen: $screen');
    } catch (e) {
      print('❌ Error navigating with context: $e');
      _navigateWithGet(screen, data);
    }
  }

  // Navigate using GetX
  void _navigateWithGet(String screen, Map<String, dynamic> data) {
    try {
      switch (screen) {
        case 'home':
          Get.offAllNamed(AppRoutes.HOME);
          break;
        case 'appointments':
        // Uncomment and adjust based on your routes
        // Get.toNamed(AppRoutes.PlumberAppointments);
          break;
        case 'profile':
        // Get.toNamed(AppRoutes.PROFILE);
          break;
        default:
          Get.offAllNamed(AppRoutes.HOME);
      }
      print('📍 GetX navigation to screen: $screen');
    } catch (e) {
      print('❌ Error navigating with Get: $e');
    }
  }

  // Handle notification tap
  void _handleNotificationTap(String? payload) {
    try {
      print('👆 Notification tapped with payload: $payload');

      if (payload != null && payload.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(payload);
        _handleMessage(RemoteMessage(data: data));
      } else {
        _navigateToScreen('home', {});
      }
    } catch (e) {
      print('❌ Error handling notification tap: $e');
      _navigateToScreen('home', {});
    }
  }

  // Subscribe to topics
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topics
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  // Delete FCM token (for logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken.value = '';
      print('✅ FCM token deleted successfully');
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }

  // Get current FCM token
  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('❌ Error getting current token: $e');
      return null;
    }
  }
}