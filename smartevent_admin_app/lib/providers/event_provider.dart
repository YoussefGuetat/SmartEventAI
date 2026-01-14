import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/stats_model.dart';
import '../services/event_service.dart';
import '../services/workflow_service.dart';

class EventProvider extends ChangeNotifier {
  EventService? _eventService;
  WorkflowService? _workflowService;

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  int? _organizerID;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with token
  void initialize(String? token, int? organizerID) {
    _eventService = EventService(token: token);
    _workflowService = WorkflowService(token: token);
    _organizerID = organizerID;
  }

  // Load all events
  Future<void> loadEvents() async {
    if (_eventService == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allEvents = await _eventService!.getAllEvents();
      // Filter events by organizerID if available
      if (_organizerID != null) {
        _events = allEvents.where((e) => e.organizerID == _organizerID).toList();
      } else {
        _events = allEvents;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create event
  Future<bool> createEvent(CreateEventRequest request) async {
    if (_eventService == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final event = await _eventService!.createEvent(request);
      _events.insert(0, event);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update event
  Future<bool> updateEvent(Event event) async {
    if (_eventService == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEvent = await _eventService!.updateEvent(event);
      final index = _events.indexWhere((e) => e.idEvenement == updatedEvent.idEvenement);
      if (index != -1) {
        _events[index] = updatedEvent;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete event
  Future<bool> deleteEvent(int id) async {
    if (_eventService == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService!.deleteEvent(id);
      _events.removeWhere((e) => e.idEvenement == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Start workflow
  Future<bool> startWorkflow(int eventId) async {
    if (_workflowService == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _workflowService!.startWorkflow(eventId);
      await loadEvents(); // Refresh events
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get statistics
  Stats getStats() {
    final totalEvents = _events.length;
    final generatedEvents = _events.where((e) => e.statusEvenement == EventState.generated).length;
    final validatedEvents = _events.where((e) => e.statusEvenement == EventState.validated).length;
    final draftEvents = _events.where((e) => e.statusEvenement == EventState.draft).length;

    return Stats(
      totalEvents: totalEvents,
      generatedEvents: generatedEvents,
      validatedEvents: validatedEvents,
      draftEvents: draftEvents,
    );
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh
  Future<void> refresh() async {
    await loadEvents();
  }
}
