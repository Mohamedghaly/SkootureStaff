import 'package:eschool_saas_staff/data/models/timeTableSlot.dart';
import 'package:eschool_saas_staff/data/repositories/teacherRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TimeTableOfTeacherState {}

class TimeTableOfTeacherInitial extends TimeTableOfTeacherState {}

class TimeTableOfTeacherFetchInProgress extends TimeTableOfTeacherState {}

class TimeTableOfTeacherFetchSuccess extends TimeTableOfTeacherState {
  final List<TimeTableSlot> timeTableSlots;

  TimeTableOfTeacherFetchSuccess({required this.timeTableSlots});
}

class TimeTableOfTeacherFetchFailure extends TimeTableOfTeacherState {
  final String errorMessage;

  TimeTableOfTeacherFetchFailure(this.errorMessage);
}

class TimeTableOfTeacherCubit extends Cubit<TimeTableOfTeacherState> {
  final TeacherRepository _teacherRepository = TeacherRepository();

  TimeTableOfTeacherCubit() : super(TimeTableOfTeacherInitial());

  void getTimeTableOfTeacher({required int teacherId}) async {
    try {
      emit(TimeTableOfTeacherFetchInProgress());
      emit(TimeTableOfTeacherFetchSuccess(
          timeTableSlots: await _teacherRepository.getTimeTableOfTeacher(
              teacherId: teacherId)));
    } catch (e) {
      emit(TimeTableOfTeacherFetchFailure(e.toString()));
    }
  }
}
