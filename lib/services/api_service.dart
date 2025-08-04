// lib/services/api_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../pages/Apis.dart';

class ApiService extends GetxService {


  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      return _processResponse(response);
    } catch (e) {
      throw 'Failed to GET data: ${e.toString()}';
    }
  }

  Future<dynamic> post(String endpoint, dynamic body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw 'Failed to POST data: ${e.toString()}';
    }
  }

  dynamic _processResponse(http.Response response) {
    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      throw decoded['message'] ?? 'Request failed with status ${response.statusCode}';
    }
  }
}