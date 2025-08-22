import 'package:eschool_saas_staff/data/models/offlineExam.dart';
import 'package:eschool_saas_staff/data/models/studentResult.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/foundation.dart';

class ExamRepository {
  ///[ 0- Upcoming, 1-On Going, 2-Completed, 3-All Details]
  Future<List<OfflineExam>> getOfflineExams(
      {int? sessionYearId, int? mediumId, int? status}) async {
    try {
      final result = await Api.get(url: Api.getExams, queryParameters: {
        "session_year_id": sessionYearId,
        "status": status,
        "medium_id": mediumId
      });

      return ((result['data'] ?? []) as List)
          .map((offlineExam) =>
              OfflineExam.fromJson(Map.from(offlineExam ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<({List<StudentResult> results, int currentPage, int totalPage})>
      getOfflineExamStudentResults(
          {required int sessionYearId,
          required int classSectionId,
          required int examId,
          int? page}) async {
    try {
      final result = await Api.get(
          url: Api.getOfflineExamStudentResults,
          queryParameters: {
            "page": page ?? 1,
            "session_year_id": sessionYearId,
            "class_section_id": classSectionId,
            "exam_id": examId
          });

      return (
        results: ((result['data']['data'] ?? []) as List)
            .map((studentResult) =>
                StudentResult.fromJson(Map.from(studentResult ?? {})))
            .toList(),
        totalPage: (result['data']['last_page'] as int),
        currentPage: (result['data']['current_page'] as int),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<String> downloadResult(
      {required int examId, required int studentId}) async {
    try {
      final result = await Api.get(
          url: Api.downloadStudentResult,
          useAuthToken: true,
          queryParameters: {"exam_id": examId, "student_id": studentId});

      return result['pdf'] ?? "";
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw ApiException(e.toString());
    }
  }
}
