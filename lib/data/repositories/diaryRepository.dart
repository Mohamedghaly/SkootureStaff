import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/data/models/studentDiaryResponse.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

class DiaryRepository {
  Future<StudentDiaryResponse> getDiaries({
    int? studentId,
    int? page,
    int? classSectionId,
    int? sessionYearId,
    int? diaryCategoryId,
    int? subjectId,
    String? search,
    String? sort,
  }) async {
    try {
      final result = await Api.get(
        url: Api.getDiaries,
        useAuthToken: true,
        queryParameters: {
          if (studentId != null) 'student_id': studentId,
          if (page != null) 'page': page,
          if (classSectionId != null) 'class_section_id': classSectionId,
          if (sessionYearId != null) 'session_year_id': sessionYearId,
          if (diaryCategoryId != null) 'diary_category_id': diaryCategoryId,
          if (subjectId != null) 'subject_id': subjectId,
          if (search != null && search.isNotEmpty) 'search': search,
          if (sort != null && sort.isNotEmpty) 'sort': sort,
        },
      );

      return StudentDiaryResponse.fromJson(Map.from(result['data'] ?? {}));
    } catch (e, st) {
      debugPrint("This is the error: $e");
      debugPrint("This is the stack trace: $st");
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> createDiary({
    required int diaryCategoryId,
    required String date,
    required Map<int, int>
        studentClassSectionMap, // student_user_id -> class_section_id
    int? subjectId,
    String? title,
    String? description,
  }) async {
    try {
      // Convert the map to JSON string as required by the API
      final String studentClassSectionMapJson = jsonEncode(
          studentClassSectionMap
              .map((key, value) => MapEntry(key.toString(), value)));

      final result = await Api.post(
        url: Api.createDiary,
        useAuthToken: true,
        body: {
          "diary_category_id": diaryCategoryId.toString(),
          "date": date,
          "student_class_section_map": studentClassSectionMapJson,
          if (subjectId != null) "subject_id": subjectId.toString(),
          if (title != null && title.isNotEmpty) "title": title,
          if (description != null && description.isNotEmpty)
            "description": description,
        },
      );

      // The API returns success response with message
      if (result['error'] == true) {
        throw ApiException(result['message'] ?? 'Failed to create diary entry');
      }

      // Return the response data so we can extract the message
      return result;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteDiary({
    required int diaryId,
  }) async {
    try {
      await Api.post(
        url: Api.deleteDiary,
        useAuthToken: true,
        body: {
          "diary_id": diaryId,
        },
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
