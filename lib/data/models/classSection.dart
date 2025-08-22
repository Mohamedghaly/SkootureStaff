import 'package:eschool_saas_staff/data/models/classDetails.dart';
import 'package:eschool_saas_staff/data/models/classTeacher.dart';
import 'package:eschool_saas_staff/data/models/medium.dart';
import 'package:eschool_saas_staff/data/models/section.dart';
import 'package:eschool_saas_staff/data/models/subjectTeacher.dart';
// this is my model please correct the model
class ClassSection {
  final int? id;
  final int? classId;
  final int? sectionId;
  final int? mediumId;
  final int? schoolId;
  final String? name;
  final String? fullName;
  final ClassDetails? classDetails;
  final Section? section;
  final Medium? medium;
  final List<ClassTeacher>? classTeachers;
  final List<SubjectTeacher>? subjectTeachers;

  ClassSection(
      {this.id,
      this.classId,
      this.sectionId,
      this.mediumId,
      this.schoolId,
      this.name,
      this.fullName,
      this.classDetails,
      this.medium,
      this.section,
      this.classTeachers,
      this.subjectTeachers});

  ClassSection copyWith(
      {int? id,
      int? classId,
      int? sectionId,
      int? mediumId,
      int? schoolId,
      String? name,
      String? fullName,
      Medium? medium,
      ClassDetails? classDetails,
      Section? section,
      List<ClassTeacher>? classTeachers,
      List<SubjectTeacher>? subjectTeachers}) {
    return ClassSection(
        subjectTeachers: subjectTeachers ?? this.subjectTeachers,
        classTeachers: classTeachers ?? this.classTeachers,
        id: id ?? this.id,
        classId: classId ?? this.classId,
        sectionId: sectionId ?? this.sectionId,
        mediumId: mediumId ?? this.mediumId,
        schoolId: schoolId ?? this.schoolId,
        name: name ?? this.name,
        fullName: fullName ?? this.fullName,
        classDetails: classDetails ?? this.classDetails,
        medium: medium ?? this.medium,
        section: section ?? this.section);
  }

  ClassSection.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        classId = json['class_id'] as int?,
        sectionId = json['section_id'] as int?,
        mediumId = json['medium_id'] as int?,
        schoolId = json['school_id'] as int?,
        name = json['name'] as String?,
        classDetails = ClassDetails.fromJson(Map.from(json['class'] ?? {})),
        medium = Medium.fromJson(Map.from(json['medium'] ?? {})),
        section = Section.fromJson(Map.from(json['section'] ?? {})),
        subjectTeachers = ((json['subject_teachers'] ?? []) as List)
            .map((subjectTeacher) =>
                SubjectTeacher.fromJson(Map.from(subjectTeacher ?? {})))
            .toList(),
        classTeachers = ((json['class_teachers'] ?? []) as List)
            .map((classTeacher) =>
                ClassTeacher.fromJson(Map.from(classTeacher ?? {})))
            .toList(),
        fullName = json['full_name'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'class_id': classId,
        'section_id': sectionId,
        'medium_id': mediumId,
        'school_id': schoolId,
        'name': name,
        'full_name': fullName,
        'class': classDetails?.toJson(),
        'medium': medium?.toJson(),
        'section': section?.toJson(),
        'subject_teachers': subjectTeachers?.map((e) => e.toJson()).toList(),
        'class_teachers': classTeachers?.map((e) => e.toJson()).toList()
      };

  @override
  bool operator ==(covariant ClassSection other) {
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return (fullName ?? "");
  }

  String getClassTeacherNames() {
    return (classTeachers?.isEmpty ?? true)
        ? "-"
        : (classTeachers!.map((e) => e.teacher?.fullName).toList().join(","));
  }
}
