import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/teacherAttendance.dart';
import 'package:eschool_saas_staff/data/models/teacherLeave.dart';
import 'package:eschool_saas_staff/data/repositories/teacherAttendanceRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TeacherAttendanceState {}

class TeacherAttendanceInitial extends TeacherAttendanceState {}

class TeacherAttendanceFetchInProgress extends TeacherAttendanceState {}

class TeacherAttendanceFetchSuccess extends TeacherAttendanceState {
  final List<TeacherAttendance> attendance;
  final List<Holiday> holidays;
  final List<DateTime> weeklyOffDates;
  final SessionYear sessionYear;
  final double totalPresent;
  final double totalAbsent;
  final List<TeacherLeaveDetail> leaveDetails;

  TeacherAttendanceFetchSuccess({
    required this.attendance,
    required this.holidays,
    required this.weeklyOffDates,
    required this.sessionYear,
    required this.totalPresent,
    required this.totalAbsent,
    required this.leaveDetails,
  });

  TeacherAttendanceFetchSuccess copyWith({
    List<TeacherAttendance>? attendance,
    List<Holiday>? holidays,
    List<DateTime>? weeklyOffDates,
    SessionYear? sessionYear,
    double? totalPresent,
    double? totalAbsent,
    List<TeacherLeaveDetail>? leaveDetails,
  }) {
    return TeacherAttendanceFetchSuccess(
      attendance: attendance ?? this.attendance,
      holidays: holidays ?? this.holidays,
      weeklyOffDates: weeklyOffDates ?? this.weeklyOffDates,
      sessionYear: sessionYear ?? this.sessionYear,
      totalPresent: totalPresent ?? this.totalPresent,
      totalAbsent: totalAbsent ?? this.totalAbsent,
      leaveDetails: leaveDetails ?? this.leaveDetails,
    );
  }
}

class TeacherAttendanceFetchFailure extends TeacherAttendanceState {
  final String errorMessage;

  TeacherAttendanceFetchFailure(this.errorMessage);
}

class TeacherAttendanceCubit extends Cubit<TeacherAttendanceState> {
  final TeacherAttendanceRepository _teacherAttendanceRepository =
      TeacherAttendanceRepository();

  TeacherAttendanceCubit() : super(TeacherAttendanceInitial());

  Future<void> fetchTeacherAttendance({
    required int month,
    required int year,
  }) async {
    emit(TeacherAttendanceFetchInProgress());
    try {
      final result = await _teacherAttendanceRepository.getTeacherAttendance(
        month: month,
        year: year,
      );

      emit(
        TeacherAttendanceFetchSuccess(
          attendance: result.attendance,
          holidays: result.holidays,
          weeklyOffDates: result.weeklyOffDates,
          sessionYear: result.sessionYear,
          totalPresent: result.totalPresent,
          totalAbsent: result.totalAbsent,
          leaveDetails: result.leaveDetails,
        ),
      );
    } catch (e) {
      emit(TeacherAttendanceFetchFailure(e.toString()));
    }
  }

  /// Get present days from attendance
  List<TeacherAttendance> getPresentDays() {
    if (state is TeacherAttendanceFetchSuccess) {
      return (state as TeacherAttendanceFetchSuccess)
          .attendance
          .where((attendance) => attendance.isPresent())
          .toList();
    }
    return [];
  }

  /// Get absent days from attendance
  List<TeacherAttendance> getAbsentDays() {
    if (state is TeacherAttendanceFetchSuccess) {
      return (state as TeacherAttendanceFetchSuccess)
          .attendance
          .where((attendance) => attendance.isAbsent())
          .toList();
    }
    return [];
  }

  /// Get holidays
  List<Holiday> getHolidays() {
    if (state is TeacherAttendanceFetchSuccess) {
      return (state as TeacherAttendanceFetchSuccess).holidays;
    }
    return [];
  }

  /// Get weekly off dates
  List<DateTime> getWeeklyOffDates() {
    if (state is TeacherAttendanceFetchSuccess) {
      return (state as TeacherAttendanceFetchSuccess).weeklyOffDates;
    }
    return [];
  }

  /// Get session year
  SessionYear? getSessionYear() {
    if (state is TeacherAttendanceFetchSuccess) {
      return (state as TeacherAttendanceFetchSuccess).sessionYear;
    }
    return null;
  }
}
