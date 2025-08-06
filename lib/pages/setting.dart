
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/theme_controller.dart';
import 'package:plumber_project/controllers/auth_controller.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController _themeController = Get.find();
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildThemeSwitch(),
            const Divider(),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSwitch() {
    return Obx(
          () => Card(
        elevation: 2,
        child: ListTile(
          title: Text(
            "Dark Mode",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Switch(
            value: _themeController.isDarkMode.value,
            onChanged: _themeController.toggleTheme,
            activeColor: Get.theme.colorScheme.secondary,
          ),
          leading: Icon(
            _themeController.isDarkMode.value
                ? Icons.dark_mode
                : Icons.light_mode,
            color: Get.theme.colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        leading: Icon(
          Icons.logout,
          color: Colors.red,
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: _showLogoutConfirmation,
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _authController.logout();
            },
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}