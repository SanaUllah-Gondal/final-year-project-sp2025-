import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:plumber_project/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/Apis.dart';


class ApiService extends GetxService {
  final StorageService _storageService = Get.find();
  final bool debugMode = true;

  void _log(String message) {
    if (debugMode) {
      debugPrint('[ApiService] $message');
    }
  }
  Future<Map<String, dynamic>> placeBid(
      String serviceType,
      String appointmentId,
      double bidAmount,
      ) async {
    final StorageService storageService = Get.find();
    final token = await storageService.getToken();

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/appointments/$serviceType/$appointmentId/price'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: json.encode({'price': bidAmount}),
      );

      if (_isHtml(response.body)) {
        return {
          'success': false,
          'message': 'Server error: Invalid HTML response',
        };
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Status updated successfully',
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to update status',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getAppointments(String serviceType) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Determine the correct endpoint based on service type
    String endpoint;
    switch (serviceType.toLowerCase()) {
      case 'plumber':
        endpoint = '$baseUrl/api/appointments/plumber';
        break;
      case 'cleaner':
        endpoint = '$baseUrl/api/appointments/cleaner';
        break;
      case 'electrician':
        endpoint = '$baseUrl/api/appointments/electrician';
        break;
      default:
        return {
          'success': false,
          'message': 'Invalid service type: $serviceType'
        };
    }

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (_isHtml1(response.body)) {
        return {
          'success': false,
          'message': 'Server error: Invalid HTML response',
          'statusCode': response.statusCode,
        };
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData['data']};
      }
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to fetch appointments',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
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

  Future<Map<String, dynamic>> getCleanerAppointments() async {
    StorageService _storageService = Get.find();
    final token = await _storageService.getToken();

    print('Making GET request to: $baseUrl/api/appointments/cleaner');
    print('Token: ${token != null ? "Present" : "Missing"}');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/appointments/cleaner'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      if (_isHtml(response.body)) {
        print('Response is HTML instead of JSON');
        return {
          'success': false,
          'message': 'Server error: Invalid HTML response',
          'data': []
        };
      }

      final responseData = json.decode(response.body);
      print('Parsed JSON response: $responseData');

      if (response.statusCode == 200) {
        print('Request successful, returning data');
        return {
          'success': true,
          'data': responseData['data'] ?? [],
        };
      }

      print('Request failed with status: ${response.statusCode}');
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to fetch appointments',
        'data': []
      };
    } catch (e) {
      print('Exception in getCleanerAppointments: $e');

      return {
        'success': false,
        'message': 'Network error: $e',
        'data': []
      };
    }
  }

  Future<Map<String, dynamic>> getPlumberAppointments() async {
    StorageService _storageService = Get.find();
    final token = await _storageService.getToken();

    print('Making GET request to: $baseUrl/api/appointments/plumber');
    print('Token: ${token != null ? "Present" : "Missing"}');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/appointments/plumber'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      if (_isHtml(response.body)) {
        print('Response is HTML instead of JSON');
        return {
          'success': false,
          'message': 'Server error: Invalid HTML response',
          'data': []
        };
      }

      final responseData = json.decode(response.body);
      print('Parsed JSON response: $responseData');

      if (response.statusCode == 200) {
        print('Request successful, returning data');
        return {
          'success': true,
          'data': responseData['data'] ?? [],
        };
      }

      print('Request failed with status: ${response.statusCode}');
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to fetch appointments',
        'data': []
      };
    } catch (e) {
      print('Exception in getPlumberAppointments: $e');

      return {
        'success': false,
        'message': 'Network error: $e',
        'data': []
      };
    }
  }

  Future<Map<String, dynamic>> getElectricianAppointments() async {
    StorageService _storageService = Get.find();
    final token = await _storageService.getToken();

    print('Making GET request to: $baseUrl/api/appointments/electrician');
    print('Token: ${token != null ? "Present" : "Missing"}');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/appointments/electrician'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      if (_isHtml(response.body)) {
        print('Response is HTML instead of JSON');
        return {
          'success': false,
          'message': 'Server error: Invalid HTML response',
          'data': []
        };
      }

      final responseData = json.decode(response.body);
      print('Parsed JSON response: $responseData');

      if (response.statusCode == 200) {
        print('Request successful, returning data');
        return {
          'success': true,
          'data': responseData['data'] ?? [],
        };
      }

      print('Request failed with status: ${response.statusCode}');
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to fetch appointments',
        'data': []
      };
    } catch (e) {
      print('Exception in getElectricianAppointments: $e');

      return {
        'success': false,
        'message': 'Network error: $e',
        'data': []
      };
    }
  }

