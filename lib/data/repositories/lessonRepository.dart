import 'package:eschool_saas_staff/data/models/lesson.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/foundation.dart';

class LessonRepository {
  Future<void> createLesson({
    required String lessonName,
    required List classSectionId,
    required int classSubjectId,
    required String lessonDescription,
    required List<Map<String, dynamic>> files,
  }) async {
    try {
      Map<String, dynamic> body = {
        "class_section_id": classSectionId,
        "class_subject_id": classSubjectId,
        "name": lessonName,
        "description": lessonDescription
      };

      if (files.isNotEmpty) {
        body['file'] = files;
      }

      await Api.post(body: body, url: Api.createLesson, useAuthToken: true);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Lesson>> getLessons({
    required int classSectionId,
    required int classSubjectId,
    int? page,
  }) async {
    try {
      final result = await Api.get(url: Api.getLessons, queryParameters: {
        "class_section_id": classSectionId,
        "class_subject_id": classSubjectId,
        "page": page ?? 1,
      });

      return ((result['data'] ?? []) as List)
          .map((lesson) => Lesson.fromJson(Map.from(lesson ?? {})))
          .toList();
    } catch (e, stk) {
      if (kDebugMode) {
        print(stk.toString());
      }
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteLesson({required int lessonId}) async {
    try {
      await Api.post(
        body: {"lesson_id": lessonId},
        url: Api.deleteLesson,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> updateLesson({
    required String lessonName,
    required int lessonId,
    required List<int> classSectionId,
    required int classSubjectId,
    required String lessonDescription,
    required List<Map<String, dynamic>> files,
  }) async {
    try {
      Map<String, dynamic> body = {
        "class_section_id": classSectionId,
        "class_subject_id": classSubjectId,
        "name": lessonName,
        "description": lessonDescription,
        "lesson_id": lessonId
      };

      if (files.isNotEmpty) {
        body['file'] = files;
      }

      await Api.post(
        body: body,
        url: Api.updateLesson,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
