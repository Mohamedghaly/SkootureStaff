import 'package:eschool_saas_staff/data/models/userDetails.dart';

/// Enum for staff attendance status
enum StaffAttendanceStatus {
  present, // type 1
  absentWithReason, // type 0 (With reason)
  absentWithoutReason, // type 0 (Without reason)
  holiday, // type 3
  firstHalfPresent, // type 4
  secondHalfPresent, // type 5
  notMarked, // default (not sent to API)
}

extension StaffAttendanceStatusExtension on StaffAttendanceStatus {
  /// Get the type value for API submission
  /// 0 - absent, 1 - present, 3 - holiday, 4 - first half present, 5 - second half present
  int get typeValue {
    switch (this) {
      case StaffAttendanceStatus.present:
        return 1;
      case StaffAttendanceStatus.absentWithReason:
        return 0; // API expects 0 for absent
      case StaffAttendanceStatus.absentWithoutReason:
        return 0; // API expects 0 for absent
      case StaffAttendanceStatus.holiday:
        return 3; // API expects 3 for holiday
      case StaffAttendanceStatus.firstHalfPresent:
        return 4;
      case StaffAttendanceStatus.secondHalfPresent:
        return 5;
      case StaffAttendanceStatus.notMarked:
        return 0; // Default value (should not be submitted)
    }
  }

  /// Get the translation key for the status label
  /// This returns the key, not the translated string
  /// Use Utils.getTranslatedLabel(status.labelKey) to get the translated text
  String get labelKey {
    switch (this) {
      case StaffAttendanceStatus.present:
        return "present";
      case StaffAttendanceStatus.absentWithReason:
        return "absent";
      case StaffAttendanceStatus.absentWithoutReason:
        return "absent";
      case StaffAttendanceStatus.holiday:
        return "holiday";
      case StaffAttendanceStatus.firstHalfPresent:
        return "halfDayFirst";
      case StaffAttendanceStatus.secondHalfPresent:
        return "halfDaySecond";
      case StaffAttendanceStatus.notMarked:
        return "notMarked";
    }
  }

  /// Convert API type value to StaffAttendanceStatus
  /// 0 - absent, 1 - present, 3 - holiday, 4 - first half present, 5 - second half present
  static StaffAttendanceStatus fromType(int? type) {
    if (type == null) return StaffAttendanceStatus.notMarked;
    switch (type) {
      case 0:
        return StaffAttendanceStatus
            .absentWithoutReason; // Default to without reason
      case 1:
        return StaffAttendanceStatus.present;
      case 3:
        return StaffAttendanceStatus.holiday;
      case 4:
        return StaffAttendanceStatus.firstHalfPresent;
      case 5:
        return StaffAttendanceStatus.secondHalfPresent;
      default:
        return StaffAttendanceStatus.notMarked;
    }
  }
}

/// Model for Staff (Teacher) details from API
class StaffMember {
  final UserDetails? userDetails;
  final StaffDetails? staffDetails;

