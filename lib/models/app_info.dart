class AppInfo {
  final String packageName;
  final String appName;
  final String? iconBase64;
  final bool isTracked;

  AppInfo({
    required this.packageName,
    required this.appName,
    this.iconBase64,
    this.isTracked = false,
  });

  AppInfo copyWith({
    String? packageName,
    String? appName,
    String? iconBase64,
    bool? isTracked,
  }) {
    return AppInfo(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      iconBase64: iconBase64 ?? this.iconBase64,
      isTracked: isTracked ?? this.isTracked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'iconBase64': iconBase64,
      'isTracked': isTracked,
    };
  }

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      iconBase64: json['iconBase64'] as String?,
      isTracked: json['isTracked'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppInfo && other.packageName == packageName;
  }

  @override
  int get hashCode => packageName.hashCode;
}
