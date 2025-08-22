import 'package:eschool_saas_staff/data/models/exam.dart';
import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/foundation.dart';

class StudentRepository {
  Future<List<StudentDetails>> getStudentsByClassSectionAndSubject({
    required int classSectionId,
    required int? classSubjectId,
    required int? examId,
    StudentListStatus? status,
    String? search,
  }) async {
    try {
      ///[0 - view all, 1 - Active, 2 - Inactive]
      int studentViewStatus = 0;
      if (status != null) {
        if (status == StudentListStatus.active) {
          studentViewStatus = 1;
        } else if (status == StudentListStatus.inactive) {
          studentViewStatus = 2;
        }
      }
      final result = await Api.get(
        url: Api.getStudents,
        useAuthToken: true,
        queryParameters: {
          "paginate": 0,
          "status": studentViewStatus,
          "class_section_id": classSectionId,
          if (search != null) "search": search,
          if (classSubjectId != null) "class_subject_id": classSubjectId,
          if (examId != null) "exam_id": examId
        },
      );

      return (result['data'] as List).map((e) {
        return StudentDetails.fromJson(Map.from(e));
      }).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<({List<StudentDetails> students, int currentPage, int totalPage})>
      getStudents(
          {required int classSectionId,
          int? page,
          int? sessionYearId,
          String? search}) async {
    try {
      final result = await Api.get(url: Api.getStudents, queryParameters: {
        "class_section_id": classSectionId,
        "page": page ?? 1,
        "session_year_id": sessionYearId,
        "search": search,
      });

      return (
        students: ((result['data']['data'] ?? []) as List)
            .map((studentDetails) =>
                StudentDetails.fromJson(Map.from(studentDetails ?? {})))
            .toList(),
        currentPage: (result['data']['current_page'] as int),
        totalPage: (result['data']['last_page'] as int),
      );
    } catch (e, stk) {
      if (kDebugMode) {
        print(stk.toString());
      }
      throw ApiException(e.toString());
    }
  }

  Future<
          ({
            List<StudentAttendance> studentAttendances,
            int currentPage,
            int totalPage
          })>
      getStudentAttendance(
          {required int classSectionId,
          required String date,
          int? status,
          int? page}) async {
    try {
      final result = await Api.get(
          url: Api.getStudentAttendanceForStaff,
          queryParameters: {
            "class_section_id": classSectionId,
            "page": page ?? 1,
            "date": date,
            "status": status
          });

      return (
        studentAttendances: ((result['data']['data'] ?? []) as List)
            .map((studentAttendance) =>
                StudentAttendance.fromJson(Map.from(studentAttendance ?? {})))
            .toList(),
        currentPage: (result['data']['current_page'] as int),
        totalPage: (result['data']['last_page'] as int),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Exam>> fetchExamsList(
      {required int examStatus,
      int? studentID,
      int? publishStatus,
      int? classSectionId}) async {
    try {
      var queryParameter = {
        'status': examStatus,
        if (studentID != null) 'student_id': studentID,
      };
      if (classSectionId != null) {
        queryParameter["class_section_id"] = classSectionId;
      }
      if (publishStatus != null) queryParameter['publish'] = publishStatus;

      final result = await Api.get(
        url: Api.examList,
        useAuthToken: true,
        queryParameters: queryParameter,
      );

      return (result['data'] as List)
          .map((e) => Exam.fromExamJson(Map.from(e)))
          .toList();
    } catch (e, st) {
      print("This is main error $st");
      throw ApiException(e.toString());
    }
  }

  Future<void> addOfflineExamMarks({
    required int examId,
    required int classSubjectId,
    required Map<String, dynamic> marksDataValue,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {
        "exam_id": examId,
        "class_subject_id": classSubjectId,
      };
      await Api.post(
        body: marksDataValue,
        url: Api.submitExamMarks,
        useAuthToken: true,
        queryParameters: queryParameters,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
