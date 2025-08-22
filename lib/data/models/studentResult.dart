import 'package:eschool_saas_staff/data/models/studentDetails.dart';

class StudentResult {
  final int? id;
  final int? examId;
  final int? classSectionId;
  final int? studentId;
  final double? totalMarks;
  final double? obtainedMarks;
  final double? percentage;
  final String? grade;
  final int? status;
  final int? sessionYearId;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final StudentDetails? studentDetails;

  StudentResult({
    this.id,
    this.examId,
    this.classSectionId,
    this.studentId,
    this.totalMarks,
    this.obtainedMarks,
    this.percentage,
    this.grade,
    this.status,
    this.sessionYearId,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.studentDetails,
  });

  StudentResult copyWith({
    int? id,
    int? examId,
    int? classSectionId,
    int? studentId,
    double? totalMarks,
    double? obtainedMarks,
    double? percentage,
    String? grade,
    int? status,
    int? sessionYearId,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
  }) {
    return StudentResult(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      classSectionId: classSectionId ?? this.classSectionId,
      studentId: studentId ?? this.studentId,
      totalMarks: totalMarks ?? this.totalMarks,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      percentage: percentage ?? this.percentage,
      grade: grade ?? this.grade,
      status: status ?? this.status,
      sessionYearId: sessionYearId ?? this.sessionYearId,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  StudentResult.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        examId = json['exam_id'] as int?,
        classSectionId = json['class_section_id'] as int?,
        studentId = json['student_id'] as int?,
        totalMarks = double.parse((json['total_marks'] ?? 0).toString()),
        obtainedMarks = double.parse((json['obtained_marks'] ?? 0).toString()),
        percentage = double.parse((json['percentage'] ?? 0).toString()),
        grade = json['grade'] as String?,
        status = json['status'] as int?,
        sessionYearId = json['session_year_id'] as int?,
        studentDetails = StudentDetails.fromJson(Map.from(json['user'] ?? {})),
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'exam_id': examId,
        'class_section_id': classSectionId,
        'student_id': studentId,
        'total_marks': totalMarks,
        'obtained_marks': obtainedMarks,
        'percentage': percentage,
        'grade': grade,
        'status': status,
        'session_year_id': sessionYearId,
        'school_id': schoolId,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
}
