class LeaveSettings {
  final int? id;
  final double? leaves;
  final String? holiday;
  final int? sessionYearId;
  final int? schoolId;

  LeaveSettings({
    this.id,
    this.leaves,
    this.holiday,
    this.sessionYearId,
    this.schoolId,
  });

  LeaveSettings copyWith({
    int? id,
    double? leaves,
    String? holiday,
    int? sessionYearId,
    int? schoolId,
  }) {
    return LeaveSettings(
      id: id ?? this.id,
      leaves: leaves ?? this.leaves,
      holiday: holiday ?? this.holiday,
      sessionYearId: sessionYearId ?? this.sessionYearId,
      schoolId: schoolId ?? this.schoolId,
    );
  }

  LeaveSettings.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        leaves = double.parse((json['leaves'] ?? 0).toString()),
        holiday = json['holiday'] as String?,
        sessionYearId = json['session_year_id'] as int?,
        schoolId = json['school_id'] as int?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'leaves': leaves,
        'holiday': holiday,
        'session_year_id': sessionYearId,
        'school_id': schoolId
      };
}
