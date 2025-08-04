
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/pages/authentication/login.dart';
import 'package:plumber_project/pages/electrition/electrition_profile.dart';
import '../electrition/electrition_dashboard.dart';
import '../plumber/plumber_dashboard.dart';
import '../plumber/plumber_profile.dart';
import '../users/dashboard.dart';
import '../users/profile.dart';

class AuthWrapper extends StatelessWidget {
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_authController.isLoading.value) {
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (!_authController.isLoggedIn.value) {
        return LoginScreen();
      }

      return _buildRoleBasedScreen();
    });
  }

  Widget _buildRoleBasedScreen() {
    switch (_authController.role.value) {
      case 'plumber':
        return _authController.hasProfile.value
            ? PlumberDashboard()
            : PlumberProfilePage();
      case 'electrician':
        return _authController.hasProfile.value
            ? ElectricianDashboard()
            : ElectricianProfilePage();
      default:
        return _authController.hasProfile.value
            ? HomeScreen()
            : ProfileScreen();
    }
  }
}