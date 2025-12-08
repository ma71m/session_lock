class SessionState {
  final int sessionTime; // milliseconds
  final int inactivityTime; // milliseconds
  final bool isSessionActive; // currently in a tracked app
  final bool isBlocked; // session limit exceeded
  final String? currentApp; // current foreground package name
  final DateTime lastUpdate;

  SessionState({
    this.sessionTime = 0,
    this.inactivityTime = 0,
    this.isSessionActive = false,
    this.isBlocked = false,
    this.currentApp,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  SessionState copyWith({
    int? sessionTime,
    int? inactivityTime,
    bool? isSessionActive,
    bool? isBlocked,
    String? currentApp,
    DateTime? lastUpdate,
  }) {
    return SessionState(
      sessionTime: sessionTime ?? this.sessionTime,
      inactivityTime: inactivityTime ?? this.inactivityTime,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isBlocked: isBlocked ?? this.isBlocked,
      currentApp: currentApp ?? this.currentApp,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  // Format session time as mm:ss
  String get formattedSessionTime {
    final duration = Duration(milliseconds: sessionTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Format inactivity time as mm:ss
  String get formattedInactivityTime {
    final duration = Duration(milliseconds: inactivityTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionTime': sessionTime,
      'inactivityTime': inactivityTime,
      'isSessionActive': isSessionActive,
      'isBlocked': isBlocked,
      'currentApp': currentApp,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  factory SessionState.fromJson(Map<String, dynamic> json) {
    return SessionState(
      sessionTime: json['sessionTime'] as int? ?? 0,
      inactivityTime: json['inactivityTime'] as int? ?? 0,
      isSessionActive: json['isSessionActive'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      currentApp: json['currentApp'] as String?,
      lastUpdate: json['lastUpdate'] != null
          ? DateTime.parse(json['lastUpdate'] as String)
          : DateTime.now(),
    );
  }
}
