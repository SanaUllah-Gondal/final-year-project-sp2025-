// lib/pages/authentication/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/pages/authentication/login.dart';

class AuthWrapper extends StatelessWidget {
  final AuthController _authController = Get.find();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_authController.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (!_authController.isLoggedIn.value) {
        return  LoginScreen();
      }

      // If logged in, trigger navigation to appropriate screen,
      // then show a spinner while navigation is performed.
      // We use a microtask to avoid triggering navigation during build.
      Future.microtask(() {
        _authController.navigateBasedOnRole();
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    });
  }
}
