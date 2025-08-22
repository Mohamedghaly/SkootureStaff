import 'package:eschool_saas_staff/data/models/classTimetableSlot.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ClassTimetableState {}

class ClassTimetableInitial extends ClassTimetableState {}

class ClassTimetableFetchInProgress extends ClassTimetableState {}

class ClassTimetableFetchSuccess extends ClassTimetableState {
  final List<ClassTimeTableSlot> classTimetableSlots;

  ClassTimetableFetchSuccess({required this.classTimetableSlots});
}

class ClassTimetableFetchFailure extends ClassTimetableState {
  final String errorMessage;

  ClassTimetableFetchFailure(this.errorMessage);
}

class ClassTimetableCubit extends Cubit<ClassTimetableState> {
  final AcademicRepository _academicRepository = AcademicRepository();

  ClassTimetableCubit() : super(ClassTimetableInitial());

  void getClassTimetable({required int classSectionId}) async {
    try {
      emit(ClassTimetableFetchInProgress());
      emit(ClassTimetableFetchSuccess(
          classTimetableSlots: await _academicRepository.getClassTimetable(
              classSectionId: classSectionId)));
    } catch (e) {
      emit(ClassTimetableFetchFailure(e.toString()));
    }
  }
}
