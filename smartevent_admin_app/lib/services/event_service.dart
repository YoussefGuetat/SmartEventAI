import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/event_model.dart';

class EventService {
  final String? token;

  EventService({this.token});

  // GET ALL EVENTS
  Future<List<Event>> getAllEvents() async {
    try{
      final response = await http.get(
        Uri.parse('${ApiConfg.baseurl}${ApiConfg.getAllEvents}'),
        headers: ApiConfg.headers(token: token),
      ).timeout(ApiConfg.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> JsonData = json.decode(response.body);
        return JsonData.map((Json) => Event.fromJson(Json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des événements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // GET EVENT BY ID
  Future<Event> getEventByID(int id) async {
    try{
       final response = await http.get(
        Uri.parse('${ApiConfg.baseurl}${ApiConfg.getEvenetByID}/$id'),
        headers: ApiConfg.headers(token: token),
      ).timeout(ApiConfg.apiTimeout);

      if (response.statusCode == 200) {
        final JsonData = json.decode(utf8.decode(response.bodyBytes));
        return Event.fromJson(JsonData);
      } else {
        throw Exception('Erreur lors du chargement de l\'événement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // CREATE EVENT
  Future<Event> createEvent(CreateEventRequest request) async {
    try{
       final response = await http.post(
        Uri.parse('${ApiConfg.baseurl}${ApiConfg.createEvent}'),
        headers: ApiConfg.headers(token: token),
        body: json.encode(request.toJson()),
      ).timeout(ApiConfg.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final JsonData = json.decode(utf8.decode(response.bodyBytes));
        return Event.fromJson(JsonData);
      } else {
        throw Exception('Erreur lors de la création de l\'événement: ${response.statusCode}');
      }
    }catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // UPDATE EVENT
  Future<Event> updateEvent(Event request) async {
    try{
      final response = await http.put(
        Uri.parse('${ApiConfg.baseurl}${ApiConfg.updateEvent}'),
        headers: ApiConfg.headers(token: token),
        body: json.encode(request.toJson()),
      ).timeout(ApiConfg.apiTimeout);

      if (response.statusCode == 200) {
        final JsonData = json.decode(utf8.decode(response.bodyBytes));
        return Event.fromJson(JsonData);
      } else {
        throw Exception('Erreur lors de la mise à jour de l\'événement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
  
  // DELETE EVENT
  Future<void> deleteEvent(int id) async {
    try{
      final response = await http.delete(
        Uri.parse('${ApiConfg.baseurl}${ApiConfg.deleteEvent}/$id'),
        headers: ApiConfg.headers(token: token),
      ).timeout(ApiConfg.apiTimeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de l\'événement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}