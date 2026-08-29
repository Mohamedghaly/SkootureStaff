import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

/// Transport User Attendance Models
/// Matches the exact API response structure from /api/transport/user/attendance-list

class TransportUserAttendanceResponse {
  final bool error;
  final String message;
  final TransportUserAttendanceData data;
  final int code;

  TransportUserAttendanceResponse({
    required this.error,
    required this.message,
    required this.data,
    required this.code,
  });

  factory TransportUserAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return TransportUserAttendanceResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: TransportUserAttendanceData.fromJson(json['data'] ?? {}),
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

class TransportUserAttendanceData {
  final AttendanceSummary summary;
  final List<AttendanceRecord> records;

  TransportUserAttendanceData({
    required this.summary,
    required this.records,
  });

  factory TransportUserAttendanceData.fromJson(Map<String, dynamic> json) {
    return TransportUserAttendanceData(
      summary: AttendanceSummary.fromJson(json['summary'] ?? {}),
      records: (json['records'] as List<dynamic>?)
              ?.map((record) =>
                  AttendanceRecord.fromJson(record as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'records': records.map((record) => record.toJson()).toList(),
    };
  }

  bool get hasData => records.isNotEmpty;
}

class AttendanceSummary {
  final int present;
  final int absent;

  AttendanceSummary({
    required this.present,
    required this.absent,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'present': present,
      'absent': absent,
    };
  }

  // Computed properties
  int get totalDays => present + absent;
  double get attendancePercentage =>
      totalDays > 0 ? (present / totalDays) * 100 : 0.0;
}

class AttendanceRecord {
  final String date;
  final String tripType;
  final String status;

  AttendanceRecord({
    required this.date,
    required this.tripType,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: json['date'] ?? '',
      tripType: json['trip_type'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'trip_type': tripType,
      'status': status,
    };
  }

  // Helper methods
  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'P':
        return Utils.getTranslatedLabel(presentKey);
      case 'A':
        return Utils.getTranslatedLabel(absentKey);
      case 'W':
        return Utils.getTranslatedLabel(waitingKey);
      default:
        return Utils.getTranslatedLabel(unknownKey);
    }
  }

  String get tripTypeDisplay {
    switch (tripType.toLowerCase()) {
      case 'pickup':
        return Utils.getTranslatedLabel(pickupKey);
      case 'drop':
        return Utils.getTranslatedLabel(dropKey);
      default:
        return tripType;
    }
  }

  bool get isPresent => status.toUpperCase() == 'P';
  bool get isAbsent => status.toUpperCase() == 'A';
}

// Filter models
class AttendanceFilters {
  final String? month;
  final String? tripType;

  AttendanceFilters({
    this.month,
    this.tripType,
  });

  Map<String, String> toApiBody() {
    final Map<String, String> body = {};
    if (month != null && month!.isNotEmpty) {
      body['month'] = month!;
    }
    if (tripType != null &&
        tripType!.isNotEmpty &&
        tripType!.toLowerCase() != 'all') {
      body['trip_type'] = tripType!.toLowerCase();
    }
    return body;
  }
}

// Dropdown options
class FilterOption {
  final String label;
  final String value;

  FilterOption({
    required this.label,
    required this.value,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterOption &&
        other.label == label &&
        other.value == value;
  }

  @override
  int get hashCode => label.hashCode ^ value.hashCode;
}
