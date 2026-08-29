import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/subjectTeacher.dart';

/// A subject-teacher option for the create form's single "Subject" dropdown.
///
/// Built by flattening the `teacher/class-detail` response (the teacher's
/// assigned classes, each with their `subject_teachers`). [id] is the
/// `subject_teacher_id` posted on create.
class OnlineClassSubjectOption {
  /// subject_teacher_id
  final int id;
  final int subjectId;
  final String subject;
  final String subjectType;
  final String classSection;
  final String teacher;

  /// Pre-built label from the API, matching the web dropdown exactly:
  /// `Subject - Type — Class Section — Teacher`.
  final String apiLabel;

  const OnlineClassSubjectOption({
    required this.id,
    required this.subjectId,
    required this.subject,
    required this.subjectType,
    required this.classSection,
    this.teacher = '',
    this.apiLabel = '',
  });

  /// Label shown in the dropdown. Prefers the API label (web format); falls
  /// back to a composed `Class - Subject` when building locally (edit mode).
  String get label {
    if (apiLabel.isNotEmpty) return apiLabel;
    final parts = [classSection, subject].where((e) => e.isNotEmpty);
    return parts.isEmpty ? subject : parts.join(' - ');
  }

  /// Parsed from the `teacher/online-classes/subject-classes` API.
  factory OnlineClassSubjectOption.fromJson(Map<String, dynamic> json) {
    return OnlineClassSubjectOption(
      id: _toInt(json['id']),
      subjectId: _toInt(json['subject_id']),
      subject: json['subject']?.toString() ?? '',
      subjectType: json['subject_type']?.toString() ?? '',
      classSection: json['class_section']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      apiLabel: json['label']?.toString() ?? '',
    );
  }

  /// Builds an option from a [ClassSection] (parent) + one of its
  /// [SubjectTeacher] rows (used in edit mode where no API call is made).
  static OnlineClassSubjectOption fromClassSubjectTeacher(
    ClassSection classSection,
    SubjectTeacher subjectTeacher,
  ) {
    return OnlineClassSubjectOption(
      id: subjectTeacher.id ?? 0,
      subjectId: subjectTeacher.subjectId ?? 0,
      subject: subjectTeacher.subject?.name ?? '',
      subjectType: subjectTeacher.subject?.type ?? '',
      classSection: classSection.fullName ?? '',
    );
  }

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OnlineClassSubjectOption && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// A lightweight subject used by the list-screen subject filter (distinct by
/// `subject_id`). Derived client-side from the loaded online classes.
class OnlineClassFilterSubject {
  final int id;
  final String name;

  const OnlineClassFilterSubject({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OnlineClassFilterSubject && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
