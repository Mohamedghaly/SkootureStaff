class LiveRouteResponse {
  final bool error;
  final String message;
  final dynamic
      data; // Can be String, Map (single trip), or List (multiple trips)
  final int code;

  LiveRouteResponse({
    required this.error,
    required this.message,
    required this.data,
    required this.code,
  });

  factory LiveRouteResponse.fromJson(Map<String, dynamic> json) {
    return LiveRouteResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      code: json['code'] ?? 200,
    );
  }

  // Helper methods
  bool get hasTrip {
    if (data is Map<String, dynamic>) {
      // Single trip object
      return (data as Map<String, dynamic>).containsKey('trip_id');
    }
    if (data is List) {
      // Multiple trips array
      return (data as List).isNotEmpty;
    }
    return false;
  }

  bool get isNoTripMessage => data is String;
  String get noTripMessage => data is String ? data as String : '';

  List<LiveTrip> get trips {
    if (data is Map<String, dynamic>) {
      // Single trip object - wrap in list
      return [LiveTrip.fromJson(Map<String, dynamic>.from(data))];
    }
    if (data is List && (data as List).isNotEmpty) {
      // Multiple trips array
      return (data as List)
          .map((item) => LiveTrip.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }
}

class LiveTrip {
  final int tripId;
  final String etaToUserStopMin;
  final int? etaToSchoolStopMin;
  final String status;
  final Vehicle vehicle;
  final ShiftTime? shiftTime;
  final RouteInfo route;
  final List<TripStop> stops;
  final String type;
  final LastReachedStop? lastReachedStop;

  LiveTrip({
    required this.tripId,
    required this.etaToUserStopMin,
    this.etaToSchoolStopMin,
    required this.status,
    required this.vehicle,
    this.shiftTime,
    required this.route,
    required this.stops,
    required this.type,
    this.lastReachedStop,
  });

  factory LiveTrip.fromJson(Map<String, dynamic> json) {
    // Parse ETA data
    final etaData = json['eta'];
    String userStopMin = '';
    int? schoolStopMin;

    if (etaData != null && etaData is Map<String, dynamic>) {
      userStopMin = etaData['user_stop_min']?.toString() ?? '';
      schoolStopMin = _parseToInt(etaData['school_stop_min']);
    }

    return LiveTrip(
      tripId: _parseToInt(json['trip_id']) ?? 0,
      etaToUserStopMin: userStopMin,
      etaToSchoolStopMin: schoolStopMin,
      status: json['status'] ?? '',
      vehicle:
          Vehicle.fromJson(Map<String, dynamic>.from(json['vehicle'] ?? {})),
      shiftTime: json['shift_time'] != null
          ? ShiftTime.fromJson(Map<String, dynamic>.from(json['shift_time']))
          : null,
      route: RouteInfo.fromJson(Map<String, dynamic>.from(json['route'] ?? {})),
      stops: (json['stops'] as List?)
              ?.map(
                  (stop) => TripStop.fromJson(Map<String, dynamic>.from(stop)))
              .toList() ??
          [],
      type: json['type'] ?? '',
      lastReachedStop: json['last_reached_stop'] != null
          ? LastReachedStop.fromJson(
              Map<String, dynamic>.from(json['last_reached_stop']))
          : null,
    );
  }

  /// Helper method to safely parse int from dynamic value
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      if (value.trim().isEmpty) return null;
      return int.tryParse(value.trim());
    }
    if (value is double) return value.toInt();
    return null;
  }
}

class Vehicle {
  final String name;
  final String number;

  Vehicle({
    required this.name,
    required this.number,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      name: json['name'] ?? '',
      number: json['number'] ?? '',
    );
  }
}

class ShiftTime {
  final String label;
  final String from;
  final String to;

  ShiftTime({
    required this.label,
    required this.from,
    required this.to,
  });

  factory ShiftTime.fromJson(Map<String, dynamic> json) {
    return ShiftTime(
      label: json['label'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}

class RouteInfo {
  final int id;
  final String name;

  RouteInfo({
    required this.id,
    required this.name,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class TripStop {
  final int? id;
  final String name;
  final String scheduledTime;
  final String? estimatedTime;
  final String actualTime;
  final List<Passenger> passengers;

  TripStop({
    this.id,
    required this.name,
    required this.scheduledTime,
    this.estimatedTime,
    required this.actualTime,
    required this.passengers,
  });

  factory TripStop.fromJson(Map<String, dynamic> json) {
    return TripStop(
      id: json['id'],
      name: json['name'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      estimatedTime: json['estimated_time'],
      actualTime: json['actual_time'] ?? '',
      passengers: (json['passengers'] as List?)
              ?.map((passenger) =>
                  Passenger.fromJson(Map<String, dynamic>.from(passenger)))
              .toList() ??
          [],
    );
  }

  // Helper methods
  bool get isCompleted => actualTime != 'Pending' && actualTime.isNotEmpty;
  bool get isPending => actualTime == 'Pending';
  bool get hasPassengers => passengers.isNotEmpty;
}

class Passenger {
  final int id;
  final String name;
  final String role;

  Passenger({
    required this.id,
    required this.name,
    required this.role,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class LastReachedStop {
  final int? id;
  final String? name;

  LastReachedStop({
    this.id,
    this.name,
  });

  factory LastReachedStop.fromJson(Map<String, dynamic> json) {
    return LastReachedStop(
      id: json['id'],
      name: json['name'],
    );
  }
}
