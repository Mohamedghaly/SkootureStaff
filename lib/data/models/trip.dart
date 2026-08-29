class Trip {
  final String status;
  final ShiftTime shiftTime;
  final Route route;
  final List<Stop> stops;
  final String type;
  final int? tripId;
  final LastReachedStop? lastReachedStop;
  final bool allStopsCompleted;
  final int? totalStops;

  Trip({
    required this.status,
    required this.shiftTime,
    required this.route,
    required this.stops,
    required this.type,
    this.tripId,
    this.lastReachedStop,
    this.allStopsCompleted = false,
    this.totalStops,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    // Parse stops and extract total_stops from the last item if it exists
    List<Stop> stopsList = [];
    int? extractedTotalStops;

    final stopsData = json['stops'] as List?;
    if (stopsData != null) {
      for (var stopJson in stopsData) {
        // Check if this item contains total_stops
        if (stopJson is Map<String, dynamic> && stopJson.containsKey('total_stops')) {
          extractedTotalStops = stopJson['total_stops'];
        } else {
          // It's a regular stop, add it to the list
          stopsList.add(Stop.fromJson(stopJson));
        }
      }
    }

    return Trip(
      status: json['status'] ?? '',
      shiftTime: ShiftTime.fromJson(json['shift_time'] ?? {}),
      route: Route.fromJson(json['route'] ?? {}),
      stops: stopsList,
      type: json['type'] ?? '',
      tripId: json['trip_id'],
      lastReachedStop: json['last_reached_stop'] != null
          ? LastReachedStop.fromJson(json['last_reached_stop'])
          : null,
      allStopsCompleted: json['all_stops_completed'] ?? false,
      totalStops: extractedTotalStops,
    );
  }

  Map<String, dynamic> toJson() {
    // Build stops list with total_stops as the last item if available
    final List<Map<String, dynamic>> stopsJson = stops.map((stop) => stop.toJson()).toList();
    if (totalStops != null) {
      stopsJson.add({'total_stops': totalStops});
    }

    return {
      'status': status,
      'shift_time': shiftTime.toJson(),
      'route': route.toJson(),
      'stops': stopsJson,
      'type': type,
      if (tripId != null) 'trip_id': tripId,
      if (lastReachedStop != null)
        'last_reached_stop': lastReachedStop!.toJson(),
      'all_stops_completed': allStopsCompleted,
    };
  }

  // Helper methods
  bool get isUpcoming => status.toLowerCase() == 'upcoming';
  bool get isInProgress => status.toLowerCase() == 'inprogress';
  bool get isCompleted => status.toLowerCase() == 'completed';

  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return 'Upcoming';
      case 'inprogress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  String get displayShiftTime {
    return '${shiftTime.label}: ${shiftTime.from} to ${shiftTime.to}';
  }

  String get displayRoute {
    if (type.toLowerCase() == 'pickup') {
      return '${route.name} (Pickup)';
    } else if (type.toLowerCase() == 'drop') {
      return '${route.name} (Drop)';
    }
    return route.name;
  }
}

class ShiftTime {
  final int id;
  final String label;
  final String from;
  final String to;

  ShiftTime({
    required this.id,
    required this.label,
    required this.from,
    required this.to,
  });

  factory ShiftTime.fromJson(Map<String, dynamic> json) {
    return ShiftTime(
      id: json['id'] ?? 1, // Default to 1 if not provided
      label: json['label'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'from': from,
      'to': to,
    };
  }
}

class Route {
  final int id;
  final String name;
  final int? routeVehicleId;

  Route({
    required this.id,
    required this.name,
    this.routeVehicleId,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      routeVehicleId: json['route_vehicle_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (routeVehicleId != null) 'route_vehicle_id': routeVehicleId,
    };
  }
}

class Stop {
  final int? id;
  final String name;
  final String scheduledTime;
  final String? estimatedTime;
  final String? actualTime;
  final List<TripPassenger> passengers;

  Stop({
    this.id,
    required this.name,
    required this.scheduledTime,
    this.estimatedTime,
    this.actualTime,
    this.passengers = const [],
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'],
      name: json['name'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      estimatedTime: json['estimated_time'],
      actualTime: json['actual_time'],
      passengers: (json['passengers'] as List?)
              ?.map((passenger) => TripPassenger.fromJson(passenger))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'scheduled_time': scheduledTime,
      if (estimatedTime != null) 'estimated_time': estimatedTime,
      if (actualTime != null) 'actual_time': actualTime,
      'passengers': passengers.map((passenger) => passenger.toJson()).toList(),
    };
  }

  bool get isReached => estimatedTime == 'Reached';
  bool get isPending => actualTime == 'Pending';
}

class TripPassenger {
  final int? id;
  final String name;
  final String? status;
  final String? role; // Added role field for Student/Teacher/Staff
  final String?
      attendanceStatus; // "present", "absent", "pending", or null for not marked
  final String? image; // Direct image URL from API

  TripPassenger({
    this.id,
    required this.name,
    this.status,
    this.role,
    this.attendanceStatus,
    this.image,
  });

  factory TripPassenger.fromJson(Map<String, dynamic> json) {
    return TripPassenger(
      id: json['id'],
      name: json['name'] ?? '',
      status: json['status'],
      role: json['role'],
      attendanceStatus: json['attendance_status'],
      image: json['image'],
    );
  }

  // Helper method to get image URL
  String? get imageUrl {
    // Use the direct image URL from API response
    if (image != null && image!.isNotEmpty) {
      return image;
    }
    // Fallback to constructed URL if needed
    if (id != null) {
      return 'https://wrteam.net/api/get-image?user_id=$id&type=profile';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (status != null) 'status': status,
      if (role != null) 'role': role,
      if (attendanceStatus != null) 'attendance_status': attendanceStatus,
      if (image != null) 'image': image,
    };
  }

  bool get isStudent => role?.toLowerCase() == 'student';
  bool get isTeacher => role?.toLowerCase() == 'teacher';
  bool get isStaff => role?.toLowerCase() == 'staff';

  bool get isAttendanceMarked =>
      attendanceStatus != null && attendanceStatus!.toLowerCase() != 'pending';
  bool get isPresent => attendanceStatus?.toLowerCase() == 'present';
  bool get isAbsent => attendanceStatus?.toLowerCase() == 'absent';
  bool get isPendingAttendance => attendanceStatus?.toLowerCase() == 'pending';
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

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    };
  }
}

class TripsResponse {
  final bool error;
  final String message;
  final List<Trip> data;
  final int code;

  TripsResponse({
    required this.error,
    required this.message,
    required this.data,
    required this.code,
  });

  factory TripsResponse.fromJson(Map<String, dynamic> json) {
    return TripsResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((trip) => Trip.fromJson(trip))
              .toList() ??
          [],
      code: json['code'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': data.map((trip) => trip.toJson()).toList(),
      'code': code,
    };
  }
}
