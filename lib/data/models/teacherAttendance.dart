class TeacherAttendance {
  final int? id;
  final int? staffId;
  final int? sessionYearId;
  final int? type; // 0- Absent, 1- Present
  final String? reason; // Reason for absence (only for absent type)
  final String? date;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final String? getDateOriginal;
  final String? dateFormat;

  TeacherAttendance({
    this.id,
    this.staffId,
    this.sessionYearId,
    this.type,
    this.reason,
    this.date,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.getDateOriginal,
    this.dateFormat,
  });

  TeacherAttendance copyWith({
    int? id,
    int? staffId,
    int? sessionYearId,
    int? type,
    String? reason,
    String? date,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
    String? getDateOriginal,
    String? dateFormat,
  }) {
    return TeacherAttendance(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      sessionYearId: sessionYearId ?? this.sessionYearId,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      date: date ?? this.date,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      getDateOriginal: getDateOriginal ?? this.getDateOriginal,
      dateFormat: dateFormat ?? this.dateFormat,
    );
  }

  TeacherAttendance.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        staffId = json['staff_id'] as int?,
        sessionYearId = json['session_year_id'] as int?,
        type = json['type'] as int?,
        reason = json['reason'] as String?,
        date = json['date'] as String?,
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        getDateOriginal = json['get_date_original'] as String?,
        dateFormat = json['date_format'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'staff_id': staffId,
        'session_year_id': sessionYearId,
        'type': type,
        'reason': reason,
        'date': date,
        'school_id': schoolId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'get_date_original': getDateOriginal,
        'date_format': dateFormat,
      };

  /// Check if present (full day or half day)
  /// Type 1: Full day present
  /// Type 4: First half present
  /// Type 5: Second half present
  bool isPresent() {
    return type == 1 || type == 4 || type == 5;
  }

  /// Check if absent (full day)
  /// Type 0: Absent
  bool isAbsent() {
    return type == 0;
  }

  /// Check if holiday
  /// Type 3: Holiday
  bool isHoliday() {
    return type == 3;
  }

  /// Check if it's a half-day attendance
  bool isHalfDay() {
    return type == 4 || type == 5;
  }

  /// Check if first half present
  bool isFirstHalfPresent() {
    return type == 4;
  }

  /// Check if second half present
  bool isSecondHalfPresent() {
    return type == 5;
  }

  /// Check if has absence reason
  bool hasAbsenceReason() {
    return isAbsent() && reason != null && reason!.isNotEmpty;
  }

  /// Get the date in DateTime format for calendar usage
  DateTime? getAttendanceDate() {
    if (getDateOriginal == null) return null;
    try {
      return DateTime.parse(getDateOriginal!);
    } catch (e) {
      return null;
    }
  }
}
