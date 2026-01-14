class GeneratedEventContent {
  final String title;
  final String description;
  final String agenda;

  GeneratedEventContent({
    required this.title,
    required this.description,
    required this.agenda,
  });

  factory GeneratedEventContent.fromJson(Map<String, dynamic> json) {
    return GeneratedEventContent(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      agenda: json['agenda'] as String? ?? '',
    );
  }
}

class EventDataPrompt {
    final String? title;
    final String? description;
    final String? location;
    final String? eventDate;
    final String? agenda;
    EventDataPrompt({
      this.title,
      this.description,
      this.location,
      this.eventDate,
      this.agenda,
    });
}

class MarketingDataPrompt {
  final String? title;
  final String? location;
  final String? eventDate;
  MarketingDataPrompt({
    this.title,
    this.location,
    this.eventDate,
  });
}