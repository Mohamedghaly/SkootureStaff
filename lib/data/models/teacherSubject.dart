import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/subject.dart';

class TeacherSubject {
  int id;
  int classSectionId;
  int subjectId;
  int classSubjectId;
  int teacherId;
  Subject subject;
  ClassSection classSection;

  TeacherSubject({
    required this.id,
    required this.classSectionId,
    required this.subjectId,
    required this.classSubjectId,
    required this.teacherId,
    required this.subject,
    required this.classSection,
  });

  factory TeacherSubject.fromJson(Map<String, dynamic> json) {
    return TeacherSubject(
      id: json['id'] ?? 0,
      classSubjectId: json['class_subject_id'] ?? 0,
      classSectionId: json['class_section_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      teacherId: json['teacher_id'] ?? 0,
      subject: Subject.fromJson(json['subject'] ?? {}),
      classSection: ClassSection.fromJson(json['class_section'] ?? {}),
    );
  }

  @override
  String toString() {
    return subject.getSybjectNameWithType();
  }

  @override
  bool operator ==(covariant TeacherSubject other) {
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
