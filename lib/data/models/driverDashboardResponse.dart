class DriverDashboardResponse {
  final bool error;
  final String message;
  final DriverDashboardData data;
  final int code;

  DriverDashboardResponse({
    required this.error,
    required this.message,
    required this.data,
    required this.code,
  });

  factory DriverDashboardResponse.fromJson(Map<String, dynamic> json) {
    return DriverDashboardResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: DriverDashboardData.fromJson(json['data'] ?? {}),
      code: json['code'] ?? 200,
    );
  }
}

class DriverDashboardData {
  final DashboardUser user;
  final List<RouteVehicle> routeVehicle;
  final List<LiveTrip> liveTrips;
  final List<NewPassenger> newPassenger;
  final List<StaffOnLeave> staffOnLeave;
  final List<MyLeave> myLeaves;
  final List<Holiday> holidays;

  DriverDashboardData({
    required this.user,
    required this.routeVehicle,
    required this.liveTrips,
    required this.newPassenger,
    required this.staffOnLeave,
    required this.myLeaves,
    required this.holidays,
  });

  factory DriverDashboardData.fromJson(Map<String, dynamic> json) {
    return DriverDashboardData(
      user: DashboardUser.fromJson(json['user'] ?? {}),
      routeVehicle: (json['route_vehicle'] as List?)
              ?.map((item) => RouteVehicle.fromJson(item))
              .toList() ??
          [],
      liveTrips: (json['live_trips'] as List?)
              ?.map((item) => LiveTrip.fromJson(item))
              .toList() ??
          [],
      newPassenger: (json['new_passenger'] as List?)
              ?.map((item) => NewPassenger.fromJson(item))
              .toList() ??
          [],
      staffOnLeave: (json['staff_on_leave'] as List?)
              ?.map((item) => StaffOnLeave.fromJson(item))
              .toList() ??
          [],
      myLeaves: (json['my_leaves'] as List?)
              ?.map((item) => MyLeave.fromJson(item))
              .toList() ??
          [],
      holidays: (json['allholidays'] as List?)
              ?.map((item) => Holiday.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class DashboardUser {
  final int id;
  final String name;
  final String avtar;

  DashboardUser({
    required this.id,
    required this.name,
    required this.avtar,
  });

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avtar: json['avtar'] ?? '',
    );
  }
}

class RouteVehicle {
  final Shift? shift;
  final Vehicle? vehicle;
  final Route? route;
  final String? status;

  RouteVehicle({
    this.shift,
    this.vehicle,
    this.route,
    this.status,
  });

  factory RouteVehicle.fromJson(Map<String, dynamic> json) {
    return RouteVehicle(
      shift: json['shift'] != null ? Shift.fromJson(json['shift']) : null,
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      route: json['route'] != null ? Route.fromJson(json['route']) : null,
      status: json['status'],
    );
  }
}

class Shift {
  final int id;
  final String name;
  final String startTime;
  final String endTime;

  Shift({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}

class Vehicle {
  final int id;
  final String name;
  final String registrationNumber;

  Vehicle({
    required this.id,
    required this.name,
    required this.registrationNumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
    );
  }
}

class Route {
  final int id;
  final String name;

  Route({
    required this.id,
    required this.name,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class LiveTrip {
  final int tripId;
  final String from;
  final String to;
  final String routeName;
  final String type;
  final String status;
  final ShiftTime shiftTime;

  LiveTrip({
    required this.tripId,
    required this.from,
    required this.to,
    required this.routeName,
    required this.type,
    required this.status,
    required this.shiftTime,
  });

  factory LiveTrip.fromJson(Map<String, dynamic> json) {
    return LiveTrip(
      tripId: json['trip_id'] ?? 0,
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      routeName: json['route_name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      shiftTime: ShiftTime.fromJson(json['shift_time'] ?? {}),
    );
  }
}

class ShiftTime {
  final String from;
  final String to;

  ShiftTime({
    required this.from,
    required this.to,
  });

  factory ShiftTime.fromJson(Map<String, dynamic> json) {
    return ShiftTime(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}

class NewPassenger {
  final int id;
  final String name;
  final String avtar;
  final ShiftTime shiftTime;
  final PickupPoint pickupPoint;
  final String mobile;

  NewPassenger({
    required this.id,
    required this.name,
    required this.avtar,
    required this.shiftTime,
    required this.pickupPoint,
    required this.mobile,
  });

  factory NewPassenger.fromJson(Map<String, dynamic> json) {
    return NewPassenger(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avtar: json['avtar'] ?? '',
      shiftTime: ShiftTime.fromJson(json['shift_time'] ?? {}),
      pickupPoint: PickupPoint.fromJson(json['pickup_point'] ?? {}),
      mobile: json['mobile'] ?? '',
    );
  }
}

class PickupPoint {
  final int id;
  final String name;

  PickupPoint({
    required this.id,
    required this.name,
  });

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class StaffOnLeave {
  final int id;
  final String name;
  final String avtar;
  final String location;
  final String leaveType;

  StaffOnLeave({
    required this.id,
    required this.name,
    required this.avtar,
    required this.location,
    required this.leaveType,
  });

  factory StaffOnLeave.fromJson(Map<String, dynamic> json) {
    return StaffOnLeave(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avtar: json['avtar'] ?? '',
      location: json['location'] ?? '',
      leaveType: json['leave_type'] ?? '',
    );
  }
}

class MyLeave {
  final String date;
  final String leaveType;
  final String reason;

  MyLeave({
    required this.date,
    required this.leaveType,
    required this.reason,
  });

  factory MyLeave.fromJson(Map<String, dynamic> json) {
    return MyLeave(
      date: json['date'] ?? '',
      leaveType: json['leave_type'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

class Holiday {
  final int id;
  final String date;
  final String title;
  final String? description;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final String? defaultDateFormat;
  final String? dmyFormat;

  Holiday({
    required this.id,
    required this.date,
    required this.title,
    this.description,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.defaultDateFormat,
    this.dmyFormat,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      schoolId: json['school_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      defaultDateFormat: json['default_date_format'],
      dmyFormat: json['dmyFormat'],
    );
  }
}
