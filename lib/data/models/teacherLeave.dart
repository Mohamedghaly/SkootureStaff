/// Model for leave detail (individual date entry within a leave)
class TeacherLeaveDetail {
  final int? id;
  final int? leaveId;
  final String? date; // Format: "2025-12-22"
  final String? type; // "Full", "First Half", "Second Half"
  final int? schoolId;

  TeacherLeaveDetail({
    this.id,
    this.leaveId,
    this.date,
    this.type,
    this.schoolId,
  });

  factory TeacherLeaveDetail.fromJson(Map<String, dynamic> json) {
    return TeacherLeaveDetail(
      id: json['id'],
      leaveId: json['leave_id'],
      date: json['date'],
      type: json['type'],
      schoolId: json['school_id'],
    );
  }

  /// Check if this is a full day leave
  bool isFullLeave() => type == 'Full';

  /// Check if this is a first half leave
  bool isFirstHalfLeave() => type == 'First Half';

  /// Check if this is a second half leave
  bool isSecondHalfLeave() => type == 'Second Half';

  /// Get leave type indicator ('F' for Full, '1' for First Half, '2' for Second Half)
  String getLeaveIndicator() {
    if (isFullLeave()) return 'L';
    if (isFirstHalfLeave()) return '1';
    if (isSecondHalfLeave()) return '2';
    return '';
  }

  /// Parse the date string to DateTime
  DateTime? getLeaveDate() {
    if (date == null || date!.isEmpty) return null;
    try {
      // Date format: "2025-12-22"
      return DateTime.parse(date!);
    } catch (e) {
      return null;
    }
  }
}

/// Model for teacher leave
class TeacherLeave {
  final int? id;
  final int? userId;
  final String? reason;
  final String? fromDate;
  final String? toDate;
  final int? status;
  final int? schoolId;
  final int? leaveMasterId;
  final List<TeacherLeaveDetail> leaveDetails;

  TeacherLeave({
    this.id,
    this.userId,
    this.reason,
    this.fromDate,
    this.toDate,
    this.status,
    this.schoolId,
    this.leaveMasterId,
    this.leaveDetails = const [],
  });

  factory TeacherLeave.fromJson(Map<String, dynamic> json) {
    List<TeacherLeaveDetail> details = [];
    if (json['leave_detail'] != null) {
      details = (json['leave_detail'] as List)
          .map((detail) => TeacherLeaveDetail.fromJson(detail))
          .toList();
    }

    return TeacherLeave(
      id: json['id'],
      userId: json['user_id'],
      reason: json['reason'],
      fromDate: json['from_date'],
      toDate: json['to_date'],
      status: json['status'],
      schoolId: json['school_id'],
      leaveMasterId: json['leave_master_id'],
      leaveDetails: details,
    );
  }

  /// Check if leave is approved (status = 1)
  bool isApproved() => status == 1;
}
