// lib/controllers/login_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/controllers/auth_controller.dart';
import 'package:plumber_project/routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthController _authController = Get.find();
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Debug logger
  void _log(String message, {bool isError = false}) {
    final prefix = isError ? '🚨 ERROR: ' : '🔍 DEBUG: ';
    debugPrint('$prefix$message');
    if (isError) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onInit() {
    _log('LoginController initialized');
    super.onInit();
    _loadSavedCredentials();
  }

  @override
  void onClose() {
    _log('LoginController disposed');
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      _log('Loading saved credentials...');
      final prefs = await SharedPreferences.getInstance();
      rememberMe.value = prefs.getBool('remember_me') ?? false;

      if (rememberMe.value) {
        final savedEmail = prefs.getString('saved_email') ?? '';
        emailController.text = savedEmail;
        _log('Loaded saved email: $savedEmail');
      }
      _log('Remember me: ${rememberMe.value}');
    } catch (e, stack) {
      _log('Error loading credentials: $e\n$stack', isError: true);
    }
  }

  Future<void> login() async {
    _log('Login attempt started');

    // Validate form
    if (!formKey.currentState!.validate()) {
      _log('Form validation failed');
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    _log('Attempting login with email: $email');

    try {
      isLoading.value = true;

      // Debug: Print credentials (remove in production)
      _log('Credentials - Email: $email, Password: ${'*' * password.length}');

      // Authenticate via AuthController (which performs backend + firebase + navigation)
      await _authController.login(email, password);
      _log('Login successful (AuthController handled navigation)');

      // Save credentials if remember me is enabled
      if (rememberMe.value) {
        _log('Saving credentials to shared preferences');
        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          prefs.setBool('remember_me', true),
          prefs.setString('saved_email', email),
        ]);
        _log('Credentials saved successfully');
      }
    } on FirebaseAuthException catch (e) {
      final errorMsg = _parseFirebaseError(e);
      _log('Firebase Auth Error: $errorMsg\nCode: ${e.code}', isError: true);
    } catch (e, stack) {
      _log('Unexpected login error: $e\n$stack', isError: true);
    } finally {
      isLoading.value = false;
      _log('Login attempt completed');
    }
  }

  String _parseFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Login failed: ${e.message}';
    }
  }

  void navigateToSignup() {
    _log('Navigating to signup screen');
    Get.toNamed(AppRoutes.SIGNUP);
  }

  // For testing/debugging purposes
  void simulateError() {
    _log('Simulating error for testing', isError: true);
    throw Exception('This is a simulated error for testing');
  }
}
