import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Apis.dart';

class AppointmentService {
  static Future<Map<String, dynamic>> createAppointment(
      Map<String, dynamic> appointmentData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    print('Creating appointment with data: $appointmentData');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(appointmentData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(response.body)['data'],
        };
      } else {
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'message': errorResponse['message'] ?? 'Failed to create appointment',
          'errors': errorResponse['errors'] ?? {},
        };
      }
    } catch (e) {
      print('Error creating appointment: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/appointments'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Get appointments response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body)['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch appointments: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateAppointmentStatus(
      String appointmentId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/appointments/$appointmentId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status}),
      );

      print('Update status response: ${response.statusCode}');
      print('Update status body: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body)['data'],
        };
      } else {
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'message': errorResponse['message'] ?? 'Failed to update appointment status',
        };
      }
    } catch (e) {
      print('Error updating appointment status: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}