import 'package:flutter/foundation.dart';

class ApiConfg {
  // Base URL for API Gateway
  static String get baseurl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else {
      // For mobile emulators/simulators
      return 'http://10.0.2.2:8080';
    }
  }

  // Endoints Authentication
  static const String authPath ='/auth';
  static const String login = '$authPath/login';
  static const String generateToken = '$authPath/generateToken';

  // Endpoints Events
  static const String eventsPath = '/events';
  static const String getAllEvents = '$eventsPath/getAllEvents';
  static const String getEvenetByID = '$eventsPath/getEvenementById';
  static const String createEvent = '$eventsPath/saveEvenement';
  static const String updateEvent = '$eventsPath/updateEvenement';
  static const String deleteEvent = '$eventsPath/deleteEvenementByID';

  // Endpoints Wrokflow
  static const String workflowPath = '/workflow';
  static const String startWorkflow = '$workflowPath/start';
  static const String getWorkflowStatus = '$workflowPath/status';

  // Endpoints AI
  static const String aiPath = '/ai';
  static const String generateEventContent = '$aiPath/generate-event-content';
  static const String generateMarketing = '$aiPath/generate-marketing';

  // Timeout
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration aiTimeout = Duration(seconds: 120); // Plus long pour les appels AI

  // Headers
  static Map<String,String> headers({String? token}) {
    final Map<String, String> baseHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      baseHeaders['Authorization'] = 'Bearer $token';
    }
    return baseHeaders;
  }

}