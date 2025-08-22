import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/subject.dart';

class Assignment {
  Assignment({
    required this.id,
    required this.classSectionId,
    required this.subjectId,
    required this.name,
    required this.instructions,
    required this.dueDate,
    required this.points,
    required this.resubmission,
    required this.extraDaysForResubmission,
    required this.sessionYearId,
    required this.createdAt,
    required this.classSection,
    required this.studyMaterial,
    required this.subject,
    required this.url,
    required this.dateFormat,
  });
  late final int id;
  late final int classSectionId;
  late final int subjectId;
  late final String name;
  late final String instructions;
  late final String dueDate;
  late final int points;
  late final int resubmission;
  late final int extraDaysForResubmission;
  late final int sessionYearId;
  late final String createdAt;
  late final ClassSection classSection;
  late final List<StudyMaterial> studyMaterial;
  late final Subject subject;
  late final String url;
  late final String dateFormat;

  Assignment.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    classSectionId = json['class_section_id'] ?? 0;
    subjectId = json['subject_id'] ?? 0;
    name = json['name'] ?? "";
    instructions = json["instructions"] ?? "";
    dueDate = json['due_date'] ?? "";
    points = json["points"] ?? 0;
    resubmission = json['resubmission'] ?? 0;
    extraDaysForResubmission = json["extra_days_for_resubmission"] ?? 0;
    sessionYearId = json['session_year_id'] ?? 0;
    createdAt = json['created_at'] ?? "";
    classSection = ClassSection.fromJson(json['class_section'] ?? {});
    studyMaterial = ((json['file'] ?? {}) as List)
        .map((e) => StudyMaterial.fromJson(Map.from(e)))
        .toList();
    subject = Subject.fromJson(json['subject'] ?? {});
    url = json['add_url'] ?? "";
    dateFormat = json['date_format'] ?? "d-m-Y";
  }
}
