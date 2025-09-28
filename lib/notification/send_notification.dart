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
  static Future<void> sendNotificationUsingApi({
    required String? token,
    required String? title,
    required String? body,
    required Map<String, dynamic>? data,
  }) async {
    try {
      String serverKey = await GetServerTokenKey().getServerTokenKey();
      print("🔑 Notification server key loaded=$serverKey");

      String url = "https://fcm.googleapis.com/v1/projects/skill-link47/messages:send";
      var headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      };

      // Message payload
      Map<String, dynamic> message = {
        "message": {
          "token": token,
          "notification": {"body": body, "title": title},
          "data": data,
        }
      };

      print("📤 Sending notification to: ${token?.substring(0, 20)}...");
      print("📝 Notification title: $title");
      print("📝 Notification body: $body");

      // Send request
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(message),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == 1) {
          print("✅ Notification sent successfully!");
        } else {
          print("❌ Notification failed: ${responseData['results']}");
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }

  // Additional method for sending appointment status updates
  static Future<void> sendAppointmentStatusNotification({
    required String? token,
    required String appointmentId,
    required String status,
    required String serviceType,
    required String userName,
    required DateTime appointmentDate,
  }) async {
    String title = '';
    String body = '';

    switch (status) {
      case 'accepted':
        title = '✅ Appointment Accepted';
        body = '$userName accepted your ${serviceType} appointment';
        break;
      case 'rejected':
        title = '❌ Appointment Declined';
        body = '$userName declined your ${serviceType} appointment';
        break;
      case 'completed':
        title = '🎉 Appointment Completed';
        body = 'Your ${serviceType} appointment has been completed';
        break;
      case 'cancelled':
        title = '⚠️ Appointment Cancelled';
        body = '$userName cancelled the ${serviceType} appointment';
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
      'type': 'appointment_status_update',
    };

    await sendNotificationUsingApi(
      token: token,
      title: title,
      body: body,
      data: data,
    );
  }
}