// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/storage_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString role = ''.obs;
  final RxBool hasProfile = false.obs;
  final StorageService _storageService = Get.find();


  @override
  void onInit() {
    super.onInit();
    _loadAuthData();
    _checkLoginStatus();
  }
  Future<void> checkLoginStatus() async => _checkLoginStatus();

  Future<void> _loadAuthData() async {
    isLoading.value = true;

    final prefs = await SharedPreferences.getInstance();

    // Check Firebase login
    final user = _auth.currentUser;
    isLoggedIn.value = user != null;

    // Restore role and hasProfile from prefs if available
    role.value = prefs.getString('role') ?? '';
    hasProfile.value = prefs.containsKey('${role.value}_profile_id');

    isLoading.value = false;
  }
  Future<void> _checkLoginStatus() async {
    try {
      isLoading.value = true;

      // Check Firebase auth state
      User? firebaseUser = _auth.currentUser;

      // Check local storage
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token');
      final storedRole = prefs.getString('role');

      isLoggedIn.value = firebaseUser != null && token != null;
      role.value = storedRole ?? '';
      hasProfile.value = prefs.getBool('has_profile') ?? false;
      print("hass profileeeeeeeeeeehas $hasProfile.value");

    } catch (e) {
      Get.snackbar('Error', 'Failed to check login status');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);

      isLoggedIn.value = true;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _auth.signOut();

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      isLoggedIn.value = false;
      role.value = '';
      hasProfile.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout');
    } finally {
      isLoading.value = false;
    }
  }
}


