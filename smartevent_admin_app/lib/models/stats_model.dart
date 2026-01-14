class Stats {
  final int totalEvents;
  final int generatedEvents;
  final int validatedEvents;
  final int draftEvents;

  Stats({
    required this.totalEvents,
    required this.generatedEvents,
    required this.validatedEvents,
    required this.draftEvents,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalEvents: json['totalEvents'],
      generatedEvents: json['generatedEvents'],
      validatedEvents: json['validatedEvents'],
      draftEvents: json['draftEvents'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'totalEvents': totalEvents,
      'generatedEvents': generatedEvents,
      'validatedEvents': validatedEvents,
      'draftEvents': draftEvents,
    };
  }
}