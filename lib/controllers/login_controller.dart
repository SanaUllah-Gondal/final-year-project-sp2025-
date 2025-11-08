import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/services/storage_service.dart';
import '../routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthController _authController = Get.find();
  final StorageService _storageService = Get.find();

  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _loadSavedCredentials();
    super.onInit();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      rememberMe.value = _storageService.getRememberMe();
      if (rememberMe.value) {
        emailController.text = _storageService.getSavedEmail() ?? '';
      }
    } catch (e) {
      debugPrint('[LoginController] Error loading saved credentials: $e');
    }
  }

  /// ✅ Email Validation Helper
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    // Basic email regex pattern
    const emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(emailPattern);

    if (!regex.hasMatch(value.trim())) {
      return 'Invalid email format';
    }

    return null;
  }

  /// ✅ Password Validation Helper (optional)
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      debugPrint('[LoginController] Form validation failed');
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (_authController.isLoading.value) {
      debugPrint('[LoginController] AuthController login already in progress.');
      return;
    }

    try {
      isLoading.value = true;
      await _authController.login(email, password);

      if (rememberMe.value) {
        await _storage_service_saveCredentials(email);
      }
    } catch (e) {
      debugPrint('[LoginController] login error: $e');
      Get.snackbar('Login error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _storage_service_saveCredentials(String email) async {
    try {
      await _storageService.saveCredentials(email);
    } catch (e) {
      debugPrint('[LoginController] Failed to save credentials: $e');
    }
  }

  void toggleRememberMe(bool value) {
    rememberMe.value = value;
  }

  void navigateToSignup() {
    Get.toNamed(AppRoutes.SIGNUP);
  }
}