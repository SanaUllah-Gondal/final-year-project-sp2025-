import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

String getBaseUrl() {
  const localIP = "10.254.109.253"; // Replace with your system local IP
  const port = "8000";

  if (kIsWeb) {
    return "http://localhost:$port";
  }

  if (Platform.isAndroid) {
    if (kDebugMode) {
      if (_isEmulator()) {
        return "http://10.0.2.2:$port"; // Android Emulator
      } else {
        return "http://$localIP:$port"; // Physical Android Device
      }
    }
  }

  if (Platform.isIOS) {
    if (kDebugMode) {
      if (_isEmulator()) {
        return "http://localhost:$port"; // iOS Simulator
      } else {
        return "http://$localIP:$port"; // Physical iOS device
      }
    }
  }

  // Production or fallback
  return "https://your-production-domain.com";
}

bool _isEmulator() {
  try {
    if (Platform.isAndroid) {
      // Basic emulator identifiers
      return Platform.environment.toString().contains("android_emulator") ||
          Platform.environment.toString().contains("emulator");
    }
    if (Platform.isIOS) {
      return Platform.environment.containsKey("SIMULATOR_DEVICE_NAME");
    }
  } catch (e) {
    print("Emulator detection failed: $e");
  }
  return false; // Assume physical if unable to detect
}

final String baseUrl = getBaseUrl();
