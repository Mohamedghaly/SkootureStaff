import 'package:eschool_saas_staff/data/models/diaryCategory.dart';
import 'package:eschool_saas_staff/data/models/subject.dart';

class Diary {
  final int id;
  final int diaryCategoryId;
  final int userId;
  final int? subjectId;
  final int sessionYearId;
  final String? description;
  final String date;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final DiaryCategory diaryCategory;
  final Subject? subject;

  Diary({
    required this.id,
    required this.diaryCategoryId,
    required this.userId,
    this.subjectId,
    required this.sessionYearId,
    this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.diaryCategory,
    this.subject,
  });

  Diary.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        diaryCategoryId = json['diary_category_id'] as int,
        userId = json['user_id'] as int,
        subjectId = json['subject_id'] as int?,
        sessionYearId = json['session_year_id'] as int,
        description = json['description'] as String?,
        date = json['date'] as String,
        createdAt = json['created_at'] as String,
        updatedAt = json['updated_at'] as String,
        deletedAt = json['deleted_at'] as String?,
        diaryCategory =
            DiaryCategory.fromJson(Map.from(json['diary_category'] ?? {})),
        subject = json['subject'] != null
            ? Subject.fromJson(Map.from(json['subject']))
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'diary_category_id': diaryCategoryId,
        'user_id': userId,
        'subject_id': subjectId,
        'session_year_id': sessionYearId,
        'description': description,
        'date': date,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'diary_category': diaryCategory.toJson(),
        'subject': subject?.toJson(),
      };
}
