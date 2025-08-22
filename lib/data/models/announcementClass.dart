class AnnouncementClass {
  final int? id;
  final int? announcementId;
  final int? classSectionId;
  final int? classSubjectId;
  final int? schoolId;

  AnnouncementClass({
    this.id,
    this.announcementId,
    this.classSectionId,
    this.classSubjectId,
    this.schoolId,
  });

  AnnouncementClass copyWith({
    int? id,
    int? announcementId,
    int? classSectionId,
    int? classSubjectId,
    int? schoolId,
  }) {
    return AnnouncementClass(
      id: id ?? this.id,
      announcementId: announcementId ?? this.announcementId,
      classSectionId: classSectionId ?? this.classSectionId,
      classSubjectId: classSubjectId ?? this.classSubjectId,
      schoolId: schoolId ?? this.schoolId,
    );
  }

  AnnouncementClass.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        announcementId = json['announcement_id'] as int?,
        classSectionId = json['class_section_id'] as int?,
        classSubjectId = json['class_subject_id'] as int?,
        schoolId = json['school_id'] as int?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'announcement_id': announcementId,
        'class_section_id': classSectionId,
        'class_subject_id': classSubjectId,
        'school_id': schoolId
      };
}
