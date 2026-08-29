import 'package:eschool_saas_staff/data/models/staffAttendance.dart';
import 'package:eschool_saas_staff/data/repositories/staffAttendanceRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StaffAttendanceState {}

class StaffAttendanceInitial extends StaffAttendanceState {}

class StaffAttendanceFetchInProgress extends StaffAttendanceState {}

class StaffAttendanceFetchSuccess extends StaffAttendanceState {
  final StaffAttendanceResponse attendanceResponse;

  StaffAttendanceFetchSuccess({required this.attendanceResponse});

  List<StaffAttendanceRecord> get records => attendanceResponse.rows ?? [];
}

class StaffAttendanceFetchFailure extends StaffAttendanceState {
  final String errorMessage;

  StaffAttendanceFetchFailure(this.errorMessage);
}

class StaffAttendanceCubit extends Cubit<StaffAttendanceState> {
  final StaffAttendanceRepository _repository = StaffAttendanceRepository();

  StaffAttendanceCubit() : super(StaffAttendanceInitial());

  Future<void> fetchStaffAttendance({
    required String date,
    int? classSectionId,
    String? search,
  }) async {
    emit(StaffAttendanceFetchInProgress());
    try {
      final response = await _repository.getStaffAttendance(
        date: date,
        classSectionId: classSectionId,
        search: search,
      );
      emit(StaffAttendanceFetchSuccess(attendanceResponse: response));
    } catch (e) {
      emit(StaffAttendanceFetchFailure(e.toString()));
    }
  }

  List<StaffAttendanceRecord> getAttendanceRecords() {
    if (state is StaffAttendanceFetchSuccess) {
      return (state as StaffAttendanceFetchSuccess).records;
    }
    return [];
  }
}
