import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/storage_service.dart';
import '../../Apis.dart';

class AppointmentService {
  static Future<Map<String, dynamic>> createAppointment(
      Map<String, dynamic> appointmentData) async {
    final StorageService _storageService = Get.find();
    final token = _storageService.getToken();

    // Extract service type and remove it from the data
    final serviceType = appointmentData['service_type']?.toLowerCase();
    appointmentData.remove('service_type');

    // Determine the correct endpoint based on service type
    String endpoint;
    switch (serviceType) {
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
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(appointmentData),
      );

      if (_isHtml(response.body)) {
        return {
          'success': false,
          'message': 'Server error: Invalid HTML response',
          'statusCode': response.statusCode,
        };
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': responseData['data']};
      }
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to create appointment',
        'errors': responseData['errors'] ?? {},
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
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

      if (_isHtml(response.body)) {
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

  static Future<Map<String, dynamic>> updateAppointmentStatus(
      String serviceType, String appointmentId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Determine the correct endpoint based on service type
    String endpoint;
    switch (serviceType.toLowerCase()) {
      case 'plumber':
        endpoint = '$baseUrl/api/appointments/plumber/$appointmentId/status';
        break;
      case 'cleaner':
        endpoint = '$baseUrl/api/appointments/cleaner/$appointmentId/status';
        break;
      case 'electrician':
        endpoint = '$baseUrl/api/appointments/electrician/$appointmentId/status';
        break;
      default:
        return {
          'success': false,
          'message': 'Invalid service type: $serviceType'
        };
    }

    try {
      final response = await http.patch(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status}),
      );

      if (_isHtml(response.body)) {
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
        'message':
        responseData['message'] ?? 'Failed to update appointment status',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  static String? getToken() {
    try {
      final StorageService _storageService = Get.find();
      return _storageService.getToken();
    } catch (e) {
      print('Error getting token: $e');
      return '';
    }
  }
  // --- Helpers ---
  static bool _isHtml(String response) {
    final t = response.trim().toLowerCase();
    return t.startsWith('<!doctype html') || t.startsWith('<html');
  }
}