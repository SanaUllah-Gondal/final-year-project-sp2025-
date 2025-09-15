import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Keys
  static const String _kToken = 'bearer_token';
  static const String _kRole = 'role';
  static const String _kUserId = 'user_id';
  static const String _kEmail = 'email';
  static const String _kName = 'name';
  static const String _kPhoneNumber = 'phone_number';
  static const String _kProfileImage = 'profile_image';
  static const String _kHasProfile = 'has_profile';
  static const String _kRememberMe = 'remember_me';
  static const String _kSavedEmail = 'saved_email';

  SharedPreferences? _prefs;

  /// Initialize the service before usage
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  /// Helper to get initialized prefs safely
  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception("StorageService not initialized. Call init() first.");
    }
    return _prefs!;
  }

  /// Save user data after successful login
  Future<void> saveUserData({
    required String token,
    required String role,
    required int userId,
    required String name,
    required String email,
    String? phoneNumber,
    String? profileImage,
  }) async {
    await _preferences.setString(_kToken, token);
    await _preferences.setString(_kRole, role);
    await _preferences.setInt(_kUserId, userId);
    await _preferences.setString(_kName, name);
    await _preferences.setString(_kEmail, email);

    if (phoneNumber != null) {
      await _preferences.setString(_kPhoneNumber, phoneNumber);
    }

    if (profileImage != null) {
      await _preferences.setString(_kProfileImage, profileImage);
    }
  }

  /// Getters for stored values
  String? getToken() => _preferences.getString(_kToken);
  String? getRole() => _preferences.getString(_kRole);
  int? getUserId() => _preferences.getInt(_kUserId);
  String? getEmail() => _preferences.getString(_kEmail);
  String? getName() => _preferences.getString(_kName);
  String? getPhoneNumber() => _preferences.getString(_kPhoneNumber);
  String?   getProfileImage() => _preferences.getString(_kProfileImage);

  /// Setters for phone number and profile image
  Future<void> savePhoneNumber(String phoneNumber) async {
    await _preferences.setString(_kPhoneNumber, phoneNumber);
  }

  Future<void> saveProfileImage(String profileImage) async {
    await _preferences.setString(_kProfileImage, profileImage);
  }

  /// Profile existence flag
  Future<void> setHasProfile(bool value) async {
    await _preferences.setBool(_kHasProfile, value);
  }

  Future<void> setRole(String role) async {
    await _preferences.setString(_kRole, role);
  }

  bool getHasProfile() => _preferences.getBool(_kHasProfile) ?? false;

  /// Save "Remember Me" credentials
  Future<void> saveCredentials(String email) async {
    await _preferences.setBool(_kRememberMe, true);
    await _preferences.setString(_kSavedEmail, email);
  }

  bool getRememberMe() => _preferences.getBool(_kRememberMe) ?? false;
  String? getSavedEmail() => _preferences.getString(_kSavedEmail);

  /// Clear all stored data, keeping credentials if Remember Me is enabled
  Future<void> clearAll() async {
    bool remember = getRememberMe();
    String? savedEmail = getSavedEmail();

    await _preferences.clear();

    if (remember && savedEmail != null) {
      await _preferences.setBool(_kRememberMe, true);
      await _preferences.setString(_kSavedEmail, savedEmail);
    }
  }
}