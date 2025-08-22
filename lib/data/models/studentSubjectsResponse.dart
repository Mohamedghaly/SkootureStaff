import 'package:eschool_saas_staff/data/models/subject.dart';

class StudentSubjectsResponse {
  final List<CoreSubject> coreSubjects;
  final List<ElectiveSubject> electiveSubjects;

  StudentSubjectsResponse({
    required this.coreSubjects,
    required this.electiveSubjects,
  });

  StudentSubjectsResponse.fromJson(Map<String, dynamic> json)
      : coreSubjects = ((json['core_subject'] ?? []) as List)
            .map((subject) => CoreSubject.fromJson(Map.from(subject)))
            .toList(),
        electiveSubjects = ((json['elective_subject'] ?? []) as List)
            .map((subject) => ElectiveSubject.fromJson(Map.from(subject)))
            .toList();

  Map<String, dynamic> toJson() => {
        'core_subject': coreSubjects.map((e) => e.toJson()).toList(),
        'elective_subject': electiveSubjects.map((e) => e.toJson()).toList(),
      };

  // Get all subjects (core + elective) as a flat list
  List<Subject> getAllSubjects() {
    List<Subject> allSubjects = [];

    // Add core subjects
    for (var coreSubject in coreSubjects) {
      allSubjects.add(coreSubject.subject);
    }

    // Add elective subjects
    for (var electiveSubject in electiveSubjects) {
      allSubjects.add(electiveSubject.classSubject.subject);
    }

    return allSubjects;
  }

  // Get unique subject names for filtering
  List<String> getSubjectNames() {
    Set<String> subjectNames = {};

    for (var coreSubject in coreSubjects) {
      subjectNames.add(coreSubject.subject.name ?? '');
    }

    for (var electiveSubject in electiveSubjects) {
      subjectNames.add(electiveSubject.classSubject.subject.name ?? '');
    }

    return subjectNames.where((name) => name.isNotEmpty).toList();
  }
}

class CoreSubject {
  final int id;
  final String name;
  final String code;
  final String bgColor;
  final String image;
  final int mediumId;
  final String type;
  final int schoolId;
  final String? deletedAt;
  final int classSubjectId;
  final String nameWithType;
  final Pivot pivot;

  CoreSubject({
    required this.id,
    required this.name,
    required this.code,
    required this.bgColor,
    required this.image,
    required this.mediumId,
    required this.type,
    required this.schoolId,
    this.deletedAt,
    required this.classSubjectId,
    required this.nameWithType,
    required this.pivot,
  });

  CoreSubject.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        code = json['code'] as String,
        bgColor = json['bg_color'] as String,
        image = json['image'] as String,
        mediumId = json['medium_id'] as int,
        type = json['type'] as String,
        schoolId = json['school_id'] as int,
        deletedAt = json['deleted_at'] as String?,
        classSubjectId = json['class_subject_id'] as int,
        nameWithType = json['name_with_type'] as String,
        pivot = Pivot.fromJson(Map.from(json['pivot'] ?? {}));

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'bg_color': bgColor,
        'image': image,
        'medium_id': mediumId,
        'type': type,
        'school_id': schoolId,
        'deleted_at': deletedAt,
        'class_subject_id': classSubjectId,
        'name_with_type': nameWithType,
        'pivot': pivot.toJson(),
      };

  // Convert to Subject model for consistency
  Subject get subject => Subject(
        id: id,
        name: name,
        code: code,
        bgColor: bgColor,
        image: image,
        mediumId: mediumId,
        type: type,
        schoolId: schoolId,
        deletedAt: deletedAt,
        nameWithType: nameWithType,
      );
}

class ElectiveSubject {
  final int classSubjectId;
  final ClassSubject classSubject;

  ElectiveSubject({
    required this.classSubjectId,
    required this.classSubject,
  });

  ElectiveSubject.fromJson(Map<String, dynamic> json)
      : classSubjectId = json['class_subject_id'] as int,
        classSubject =
            ClassSubject.fromJson(Map.from(json['class_subject'] ?? {}));

  Map<String, dynamic> toJson() => {
        'class_subject_id': classSubjectId,
        'class_subject': classSubject.toJson(),
      };
}

class ClassSubject {
  final int id;
  final int classId;
  final int subjectId;
  final String type;
  final int electiveSubjectGroupId;
  final int? semesterId;
  final int virtualSemesterId;
  final int schoolId;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  final String subjectWithName;
  final Subject subject;

  ClassSubject({
    required this.id,
    required this.classId,
    required this.subjectId,
    required this.type,
    required this.electiveSubjectGroupId,
    this.semesterId,
    required this.virtualSemesterId,
    required this.schoolId,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.subjectWithName,
    required this.subject,
  });

  ClassSubject.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        classId = json['class_id'] as int,
        subjectId = json['subject_id'] as int,
        type = json['type'] as String,
        electiveSubjectGroupId = json['elective_subject_group_id'] as int,
        semesterId = json['semester_id'] as int?,
        virtualSemesterId = json['virtual_semester_id'] as int,
        schoolId = json['school_id'] as int,
        deletedAt = json['deleted_at'] as String?,
        createdAt = json['created_at'] as String,
        updatedAt = json['updated_at'] as String,
        subjectWithName = json['subject_with_name'] as String,
        subject = Subject.fromJson(Map.from(json['subject'] ?? {}));

  Map<String, dynamic> toJson() => {
        'id': id,
        'class_id': classId,
        'subject_id': subjectId,
        'type': type,
        'elective_subject_group_id': electiveSubjectGroupId,
        'semester_id': semesterId,
        'virtual_semester_id': virtualSemesterId,
        'school_id': schoolId,
        'deleted_at': deletedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'subject_with_name': subjectWithName,
        'subject': subject.toJson(),
      };
}

class Pivot {
  final int classId;
  final int subjectId;
  final int? semesterId;

  Pivot({
    required this.classId,
    required this.subjectId,
    this.semesterId,
  });

  Pivot.fromJson(Map<String, dynamic> json)
      : classId = json['class_id'] as int,
        subjectId = json['subject_id'] as int,
        semesterId = json['semester_id'] as int?;

  Map<String, dynamic> toJson() => {
        'class_id': classId,
        'subject_id': subjectId,
        'semester_id': semesterId,
      };
}
