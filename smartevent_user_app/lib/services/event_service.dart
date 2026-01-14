import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/event_model.dart';

class EventService {
  // GEt All validated events
  Future<List<Event>> getAllEvents() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getAllEvents}'),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        final allEvents = jsonData.map((json) => Event.fromJson(json)).toList();
        
        // Filter to show only VALIDATED events
        return allEvents.where((event) => event.statusEvenement == EventState.validated).toList();
      } else {
        throw Exception('Erreur lors du chargement des événements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Get Event by ID
  Future<Event> getEventById(int eventId) async {
    try{
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getEventById}/$eventId'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.apiTimeout);

      if(response.statusCode == 200){
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return Event.fromJson(jsonData);
      } else {
        throw Exception('Échec du chargement de l\'événement : ${response.statusCode}');
      }
    }catch(e){
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Get unique cities from events
  List<String> getUniqueCities(List<Event> events){  
    final cities = events.map((e) => e.location).toSet().toList();
    cities.sort();
    return cities;
  }

  // Filter events by city
  List<Event> filterByCity(List<Event> events, String city){
    return events.where((e) => e.location == city).toList();
  }

  // Search events
  List<Event> searchEvents(List<Event> events, String query){
    final lowerQuery = query.toLowerCase();
    return events.where((e) =>
      e.titleEvenement.toLowerCase().contains(lowerQuery) ||
      e.descriptionEvenement.toLowerCase().contains(lowerQuery) ||
      e.agenda.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Sort events by date
  List<Event> sortByDate(List<Event> events, {bool ascending = true}){
   events.sort((a, b) {
      final comparison = a.dateEvenement.compareTo(b.dateEvenement);
      return ascending ? comparison : -comparison;
    });
    return events;
  } 

}
