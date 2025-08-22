import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ClassesAndSessionYearsState {}

class ClassesAndSessionYearsInitial extends ClassesAndSessionYearsState {}

class ClassesAndSessionYearsFetchInProgress
    extends ClassesAndSessionYearsState {}

class ClassesAndSessionYearsFetchSuccess extends ClassesAndSessionYearsState {
  final List<ClassSection> classSections;
  final List<SessionYear> sessionYears;
  final List<ClassSection> primaryClassSections;

  ClassesAndSessionYearsFetchSuccess(
      {required this.classSections,
      required this.sessionYears,
      required this.primaryClassSections});
}

class ClassesAndSessionYearsFetchFailure extends ClassesAndSessionYearsState {
  final String errorMessage;

  ClassesAndSessionYearsFetchFailure(this.errorMessage);
}

class ClassesAndSessionYearsCubit extends Cubit<ClassesAndSessionYearsState> {
  final AcademicRepository _academicRepository = AcademicRepository();

  ClassesAndSessionYearsCubit() : super(ClassesAndSessionYearsInitial());

  void getClassesAndSessionYears() async {
    try {
      emit(ClassesAndSessionYearsFetchInProgress());
      final result = await _academicRepository.getClasses();
      emit(ClassesAndSessionYearsFetchSuccess(
          classSections: result.classes,
          primaryClassSections: result.primaryClasses,
          sessionYears: await _academicRepository.getSessionYears()));
    } catch (e) {
      emit(ClassesAndSessionYearsFetchFailure(e.toString()));
    }
  }

  List<ClassSection> getClasses() {
    if (state is ClassesAndSessionYearsFetchSuccess) {
      List<ClassSection> classes = List<ClassSection>.from(
          (state as ClassesAndSessionYearsFetchSuccess).classSections);
      classes.addAll(List<ClassSection>.from(
          (state as ClassesAndSessionYearsFetchSuccess).primaryClassSections));
      return classes;
    }
    return [];
  }
}
