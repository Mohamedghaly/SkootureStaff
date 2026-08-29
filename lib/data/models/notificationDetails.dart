class NotificationDetails {
  final int? id;
  final String? title;
  final String? message;
  final String? image;
  final String? sendTo;
  final int? isCustom;
  final int? sessionYearId;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final String? type;

  NotificationDetails({
    this.id,
    this.title,
    this.message,
    this.image,
    this.sendTo,
    this.isCustom,
    this.sessionYearId,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.type,
  });

  NotificationDetails copyWith({
    int? id,
    String? title,
    String? message,
    String? image,
    String? sendTo,
    int? isCustom,
    int? sessionYearId,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
    String? type,
  }) {
    return NotificationDetails(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      image: image ?? this.image,
      sendTo: sendTo ?? this.sendTo,
      isCustom: isCustom ?? this.isCustom,
      sessionYearId: sessionYearId ?? this.sessionYearId,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
    );
  }

  NotificationDetails.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        title = json['title'] as String?,
        message = json['message'] as String?,
        image = json['image'] as String?,
        sendTo = json['send_to'] as String?,
        isCustom = json['is_custom'] as int?,
        sessionYearId = json['session_year_id'] as int?,
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        type = json['type'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'image': image,
        'send_to': sendTo,
        'is_custom': isCustom,
        'session_year_id': sessionYearId,
        'school_id': schoolId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'type': type,
      };
}
