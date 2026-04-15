class RouteStopsResponse {
  final bool error;
  final String message;
  final RouteStopsData data;
  final int code;

  RouteStopsResponse({
    required this.error,
    required this.message,
    required this.data,
    required this.code,
  });

  factory RouteStopsResponse.fromJson(Map<String, dynamic> json) {
    return RouteStopsResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: RouteStopsData.fromJson(json['data'] ?? {}),
      code: json['code'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': data.toJson(),
      'code': code,
    };
  }
}

class RouteStopsData {
  final RouteInfo route;
  final List<RouteStop> stops;

  RouteStopsData({
    required this.route,
    required this.stops,
  });

  factory RouteStopsData.fromJson(Map<String, dynamic> json) {
    return RouteStopsData(
      route: RouteInfo.fromJson(json['route'] ?? {}),
      stops: (json['stops'] as List<dynamic>? ?? [])
          .map((stop) => RouteStop.fromJson(stop))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route': route.toJson(),
      'stops': stops.map((stop) => stop.toJson()).toList(),
    };
  }

  // Helper methods
  RouteStop? get userStop => stops.firstWhere(
        (stop) => stop.isUserStop,
        orElse: () => stops.isNotEmpty ? stops.first : RouteStop.empty(),
      );

  int get userStopIndex => stops.indexWhere((stop) => stop.isUserStop);

  List<RouteStop> get stopsBeforeUser {
    final userIndex = userStopIndex;
    return userIndex > 0 ? stops.sublist(0, userIndex) : [];
  }

  List<RouteStop> get stopsAfterUser {
    final userIndex = userStopIndex;
    return userIndex >= 0 && userIndex < stops.length - 1
        ? stops.sublist(userIndex + 1)
        : [];
  }

  bool get hasUserStop => stops.any((stop) => stop.isUserStop);
}

class RouteInfo {
  final int id;
  final String name;
  final String vehicleName;
  final String vehicleRegistration;

  RouteInfo({
    required this.id,
    required this.name,
    required this.vehicleName,
    required this.vehicleRegistration,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: _parseToInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      vehicleName: json['vehicle_name'] ?? '',
      vehicleRegistration: json['vehicle_registration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vehicle_name': vehicleName,
      'vehicle_registration': vehicleRegistration,
    };
  }

  // Helper methods
  String get displayName => name.isNotEmpty ? name : 'Unknown Route';
  String get vehicleDisplayName =>
      vehicleName.isNotEmpty ? vehicleName : 'Unknown Vehicle';
  String get registrationDisplay => vehicleRegistration.isNotEmpty
      ? vehicleRegistration
      : 'Unknown Registration';

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }
}

class RouteStop {
  final int id;
  final String name;
  final String scheduledTime;
  final bool isUserStop;

  RouteStop({
    required this.id,
    required this.name,
    required this.scheduledTime,
    required this.isUserStop,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: _parseToInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      isUserStop: json['is_user_stop'] ?? false,
    );
  }

  factory RouteStop.empty() {
    return RouteStop(
      id: 0,
      name: '',
      scheduledTime: '',
      isUserStop: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scheduled_time': scheduledTime,
      'is_user_stop': isUserStop,
    };
  }

  // Helper methods
  String get displayName => name.isNotEmpty ? name : 'Unknown Stop';
  String get timeDisplay =>
      scheduledTime.isNotEmpty ? scheduledTime : 'Unknown Time';

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }
}
