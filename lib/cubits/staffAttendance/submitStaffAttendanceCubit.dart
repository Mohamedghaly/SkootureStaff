import 'package:eschool_saas_staff/data/models/staffAttendance.dart';
import 'package:eschool_saas_staff/data/repositories/staffAttendanceRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubmitStaffAttendanceState {}

class SubmitStaffAttendanceInitial extends SubmitStaffAttendanceState {}

class SubmitStaffAttendanceInProgress extends SubmitStaffAttendanceState {}

class SubmitStaffAttendanceSuccess extends SubmitStaffAttendanceState {}

class SubmitStaffAttendanceFailure extends SubmitStaffAttendanceState {
  final String errorMessage;

  SubmitStaffAttendanceFailure(this.errorMessage);
}

class SubmitStaffAttendanceCubit extends Cubit<SubmitStaffAttendanceState> {
  final StaffAttendanceRepository _repository = StaffAttendanceRepository();

  SubmitStaffAttendanceCubit() : super(SubmitStaffAttendanceInitial());

  Future<void> submitAttendance({
    required StaffAttendanceSubmissionPayload payload,
  }) async {
    emit(SubmitStaffAttendanceInProgress());
    try {
      await _repository.submitStaffAttendance(payload: payload);
      emit(SubmitStaffAttendanceSuccess());
    } catch (e) {
      emit(SubmitStaffAttendanceFailure(e.toString()));
    }
  }

  void resetState() {
    emit(SubmitStaffAttendanceInitial());
  }
}