// Check if user has ongoing appointments using existing methods
  Future<Map<String, dynamic>> checkOngoingAppointments(String serviceType) async {
    try {
      _log('Checking ongoing appointments for: $serviceType');

      // Get appointments for all service types
      final List<Future<Map<String, dynamic>>> futures = [
        getCleanerAppointments(),
        getPlumberAppointments(),
        getElectricianAppointments(),
      ];

      final results = await Future.wait(futures);

      // Check for pending/confirmed appointments in the specified service type
      for (var result in results) {
        if (result['success'] == true && result['data'] != null) {
          List<Map<String, dynamic>> appointments = [];

          // Parse appointments based on response format
          if (result['data'] is List) {
            appointments = List<Map<String, dynamic>>.from(result['data'] ?? []);
          } else if (result['data'] is Map) {
            final dataMap = result['data'] as Map<String, dynamic>;
            if (dataMap['data'] is List) {
              appointments = List<Map<String, dynamic>>.from(dataMap['data'] ?? []);
            } else {
              // If it's a single appointment map, wrap it in a list
              appointments = [dataMap];
            }
          }

          // Check each appointment for matching service type and ongoing status
          for (var appointment in appointments) {
            final status = appointment['status']?.toString().toLowerCase();
            final appointmentServiceType = _getAppointmentServiceType(appointment, result);

            // Check if this appointment matches the service type and has ongoing status
            if (appointmentServiceType.toLowerCase() == serviceType.toLowerCase() &&
                (status == 'pending' || status == 'confirmed' || status == 'accepted')) {
              _log('Found ongoing $serviceType appointment with status: $status');
              return {
                'success': true,
                'hasOngoing': true,
                'appointment': appointment,
                'serviceType': serviceType,
                'status': status,
                'message': 'You have an ongoing $serviceType appointment (Status: ${status?.toUpperCase()})'
              };
            }
          }
        }
      }

      _log('No ongoing $serviceType appointments found');
      return {
        'success': true,
        'hasOngoing': false,
        'message': 'No ongoing $serviceType appointments found'
      };
    } catch (e) {
      _log('Check ongoing appointments error: $e');
      return {
        'success': false,
        'hasOngoing': false,
        'message': 'Error checking appointments: $e'
      };
    }
  }
  Future<Map<String, dynamic>> getUserAppointments() async {
    try {
      _log('Getting all user appointments');

      final List<Future<Map<String, dynamic>>> futures = [
        getCleanerAppointments(),
        getPlumberAppointments(),
        getElectricianAppointments(),
      ];

      final results = await Future.wait(futures);

      List<Map<String, dynamic>> allAppointments = [];

      for (var result in results) {
        if (result['success'] == true && result['data'] != null) {
          // Handle the pagination structure - extract the actual appointments list
          final data = result['data'];
          List<dynamic> appointmentsData = [];

          if (data is Map<String, dynamic>) {
            // This is the pagination structure with 'data' field containing the list
            appointmentsData = data['data'] ?? [];
          } else if (data is List) {
            // This is already a list
            appointmentsData = data;
          }

          // Convert to List<Map<String, dynamic>>
          final appointments = List<Map<String, dynamic>>.from(
              appointmentsData.whereType<Map<String, dynamic>>()
          );

          // Add service type to each appointment
          for (var appointment in appointments) {
            appointment['service_type'] = _getAppointmentServiceType(appointment, result);
            allAppointments.add(appointment);
          }
        }
      }

      // Sort by date (newest first)
      allAppointments.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['appointment_date'] ?? a['created_at'] ?? DateTime.now().toString());
          final dateB = DateTime.parse(b['appointment_date'] ?? b['created_at'] ?? DateTime.now().toString());
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      return {
        'success': true,
        'data': allAppointments,
        'message': 'Appointments loaded successfully'
      };
    } catch (e) {
      _log('Get user appointments error: $e');
      return {
        'success': false,
        'data': [],
        'message': 'Error loading appointments: $e'
      };
    }
  }

