class CurrentPlanResponse {
  final bool error;
  final String message;
  final CurrentPlan? data;
  final int code;

  CurrentPlanResponse({
    required this.error,
    required this.message,
    this.data,
    required this.code,
  });

  factory CurrentPlanResponse.fromJson(Map<String, dynamic> json) {
    return CurrentPlanResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CurrentPlan.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
      code: json['code'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': data?.toJson(),
      'code': code,
    };
  }

  bool get isSuccess => !error && data != null;
}

class CurrentPlan {
  final int? paymentId;
  final int? shiftId;
  final String? duration;
  final String? validFrom;
  final String? validTo;
  final String? totalFee;
  final String? paymentMode;
  final PlanRoute? route;
  final PlanShift? shift;
  final PlanPickupStop? pickupStop;
  final PlanVehicle? vehicle;
  final String? estimatedPickupTime;
  final int? vehicleId;

  CurrentPlan({
    this.paymentId,
    this.shiftId,
    this.duration,
    this.validFrom,
    this.validTo,
    this.totalFee,
    this.paymentMode,
    this.route,
    this.shift,
    this.pickupStop,
    this.vehicle,
    this.estimatedPickupTime,
    this.vehicleId,
  });

  factory CurrentPlan.fromJson(Map<String, dynamic> json) {
    // Handle fees object (for expired plan response where fees is nested)
    final fees = json['fees'] as Map<String, dynamic>?;

    // Parse validity string "2025-11-07 to 2025-11-20" into validFrom and validTo
    String? validFrom = json['valid_from'];
    String? validTo = json['valid_to'];

    if (json['validity'] != null && json['validity'] is String) {
      final validityString = json['validity'] as String;
      final parts = validityString.split(' to ');
      if (parts.length == 2) {
        validFrom = parts[0].trim();
        validTo = parts[1].trim();
      }
    }

    // Get duration and totalFee - check both root level and fees object
    String? duration = json['duration'] ?? fees?['duration'];
    String? totalFee = json['total_fee'] ?? fees?['total_fee'];

    // Handle pickup_stop vs pickup_point (API uses different keys)
    final pickupStopData = json['pickup_stop'] ?? json['pickup_point'];

    return CurrentPlan(
      paymentId: json['payment_id'],
      shiftId: json['shift_id'],
      duration: duration,
      validFrom: validFrom,
      validTo: validTo,
      totalFee: totalFee,
      paymentMode: json['payment_mode'],
      route: json['route'] != null
          ? PlanRoute.fromJson(Map<String, dynamic>.from(json['route']))
          : null,
      shift: json['shift'] != null
          ? PlanShift.fromJson(Map<String, dynamic>.from(json['shift']))
          : null,
      pickupStop: pickupStopData != null
          ? PlanPickupStop.fromJson(Map<String, dynamic>.from(pickupStopData))
          : null,
      vehicle: json['vehicle'] != null
          ? PlanVehicle.fromJson(Map<String, dynamic>.from(json['vehicle']))
          : null,
      estimatedPickupTime: json['estimated_pickup_time'],
      vehicleId: json['vehicle_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'shift_id': shiftId,
      'duration': duration,
      'valid_from': validFrom,
      'valid_to': validTo,
      'total_fee': totalFee,
      'payment_mode': paymentMode,
      'route': route?.toJson(),
      'shift': shift?.toJson(),
      'pickup_stop': pickupStop?.toJson(),
      'vehicle': vehicle?.toJson(),
      'estimated_pickup_time': estimatedPickupTime,
      'vehicle_id': vehicleId,
    };
  }
}

class PlanRoute {
  final int? id;
  final String? name;

  PlanRoute({
    this.id,
    this.name,
  });

  factory PlanRoute.fromJson(Map<String, dynamic> json) {
    return PlanRoute(
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

class PlanShift {
  final String? name;
  final String? timeWindow;

  PlanShift({
    this.name,
    this.timeWindow,
  });

  factory PlanShift.fromJson(Map<String, dynamic> json) {
    return PlanShift(
      name: json['name'],
      timeWindow: json['time_window'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time_window': timeWindow,
    };
  }
}

class PlanPickupStop {
  final int? id;
  final String? name;

  PlanPickupStop({
    this.id,
    this.name,
  });

  factory PlanPickupStop.fromJson(Map<String, dynamic> json) {
    return PlanPickupStop(
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

class PlanVehicle {
  final int? vehicleId;
  final String? vehicleName;
  final String? vehicleRegistration;

  PlanVehicle({
    this.vehicleId,
    this.vehicleName,
    this.vehicleRegistration,
  });

  factory PlanVehicle.fromJson(Map<String, dynamic> json) {
    return PlanVehicle(
      vehicleId: json['vehicle_id'],
      vehicleName: json['vehicle_name'],
      vehicleRegistration: json['vehicle_registration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'vehicle_name': vehicleName,
      'vehicle_registration': vehicleRegistration,
    };
  }
}
