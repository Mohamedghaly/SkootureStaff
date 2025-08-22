import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/data/repositories/attendanceRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceFetchInProgress extends AttendanceState {}

class AttendanceFetchSuccess extends AttendanceState {
  final List<StudentAttendance> attendance;
  final bool isHoliday;
  final Holiday holidayDetails;

  AttendanceFetchSuccess({
    required this.attendance,
    required this.isHoliday,
    required this.holidayDetails,
  });
}

class AttendanceFetchFailure extends AttendanceState {
  final String errorMessage;

  AttendanceFetchFailure(this.errorMessage);
}

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _attendanceRepository = AttendanceRepository();

  AttendanceCubit() : super(AttendanceInitial());

  Future<void> fetchAttendance({
    required int classSectionId,
    required DateTime date,
    required int? type,
  }) async {
    emit(AttendanceFetchInProgress());
    try {
      final result = await _attendanceRepository.getAttendance(
        classSectionId: classSectionId,
        date: "${date.year}-${date.month}-${date.day}",
        type: type,
      );

      emit(
        AttendanceFetchSuccess(
          attendance: result.attendance,
          isHoliday: result.isHoliday,
          holidayDetails: result.holidayDetails,
        ),
      );
    } catch (e) {
      emit(AttendanceFetchFailure(e.toString()));
    }
  }
}
