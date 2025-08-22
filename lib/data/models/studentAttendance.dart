import 'package:eschool_saas_staff/data/models/studentDetails.dart';

class StudentAttendance {
  final int? id;
  final int? classSectionId;
  final int? studentId;
  final int? sessionYearId;
  final int? type; //0- Abesnt, 1- Present and 3-Holiday
  final String? date;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final StudentDetails? studentDetails;

  StudentAttendance(
      {this.id,
      this.classSectionId,
      this.studentId,
      this.sessionYearId,
      this.type,
      this.date,
      this.schoolId,
      this.createdAt,
      this.updatedAt,
      this.studentDetails});

  StudentAttendance copyWith({
    int? id,
    int? classSectionId,
    int? studentId,
    int? sessionYearId,
    int? type,
    String? date,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
    StudentDetails? studentDetails,
  }) {
    return StudentAttendance(
      studentDetails: studentDetails ?? this.studentDetails,
      id: id ?? this.id,
      classSectionId: classSectionId ?? this.classSectionId,
      studentId: studentId ?? this.studentId,
      sessionYearId: sessionYearId ?? this.sessionYearId,
      type: type ?? this.type,
    date: date ?? this.date,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory StudentAttendance.fromStudentDetails(
      {required StudentDetails studentDetails, int? type}) {
    return StudentAttendance(
      id: 0,
      schoolId: studentDetails.schoolId,
      classSectionId: studentDetails.student?.classSectionId,
      sessionYearId: studentDetails.student?.sessionYearId,
      type: type ??
          1, //default attendance on add attendance screen items is Present
      studentDetails: studentDetails,
    );
  }

  StudentAttendance.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        classSectionId = json['class_section_id'] as int?,
        studentId = json['student_id'] as int?,
        sessionYearId = json['session_year_id'] as int?,
        type = json['type'] as int?,
        date = json['date'] as String?,
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        studentDetails = StudentDetails.fromJson(Map.from(json['user'] ?? {})),
        updatedAt = json['updated_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'class_section_id': classSectionId,
        'student_id': studentId,
        'session_year_id': sessionYearId,
        'type': type,
        'date': date,
        'school_id': schoolId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'user': studentDetails?.toJson(),
      };

  bool isPresent() {
    return type == 1;
  }

  bool isHoliday() {
    return type == 3;
  }
}