  StaffMember({
    this.userDetails,
    this.staffDetails,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      userDetails: json['user_details'] != null
          ? UserDetails.fromJson(Map.from(json['user_details']))
          : null,
      staffDetails: json['staff_details'] != null
          ? StaffDetails.fromJson(Map.from(json['staff_details']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_details': userDetails?.toJson(),
      'staff_details': staffDetails?.toJson(),
    };
  }
}

/// Staff table details
class StaffDetails {
  final int? staffTableId;
  final int? userId;

  StaffDetails({
    this.staffTableId,
    this.userId,
  });

  factory StaffDetails.fromJson(Map<String, dynamic> json) {
    return StaffDetails(
      staffTableId: json['staff_table_id'] as int?,
      userId: json['user_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_table_id': staffTableId,
      'user_id': userId,
    };
  }
}

/// Model for attendance record info
class AttendanceRecordInfo {
  final int? attendanceId;
  final int? rowNumber;
  final int? staffId;
  final String? date;
  final String? dayName;
  final String? statusLabel;

  AttendanceRecordInfo({
    this.attendanceId,
    this.rowNumber,
    this.staffId,
    this.date,
    this.dayName,
    this.statusLabel,
  });

  factory AttendanceRecordInfo.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordInfo(
      attendanceId: json['attendance_id'] as int?,
      rowNumber: json['row_number'] as int?,
      staffId: json['staff_id'] as int?,
      date: json['date'] as String?,
      dayName: json['day_name'] as String?,
      statusLabel: json['status_label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'row_number': rowNumber,
      'staff_id': staffId,
      'date': date,
      'day_name': dayName,
      'status_label': statusLabel,
    };
  }
}

/// Model for attendance info from API
class AttendanceInfo {
  final String? statusLabel;
  final String? formattedDate;
  final int? statusCode;

  AttendanceInfo({
    this.statusLabel,
    this.formattedDate,
    this.statusCode,
  });

  factory AttendanceInfo.fromJson(Map<String, dynamic> json) {
    return AttendanceInfo(
      statusLabel: json['status_label'] as String?,
      formattedDate: json['formatted_date'] as String?,
      statusCode: json['status_code'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_label': statusLabel,
      'formatted_date': formattedDate,
      'status_code': statusCode,
    };
  }
}

/// Model for leave info
class LeaveInfo {
  final String? detectedLeaveType;
  final AdminLeave? adminLeave;
  final AttendanceCreatedLeave? attendanceCreatedLeave;

  LeaveInfo({
    this.detectedLeaveType,
    this.adminLeave,
    this.attendanceCreatedLeave,
  });

  factory LeaveInfo.fromJson(Map<String, dynamic> json) {
    return LeaveInfo(
      detectedLeaveType: json['detected_leave_type'] as String?,
      adminLeave: json['admin_leave'] != null
          ? AdminLeave.fromJson(Map.from(json['admin_leave']))
          : null,
      attendanceCreatedLeave: json['attendance_created_leave'] != null
          ? AttendanceCreatedLeave.fromJson(
              Map.from(json['attendance_created_leave']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detected_leave_type': detectedLeaveType,
      'admin_leave': adminLeave?.toJson(),
      'attendance_created_leave': attendanceCreatedLeave?.toJson(),
    };
  }

  bool hasLeave() {
    return (adminLeave?.isAdminLeave ?? false) ||
        (attendanceCreatedLeave?.isAttendanceLeave ?? false);
  }

  /// Check if staff has admin leave (approved by admin)
  bool hasAdminLeave() {
    return adminLeave?.isAdminLeave ?? false;
  }

  /// Check if staff has full day leave
  bool isFullLeave() {
    return hasLeave() &&
        (detectedLeaveType?.toLowerCase() == 'full' ||
            detectedLeaveType?.toLowerCase() == 'full day');
  }

  /// Check if staff has first half leave
  bool isFirstHalfLeave() {
    return hasLeave() && detectedLeaveType?.toLowerCase() == 'first half';
  }

  /// Check if staff has second half leave
  bool isSecondHalfLeave() {
    return hasLeave() && detectedLeaveType?.toLowerCase() == 'second half';
  }

  /// Check if staff has admin-approved first half leave
  /// This is used to disable the first half option in attendance bottom sheet
  bool hasAdminFirstHalfLeave() {
    return hasAdminLeave() && detectedLeaveType?.toLowerCase() == 'first half';
  }

  /// Check if staff has admin-approved second half leave
  /// This is used to disable the second half option in attendance bottom sheet
  bool hasAdminSecondHalfLeave() {
    return hasAdminLeave() && detectedLeaveType?.toLowerCase() == 'second half';
  }

  /// Get display label translation key for leave type
  /// Returns the translation key, not the translated string
  /// Use Utils.getTranslatedLabel(leave.getLeaveLabelKey()) to get translated text
  String getLeaveLabelKey() {
    if (!hasLeave()) return '';

    if (isFullLeave()) return 'onLeaveFullDay';
    if (isFirstHalfLeave()) return 'onLeaveFirstHalf';
    if (isSecondHalfLeave()) return 'onLeaveSecondHalf';

    return 'onLeave';
  }

  /// Get display label for leave type (deprecated - use getLeaveLabelKey instead)
  @Deprecated('Use getLeaveLabelKey() with Utils.getTranslatedLabel() instead')
  String getLeaveLabel() {
    return getLeaveLabelKey();
  }
}

class AdminLeave {
  final bool? isAdminLeave;
  final List<String>? typesDetected;

  AdminLeave({
    this.isAdminLeave,
    this.typesDetected,
  });

  factory AdminLeave.fromJson(Map<String, dynamic> json) {
    return AdminLeave(
      isAdminLeave: json['is_admin_leave'] as bool?,
      typesDetected: (json['types_detected'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_admin_leave': isAdminLeave,
      'types_detected': typesDetected,
    };
  }
}

class AttendanceCreatedLeave {
  final bool? isAttendanceLeave;
  final List<String>? typesDetected;
  final String? reason;

  AttendanceCreatedLeave({
    this.isAttendanceLeave,
    this.typesDetected,
    this.reason,
  });

  factory AttendanceCreatedLeave.fromJson(Map<String, dynamic> json) {
    return AttendanceCreatedLeave(
      isAttendanceLeave: json['is_attendance_leave'] as bool?,
      typesDetected: (json['types_detected'] as List?)?.cast<String>(),
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_attendance_leave': isAttendanceLeave,
      'types_detected': typesDetected,
      'reason': reason,
    };
  }
}

/// Main model for Staff Attendance Record
class StaffAttendanceRecord {
  final String? recordType;
  final AttendanceRecordInfo? recordInfo;
  final StaffMember? staff;
  final AttendanceInfo? attendance;
  final LeaveInfo? leave;
  final List<String>? holidayConfig;
  final bool payrollExists;

  // Local state for UI
  StaffAttendanceStatus? currentStatus;
  String? reason;

  StaffAttendanceRecord({
    this.recordType,
    this.recordInfo,
    this.staff,
    this.attendance,
    this.leave,
    this.holidayConfig,
    this.payrollExists = false,
    this.currentStatus,
    this.reason,
  });

  factory StaffAttendanceRecord.fromJson(Map<String, dynamic> json) {
    final recordType = json['record_type'] as String?;
    final attendanceInfo = json['attendance'] != null
        ? AttendanceInfo.fromJson(Map.from(json['attendance']))
        : null;
    final leaveInfo = json['leave'] != null
        ? LeaveInfo.fromJson(Map.from(json['leave']))
        : null;

    // Extract reason from leave.attendance_created_leave.reason
    String? extractedReason;
    if (leaveInfo?.attendanceCreatedLeave?.reason != null) {
      extractedReason = leaveInfo!.attendanceCreatedLeave!.reason;
    }

    // Determine initial status based on record_type and status_code
    StaffAttendanceStatus initialStatus = StaffAttendanceStatus.notMarked;
    if (recordType == 'already_marked' && attendanceInfo?.statusCode != null) {
      // Map status_code to StaffAttendanceStatus
      // API values: 0 = Absent, 1 = Present, 3 = Holiday, 4 = First half, 5 = Second half
      switch (attendanceInfo!.statusCode) {
        case 0:
          // Absent - could be with or without reason (determined by reason field)
          initialStatus = StaffAttendanceStatus.absentWithoutReason;
          break;
        case 1:
          initialStatus = StaffAttendanceStatus.present;
          break;
        case 3:
          initialStatus = StaffAttendanceStatus.holiday;
          break;
        case 4:
          initialStatus = StaffAttendanceStatus.firstHalfPresent;
          break;
        case 5:
          initialStatus = StaffAttendanceStatus.secondHalfPresent;
          break;
        default:
          initialStatus = StaffAttendanceStatus.notMarked;
      }
    }

    return StaffAttendanceRecord(
      recordType: recordType,
      recordInfo: json['record_info'] != null
          ? AttendanceRecordInfo.fromJson(Map.from(json['record_info']))
          : null,
      staff: json['staff'] != null
          ? StaffMember.fromJson(Map.from(json['staff']))
          : null,
      attendance: attendanceInfo,
      leave: leaveInfo,
      holidayConfig: json['holiday_config'] != null
          ? List<String>.from(json['holiday_config'])
          : null,
      payrollExists: json['payroll_exists'] ?? false,
      currentStatus: initialStatus,
      reason: extractedReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'record_type': recordType,
      'record_info': recordInfo?.toJson(),
      'staff': staff?.toJson(),
      'attendance': attendance?.toJson(),
      'leave': leave?.toJson(),
      'holiday_config': holidayConfig,
      'payroll_exists': payrollExists,
    };
  }

  /// Get staff ID
  int? get staffId => recordInfo?.staffId;

  /// Get staff name
  String get staffName => staff?.userDetails?.fullName ?? '-';

  /// Get staff image
  String? get staffImage => staff?.userDetails?.image;

  /// Check if attendance is already marked
  bool isMarked() {
    return recordInfo?.attendanceId != null;
  }

  /// Check if staff has pre-approved leave (should not be included in submission)
  bool hasPreApprovedLeave() {
    return leave?.hasLeave() ?? false;
  }

  /// Check if staff has full day leave
  bool hasFullLeave() {
    return leave?.isFullLeave() ?? false;
  }

  /// Check if staff has first half leave
  bool hasFirstHalfLeave() {
    return leave?.isFirstHalfLeave() ?? false;
  }

  /// Check if staff has second half leave
  bool hasSecondHalfLeave() {
    return leave?.isSecondHalfLeave() ?? false;
  }

  /// Check if staff has admin-approved first half leave
  /// This should disable the first half attendance option
  bool hasAdminFirstHalfLeave() {
    return leave?.hasAdminFirstHalfLeave() ?? false;
  }

  /// Check if staff has admin-approved second half leave
  /// This should disable the second half attendance option
  bool hasAdminSecondHalfLeave() {
    return leave?.hasAdminSecondHalfLeave() ?? false;
  }

  /// Check if staff can be selected for attendance marking
  /// Only payroll existence prevents selection - leave status no longer restricts selection
  bool canBeSelected() {
    // Cannot select if payroll has been generated for this staff member
    if (payrollExists) return false;

    // Staff can be selected regardless of leave status
    return true;
  }

  /// Check if a specific attendance status is allowed for this staff
  /// All statuses are now allowed regardless of leave status
  bool isStatusAllowed(StaffAttendanceStatus status) {
    // All statuses are allowed - leave status no longer restricts options
    return true;
  }

  /// Get attendance ID for update
  int? get attendanceId => recordInfo?.attendanceId;

  /// Copy with method for updating status
  StaffAttendanceRecord copyWith({
    StaffAttendanceStatus? currentStatus,
    String? reason,
  }) {
    return StaffAttendanceRecord(
      recordType: recordType,
      recordInfo: recordInfo,
      staff: staff,
      attendance: attendance,
      leave: leave,
      holidayConfig: holidayConfig,
      payrollExists: payrollExists,
      currentStatus: currentStatus ?? this.currentStatus,
      reason: reason ?? this.reason,
    );
  }
}

/// Response model for staff attendance API
class StaffAttendanceResponse {
  final String? date;
  final int? total;
  final List<StaffAttendanceRecord>? rows;
  final String? status; // "holiday" when date is marked as holiday
  final int? code; // 3 for holiday
  final String? message; // holiday message

  StaffAttendanceResponse({
    this.date,
    this.total,
    this.rows,
    this.status,
    this.code,
    this.message,
  });

  factory StaffAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return StaffAttendanceResponse(
      date: json['date'] as String?,
      total: json['total'] as int?,
      rows: (json['rows'] as List?)
          ?.map((row) => StaffAttendanceRecord.fromJson(Map.from(row)))
          .toList(),
      status: json['status'] as String?,
      code: json['code'] as int?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total': total,
      'rows': rows?.map((row) => row.toJson()).toList(),
      'status': status,
      'code': code,
      'message': message,
    };
  }

  /// Check if the date is marked as a holiday
  bool get isHoliday => status == 'holiday' && code == 3;
}

/// Model for attendance submission data
class AttendanceSubmissionData {
  final int? id; // attendance_id for update, null for new
  final int? staffId;
  final int? type; // 1-5 based on status
  final String? reason;
  final int? leaveId;

  AttendanceSubmissionData({
    this.id,
    required this.staffId,
    required this.type,
    this.reason,
    this.leaveId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': staffId,
      'type': type,
      'reason': reason,
      'leave_id': leaveId,
    };
  }
}

/// Model for complete attendance submission payload
class StaffAttendanceSubmissionPayload {
  final String date;
  final bool? holiday; // true to mark as holiday, null otherwise
  final List<AttendanceSubmissionData> attendanceData;
  final bool absentNotification;

  StaffAttendanceSubmissionPayload({
    required this.date,
    this.holiday,
    required this.attendanceData,
    required this.absentNotification,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'holiday': holiday,
      'attendance_data': attendanceData.map((data) => data.toJson()).toList(),
      'absent_notification': absentNotification,
    };
  }
}
