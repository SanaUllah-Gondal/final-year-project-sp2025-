// lib/services/storage_service.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  // Call this during app startup via Get.putAsync(() => StorageService().init());
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('💾 StorageService initialized');
    return this;
  }

  Future<void> saveUserData({
    required String token,
    required String role,
    required int userId,
    required String email,
    required String name,

  }) async {
    try {
      // Validate role
      final validRoles = ['plumber', 'electrician', 'cleaner', 'user'];
      final normalizedRole = role.toLowerCase();

      if (!validRoles.contains(normalizedRole)) {
        throw 'Invalid role: $role';
      }

      await Future.wait([
        _prefs.setString('bearer_token', token),
        _prefs.setString('role', normalizedRole),
        _prefs.setInt('user_id', userId),
        _prefs.setString('email', email),
        _prefs.setString('name', name),

      ]);
      debugPrint('💾 Saved user data for role: $normalizedRole');
    } catch (e) {
      debugPrint('❌ Error saving user data: $e');
      rethrow;
    }
  }

  String? getToken() => _prefs.getString('bearer_token');
  String? getRole() => _prefs.getString('role');
  int? getUserId() => _prefs.getInt('user_id');
  String? getEmail() => _prefs.getString('email');
  String? getName() => _prefs.getString('name');
  bool? getHasProfile() => _prefs.getBool('has_profile');

  Future<void> setHasProfile(bool value) async {
    await _prefs.setBool('has_profile', value);
    debugPrint('💾 set has_profile = $value');
  }

  Future<void> clearAll() async {
    await _prefs.clear();
    debugPrint('🧹 Cleared all storage data');
  }
}
