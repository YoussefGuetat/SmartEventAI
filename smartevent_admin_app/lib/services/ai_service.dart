import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/ai_model.dart';

class AIService {
  final String? token;

  AIService({this.token});

  // Genrate event content (title, description, agenda) using AI
  Future<GeneratedEventContent> generateEventContent({
    required EventDataPrompt prompt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfg.baseurl}${ApiConfg.generateEventContent}'),
        headers: ApiConfg.headers(token: token),
        body: json.encode({
          'title': prompt.title,
          'description': prompt.description,
          'location': prompt.location,
          'eventDate': prompt.eventDate,
          'agenda': prompt.agenda,
        }),
      ).timeout(ApiConfg.apiTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return GeneratedEventContent.fromJson(jsonData);
      } else {
        throw Exception('Erreur lors de la génération du contenu de l\'événement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Generate marketing content using AI
  Future<String> generateMarketing({
    required MarketingDataPrompt prompt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfg.baseurl}${ApiConfg.generateMarketing}'),
        headers: ApiConfg.headers(token: token),
        body: json.encode({
          'title': prompt.title,
          'location': prompt.location,
          'eventDate': prompt.eventDate,
        }),
      ).timeout(ApiConfg.apiTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['marketing'] as String? ?? '';
      } else {
        throw Exception('Erreur lors de la génération du contenu marketing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
