import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:plumber_project/services/storage_service.dart';
import '../pages/Apis.dart';

class ApiService extends GetxService {
  final StorageService _storageService = Get.find();
  final bool debugMode = true;

  void _log(String message) {
    if (debugMode) {
      debugPrint('[ApiService] $message');
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      _log('POST $path with body: ${jsonEncode(body)}');

      final url = Uri.parse('$baseUrl$path');
      final token = await _storageService.getToken();

      // Create headers with proper type
      Map<String, String> authHeaders = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      final resp = await http.post(
        url,
        body: jsonEncode(body),
        headers: authHeaders,
      ).timeout(const Duration(seconds: 30));

      _log('Response: ${resp.statusCode} ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } else {
        throw Exception('API error: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      _log('POST $path error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? headers}) async {
    try {
      _log('GET $path');

      final url = Uri.parse('$baseUrl$path');
      final token = await _storageService.getToken();

      // Create headers with proper type
      Map<String, String> authHeaders = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      final resp = await http.get(
        url,
        headers: authHeaders,
      ).timeout(const Duration(seconds: 30));

      _log('Response: ${resp.statusCode} ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } else {
        throw Exception('API error: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      _log('GET $path error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      _log('PUT $path with body: ${jsonEncode(body)}');

      final url = Uri.parse('$baseUrl$path');
      final token = await _storageService.getToken();

      Map<String, String> authHeaders = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      final resp = await http.put(
        url,
        body: jsonEncode(body),
        headers: authHeaders,
      ).timeout(const Duration(seconds: 30));

      _log('Response: ${resp.statusCode} ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } else {
        throw Exception('API error: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      _log('PUT $path error: $e');
      rethrow;
    }
  }

  // Toggle online/offline status - UPDATED for new structure
  Future<Map<String, dynamic>> toggleOnlineStatus({
    required String providerType,
    required bool isOnline,
    required String addressName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await post('/api/providers/$providerType/toggle-status', body: {
        'is_online': isOnline,
        'address_name': addressName,
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      _log('Toggle online status error: $e');
      rethrow;
    }
  }

  // Update working status - SIMPLIFIED
  Future<Map<String, dynamic>> updateWorkingStatus({
    required String providerType,
    required bool isWorking,
  }) async {
    try {
      return await post('/api/providers/$providerType/working-status', body: {
        'is_working': isWorking,
      });
    } catch (e) {
      _log('Update working status error: $e');
      rethrow;
    }
  }

  // Get provider status - SIMPLIFIED
  Future<Map<String, dynamic>> getProviderStatus(String providerType) async {
    try {
      return await get('/api/providers/$providerType/status');
    } catch (e) {
      _log('Get provider status error: $e');
      rethrow;
    }
  }

  // Update provider location - UPDATED for new structure
  Future<Map<String, dynamic>> updateProviderLocation({
    required String providerType,
    required String addressName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await post('/api/providers/$providerType/update-location', body: {
        'address_name': addressName,
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      _log('Update location error: $e');
      rethrow;
    }
  }

  // Get available providers
  Future<Map<String, dynamic>> getAvailableProviders(String providerType) async {
    try {
      return await get('/api/providers/available/$providerType');
    } catch (e) {
      _log('Get available providers error: $e');
      rethrow;
    }
  }

  // Get plumber profile by ID
  Future<Map<String, dynamic>> getPlumberProfileById(int id) async {
    try {
      return await get('/api/profiles/plumbers/$id');
    } catch (e) {
      _log('Get plumber profile error: $e');
      rethrow;
    }
  }

  // Get detailed plumber profile with phone and image
  Future<Map<String, dynamic>> getPlumberProfileDetails(int profileId) async {
    try {
      return await get('/api/profiles/plumber/$profileId');
    } catch (e) {
      _log('Get plumber profile details error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyElectricianProfile() async {
    try {
      return await get('/api/electrician/profiles/my');
    } catch (e) {
      _log('Get electrician profile error: $e');
      rethrow;
    }
  }

  // Get my plumber profile (protected)
  Future<Map<String, dynamic>> getMyPlumberProfile() async {
    try {
      return await get('/api/plumber/profiles/my');
    } catch (e) {
      _log('Get my plumber profile error: $e');
      rethrow;
    }
  }

  // Get my cleaner profile
  Future<Map<String, dynamic>> getMyCleanerProfile() async {
    try {
      return await get('/api/cleaner/profiles/my');
    } catch (e) {
      _log('Get my cleaner profile error: $e');
      rethrow;
    }
  }

  // Check if plumber profile exists (protected)
  Future<Map<String, dynamic>> checkPlumberProfileExists() async {
    try {
      return await get('/api/profiles/check-plumber');
    } catch (e) {
      _log('Check plumber profile error: $e');
      rethrow;
    }
  }

  // Update plumber profile (protected)
  Future<Map<String, dynamic>> updatePlumberProfile(Map<String, dynamic> data) async {
    try {
      return await put('/api/profiles/plumber/me', body: data);
    } catch (e) {
      _log('Update plumber profile error: $e');
      rethrow;
    }
  }

  // Get user info (protected)
  Future<Map<String, dynamic>> getMe() async {
    try {
      return await get('/api/me');
    } catch (e) {
      _log('Get user info error: $e');
      rethrow;
    }
  }

  // Additional methods that might be needed for the new structure

  // Update cleaner profile
  Future<Map<String, dynamic>> updateCleanerProfile(Map<String, dynamic> data) async {
    try {
      return await put('/api/profiles/cleaner/my', body: data);
    } catch (e) {
      _log('Update cleaner profile error: $e');
      rethrow;
    }
  }

  // Update electrician profile
  Future<Map<String, dynamic>> updateElectricianProfile(Map<String, dynamic> data) async {
    try {
      return await put('/api/profiles/electrician/me', body: data);
    } catch (e) {
      _log('Update electrician profile error: $e');
      rethrow;
    }
  }

  // Check if cleaner profile exists
  Future<Map<String, dynamic>> checkCleanerProfileExists() async {
    try {
      return await get('/api/profiles/check-cleaner');
    } catch (e) {
      _log('Check cleaner profile error: $e');
      rethrow;
    }
  }

  // Check if electrician profile exists
  Future<Map<String, dynamic>> checkElectricianProfileExists() async {
    try {
      return await get('/api/profiles/check-electrician');
    } catch (e) {
      _log('Check electrician profile error: $e');
      rethrow;
    }
  }

  // Get user email (if needed separately)
  Future<String?> getUserEmail() async {
    try {
      final userData = await getMe();
      return userData['email']?.toString();
    } catch (e) {
      _log('Get user email error: $e');
      return null;
    }
  }
}