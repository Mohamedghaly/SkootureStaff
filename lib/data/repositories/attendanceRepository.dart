import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class AttendanceRepository {
  Future<
      ({
        List<StudentAttendance> attendance,
        bool isHoliday,
        Holiday holidayDetails
      })> getAttendance({
    required int classSectionId,
    required int? type,
    required String date,
  }) async {
    try {
      final result = await Api.get(
        url: Api.getAttendance,
        useAuthToken: true,
        queryParameters: {
          "class_section_id": classSectionId,
          "date": date,
          if (type != null) "type": type
        },
      );

      return (
        attendance: (result['data'] as List)
            .map(
              (attendanceReport) =>
                  StudentAttendance.fromJson(attendanceReport),
            )
            .toList(),
        isHoliday: result['is_holiday'] as bool,
        holidayDetails: Holiday.fromJson(
          Map.from(result['holiday'] == null
              ? {}
              : (result['holiday'] as List).firstOrNull ?? {}),
        )
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> submitAttendance({
    required int classSectionId,
    required String date,
    required List<Map<String, dynamic>> attendance,
    required bool isHoliday,
    required bool sendAbsentNotification,
  }) async {
    try {
      await Api.post(
        url: Api.submitAttendance,
        useAuthToken: true,
        body: {
          "class_section_id": classSectionId,
          "date": date,
          "attendance": attendance,
          "absent_notification": sendAbsentNotification ? 1 : 0,
          "holiday": isHoliday ? 1 : 0,
        },
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
