import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  static const base = 'http://10.0.2.2:8000/api'; // adjust for device
  static Future<List<dynamic>> fetchWorkers() async {
    try {
      final res = await http.get(Uri.parse('$base/workers'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'];
      }
    } catch (_) {}
    return [];
  }
}
