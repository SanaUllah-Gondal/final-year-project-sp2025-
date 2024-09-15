import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class FirebaseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getProviderData(
      String serviceType,
      String providerId
      ) async {
    try {
      String collectionName = _getCollectionName(serviceType);
      print('Collection Name: $collectionName');
      print('Provider ID: $providerId');

      final doc = await _firestore
          .collection(collectionName)
          .doc(providerId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print('Error fetching provider data: $e');
    }

    return null;
  }

  Future<String?> getProblemImage(String serviceType, String appointmentId) async {
    try {
      String collectionName = '${serviceType}_appointment';

      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('id', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final problemImage = data['problem_image'];

        if (problemImage is String && problemImage.isNotEmpty) {
          return problemImage;
        }
      }
    } catch (e) {
      print('Error fetching problem image: $e');
    }

    return null;
  }

  String _getCollectionName(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'cleaner':
        return 'cleaner';
      case 'plumber':
        return 'plumber';
      case 'electrician':
        return 'electrician';
      default:
        return serviceType;
    }
  }

  Uint8List? decodeBase64Image(String base64String) {
    try {
      if (base64String.startsWith('data:image/')) {
        final base64Data = base64String.split(',').last;
        return base64.decode(base64Data);
      } else {
        return base64.decode(base64String);
      }
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }
}