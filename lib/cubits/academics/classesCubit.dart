import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ClassesState {}

class ClassesInitial extends ClassesState {}

class ClassesFetchInProgress extends ClassesState {}

class ClassesFetchSuccess extends ClassesState {
  final List<ClassSection> classes;
  final List<ClassSection> primaryClasses;

  ClassesFetchSuccess({required this.classes, required this.primaryClasses});
}

class ClassesFetchFailure extends ClassesState {
  final String errorMessage;

  ClassesFetchFailure(this.errorMessage);
}

class ClassesCubit extends Cubit<ClassesState> {
  final AcademicRepository _academicRepository = AcademicRepository();

  ClassesCubit() : super(ClassesInitial());

  void getClasses() async {
    try {
      emit(ClassesFetchInProgress());
      final result = await _academicRepository.getClasses();
      emit(ClassesFetchSuccess(
          classes: result.classes, primaryClasses: result.primaryClasses));
    } catch (e) {
      emit(ClassesFetchFailure(e.toString()));
    }
  }

  List<ClassSection> getAllClasses() {
    if (state is ClassesFetchSuccess) {
      List<ClassSection> classes =
          List<ClassSection>.from((state as ClassesFetchSuccess).classes);
      classes.addAll(List<ClassSection>.from(
          (state as ClassesFetchSuccess).primaryClasses));
      return classes;
    }
    return [];
  }
}
