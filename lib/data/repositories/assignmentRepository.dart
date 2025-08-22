import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/assignment.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:file_picker/file_picker.dart';

class AssignmentRepository {
  Future<({List<Assignment> assignments, int currentPage, int totalPage})>
      fetchAssignment({
    required int classSectionId,
    required int classSubjectId,
    int? page,
  }) async {
    try {
      final result = await Api.get(
        url: Api.getAssignment,
        useAuthToken: true,
        queryParameters: {
          "class_section_id": classSectionId,
          "class_subject_id": classSubjectId,
          "page": page ?? 0,
        },
      );

      return (
        assignments: ((result['data']['data'] ?? []) as List)
            .map((e) => Assignment.fromJson(e))
            .toList(),
        currentPage: (result["data"]["current_page"] as int),
        totalPage: (result["data"]["last_page"] as int)
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteAssignment({
    required int assignmentId,
  }) async {
    try {
      final body = {"assignment_id": assignmentId};

      await Api.post(
        url: Api.deleteAssignment,
        useAuthToken: true,
        body: body,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> editAssignment({
    required int assignmentId,
    required List<int> classSelectionId,
    required int classSubjectId,
    required String name,
    required String dateTime,
    required String instruction,
    required int points,
    required int resubmission,
    required int extraDayForResubmission,
    List<PlatformFile>? filePaths,
    required String url,
  }) async {
    try {
      List<MultipartFile> files = [];
      for (var filePath in filePaths!) {
        files.add(await MultipartFile.fromFile(filePath.path!));
      }

      var body = {
        "class_section_id": classSelectionId,
        "assignment_id": assignmentId,
        "class_subject_id": classSubjectId,
        "name": name,
        "instructions": instruction,
        "due_date": dateTime,
        "points": points,
        "resubmission": resubmission,
        "extra_days_for_resubmission": extraDayForResubmission,
        "file": files,
        "add_url": url
      };
      if (instruction.isEmpty) {
        body.remove("instructions");
      }
      if (points == 0) {
        body.remove("points");
      }
      if (filePaths.isEmpty) {
        body.remove("file");
      }
      if (resubmission == 0) {
        body.remove("extra_days_for_resubmission");
      }
      if (url.isEmpty) {
        body.remove("add_url");
      }
      await Api.post(
        body: body,
        url: Api.uploadAssignment,
        useAuthToken: true,
      );
    } catch (e) {
      ApiException(e.toString());
    }
  }

  Future<void> createAssignment(
      {required List<int> classSectionId,
      required int classSubjectId,
      required String name,
      required String instruction,
      required String dateTime,
      required int points,
      required bool resubmission,
      required int extraDayForResubmission,
      required List<PlatformFile>? filePaths,
      required String url}) async {
    try {
      List<MultipartFile> files = [];
      for (var filePath in filePaths!) {
        files.add(await MultipartFile.fromFile(filePath.path!));
      }
      var body = {
        "class_section_id": classSectionId,
        "class_subject_id": classSubjectId,
        "name": name,
        "instructions": instruction,
        "due_date": dateTime,
        "points": points,
        "resubmission": resubmission ? 1 : 0,
        "extra_days_for_resubmission": extraDayForResubmission,
        "file": files,
        "add_url": url
      };
      if (instruction.isEmpty) {
        body.remove("instructions");
      }
      if (points == 0) {
        body.remove("points");
      }
      if (filePaths.isEmpty) {
        body.remove("file");
      }
      if (resubmission == false) {
        body.remove("extra_days_for_resubmission");
      }

      await Api.post(
        url: Api.createAssignment,
        body: body,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
