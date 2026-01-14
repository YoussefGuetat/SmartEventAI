import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  List<Event> _events = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCity = 'ALL';

  List<Event> get events => _filteredEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCity => _selectedCity;

   List<String> get cities {
    final allCities = _eventService.getUniqueCities(_events);
    return ['ALL', ...allCities];
  }

  // Load all events
  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _eventService.getAllEvents();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Search events
  void searchEvents(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Filter by city
  void filterByCity(String city) {
    _selectedCity = city;
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredEvents = _events;

    // Filter by city
    if (_selectedCity != 'ALL') {
      _filteredEvents = _eventService.filterByCity(_filteredEvents, _selectedCity);
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      _filteredEvents = _eventService.searchEvents(_filteredEvents, _searchQuery);
    }

    // Sort by date
    _filteredEvents = _eventService.sortByDate(_filteredEvents, ascending: true);

    notifyListeners();
  }

  // Refresh events
  Future<void> refresh() async {
    await loadEvents();
  }

  // Get event by ID
  Future<Event?> getEventById(int id) async {
    try{
      return await _eventService.getEventById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}