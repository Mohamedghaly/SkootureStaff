import 'package:eschool_saas_staff/data/models/streamDetails.dart';

class ClassDetails {
  final int? id;
  final String? name;
  final int? includeSemesters;
  final int? mediumId;
  final int? shiftId;
  final int? streamId;
  final int? schoolId;
  final String? fullName;
  final StreamDetails? stream;
  final String? semesterName;

  ClassDetails({
    this.id,
    this.semesterName,
    this.name,
    this.includeSemesters,
    this.mediumId,
    this.shiftId,
    this.streamId,
    this.schoolId,
    this.fullName,
    this.stream,
  });

  ClassDetails copyWith(
      {int? id,
      String? name,
      int? includeSemesters,
      int? mediumId,
      int? shiftId,
      int? streamId,
      int? schoolId,
      String? fullName,
      StreamDetails? stream,
      String? semesterName}) {
    return ClassDetails(
      id: id ?? this.id,
      semesterName: semesterName ?? this.semesterName,
      name: name ?? this.name,
      includeSemesters: includeSemesters ?? this.includeSemesters,
      mediumId: mediumId ?? this.mediumId,
      shiftId: shiftId ?? this.shiftId,
      streamId: streamId ?? this.streamId,
      schoolId: schoolId ?? this.schoolId,
      fullName: fullName ?? this.fullName,
      stream: stream ?? this.stream,
    );
  }

  ClassDetails.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        includeSemesters = json['include_semesters'] as int?,
        mediumId = json['medium_id'] as int?,
        shiftId = json['shift_id'] as int?,
        streamId = json['stream_id'] as int?,
        schoolId = json['school_id'] as int?,
        semesterName = json['semester_name'] as String?,
        stream = StreamDetails.fromJson(Map.from(json['stream'] ?? {})),
        fullName = json['full_name'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'include_semesters': includeSemesters,
        'medium_id': mediumId,
        'shift_id': shiftId,
        'stream_id': streamId,
        'school_id': schoolId,
        'full_name': fullName,
        'semester_name': semesterName,
        'stream': stream?.toJson(),
      };
}
