import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:8000';
  } else if (kDebugMode) {
    // Check if we're on a physical device
    if (_isPhysicalDevice()) {
      return 'http://10.0.2.2:8000'; // Your computer's IP
    } else {
      // Emulator/Simulator
      return 'http://10.0.2.2:8000';
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000'; // Android emulator
      } else if (Platform.isIOS) {
        return 'http://localhost:8000'; // iOS simulator
      }
    }
  }
  // Production or fallback
  return 'http://10.0.2.2:8000';
}

bool _isPhysicalDevice() {
  if (kIsWeb) return false;

  try {
    if (Platform.isAndroid) {
      // Check Android environment variables to detect emulator
      final environment = Platform.environment;
      return !environment.containsKey('ANDROID_ROOT') ||
          environment['ANDROID_ROOT']?.contains('emulator') == false;
    } else if (Platform.isIOS) {
      // Check iOS environment variables to detect simulator
      return !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
    }
  } catch (e) {
    print('Error detecting device type: $e');
  }

  return true; // Assume physical device if we can't determine
}

final String baseUrl = getBaseUrl();