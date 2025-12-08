class SessionRecord {
  final DateTime startTime;
  final DateTime endTime;
  final int durationMs;
  final List<String> appsUsed;

  SessionRecord({
    required this.startTime,
    required this.endTime,
    required this.durationMs,
    required this.appsUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMs': durationMs,
      'appsUsed': appsUsed,
    };
  }

  factory SessionRecord.fromJson(Map<String, dynamic> json) {
    return SessionRecord(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationMs: json['durationMs'] as int,
      appsUsed:
          (json['appsUsed'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }
}

class SessionHistory {
  final DateTime date;
  final List<SessionRecord> sessions;
  final int totalTimeMs;

  SessionHistory({
    required this.date,
    required this.sessions,
    required this.totalTimeMs,
  });

  // Get date without time component
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'totalTimeMs': totalTimeMs,
    };
  }

  factory SessionHistory.fromJson(Map<String, dynamic> json) {
    return SessionHistory(
      date: DateTime.parse(json['date'] as String),
      sessions: (json['sessions'] as List<dynamic>)
          .map((e) => SessionRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalTimeMs: json['totalTimeMs'] as int,
    );
  }
}
