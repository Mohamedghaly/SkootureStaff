class TransportDashboard {
  final TransportPlan? plan;
  final BusInfo? busInfo;
  final LiveSummary? liveSummary;
  final List<TodayAttendance> todayAttendance;
  final TransportRequest? requests;
  final String? status; // For handling "No plan found" message

  TransportDashboard({
    this.plan,
    this.busInfo,
    this.liveSummary,
    required this.todayAttendance,
    this.requests,
    this.status,
  });

  factory TransportDashboard.fromJson(Map<String, dynamic> json) {
    return TransportDashboard(
      plan: json['plan'] != null
          ? TransportPlan.fromJson(Map<String, dynamic>.from(json['plan']))
          : null,
      busInfo: json['bus_info'] != null
          ? BusInfo.fromJson(Map<String, dynamic>.from(json['bus_info']))
          : null,
      liveSummary: json['live_summary'] != null && json['live_summary'] is Map
          ? LiveSummary.fromJson(
              Map<String, dynamic>.from(json['live_summary']))
          : null,
      todayAttendance: _parseTodayAttendance(json['today_attendance']),
      requests: json['requests'] != null
          ? TransportRequest.fromJson(
              Map<String, dynamic>.from(json['requests']))
          : null,
      status: json['status'] as String?, // Handle the status message
    );
  }

  /// Helper method to safely parse today_attendance from dynamic value
  /// Handles both List<Map> (proper objects) and List<String> (error messages)
  static List<TodayAttendance> _parseTodayAttendance(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      List<TodayAttendance> attendanceList = [];

      for (var item in value) {
        // If item is a Map (proper attendance object)
        if (item is Map<String, dynamic>) {
          try {
            attendanceList.add(TodayAttendance.fromJson(item));
          } catch (e) {
            // Skip invalid objects
            continue;
          }
        }
        // If item is a String (like "No attendance found for today")
        else if (item is String) {
          // Create a placeholder attendance object for UI display
          // We can ignore these string messages as they're just status messages
          continue;
        }
      }

      return attendanceList;
    }

    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan?.toJson(),
      'bus_info': busInfo?.toJson(),
      'live_summary': liveSummary?.toJson(),
      'today_attendance': todayAttendance.map((item) => item.toJson()).toList(),
      'requests': requests?.toJson(),
      'status': status,
    };
  }

  // Helper method to check if there's no plan data
  bool get hasNoPlan => status?.toLowerCase().contains('no plan') == true;
}

class TransportPlan {
  final int? planId;
  final String? status;
  final String? duration;
  final String? validFrom;
  final String? validTo;
  final TransportRoute? route;
  final PickupStop? pickupStop;
  final int? expiresInDays;
  final int? shiftId;

  TransportPlan({
    this.planId,
    this.status,
    this.duration,
    this.validFrom,
    this.validTo,
    this.route,
    this.pickupStop,
    this.expiresInDays,
    this.shiftId,
  });

  factory TransportPlan.fromJson(Map<String, dynamic> json) {
    return TransportPlan(
      planId: json['plan_id'],
      status: json['status'],
      duration: json['duration'],
      validFrom: json['valid_from'],
      validTo: json['valid_to'],
      route: json['route'] != null
          ? TransportRoute.fromJson(Map<String, dynamic>.from(json['route']))
          : null,
      pickupStop: json['pickup_stop'] != null
          ? PickupStop.fromJson(Map<String, dynamic>.from(json['pickup_stop']))
          : null,
      expiresInDays: json['expires_in_days'],
      shiftId: json['shift_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'status': status,
      'duration': duration,
      'valid_from': validFrom,
      'valid_to': validTo,
      'route': route?.toJson(),
      'pickup_stop': pickupStop?.toJson(),
      'expires_in_days': expiresInDays,
      'shift_id': shiftId,
    };
  }
}

class TransportRoute {
  final int? id;
  final String? name;

  TransportRoute({
    this.id,
    this.name,
  });

