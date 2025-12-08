class AppSettings {
  final int sessionDuration; // minutes
  final int breakDuration; // minutes
  final List<String> trackedApps; // package names
  final bool strictMode;
  final bool allowEmergencyBypass;
  final bool isMonitoring; // monitoring service active

  AppSettings({
    this.sessionDuration = 20,
    this.breakDuration = 10,
    this.trackedApps = const [],
    this.strictMode = false,
    this.allowEmergencyBypass = true,
    this.isMonitoring = false,
  });

  AppSettings copyWith({
    int? sessionDuration,
    int? breakDuration,
    List<String>? trackedApps,
    bool? strictMode,
    bool? allowEmergencyBypass,
    bool? isMonitoring,
  }) {
    return AppSettings(
      sessionDuration: sessionDuration ?? this.sessionDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      trackedApps: trackedApps ?? this.trackedApps,
      strictMode: strictMode ?? this.strictMode,
      allowEmergencyBypass: allowEmergencyBypass ?? this.allowEmergencyBypass,
      isMonitoring: isMonitoring ?? this.isMonitoring,
    );
  }

  // Convert durations to milliseconds for timer logic
  int get sessionDurationMs => sessionDuration * 60 * 1000;
  int get breakDurationMs => breakDuration * 60 * 1000;

  Map<String, dynamic> toJson() {
    return {
      'sessionDuration': sessionDuration,
      'breakDuration': breakDuration,
      'trackedApps': trackedApps,
      'strictMode': strictMode,
      'allowEmergencyBypass': allowEmergencyBypass,
      'isMonitoring': isMonitoring,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      sessionDuration: json['sessionDuration'] as int? ?? 20,
      breakDuration: json['breakDuration'] as int? ?? 10,
      trackedApps: (json['trackedApps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      strictMode: json['strictMode'] as bool? ?? false,
      allowEmergencyBypass: json['allowEmergencyBypass'] as bool? ?? true,
      isMonitoring: json['isMonitoring'] as bool? ?? false,
    );
  }
}
