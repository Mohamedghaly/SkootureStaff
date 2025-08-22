import 'package:eschool_saas_staff/data/repositories/attendanceRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubmitAttendanceState {}

class SubmitAttendanceInitial extends SubmitAttendanceState {}

class SubmitAttendanceInProgress extends SubmitAttendanceState {}

class SubmitAttendanceSuccess extends SubmitAttendanceState {}

class SubmitAttendanceFailure extends SubmitAttendanceState {
  final String errorMessage;

  SubmitAttendanceFailure(this.errorMessage);
}

class SubmitAttendanceCubit extends Cubit<SubmitAttendanceState> {
  final AttendanceRepository _teacherRepository = AttendanceRepository();

  SubmitAttendanceCubit() : super(SubmitAttendanceInitial());

  Future<void> submitAttendance({
    required DateTime dateTime,
    required int classSectionId,
    required List<({StudentAttendanceStatus status, int studentId})>
        attendanceReport,
    required bool sendAbsentNotification,
    required bool isHoliday,
  }) async {
    emit(SubmitAttendanceInProgress());
    try {
      await _teacherRepository.submitAttendance(
        isHoliday: isHoliday,
        sendAbsentNotification: sendAbsentNotification,
        classSectionId: classSectionId,
        date: "${dateTime.year}-${dateTime.month}-${dateTime.day}",
        attendance: attendanceReport
            .map(
              (attendanceReport) => {
                "student_id": attendanceReport.studentId,
                "type":
                    attendanceReport.status == StudentAttendanceStatus.present
                        ? 1
                        : 0
              },
            )
            .toList(),
      );
      emit(SubmitAttendanceSuccess());
    } catch (e) {
      emit(SubmitAttendanceFailure(e.toString()));
    }
  }
}
