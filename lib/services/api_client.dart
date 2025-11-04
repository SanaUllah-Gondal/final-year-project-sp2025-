import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/Apis.dart';

class ApiClient {


  static Future<http.Response> request(
      String endpoint, {
        String method = "GET",
        Map<String, String>? headers,
        dynamic body,
      }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      throw Exception("Not logged in");
    }

    // Check token expiry here if you store expiry time
    bool expired = await _isTokenExpired();
    if (expired) {
      bool refreshed = await _refreshToken();
      if (!refreshed) {
        throw Exception("Session expired. Please login again.");
      }
      token = prefs.getString('access_token');
    }

    headers ??= {};
    headers['Authorization'] = 'Bearer $token';
    headers['Content-Type'] = 'application/json';

    Uri url = Uri.parse("$baseUrl/$endpoint");
    http.Response res;

    switch (method) {
      case "POST":
        res = await http.post(url, headers: headers, body: jsonEncode(body));
        break;
      case "PUT":
        res = await http.put(url, headers: headers, body: jsonEncode(body));
        break;
      case "DELETE":
        res = await http.delete(url, headers: headers);
        break;
      default:
        res = await http.get(url, headers: headers);
    }

    if (res.statusCode == 401) {
      // Token might have expired mid-request
      bool refreshed = await _refreshToken();
      if (refreshed) {
        return request(endpoint, method: method, headers: headers, body: body);
      } else {
        throw Exception("Session expired. Please login again.");
      }
    }

    return res;
  }

  static Future<bool> _isTokenExpired() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? expiry = prefs.getInt('token_expiry');
    if (expiry == null) return true;
    return DateTime.now().millisecondsSinceEpoch > expiry;
  }

  static Future<bool> _refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return false;

    var res = await http.post(
      Uri.parse("$baseUrl/refresh"),
      body: {"refresh_token": refreshToken},
    );

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      prefs.setString('access_token', data['access_token']);
      prefs.setInt(
        'token_expiry',
        DateTime.now()
            .add(Duration(seconds: data['expires_in']))
            .millisecondsSinceEpoch,
      );
      return true;
    }

    return false;
  }
}
