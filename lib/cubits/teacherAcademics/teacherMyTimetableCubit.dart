import 'package:eschool_saas_staff/data/models/timeTableSlot.dart';
import 'package:eschool_saas_staff/data/repositories/teacherAcademicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TeacherMyTimetableState {}

class TeacherMyTimetableInitial extends TeacherMyTimetableState {}

class TeacherMyTimetableFetchInProgress extends TeacherMyTimetableState {}

class TeacherMyTimetableFetchSuccess extends TeacherMyTimetableState {
  final List<TimeTableSlot> timeTableSlots;

  TeacherMyTimetableFetchSuccess({required this.timeTableSlots});
}

class TeacherMyTimetableFetchFailure extends TeacherMyTimetableState {
  final String errorMessage;

  TeacherMyTimetableFetchFailure(this.errorMessage);
}

class TeacherMyTimetableCubit extends Cubit<TeacherMyTimetableState> {
  final TeacherAcademicsRepository _teacherAcademicsRepository =
      TeacherAcademicsRepository();

  TeacherMyTimetableCubit() : super(TeacherMyTimetableInitial());

  void getTeacherMyTimetable({bool isRefresh = false}) async {
    if (state is TeacherMyTimetableFetchSuccess && !isRefresh) {
      return;
    }
    try {
      emit(TeacherMyTimetableFetchInProgress());
      emit(TeacherMyTimetableFetchSuccess(
          timeTableSlots:
              await _teacherAcademicsRepository.getTeacherMyTimetable()));
    } catch (e) {
      emit(TeacherMyTimetableFetchFailure(e.toString()));
    }
  }
}
