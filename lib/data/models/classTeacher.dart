import 'package:eschool_saas_staff/data/models/userDetails.dart';

class ClassTeacher {
  final int? id;
  final int? classSectionId;
  final int? teacherId;
  final int? schoolId;
  final int? classId;
  final UserDetails? teacher;

  ClassTeacher(
      {this.id,
      this.classSectionId,
      this.teacherId,
      this.schoolId,
      this.classId,
      this.teacher});

  ClassTeacher copyWith({
    int? id,
    int? classSectionId,
    int? teacherId,
    int? schoolId,
    int? classId,
    UserDetails? teacher,
  }) {
    return ClassTeacher(
      teacher: teacher ?? this.teacher,
      id: id ?? this.id,
      classSectionId: classSectionId ?? this.classSectionId,
      teacherId: teacherId ?? this.teacherId,
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
    );
  }

  ClassTeacher.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        classSectionId = json['class_section_id'] as int?,
        teacherId = json['teacher_id'] as int?,
        schoolId = json['school_id'] as int?,
        teacher = UserDetails.fromJson(Map.from(json['teacher'] ?? {})),
        classId = json['class_id'] as int?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'class_section_id': classSectionId,
        'teacher_id': teacherId,
        'school_id': schoolId,
        'class_id': classId,
        'teacher': teacher?.toJson()
      };
}
