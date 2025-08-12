import 'dart:convert';
import 'package:flutter/material.dart';

Map<String, dynamic>? parseJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));

    return jsonDecode(decoded) as Map<String, dynamic>;
  } catch (e) {
    debugPrint('Error parsing JWT: $e');
    return null;
  }
}

void checkTokenExpiry(String token) {
  final payload = parseJwt(token);
  if (payload == null) return;

  final exp = payload['exp'] as int?;
  if (exp == null) return;

  final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  final currentDate = DateTime.now();

  debugPrint('Token expires at: $expiryDate');
  debugPrint('Current time: $currentDate');

  if (currentDate.isAfter(expiryDate)) {
    debugPrint('Token has expired!');
  } else {
    debugPrint('Token is still valid');
    debugPrint('Time remaining: ${expiryDate.difference(currentDate)}');
  }
}