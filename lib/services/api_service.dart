// lib/services/api_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../pages/Apis.dart';

class ApiService extends GetxService {
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw 'Failed to make GET request: $e';
    }
  }

  Future<dynamic> post(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers?..['Content-Type'] = 'application/json',
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw 'Failed to make POST request: $e';
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw 'Request failed with status: ${response.statusCode}. ${response.body}';
    }
  }
}
