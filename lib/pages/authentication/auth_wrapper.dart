import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/pages/authentication/login.dart';
import 'package:plumber_project/pages/electrition/electrition_profile.dart';
import '../electrition/electrition_dashboard.dart';
import '../plumber/plumber_dashboard.dart';
import '../plumber/plumber_profile.dart';
import '../users/dashboard.dart';
import '../users/profile.dart';

class AuthWrapper extends StatefulWidget {
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthController _authController = Get.find();

  @override
  void initState() {
    super.initState();
    _loadHasProfileFromPrefs();
  }

  Future<void> _loadHasProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final hasProfile = prefs.getBool('hasProfile') ?? false;
    _authController.hasProfile.value = hasProfile;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      print('isLoggedIn: ${_authController.isLoggedIn.value}');
      print('role: ${_authController.role.value}');
      print('hasProfile: ${_authController.hasProfile.value}');

      if (_authController.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (!_authController.isLoggedIn.value) {
        return const LoginScreen();
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
