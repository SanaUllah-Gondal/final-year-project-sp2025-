import 'dart:convert';
import 'package:http/http.dart' as http;

import 'get_server_key.dart';

class GetServerTokenKey {
  Future<String> getServerTokenKey() async {
    GetServerKey serverKeyObj = GetServerKey();
    String serverKey = await serverKeyObj.getServerTokenKey();
    return serverKey;
  }
}

class SendNotificationService {
  static const String _projectId = 'skill-link47';
  static const String _baseUrl = 'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

  static Future<Map<String, dynamic>> sendNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? sound = 'default',
    String priority = 'HIGH', // 'HIGH' or 'NORMAL'
  }) async {
    try {
      String serverKey = await GetServerTokenKey().getServerTokenKey();
      print("🔑 Using server access token");

      var headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      };

      // Build HTTP v1 compliant message payload
      Map<String, dynamic> message = _buildMessagePayload(
        token: token,
        title: title,
        body: body,
        data: data,
        imageUrl: imageUrl,
        sound: sound,
        priority: priority,
      );

      print("📤 Sending notification to: ${token.substring(0, 20)}...");
      print("📝 Title: $title");
      print("📝 Body: $body");
      if (data != null) print("📊 Data: $data");

      // Send HTTP v1 request
      final http.Response response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: jsonEncode(message),
      ).timeout(const Duration(seconds: 30));

      print("📥 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("✅ Notification sent successfully!");
        return {'success': true, 'message': 'Notification sent successfully', 'response': responseData};
      } else {
        final errorData = json.decode(response.body);
        print("❌ HTTP Error: ${response.statusCode} - ${errorData['error']['message']}");
        print("📥 Response body: ${response.body}");
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${errorData['error']['message']}'
        };
      }
    } catch (e) {
      print("❌ Error sending notification: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  static Map<String, dynamic> _buildMessagePayload({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? sound,
    required String priority,
  }) {
    Map<String, dynamic> payload = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body,
        },
        // ✅ CORRECT Android configuration with priority at root level
        "android": {
          "priority": priority, // "HIGH" or "NORMAL" - CORRECT LOCATION
          "notification": {
            "sound": sound ?? "default",
            "channel_id": "high_importance_channel",
            "default_sound": true,
            "default_vibrate_timings": true,
          }
        },
        // ✅ CORRECT iOS configuration with priority header
        "apns": {
          "headers": {
            "apns-priority": priority == "HIGH" ? "10" : "5", // "10" for high, "5" for normal
          },
          "payload": {
            "aps": {
              "alert": {
                "title": title,
                "body": body,
              },
              "sound": sound ?? "default",
              "badge": 1,
            }
          }
        }
      }
    };

    // Add data if provided
    if (data != null && data.isNotEmpty) {
      payload["message"]["data"] = _stringifyData(data);
    }

    // Add image if provided
    if (imageUrl != null && imageUrl.isNotEmpty) {
      payload["message"]["notification"]["image"] = imageUrl;

      // Android specific image
      if (payload["message"]["android"] != null &&
          payload["message"]["android"]["notification"] != null) {
        payload["message"]["android"]["notification"]["image"] = imageUrl;
      }

      // iOS specific image
      if (payload["message"]["apns"] != null) {
        payload["message"]["apns"]["fcm_options"] = {
          "image": imageUrl
        };
      }
    }

    return payload;
  }

  // Convert nested JSON to string for data field (HTTP v1 requirement)
  static Map<String, String> _stringifyData(Map<String, dynamic> data) {
    Map<String, String> stringifiedData = {};

    data.forEach((key, value) {
      if (value is Map || value is List) {
        stringifiedData[key] = jsonEncode(value);
      } else {
        stringifiedData[key] = value.toString();
      }
    });

    return stringifiedData;
  }
