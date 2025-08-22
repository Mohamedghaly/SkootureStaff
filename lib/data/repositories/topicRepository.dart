import 'package:eschool_saas_staff/data/models/topic.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class TopicRepository {
  Future<List<Topic>> fetchTopics({required int lessonId}) async {
    try {
      final result = await Api.get(
        url: Api.getTopics,
        useAuthToken: true,
        queryParameters: {"lesson_id": lessonId},
      );

      return (result['data'] as List)
          .map((topic) => Topic.fromJson(Map.from(topic)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteTopic({required int topicId}) async {
    try {
      await Api.post(
        url: Api.deleteTopic,
        useAuthToken: true,
        body: {"topic_id": topicId},
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> createTopic({
    required String topicName,
    required List classSectionId,
    required int subjectId,
    required String topicDescription,
    required int lessonId,
    required List<Map<String, dynamic>> files,
  }) async {
    try {
      Map<String, dynamic> body = {
        "class_section_id": classSectionId,
        "class_subject_id": subjectId,
        "name": topicName,
        "description": topicDescription,
        "lesson_id": lessonId
      };

      if (files.isNotEmpty) {
        body['file'] = files;
      }

      await Api.post(url: Api.createTopic, useAuthToken: true, body: body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> editTopic({
    required String topicName,
    required List classSectionId,
    required int subjectId,
    required String topicDescription,
    required int lessonId,
    required int topicId,
    required List<Map<String, dynamic>> files,
  }) async {
    try {
      Map<String, dynamic> body = {
        "class_section_id": classSectionId,
        "class_subject_id": subjectId,
        "name": topicName,
        "topic_id": topicId,
        "description": topicDescription,
        "lesson_id": lessonId
      };

      if (files.isNotEmpty) {
        body['file'] = files;
      }

      await Api.post(url: Api.updateTopic, useAuthToken: true, body: body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
