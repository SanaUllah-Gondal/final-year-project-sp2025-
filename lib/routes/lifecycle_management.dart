import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/auth_controller.dart';

class LifecycleManager extends StatefulWidget {
  final Widget child;

  LifecycleManager({required this.child});

  @override
  _LifecycleManagerState createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends State<LifecycleManager> with WidgetsBindingObserver {
  final AuthController _authController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {

      _authController.checkLoginStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}