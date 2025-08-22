import 'package:eschool_saas_staff/data/models/studentSubjectsResponse.dart';
import 'package:eschool_saas_staff/data/models/subject.dart';
import 'package:eschool_saas_staff/data/repositories/studentSubjectsRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StudentSubjectsState {}

class StudentSubjectsInitial extends StudentSubjectsState {}

class StudentSubjectsFetchInProgress extends StudentSubjectsState {}

class StudentSubjectsFetchSuccess extends StudentSubjectsState {
  final StudentSubjectsResponse studentSubjects;

  StudentSubjectsFetchSuccess({required this.studentSubjects});
}

class StudentSubjectsFetchFailure extends StudentSubjectsState {
  final String errorMessage;

  StudentSubjectsFetchFailure(this.errorMessage);
}

class StudentSubjectsCubit extends Cubit<StudentSubjectsState> {
  final StudentSubjectsRepository _studentSubjectsRepository =
      StudentSubjectsRepository();

  StudentSubjectsCubit() : super(StudentSubjectsInitial());

  void getStudentSubjects() async {
    try {
      emit(StudentSubjectsFetchInProgress());

      final studentSubjects =
          await _studentSubjectsRepository.getStudentSubjects();

      emit(StudentSubjectsFetchSuccess(studentSubjects: studentSubjects));
    } catch (e) {
      emit(StudentSubjectsFetchFailure(e.toString()));
    }
  }

  // Get all subject names for filtering
  List<String> getSubjectNames() {
    if (state is StudentSubjectsFetchSuccess) {
      return (state as StudentSubjectsFetchSuccess)
          .studentSubjects
          .getSubjectNames();
    }
    return [];
  }

  // Get all subjects as a flat list
  List<Subject> getAllSubjects() {
    if (state is StudentSubjectsFetchSuccess) {
      return (state as StudentSubjectsFetchSuccess)
          .studentSubjects
          .getAllSubjects();
    }
    return [];
  }
}
