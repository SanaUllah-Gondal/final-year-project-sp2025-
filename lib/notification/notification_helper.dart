import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plumber_project/notification/send_notification.dart';


class NotificationHelper {
  static Future<String?> getUserFcmToken(String userEmail) async {
    try {
      final tokenDoc = await FirebaseFirestore.instance
          .collection('userTokens')
          .doc(userEmail)
          .get();

      if (tokenDoc.exists) {
        return tokenDoc.data()?['deviceToken'] as String?;
      }
      return null;
    } catch (e) {
      print('❌ Error fetching user FCM token: $e');
      return null;
    }
  }
  static Future<void> sendBidNotification({
    required String userEmail,
    required String appointmentId,
    required double bidAmount,
    required String serviceType,
    required String providerName,
  }) async {
    try {
      final userFcmToken = await getUserFcmToken(userEmail);

      if (userFcmToken != null && userFcmToken.isNotEmpty) {
        final title = '💰 New Bid Received';
        final body = '$providerName placed a bid of Rs. ${bidAmount.toStringAsFixed(0)} for your $serviceType appointment';

        final notificationResult = await SendNotificationService.sendBidNotification(
          token: userFcmToken,
          appointmentId: appointmentId,
          bidAmount: bidAmount,
          serviceType: serviceType,
          providerName: providerName,
          priority: 'HIGH',
        );

        if (notificationResult['success'] == true) {
          print('✅ Bid notification sent successfully to $userEmail');
        } else {
          print('❌ Failed to send bid notification: ${notificationResult['error']}');
        }
      } else {
        print('⚠️ No FCM token found for user: $userEmail');
      }
    } catch (e) {
      print('❌ Error sending bid notification: $e');
    }
  }

  static Future<void> sendAppointmentStatusNotification({
    required String userEmail,
    required String appointmentId,
    required String status,
    required String serviceType,
    required String providerName,
    required DateTime appointmentDate,
  }) async {
    try {
      final userFcmToken = await getUserFcmToken(userEmail);

      if (userFcmToken != null && userFcmToken.isNotEmpty) {
        String title = '';
        String body = '';
        String notificationStatus = '';

        switch (status) {
          case 'confirmed':
            title = '✅ Appointment Confirmed';
            body = 'Your $serviceType appointment has been confirmed by $providerName';
            notificationStatus = 'accepted';
            break;
          case 'cancelled':
            title = '❌ Appointment Cancelled';
            body = 'Your $serviceType appointment has been cancelled by $providerName';
            notificationStatus = 'cancelled';
            break;
          default:
            title = 'Appointment Updated';
            body = 'Your appointment status has been updated to $status';
            notificationStatus = status;
        }

        final notificationResult = await SendNotificationService.sendAppointmentStatusNotification(
          token: userFcmToken,
          appointmentId: appointmentId,
          status: notificationStatus,
          serviceType: serviceType,
          userName: providerName,
          appointmentDate: appointmentDate,
          priority: 'HIGH',
        );

        if (notificationResult['success'] == true) {
          print('✅ Status notification sent successfully to $userEmail');
        } else {
          print('❌ Failed to send notification: ${notificationResult['error']}');
        }
      } else {
        print('⚠️ No FCM token found for user: $userEmail');
      }
    } catch (e) {
      print('❌ Error sending status notification: $e');
    }
  }
}