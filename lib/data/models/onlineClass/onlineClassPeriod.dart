import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassUtils.dart';

/// A single timetable period (one weekday row) an online class can attach to.
///
/// Built from a `teacher/teacher_timetable` row, filtered by
/// `subject_teacher_id`. [id] is the timetable row id, sent back as
/// `period_ids[]` on create.
class OnlineClassPeriod {
  final int id;

  /// Weekday, e.g. `Monday`.
  final String day;

  /// Display start time, e.g. `9:00 AM`.
  final String startTime;

  /// Display end time, e.g. `9:30 AM`.
  final String endTime;

  /// Whether this period already has an online class configured (shows the
  /// "configured" link badge, like the web).
  final bool hasLink;

  const OnlineClassPeriod({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.hasLink = false,
  });

  /// Combined range, e.g. `9:00 AM to 9:30 AM`.
  String get timeRange => '$startTime to $endTime';

  factory OnlineClassPeriod.fromJson(Map<String, dynamic> json) {
    return OnlineClassPeriod(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      day: json['day']?.toString() ?? '',
      startTime: OnlineClassUtils.formatTime(json['start_time']?.toString() ?? ''),
      endTime: OnlineClassUtils.formatTime(json['end_time']?.toString() ?? ''),
      hasLink: json['has_link'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OnlineClassPeriod && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
