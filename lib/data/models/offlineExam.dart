import 'package:eschool_saas_staff/data/models/offlineExamTimetableSlot.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';

class OfflineExam {
  final int? id;
  final String? name;
  final String? description;
  final int? publish;
  final String? sessionYear;
  final String? examStartingDate;
  final String? examEndingDate;
  final String? examStatus;
  final String? className;
  final List<OfflineExamTimeTableSlot>? timetableSlots;

  OfflineExam({
    this.id,
    this.name,
    this.description,
    this.publish,
    this.sessionYear,
    this.examStartingDate,
    this.examEndingDate,
    this.examStatus,
    this.className,
    this.timetableSlots,
  });

  OfflineExam copyWith(
      {int? id,
      String? name,
      String? description,
      int? publish,
      String? sessionYear,
      String? examStartingDate,
      String? examEndingDate,
      String? examStatus,
      String? className,
      List<OfflineExamTimeTableSlot>? timetableSlots}) {
    return OfflineExam(
      id: id ?? this.id,
      name: name ?? this.name,
      timetableSlots: timetableSlots ?? this.timetableSlots,
      description: description ?? this.description,
      publish: publish ?? this.publish,
      sessionYear: sessionYear ?? this.sessionYear,
      examStartingDate: examStartingDate ?? this.examStartingDate,
      examEndingDate: examEndingDate ?? this.examEndingDate,
      examStatus: examStatus ?? this.examStatus,
      className: className ?? this.className,
    );
  }

  OfflineExam.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        description = json['description'] as String?,
        publish = json['publish'] as int?,
        sessionYear = json['session_year'] as String?,
        examStartingDate = json['exam_starting_date'] as String?,
        examEndingDate = json['exam_ending_date'] as String?,
        timetableSlots = ((json['timetable'] ?? []) as List)
            .map((timetableSlot) => OfflineExamTimeTableSlot.fromJson(
                Map.from(timetableSlot ?? {})))
            .toList(),
        className = json['class_name'] as String?,
        examStatus = json['exam_status'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'publish': publish,
        'session_year': sessionYear,
        'exam_starting_date': examStartingDate,
        'exam_ending_date': examEndingDate,
        'exam_status': examStatus,
        'class_name': className,
        'timetable': timetableSlots
            ?.map((timetableSlot) => timetableSlot.toJson())
            .toList()
      };

  String getOfflineStatusKey() {
    ///[Exam status]
// 0 - Upcoming
// 1 - On Going
// 2 - Completed

    if ((examStartingDate ?? "").isEmpty) {
      return upcomingKey;
    }
    if (examStatus == "0") {
      return upcomingKey;
    }
    if (examStatus == "1") {
      return onGoingKey;
    }
    if (examStatus == "2") {
      return completedKey;
    }

    return upcomingKey;
  }

  @override
  bool operator ==(covariant OfflineExam other) {
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return (name ?? "");
  }
}