// Send bid notification with high priority
  static Future<Map<String, dynamic>> sendBidNotification({
    required String token,
    required String appointmentId,
    required double bidAmount,
    required String serviceType,
    required String providerName,
    String? providerImage,
    String priority = 'HIGH',
  }) async {
    final data = {
      'screen': 'appointments',
      'appointment_id': appointmentId,
      'service_type': serviceType,
      'bid_amount': bidAmount.toString(),
      'provider_name': providerName,
      'type': 'new_bid',
      'timestamp': DateTime.now().toIso8601String(),
    };

    return await sendNotification(
      token: token,
      title: '💰 New Bid Received',
      body: '$providerName placed a bid of Rs. ${bidAmount.toStringAsFixed(0)} for your $serviceType appointment',
      data: data,
      imageUrl: providerImage,
      priority: priority,
    );
  }
  // Send notification to multiple tokens
  static Future<Map<String, dynamic>> sendMulticastNotification({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String priority = 'HIGH',
  }) async {
    final Map<String, dynamic> results = {
      'successful': 0,
      'failed': 0,
      'errors': <String>[],
      'total': tokens.length,
    };

    for (String token in tokens) {
      final result = await sendNotification(
        token: token,
        title: title,
        body: body,
        data: data,
        priority: priority,
      );

      if (result['success'] == true) {
        results['successful'] = (results['successful'] as int) + 1;
      } else {
        results['failed'] = (results['failed'] as int) + 1;
        final errorMessage = result['error']?.toString() ?? 'Unknown error';
        (results['errors'] as List<String>).add("Token ${token.substring(0, 10)}...: $errorMessage");
      }
    }

    print("📊 Multicast results: ${results['successful']} successful, ${results['failed']} failed out of ${results['total']} total");
    return results;
  }

  // Alternative approach using more type-safe structure
  static Future<MulticastResult> sendMulticastNotificationV2({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String priority = 'HIGH',
  }) async {
    int successful = 0;
    int failed = 0;
    final List<String> errors = [];

    for (String token in tokens) {
      final result = await sendNotification(
        token: token,
        title: title,
        body: body,
        data: data,
        priority: priority,
      );

      if (result['success'] == true) {
        successful++;
      } else {
        failed++;
        final errorMessage = result['error']?.toString() ?? 'Unknown error';
        errors.add("Token ${token.substring(0, 10)}...: $errorMessage");
      }
    }

    print("📊 Multicast results: $successful successful, $failed failed out of ${tokens.length} total");

    return MulticastResult(
      successful: successful,
      failed: failed,
      total: tokens.length,
      errors: errors,
    );
  }

  // Send appointment status notification with high priority
  static Future<Map<String, dynamic>> sendAppointmentStatusNotification({
    required String token,
    required String appointmentId,
    required String status,
    required String serviceType,
    required String userName,
    required DateTime appointmentDate,
    String? userImage,
    String priority = 'HIGH',
  }) async {
    String title = '';
    String body = '';

    switch (status) {
      case 'accepted':
        title = '✅ Appointment Accepted';
        body = '$userName accepted your $serviceType appointment';
        break;
      case 'rejected':
        title = '❌ Appointment Declined';
        body = '$userName declined your $serviceType appointment';
        break;
      case 'completed':
        title = '🎉 Appointment Completed';
        body = 'Your $serviceType appointment has been completed';
        break;
      case 'cancelled':
        title = '⚠️ Appointment Cancelled';
        body = '$userName cancelled the $serviceType appointment';
        break;
      default:
        title = 'Appointment Update';
        body = 'Your appointment status has been updated to $status';
    }

    final data = {
      'screen': 'appointments',
      'appointment_id': appointmentId,
      'service_type': serviceType,
      'status': status,
      'appointment_date': appointmentDate.toIso8601String(),
      'user_name': userName,
      'type': 'appointment_status_update',
    };

    return await sendNotification(
      token: token,
      title: title,
      body: body,
      data: data,
      imageUrl: userImage,
      priority: priority,
    );
  }

  // Send new appointment request with high priority
  static Future<Map<String, dynamic>> sendNewAppointmentNotification({
    required String token,
    required String appointmentId,
    required String serviceType,
    required String userName,
    required DateTime appointmentDate,
    String? userImage,
    String priority = 'HIGH',
  }) async {
    final data = {
      'screen': 'appointments',
      'appointment_id': appointmentId,
      'service_type': serviceType,
      'appointment_date': appointmentDate.toIso8601String(),
      'user_name': userName,
      'type': 'new_appointment',
    };

    return await sendNotification(
      token: token,
      title: '📅 New Appointment Request',
      body: '$userName booked a $serviceType appointment',
      data: data,
      imageUrl: userImage,
      priority: priority,
    );
  }

  // Send urgent notification with maximum priority
  static Future<Map<String, dynamic>> sendUrgentNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    return await sendNotification(
      token: token,
      title: title,
      body: body,
      data: data,
      priority: 'HIGH', // Maximum priority for urgent notifications
    );
  }

  // Send low priority notification (for non-urgent updates)
  static Future<Map<String, dynamic>> sendLowPriorityNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    return await sendNotification(
      token: token,
      title: title,
      body: body,
      data: data,
      priority: 'NORMAL', // Lower priority for non-urgent notifications
    );
  }
}

// Type-safe result class for multicast notifications
class MulticastResult {
  final int successful;
  final int failed;
  final int total;
  final List<String> errors;

  MulticastResult({
    required this.successful,
    required this.failed,
    required this.total,
    required this.errors,
  });

  double get successRate => total > 0 ? successful / total : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'successful': successful,
      'failed': failed,
      'total': total,
      'errors': errors,
      'success_rate': successRate,
    };
  }
}