// Check if user has any pending appointments across all services
  Future<bool> hasPendingAppointments() async {
    try {
      final response = await getUserAppointments();
      if (response['success'] == true) {
        final appointments = List<Map<String, dynamic>>.from(response['data'] ?? []);
        return appointments.any((appointment) {
          final status = appointment['status']?.toString().toLowerCase();
          return status == 'pending' || status == 'confirmed' || status == 'accepted';
        });
      }
      return false;
    } catch (e) {
      _log('Has pending appointments error: $e');
      return false;
    }
  }
  // Helper method to determine service type from appointment data
  String _getAppointmentServiceType(Map<String, dynamic> appointment, Map<String, dynamic> result) {
    // Try to get from appointment data first
    if (appointment['service_type'] != null) {
      return appointment['service_type'].toString();
    }

    // Try to determine from result data
    final requestUrl = result.toString().toLowerCase();
    if (requestUrl.contains('cleaner')) return 'cleaner';
    if (requestUrl.contains('plumber')) return 'plumber';
    if (requestUrl.contains('electrician')) return 'electrician';

    // Default based on appointment data structure
    if (appointment['cleaner_id'] != null) return 'cleaner';
    if (appointment['plumber_id'] != null) return 'plumber';
    if (appointment['electrician_id'] != null) return 'electrician';

    return 'unknown';
  }

  bool _isHtml(String responseBody) {
    final trimmed = responseBody.trim();
    return trimmed.startsWith('<!DOCTYPE html') ||
        trimmed.startsWith('<html') ||
        trimmed.contains('<body') ||
        trimmed.contains('<head') ||
        trimmed.contains('<title') ||
        trimmed.startsWith('HTTP') ||
        trimmed.contains('<!DOCTYPE HTML');
  }


  Future<Map<String, dynamic>> completeAppointmentWithPayment(
      String serviceType,
      String appointmentId,
      String paymentMethod,
      double amount,
      ) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        '/$serviceType/appointments/$appointmentId/complete',
        data: {
          'payment_method': paymentMethod,
          'amount': amount,
          'completed_at': DateTime.now().toIso8601String(),
        },
      );

      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to complete appointment',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  Future<Map<String, dynamic>> updateAppointmentStatus(
      String serviceType,
      String appointmentId,
      String status
      ) async {
    StorageService _storageService= Get.find();
    final token = await _storageService.getToken();
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/appointments/$serviceType/$appointmentId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (_isHtml(response.body)) {
        return {
          'success': false,
          'message': 'Server error: Invalid HTML response',
        };
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Status updated successfully',
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to update status',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
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
      return await get('/api/cleaner/profile/my');
    } catch (e) {
      _log('Get my cleaner profile error: $e');
      rethrow;
    }
  }

  // Check if plumber profile exists (protected)
  Future<Map<String, dynamic>> checkPlumberProfileExists() async {
    try {
      return await get('/api/profile/check-plumber');
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

  // Get user email
  Future<String?> getUserEmail() async {
    try {
      final userData = await getMe();
      return userData['email']?.toString();
    } catch (e) {
      _log('Get user email error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> cancelAppointment(String serviceType, String appointmentId) async {
    return await post('/api/$serviceType-appointments/$appointmentId/cancel');
  }

  static bool _isHtml1(String response) {
    final t = response.trim().toLowerCase();
    return t.startsWith('<!doctype html') || t.startsWith('<html');
  }
}