import 'package:flutter/material.dart';
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
  bool _isInitialized = false;

  /// Initialize the service before usage
  Future<StorageService> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      debugPrint('StorageService initialized successfully');
      return this;
    } catch (e) {
      _isInitialized = false;
      debugPrint('StorageService initialization failed: $e');
      throw Exception("StorageService initialization failed: $e");
    }
  }

  /// Helper to get initialized prefs safely
  SharedPreferences get _preferences {
    if (_prefs == null || !_isInitialized) {
      throw Exception("StorageService not initialized. Call init() first.");
    }
    return _prefs!;
  }

  /// Check if storage is properly initialized
  bool get isInitialized => _isInitialized && _prefs != null;

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
    try {
      if (!isInitialized) {
        throw Exception("StorageService not initialized");
      }

      await Future.wait([
        _preferences.setString(_kToken, token),
        _preferences.setString(_kRole, role),
        _preferences.setInt(_kUserId, userId),
        _preferences.setString(_kName, name),
        _preferences.setString(_kEmail, email),
      ]);

      if (phoneNumber != null) {
        await _preferences.setString(_kPhoneNumber, phoneNumber);
      }

      if (profileImage != null) {
        await _preferences.setString(_kProfileImage, profileImage);
      }

      debugPrint('User data saved successfully for user: $email');
    } catch (e) {
      debugPrint('Failed to save user data: $e');
      throw Exception("Failed to save user data: $e");
    }
  }

  /// Getters for stored values with null safety
  String? getToken() {
    try {
      return isInitialized ? _preferences.getString(_kToken) : null;
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  String? getRole() {
    try {
      return isInitialized ? _preferences.getString(_kRole) : null;
    } catch (e) {
      debugPrint('Error getting role: $e');
      return null;
    }
  }

  int? getUserId() {
    try {
      return isInitialized ? _preferences.getInt(_kUserId) : null;
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  String? getEmail() {
    try {
      return isInitialized ? _preferences.getString(_kEmail) : null;
    } catch (e) {
      debugPrint('Error getting email: $e');
      return null;
    }
  }

  String? getName() {
    try {
      return isInitialized ? _preferences.getString(_kName) : null;
    } catch (e) {
      debugPrint('Error getting name: $e');
      return null;
    }
  }

  String? getPhoneNumber() {
    try {
      return isInitialized ? _preferences.getString(_kPhoneNumber) : null;
    } catch (e) {
      debugPrint('Error getting phone number: $e');
      return null;
    }
  }

  String? getProfileImage() {
    try {
      return isInitialized ? _preferences.getString(_kProfileImage) : null;
    } catch (e) {
      debugPrint('Error getting profile image: $e');
      return null;
    }
  }

  /// Setters for phone number and profile image
  Future<void> savePhoneNumber(String phoneNumber) async {
    try {
      if (!isInitialized) {
        throw Exception("StorageService not initialized");
      }
      await _preferences.setString(_kPhoneNumber, phoneNumber);
      debugPrint('Phone number saved successfully');
    } catch (e) {
      debugPrint('Failed to save phone number: $e');
      throw Exception("Failed to save phone number: $e");
    }
  }

  Future<void> saveProfileImage(String profileImage) async {
    try {
      if (!isInitialized) {
        throw Exception("StorageService not initialized");
      }
      await _preferences.setString(_kProfileImage, profileImage);
      debugPrint('Profile image saved successfully');
    } catch (e) {
      debugPrint('Failed to save profile image: $e');
      throw Exception("Failed to save profile image: $e");
    }
  }

  /// Profile existence flag
  Future<void> setHasProfile(bool value) async {
    try {
      if (!isInitialized) {
        throw Exception("StorageService not initialized");
      }
      await _preferences.setBool(_kHasProfile, value);
      debugPrint('HasProfile set to: $value');
    } catch (e) {
      debugPrint('Failed to set hasProfile: $e');
      throw Exception("Failed to set hasProfile: $e");
    }
  }

  Future<void> setRole(String role) async {
    try {
      if (!isInitialized) {
        throw Exception("StorageService not initialized");
      }
      await _preferences.setString(_kRole, role);
      debugPrint('Role set to: $role');
    } catch (e) {
      debugPrint('Failed to set role: $e');
      throw Exception("Failed to set role: $e");
    }
  }

  bool getHasProfile() {
    try {
      return isInitialized ? _preferences.getBool(_kHasProfile) ?? false : false;
    } catch (e) {
      debugPrint('Error getting hasProfile: $e');
      return false;
    }
  }

  /// Save "Remember Me" credentials
  Future<void> saveCredentials(String email) async {
    try {
      if (!isInitialized) {
        throw Exception("StorageService not initialized");
      }
      await _preferences.setBool(_kRememberMe, true);
      await _preferences.setString(_kSavedEmail, email);
      debugPrint('Credentials saved for email: $email');
    } catch (e) {
      debugPrint('Failed to save credentials: $e');
      throw Exception("Failed to save credentials: $e");
    }
  }

  bool getRememberMe() {
    try {
      return isInitialized ? _preferences.getBool(_kRememberMe) ?? false : false;
    } catch (e) {
      debugPrint('Error getting remember me: $e');
      return false;
    }
  }

  String? getSavedEmail() {
    try {
      return isInitialized ? _preferences.getString(_kSavedEmail) : null;
    } catch (e) {
      debugPrint('Error getting saved email: $e');
      return null;
    }
  }

  /// Clear all stored data, keeping credentials if Remember Me is enabled
  Future<void> clearAll() async {
    try {
      if (!isInitialized) {
        throw Exception("StorageService not initialized");
      }

      bool remember = getRememberMe();
      String? savedEmail = getSavedEmail();

      await _preferences.clear();
      _isInitialized = false;

      // Re-initialize after clear
      await init();

      if (remember && savedEmail != null) {
        await _preferences.setBool(_kRememberMe, true);
        await _preferences.setString(_kSavedEmail, savedEmail);
      }

      debugPrint('Storage cleared successfully');
    } catch (e) {
      debugPrint('Failed to clear storage: $e');
      throw Exception("Failed to clear storage: $e");
    }
  }

  /// Clear specific data while keeping others
  Future<void> clearUserData() async {
    try {
      if (!isInitialized) {
        throw Exception("StorageService not initialized");
      }

      bool remember = getRememberMe();
      String? savedEmail = getSavedEmail();

      // Remove only user-specific data, keep app settings
      await _preferences.remove(_kToken);
      await _preferences.remove(_kRole);
      await _preferences.remove(_kUserId);
      await _preferences.remove(_kEmail);
      await _preferences.remove(_kName);
      await _preferences.remove(_kPhoneNumber);
      await _preferences.remove(_kProfileImage);
      await _preferences.remove(_kHasProfile);

      debugPrint('User data cleared successfully');
    } catch (e) {
      debugPrint('Failed to clear user data: $e');
      throw Exception("Failed to clear user data: $e");
    }
  }

  /// Get all stored data for debugging
  Map<String, dynamic> getAllData() {
    try {
      if (!isInitialized) {
        return {'error': 'StorageService not initialized'};
      }

      return {
        'token': getToken(),
        'role': getRole(),
        'userId': getUserId(),
        'email': getEmail(),
        'name': getName(),
        'phoneNumber': getPhoneNumber(),
        'profileImage': getProfileImage(),
        'hasProfile': getHasProfile(),
        'rememberMe': getRememberMe(),
        'savedEmail': getSavedEmail(),
        'isInitialized': isInitialized,
      };
    } catch (e) {
      return {'error': 'Failed to get all data: $e'};
    }
  }
}