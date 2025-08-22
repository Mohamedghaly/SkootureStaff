import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ClassesWithTeacherDetailsState {}

class ClassesWithTeacherDetailsInitial extends ClassesWithTeacherDetailsState {}

class ClassesWithTeacherDetailsFetchInProgress
    extends ClassesWithTeacherDetailsState {}

class ClassesWithTeacherDetailsFetchSuccess
    extends ClassesWithTeacherDetailsState {
  final List<ClassSection> classes;

  ClassesWithTeacherDetailsFetchSuccess({required this.classes});
}

class ClassesWithTeacherDetailsFetchFailure
    extends ClassesWithTeacherDetailsState {
  final String errorMessage;

  ClassesWithTeacherDetailsFetchFailure(this.errorMessage);
}

class ClassesWithTeacherDetailsCubit
    extends Cubit<ClassesWithTeacherDetailsState> {
  final AcademicRepository _academicRepository = AcademicRepository();

  ClassesWithTeacherDetailsCubit() : super(ClassesWithTeacherDetailsInitial());

  void getClassesWithTeacherDetails() async {
    try {
      emit(ClassesWithTeacherDetailsFetchInProgress());
      emit(ClassesWithTeacherDetailsFetchSuccess(
          classes: await _academicRepository.getClassesWithTeacherDetails()));
    } catch (e) {
 
      emit(ClassesWithTeacherDetailsFetchFailure(e.toString()));
    }
  }
}
