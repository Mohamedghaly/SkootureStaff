class SessionYear {
  final int? id;
  final String? name;
  final int? defaultYear;
  final String? startDate;
  final String? endDate;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  SessionYear({
    this.id,
    this.name,
    this.defaultYear,
    this.startDate,
    this.endDate,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  SessionYear copyWith({
    int? id,
    String? name,
    int? defaultYear,
    String? startDate,
    String? endDate,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return SessionYear(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultYear: defaultYear ?? this.defaultYear,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  SessionYear.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        defaultYear = json['default'] as int?,
        startDate = json['start_date'] as String?,
        endDate = json['end_date'] as String?,
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        deletedAt = json['deleted_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'default': defaultYear,
        'start_date': startDate,
        'end_date': endDate,
        'school_id': schoolId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt
      };

  bool isThisDefault() {
    return defaultYear == 1;
  }

   @override
  bool operator ==(covariant SessionYear other) {
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return (name ?? "");
  }
}
