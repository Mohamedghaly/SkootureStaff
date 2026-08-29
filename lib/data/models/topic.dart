import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';

// Represents the nested `lesson` object returned inside each topic
class TopicLesson {
  late final int id;
  late final String name;
  late final String description;
  late final int schoolId;
  late final String createdAt;
  late final String updatedAt;

  TopicLesson.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
    description = json['description'] ?? "";
    schoolId = json['school_id'] ?? 0;
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
  }
}

// Represents one entry in `lesson_topic_class[]` — a class section assigned to the topic
class LessonTopicClass {
  late final int id;
  late final int lessonTopicId;
  late final int classSectionId;
  late final int schoolId;
  late final String createdAt;
  late final String updatedAt;
  late final ClassSection? classSection;

  LessonTopicClass.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    lessonTopicId = json['lesson_topic_id'] ?? 0;
    classSectionId = json['class_section_id'] ?? 0;
    schoolId = json['school_id'] ?? 0;
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
    classSection = json['class_section'] != null
        ? ClassSection.fromJson(Map.from(json['class_section']))
        : null;
  }
}

class Topic {
  Topic({
    required this.id,
    required this.name,
    required this.lessonId,
    required this.description,
  });

  late final int id;
  late final String name;
  late final int lessonId;
  late final String description;
  late final int schoolId;
  late final String createdAt;
  late final String updatedAt;
  late final List<StudyMaterial> studyMaterials;
  late final TopicLesson? lesson;
  late final List<LessonTopicClass> lessonTopicClasses;

  Topic.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
    lessonId = json['lesson_id'] ?? 0;
    description = json['description'] ?? "";
    schoolId = json['school_id'] ?? 0;
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";

    studyMaterials = ((json['file'] ?? []) as List)
        .map((file) => StudyMaterial.fromJson(Map.from(file)))
        .toList();

    lesson = json['lesson'] != null
        ? TopicLesson.fromJson(Map.from(json['lesson']))
        : null;

    lessonTopicClasses = ((json['lesson_topic_class'] ?? []) as List)
        .map((e) => LessonTopicClass.fromJson(Map.from(e)))
        .toList();
  }
}
