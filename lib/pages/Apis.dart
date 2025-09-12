import 'package:flutter/foundation.dart';

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:8000'; // For web
  } else if (kDebugMode) {
    // For emulators and local testing
    return 'http://10.0.2.2:8000'; // Android emulator
    // return 'http://localhost:8000'; // iOS simulator
    // return 'http://10.116.228.253:8000'; //  LAN IP
  } else {
    // server IP
    return 'http://10.116.228.253:8000';
  }
}

final String baseUrl = getBaseUrl();