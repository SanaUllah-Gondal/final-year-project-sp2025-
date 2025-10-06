// notification_wrapper.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'notification_service.dart';

class NotificationWrapper extends StatefulWidget {
  final Widget child;

  const NotificationWrapper({super.key, required this.child});

  @override
  State<NotificationWrapper> createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends State<NotificationWrapper> {
  final NotificationService _notificationService = Get.find<NotificationService>();

  @override
  void initState() {
    super.initState();
    _setupNotificationContext();
  }

  void _setupNotificationContext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService.setContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}