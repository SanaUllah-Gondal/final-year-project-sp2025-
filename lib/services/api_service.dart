import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../pages/Apis.dart';

class ApiService extends GetxService {

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$path');
    final resp = await http.post(url, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      ...?headers,
    });

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      debugPrint('[ApiService] POST $path failed: ${resp.statusCode} ${resp.body}');
      throw Exception('API error: ${resp.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$path');
    final resp = await http.get(url, headers: headers);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      debugPrint('[ApiService] GET $path failed: ${resp.statusCode} ${resp.body}');
      throw Exception('API error: ${resp.statusCode}');
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
