import 'package:eschool_saas_staff/data/models/diary.dart';

class DiaryStudent {
  final int id;
  final int diaryId;
  final int studentId;
  final int classSectionId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final Diary diary;

  DiaryStudent({
    required this.id,
    required this.diaryId,
    required this.studentId,
    required this.classSectionId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.diary,
  });

  DiaryStudent.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        diaryId = json['diary_id'] as int,
        studentId = json['student_id'] as int,
        classSectionId = json['class_section_id'] as int,
        createdAt = json['created_at'] as String,
        updatedAt = json['updated_at'] as String,
        deletedAt = json['deleted_at'] as String?,
        diary = Diary.fromJson(Map.from(json['diary'] ?? {}));

  Map<String, dynamic> toJson() => {
        'id': id,
        'diary_id': diaryId,
        'student_id': studentId,
        'class_section_id': classSectionId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'diary': diary.toJson(),
      };
}
