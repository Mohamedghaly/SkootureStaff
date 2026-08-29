import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassEnums.dart';
import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassUtils.dart';

/// One online class = one academic timetable Lecture row that has been
/// configured with online-class fields.
///
/// Parsed from a `teacher/teacher_timetable` row. A row is considered an online
/// class only when [meetingLink] is set ([isOnlineClass]).
class OnlineClass {
  /// Timetable row id (used for update / delete).
  final int id;
  final int subjectTeacherId;
  final int subjectId;

  /// Class-section full name, e.g. `9 - B English`.
  final String classSection;

  /// Subject name, e.g. `Network Security`.
  final String subject;
  final String subjectType;

  /// Weekday, e.g. `Monday`.
  final String day;

  /// Display times, e.g. `9:00 AM`.
  final String startTime;
  final String endTime;

  final OnlineClassRepeatType repeat;
  final String meetingLink;
  final String note;
  final DateTime? startDate;
  final DateTime? endDate;
  final OnlineClassStatus status;

  const OnlineClass({
    required this.id,
    this.subjectTeacherId = 0,
    this.subjectId = 0,
    this.classSection = '',
    this.subject = '',
    this.subjectType = '',
    this.day = '',
    this.startTime = '',
    this.endTime = '',
    this.repeat = OnlineClassRepeatType.noRepeat,
    this.meetingLink = '',
    this.note = '',
    this.startDate,
    this.endDate,
    this.status = OnlineClassStatus.upcoming,
  });

  /// Title shown on the card / sheets, e.g. `9 - B English - Network Security`.
  String get title {
    final composed = [classSection, subject].where((e) => e.isNotEmpty);
    return composed.join(' - ');
  }

  /// Combined time range, e.g. `9:00 AM to 9:30 AM`.
  String get timeRange =>
      (startTime.isEmpty && endTime.isEmpty) ? '' : '$startTime to $endTime';

  /// A timetable row only represents an online class once it has a link.
  bool get isOnlineClass => meetingLink.isNotEmpty;

  factory OnlineClass.fromJson(Map<String, dynamic> json) {
    final classSectionJson = json['class_section'];
    final subjectJson = json['subject'];

    final startTimeRaw = json['start_time']?.toString() ?? '';
    final endTimeRaw = json['end_time']?.toString() ?? '';
    final repeat = OnlineClassRepeatType.fromString(json['repeat'] as String?);
    final day = json['day']?.toString() ?? '';
    final startDate = OnlineClassUtils.parseDate(json['start_date']);
    final endDate = OnlineClassUtils.parseDate(json['end_date']);

    return OnlineClass(
      id: _toInt(json['id']),
      subjectTeacherId: _toInt(json['subject_teacher_id']),
      subjectId: _toInt(json['subject_id']),
      classSection: classSectionJson is Map
          ? (classSectionJson['full_name']?.toString() ?? '')
          : '',
      subject:
          subjectJson is Map ? (subjectJson['name']?.toString() ?? '') : '',
      subjectType:
          subjectJson is Map ? (subjectJson['type']?.toString() ?? '') : '',
      day: day,
      startTime: OnlineClassUtils.formatTime(startTimeRaw),
      endTime: OnlineClassUtils.formatTime(endTimeRaw),
      repeat: repeat,
      meetingLink: json['meeting_link']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      startDate: startDate,
      endDate: endDate,
      status: OnlineClassUtils.deriveStatus(
        startDate: startDate,
        endDate: endDate,
        repeat: repeat,
        day: day,
        startTimeRaw: startTimeRaw,
        endTimeRaw: endTimeRaw,
      ),
    );
  }

  OnlineClass copyWith({
    int? id,
    int? subjectTeacherId,
    int? subjectId,
    String? classSection,
    String? subject,
    String? subjectType,
    String? day,
    String? startTime,
    String? endTime,
    OnlineClassRepeatType? repeat,
    String? meetingLink,
    String? note,
    DateTime? startDate,
    DateTime? endDate,
    OnlineClassStatus? status,
  }) {
    return OnlineClass(
      id: id ?? this.id,
      subjectTeacherId: subjectTeacherId ?? this.subjectTeacherId,
      subjectId: subjectId ?? this.subjectId,
      classSection: classSection ?? this.classSection,
      subject: subject ?? this.subject,
      subjectType: subjectType ?? this.subjectType,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      repeat: repeat ?? this.repeat,
      meetingLink: meetingLink ?? this.meetingLink,
      note: note ?? this.note,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
