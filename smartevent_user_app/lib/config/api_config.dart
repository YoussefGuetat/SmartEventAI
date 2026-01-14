import 'package:flutter/foundation.dart';
class ApiConfig {
  // Base URL for API Gateway
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else {
      // For mobile emulators/simulators
      return 'http://10.0.2.2:8080';
    }
  }


  // Endpoints Events
  static const String eventsPath = '/events';
  static const String getAllEvents = '$eventsPath/getAllEvents';
  static const String getEventById = '$eventsPath/getEvenementById';

  static const Duration apiTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
