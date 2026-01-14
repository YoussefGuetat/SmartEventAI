enum EventState {
  draft('DRAFT', 'Brouillon'),
  validated('VALIDATED', 'Validé'),
  generated('GENERATED', 'Généré');

  final String value;
  final String label;

  const EventState(this.value, this.label);

  static EventState fromString(String Value) {
    return EventState.values.firstWhere(
      (status) => status.value == Value.toUpperCase(),
      orElse: () => EventState.draft,
    );
  }
}

class Event {
  final int? idEvenement;
  final int? organizerID;
  final String titleEvenement;
  final String descriptionEvenement;
  final String dateEvenement;
  final String location;
  final EventState statusEvenement;
  final String agenda;

  Event({
    this.idEvenement,
    this.organizerID,
    required this.titleEvenement,
    required this.descriptionEvenement,
    required this.dateEvenement,
    required this.location,
    required this.statusEvenement,
    required this.agenda,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      idEvenement: json['idEvenement'],
      organizerID: json['organizerId'],
      titleEvenement: json['titleEvenement'],
      descriptionEvenement: json['descriptionEvenement'],
      dateEvenement: json['dateEvenement'],
      location: json['location'],
      statusEvenement: EventState.fromString(json['statusEvenement']),
      agenda: json['agenda'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEvenement': idEvenement,
      'organizerId': organizerID,
      'titleEvenement': titleEvenement,
      'descriptionEvenement': descriptionEvenement,
      'dateEvenement': dateEvenement,
      'location': location,
      'statusEvenement': statusEvenement.value,
      'agenda': agenda,
    };
  }

  Event copyWith({
    int? idEvenement,
    int? organizerID,
    String? titleEvenement,
    String? descriptionEvenement,
    String? dateEvenement,
    String? location,
    EventState? statusEvenement,
    String? agenda,
  }) {
    return Event(
      idEvenement: idEvenement ?? this.idEvenement,
      organizerID: organizerID ?? this.organizerID,
      titleEvenement: titleEvenement ?? this.titleEvenement,
      descriptionEvenement: descriptionEvenement ?? this.descriptionEvenement,
      dateEvenement: dateEvenement ?? this.dateEvenement,
      location: location ?? this.location,
      statusEvenement: statusEvenement ?? this.statusEvenement,
      agenda: agenda ?? this.agenda,
    );
  }
}

class CreateEventRequest {
  final int organizerID;
  final String titleEvenement;
  final String descriptionEvenement;
  final String dateEvenement;
  final String location;
  final EventState statusEvenement;
  final String agenda;

  CreateEventRequest({
    required this.organizerID,
    required this.titleEvenement,
    required this.descriptionEvenement,
    required this.dateEvenement,
    required this.location,
    required this.statusEvenement,
    required this.agenda,
  });

  Map<String, dynamic> toJson() {
    return {
      'organizerId': organizerID,
      'titleEvenement': titleEvenement,
      'descriptionEvenement': descriptionEvenement,
      'dateEvenement': dateEvenement,
      'location': location,
      'statusEvenement': statusEvenement.value,
      'agenda': agenda,
    };
  }
}
