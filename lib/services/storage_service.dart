// lib/services/storage_service.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveUserData({
    required String token,
    required String role,
    required int userId,
    required String email,
  }) async {
    await _prefs.setString('bearer_token', token);
    await _prefs.setString('role', role);
    await _prefs.setInt('user_id', userId);
    await _prefs.setString('email', email);
  }

  Future<void> setHasProfile(bool value) async {
    await _prefs.setBool('has_profile', value);
  }

  String? getToken() => _prefs.getString('bearer_token');
  String? getRole() => _prefs.getString('role');
  int? getUserId() => _prefs.getInt('user_id');
  bool? getHasProfile() => _prefs.getBool('has_profile');

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}