  factory TransportRoute.fromJson(Map<String, dynamic> json) {
    return TransportRoute(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class PickupStop {
  final int? id;
  final String? name;

  PickupStop({
    this.id,
    this.name,
  });

  factory PickupStop.fromJson(Map<String, dynamic> json) {
    return PickupStop(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class BusInfo {
  final int? vehicleId;
  final String? vehicleName;
  final String? registration;
  final TransportDriver? driver;
  final TransportAttender? attender;

  BusInfo({
    this.vehicleId,
    this.vehicleName,
    this.registration,
    this.driver,
    this.attender,
  });

  factory BusInfo.fromJson(Map<String, dynamic> json) {
    return BusInfo(
      vehicleId: json['vehicle_id'],
      vehicleName: json['vehicle_name'],
      registration: json['registration'],
      driver: json['driver'] != null
          ? TransportDriver.fromJson(Map<String, dynamic>.from(json['driver']))
          : null,
      attender: json['attender'] != null
          ? TransportAttender.fromJson(
              Map<String, dynamic>.from(json['attender']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'vehicle_name': vehicleName,
      'registration': registration,
      'driver': driver?.toJson(),
      'attender': attender?.toJson(),
    };
  }
}

class TransportDriver {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? avatar;

  TransportDriver({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.avatar,
  });

  factory TransportDriver.fromJson(Map<String, dynamic> json) {
    return TransportDriver(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      avatar: json['avtar'], // Note: API response has typo "avtar"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avtar': avatar,
    };
  }
}

class TransportAttender {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? avatar;

  TransportAttender({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.avatar,
  });

  factory TransportAttender.fromJson(Map<String, dynamic> json) {
    return TransportAttender(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      avatar: json['avtar'], // Note: API response has typo "avtar"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avtar': avatar,
    };
  }
}

class LiveSummary {
  final String? status;
  final String? currentLocation;
  final int? etaToUserStopMin;
  final String? nextLocation;
  final String? estimatedTime;

  LiveSummary({
    this.status,
    this.currentLocation,
    this.etaToUserStopMin,
    this.nextLocation,
    this.estimatedTime,
  });

  factory LiveSummary.fromJson(Map<String, dynamic> json) {
    return LiveSummary(
      status: json['status'],
      currentLocation: json['current_location'],
      etaToUserStopMin: _parseEtaToInt(json['eta_to_user_stop_min']),
      nextLocation: json['next_location'],
      estimatedTime: json['estimated_time'],
    );
  }

  /// Helper method to safely parse ETA from dynamic value
  /// Handles both int (108) and string ("Delayed", "On Time") values
  static int? _parseEtaToInt(dynamic value) {
    if (value == null) return null;

    // If it's already an int, return it
    if (value is int) return value;

    // If it's a string, try different approaches
    if (value is String) {
      String trimmedValue = value.trim();
      if (trimmedValue.isEmpty) return null;

      // Try to parse as number first
      int? parsedInt = int.tryParse(trimmedValue);
      if (parsedInt != null) return parsedInt;

      // If it's a status string like "Delayed", "On Time", etc.
      // Return null so UI can handle it appropriately
      return null;
    }

    // If it's a double, convert to int
    if (value is double) return value.toInt();

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'current_location': currentLocation,
      'eta_to_user_stop_min': etaToUserStopMin,
      'next_location': nextLocation,
      'estimated_time': estimatedTime,
    };
  }
}

class TodayAttendance {
  final String? status;
  final String? tripType;
  final String? time;

  TodayAttendance({
    this.status,
    this.tripType,
    this.time,
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      status: json['status'],
      tripType: json['trip_type'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'trip_type': tripType,
      'time': time,
    };
  }

  // Helper method to get attendance status display
  String getStatusDisplay() {
    switch (status?.toUpperCase()) {
      case 'P':
        return 'Present';
      case 'A':
        return 'Absent';
      case 'W':
        return 'Waiting';
      default:
        return 'Not Marked';
    }
  }

  // Helper method to get trip type display
  String getTripTypeDisplay() {
    switch (tripType?.toLowerCase()) {
      case 'pickup':
        return 'Pickup';
      case 'drop':
        return 'Drop';
      default:
        return 'Unknown';
    }
  }
}

class TransportRequest {
  final int? id;
  final String? status;
  final String? requestedOn;
  final RequestedBy? requestedBy;
  final RequestDetails? details;
  final RequestReview? review;

  TransportRequest({
    this.id,
    this.status,
    this.requestedOn,
    this.requestedBy,
    this.details,
    this.review,
  });

  factory TransportRequest.fromJson(Map<String, dynamic> json) {
    return TransportRequest(
      id: _parseToInt(json['id']),
      status: json['status'],
      requestedOn: json['requested_on'],
      requestedBy: json['requested_by'] != null
          ? RequestedBy.fromJson(
              Map<String, dynamic>.from(json['requested_by']))
          : null,
      details: json['details'] != null
          ? RequestDetails.fromJson(Map<String, dynamic>.from(json['details']))
          : null,
      review: json['review'] != null
          ? RequestReview.fromJson(Map<String, dynamic>.from(json['review']))
          : null,
    );
  }

  /// Helper method to safely parse int from dynamic value (handles both String and int)
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;

    // If it's already an int, return it
    if (value is int) return value;

    // If it's a string, try to parse it
    if (value is String) {
      if (value.trim().isEmpty) return null;
      return int.tryParse(value.trim());
    }

    // If it's a double, convert to int
    if (value is double) return value.toInt();

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'requested_on': requestedOn,
      'requested_by': requestedBy?.toJson(),
      'details': details?.toJson(),
      'review': review?.toJson(),
    };
  }
}

class RequestedBy {
  final int? studentId;
  final String? name;

  RequestedBy({
    this.studentId,
    this.name,
  });

  factory RequestedBy.fromJson(Map<String, dynamic> json) {
    return RequestedBy(
      studentId: _parseToInt(json['student_id']),
      name: json['name'],
    );
  }

  /// Helper method to safely parse int from dynamic value (handles both String and int)
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;

    // If it's already an int, return it
    if (value is int) return value;

    // If it's a string, try to parse it
    if (value is String) {
      if (value.trim().isEmpty) return null;
      return int.tryParse(value.trim());
    }

    // If it's a double, convert to int
    if (value is double) return value.toInt();

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
    };
  }
}

class RequestDetails {
  final PickupStop? pickupStop;
  final RequestPlan? plan;

  RequestDetails({
    this.pickupStop,
    this.plan,
  });

  factory RequestDetails.fromJson(Map<String, dynamic> json) {
    return RequestDetails(
      pickupStop: json['pickup_stop'] != null
          ? PickupStop.fromJson(Map<String, dynamic>.from(json['pickup_stop']))
          : null,
      plan: json['plan'] != null
          ? RequestPlan.fromJson(Map<String, dynamic>.from(json['plan']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup_stop': pickupStop?.toJson(),
      'plan': plan?.toJson(),
    };
  }
}

class RequestPlan {
  final String? duration;
  final String? validity;

  RequestPlan({
    this.duration,
    this.validity,
  });

  factory RequestPlan.fromJson(Map<String, dynamic> json) {
    return RequestPlan(
      duration: json['duration'],
      validity: json['validity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'validity': validity,
    };
  }
}

class RequestReview {
  final String? respondedOn;

  RequestReview({
    this.respondedOn,
  });

  factory RequestReview.fromJson(Map<String, dynamic> json) {
    return RequestReview(
      respondedOn: json['responded_on'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responded_on': respondedOn,
    };
  }
}
