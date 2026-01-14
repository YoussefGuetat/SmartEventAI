import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class WorkflowService {
  final String? token;

  WorkflowService({this.token});

  // START WORKFLOW
  Future<Map<String, dynamic>> startWorkflow(int eventId) async {
    try {
     final response = await http.post(
      Uri.parse('${ApiConfg.baseurl}${ApiConfg.startWorkflow}/$eventId'),
      headers: ApiConfg.headers(token: token),
     ).timeout(ApiConfg.apiTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData as Map<String, dynamic>;
      } else {
        throw Exception('Erreur lors du démarrage du workflow: ${response.statusCode}');
      }
    }catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}