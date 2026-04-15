import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/teacherAttendance.dart';
import 'package:eschool_saas_staff/data/models/teacherLeave.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class TeacherAttendanceRepository {
  Future<
      ({
        List<TeacherAttendance> attendance,
        List<Holiday> holidays,
        List<DateTime> weeklyOffDates,
        SessionYear sessionYear,
        double totalPresent,
        double totalAbsent,
        List<TeacherLeaveDetail> leaveDetails,
      })> getTeacherAttendance({
    required int month,
    required int year,
  }) async {
    try {
      final result = await Api.get(
        url: Api.getTeacherAttendance,
        useAuthToken: true,
        queryParameters: {
          "month": month,
          "year": year,
        },
      );

      final data = result['data'] as Map<String, dynamic>;

      // Parse weekly_off_dates from API response
      // The API returns dates in 'dd-MM-yyyy' format (e.g., "01-12-2025")
      List<DateTime> weeklyOffDates = [];
      if (data['weekly_off_dates'] != null) {
        final weeklyOffDatesList = data['weekly_off_dates'] as List;
        for (var dateString in weeklyOffDatesList) {
          try {
            // Parse date in 'dd-MM-yyyy' format
            final parsedDate =
                DateFormat('dd-MM-yyyy').parse(dateString.toString());
            weeklyOffDates.add(parsedDate);
          } catch (e) {
            // Skip invalid date formats
            debugPrint(
                'Failed to parse weekly off date: $dateString, error: $e');
          }
        }
      }

      // Parse total_present and total_absent from API
      // These can be double values (e.g., 2.5 for half-days)
      double totalPresent = 0.0;
      double totalAbsent = 0.0;
      if (data['total_present'] != null) {
        totalPresent = (data['total_present'] is int)
            ? (data['total_present'] as int).toDouble()
            : (data['total_present'] as num).toDouble();
      }
      if (data['total_absent'] != null) {
        totalAbsent = (data['total_absent'] is int)
            ? (data['total_absent'] as int).toDouble()
            : (data['total_absent'] as num).toDouble();
      }

      // Parse leaves and extract all leave_detail entries
      // Each leave_detail has a specific date and type (Full, First Half, Second Half)
      List<TeacherLeaveDetail> leaveDetails = [];
      if (data['leaves'] != null) {
        final leavesList = data['leaves'] as List;
        for (var leaveJson in leavesList) {
          final leave = TeacherLeave.fromJson(leaveJson);
          // Only include approved leaves (status = 1)
          if (leave.isApproved()) {
            leaveDetails.addAll(leave.leaveDetails);
          }
        }
      }

      return (
        attendance: (data['attendance'] as List)
            .map(
              (attendanceReport) =>
                  TeacherAttendance.fromJson(attendanceReport),
            )
            .toList(),
        holidays: (data['holidays'] as List)
            .map(
              (holiday) => Holiday.fromJson(holiday),
            )
            .toList(),
        weeklyOffDates: weeklyOffDates,
        sessionYear:
            SessionYear.fromJson(data['session_year'] as Map<String, dynamic>),
        totalPresent: totalPresent,
        totalAbsent: totalAbsent,
        leaveDetails: leaveDetails,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
