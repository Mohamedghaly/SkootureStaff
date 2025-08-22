import 'package:eschool_saas_staff/data/models/studyMaterial.dart';

class Lesson {
  Lesson({
    required this.id,
    required this.name,
    required this.description,
    required this.classSectionId,
    required this.subjectId,
    required this.studyMaterials,
    required this.topicsCount,
  });
  late final int id;
  late final List<StudyMaterial> studyMaterials;
  late final String name;
  late final String description;
  late final int classSectionId;
  late final int subjectId;
  late final int topicsCount;

  Lesson.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
    topicsCount = json['topic_count'] ?? 0;
    description = json['description'] ?? "";
    classSectionId = json['class_section_id'] ?? 0;
    subjectId = json['subject_id'] ?? 0;
    studyMaterials = ((json['file'] ?? []) as List)
        .map((file) => StudyMaterial.fromJson(Map.from(file)))
        .toList();
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(covariant Lesson other) {
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
