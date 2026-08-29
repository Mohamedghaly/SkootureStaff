import 'package:eschool_saas_staff/data/models/onlineClass/onlineClass.dart';
import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassPeriod.dart';
import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassSubjectOption.dart';
import 'package:eschool_saas_staff/utils/api.dart';

/// Repository for the Online Class feature.
///
/// The create form mirrors the web admin panel:
/// - `teacher/online-classes/subject-classes` → the combined "Subject & Class"
///   options (subject-teachers that have a timetable).
/// - `teacher/online-classes/periods`         → the periods for the chosen
///   subject (separate call, made after the subject is selected).
///
/// The list reuses `teacher/teacher_timetable` (rows that have a meeting link).
/// Writes hit the dedicated online-class endpoints.
class OnlineClassRepository {
  /// The teacher's online classes — every timetable row that has a meeting
  /// link configured. Status is derived inside [OnlineClass.fromJson].
  ///
  /// `type=online_class` asks the API for online-class rows only; the
  /// [OnlineClass.isOnlineClass] filter stays as a safety net for servers
  /// that don't support the parameter yet.
  Future<List<OnlineClass>> getOnlineClasses() async {
    try {
      final result = await Api.get(
        url: Api.getTeacherMyTimetable,
        queryParameters: {'type': 'online_class'},
      );
      final rows = (result['data'] ?? []) as List;
      return rows
          .map((row) => OnlineClass.fromJson(Map<String, dynamic>.from(row)))
          .where((onlineClass) => onlineClass.isOnlineClass)
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// The combined "Subject & Class" options for the create form's dropdown,
  /// mirroring the web admin panel (subject-teachers that have a timetable,
  /// labelled "Subject - Type — Class — Teacher").
  Future<List<OnlineClassSubjectOption>> getSubjectOptions() async {
    try {
      final result = await Api.get(url: Api.getOnlineClassSubjects);
      return ((result['data'] ?? []) as List)
          .map((e) =>
              OnlineClassSubjectOption.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// The existing timetable periods for the selected subject-teacher, loaded
  /// via the dedicated periods endpoint — a separate call made after the
  /// subject is chosen, exactly like the web.
  Future<List<OnlineClassPeriod>> getPeriods({
    required int subjectTeacherId,
  }) async {
    try {
      final result = await Api.get(
        url: Api.getOnlineClassPeriods,
        queryParameters: {'subject_teacher_id': subjectTeacherId},
      );
      return ((result['data'] ?? []) as List)
          .map((e) => OnlineClassPeriod.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Creates an online class by attaching the configuration to the selected
  /// period(s). Dates must be `dd-MM-yyyy`; they are sent for the recurring
  /// repeat types only — `No Repeat` is scheduled on the period's own slot by
  /// the backend, so both dates are omitted.
  Future<void> createOnlineClass({
    required int subjectTeacherId,
    required String repeat,
    String? startDate,
    String? endDate,
    required String meetingLink,
    required List<int> periodIds,
    String? note,
  }) async {
    try {
      final body = <String, dynamic>{
        'subject_teacher_id': subjectTeacherId.toString(),
        'repeat': repeat,
        'meeting_link': meetingLink,
        'period_ids': periodIds.map((id) => id.toString()).toList(),
      };
      if (startDate != null) body['start_date'] = startDate;
      if (endDate != null) body['end_date'] = endDate;
      if (note != null && note.isNotEmpty) body['note'] = note;

      await Api.post(url: Api.createOnlineClass, body: body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Updates a single online-class row's schedule fields. Dates follow the
  /// same rule as create: omitted for `No Repeat`.
  Future<void> updateOnlineClass({
    required int id,
    required String repeat,
    String? startDate,
    String? endDate,
    required String meetingLink,
    String? note,
  }) async {
    try {
      final body = <String, dynamic>{
        'id': id.toString(),
        'repeat': repeat,
        'meeting_link': meetingLink,
      };
      if (startDate != null) body['start_date'] = startDate;
      if (endDate != null) body['end_date'] = endDate;
      if (note != null) body['note'] = note;

      await Api.post(url: Api.updateOnlineClass, body: body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Clears the online-class fields on the given timetable row.
  Future<void> deleteOnlineClass({required int id}) async {
    try {
      await Api.post(
        url: Api.deleteOnlineClass,
        body: {'id': id.toString()},
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
