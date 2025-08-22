import 'package:eschool_saas_staff/data/models/announcementClass.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';

class Announcement {
  final int? id;
  final String? title;
  final String? description;
  final int? sessionYearId;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final List<StudyMaterial>? files;
  final List<AnnouncementClass>? announcementClasses;

  Announcement({
    this.id,
    this.announcementClasses,
    this.title,
    this.description,
    this.sessionYearId,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.files,
  });

  Announcement.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        announcementClasses = ((json['announcement_class'] ?? []) as List)
            .map((announcementClass) =>
                AnnouncementClass.fromJson(Map.from(announcementClass ?? {})))
            .toList(),
        title = json['title'] as String?,
        description = json['description'] as String?,
        sessionYearId = json['session_year_id'] as int?,
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        files = ((json['file'] ?? []) as List)
            .map((file) => StudyMaterial.fromJson(Map.from(file ?? {})))
            .toList(),
        updatedAt = json['updated_at'] as String?;
}
