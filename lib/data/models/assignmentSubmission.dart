import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/subject.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class AssignmentSubmission {
  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.sessionYearId,
    required this.feedback,
    required this.points,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.assignment,
    required this.student,
    required this.file,
  });
  late final int id;
  late final int assignmentId;
  late final int studentId;
  late final int sessionYearId;
  late final String feedback;
  late final int points;
  late final int status;
  late final String createdAt;
  late final String updatedAt;
  late final ReviewAssignment assignment;
  late final ReviewAssignmentStudent student;
  late final List<StudyMaterial> file;

  AssignmentSubmissionStatus get submissionStatus =>
      Utils.getAssignmentSubmissionStatusFromTypeId(typeId: status);

  AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    assignmentId = json['assignment_id'] ?? 0;
    studentId = json['student_id'] ?? 0;
    sessionYearId = json['session_year_id'] ?? 0;
    feedback = json['feedback'] ?? "";
    points = json['points'] ?? 0;
    status = json['status'] ?? 0;
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
    assignment = ReviewAssignment.fromJson(json['assignment'] ?? {});
    student = ReviewAssignmentStudent.fromJson(json['student'] ?? {});
    file = List.from(json['file'] ?? [])
        .map((e) => StudyMaterial.fromJson(e))
        .toList();
  }

  AssignmentSubmission copyWith({
    int? status,
    String? feedback,
    int? points,
    int? id,
  }) {
    return AssignmentSubmission(
      id: id ?? this.id,
      assignmentId: assignmentId,
      studentId: studentId,
      sessionYearId: sessionYearId,
      feedback: feedback ?? this.feedback,
      points: points ?? this.points,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      assignment: assignment,
      student: student,
      file: file,
    );
  }
}

class ReviewAssignment {
  ReviewAssignment({
    required this.id,
    required this.classSectionId,
    required this.classSubjectId,
    required this.name,
    required this.instructions,
    required this.dueDate,
    required this.points,
    required this.resubmission,
    required this.extraDaysForResubmission,
    required this.sessionYearId,
    required this.createdAt,
    required this.subject,
  });
  late final int id;
  late final int classSectionId;
  late final int classSubjectId;
  late final String name;
  late final String instructions;
  late final String dueDate;
  late final int points;
  late final int resubmission;
  late final int extraDaysForResubmission;
  late final int sessionYearId;
  late final String createdAt;
  late final Subject subject;

  ReviewAssignment.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    classSectionId = json['class_section_id'] ?? 0;
    classSubjectId = json['class_subject_id'] ?? 0;
    name = json['name'] ?? "";
    instructions = json['instructions'] ?? "";
    dueDate = json['due_date'] ?? "";
    points = json['points'] ?? 0;
    resubmission = json['resubmission'] ?? 0;
    extraDaysForResubmission = json['extra_days_for_resubmission'] ?? 0;
    sessionYearId = json['session_year_id'] ?? 0;
    createdAt = json['created_at'] ?? "";
    subject = Subject.fromJson(
        json['class_subject']?['subject'] ?? {});
  }
}


class ReviewAssignmentStudent {
  ReviewAssignmentStudent({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.image,
  });
  late final int id;
  late final int userId;
  late final String firstName;
  late final String lastName;
  late final String image;

  String get fullName => "$firstName $lastName";

  ReviewAssignmentStudent.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    userId = json['user_id'] ?? 0;
    firstName = json['first_name'] ?? "";
    lastName = json['last_name'] ?? "";
    image = json['image'] ?? "";
  }
}

///[Assignment submission status converter for application]
enum AssignmentSubmissionFilters {
  all,
  submitted,
  resubmitted,
  accepted,
  rejected,
}

class AssignmentSubmissionStatus {
  //0 - Submitted
  //1 - Accepted
  //2 - Rejected
  //3 - Resubmitted
  final int typeStatusId;
  final String titleKey;
  final AssignmentSubmissionFilters filter;
  final Color color;

  AssignmentSubmissionStatus(
      {required this.typeStatusId,
      required this.titleKey,
      required this.filter,
      required this.color});

  @override
  String toString() {
    return titleKey;
  }

  @override
  bool operator ==(covariant AssignmentSubmissionStatus other) {
    return other.typeStatusId == typeStatusId;
  }

  @override
  int get hashCode {
    return typeStatusId.hashCode;
  }
}
