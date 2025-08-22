class Holiday {
  final int? id;
  final String? date;
  final String? title;
  final String? description;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final String? defaultDateFormat;

  Holiday({
    this.id,
    this.date,
    this.title,
    this.description,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.defaultDateFormat,
  });

  Holiday copyWith({
    int? id,
    String? date,
    String? title,
    String? description,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
    String? defaultDateFormat,
  }) {
    return Holiday(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      defaultDateFormat: defaultDateFormat ?? this.defaultDateFormat,
    );
  }

  Holiday.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        date = json['date'] as String?,
        title = json['title'] as String?,
        description = json['description'] as String?,
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        defaultDateFormat = json['default_date_format'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'title': title,
        'description': description,
        'school_id': schoolId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'default_date_format': defaultDateFormat
      };
}
