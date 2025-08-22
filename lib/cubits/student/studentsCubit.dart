import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/data/repositories/studentRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StudentsState {}

class StudentsInitial extends StudentsState {}

class StudentsFetchInProgress extends StudentsState {}

class StudentsFetchSuccess extends StudentsState {
  final int totalPage;
  final int currentPage;
  final List<StudentDetails> students;
  final bool fetchMoreError;
  final bool fetchMoreInProgress;

  StudentsFetchSuccess(
      {required this.currentPage,
      required this.students,
      required this.fetchMoreError,
      required this.fetchMoreInProgress,
      required this.totalPage});

  StudentsFetchSuccess copyWith(
      {int? currentPage,
      bool? fetchMoreError,
      bool? fetchMoreInProgress,
      int? totalPage,
      List<StudentDetails>? students}) {
    return StudentsFetchSuccess(
        currentPage: currentPage ?? this.currentPage,
        students: students ?? this.students,
        fetchMoreError: fetchMoreError ?? this.fetchMoreError,
        fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
        totalPage: totalPage ?? this.totalPage);
  }
}

class StudentsFetchFailure extends StudentsState {
  final String errorMessage;

  StudentsFetchFailure(this.errorMessage);
}

class StudentsCubit extends Cubit<StudentsState> {
  final StudentRepository _studentRepository = StudentRepository();

  StudentsCubit() : super(StudentsInitial());

  void getStudents(
      {required int classSectionId, int? sessionYearId, String? search}) async {
    emit(StudentsFetchInProgress());
    try {
      final result = await _studentRepository.getStudents(
          classSectionId: classSectionId,
          search: search,
          sessionYearId: sessionYearId);
      emit(StudentsFetchSuccess(
          currentPage: result.currentPage,
          students: result.students,
          fetchMoreError: false,
          fetchMoreInProgress: false,
          totalPage: result.totalPage));
    } catch (e) {
      emit(StudentsFetchFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is StudentsFetchSuccess) {
      return (state as StudentsFetchSuccess).currentPage <
          (state as StudentsFetchSuccess).totalPage;
    }
    return false;
  }

  void fetchMore(
      {required int classSectionId, int? sessionYearId, String? search}) async {
    //
    if (state is StudentsFetchSuccess) {
      if ((state as StudentsFetchSuccess).fetchMoreInProgress) {
        return;
      }
      try {
        emit((state as StudentsFetchSuccess)
            .copyWith(fetchMoreInProgress: true));

        final result = await _studentRepository.getStudents(
            classSectionId: classSectionId,
            search: search,
            sessionYearId: sessionYearId,
            page: (state as StudentsFetchSuccess).currentPage + 1);

        final currentState = (state as StudentsFetchSuccess);
        List<StudentDetails> students = currentState.students;

        students.addAll(result.students);

        emit(StudentsFetchSuccess(
            currentPage: result.currentPage,
            fetchMoreError: false,
            fetchMoreInProgress: false,
            totalPage: result.totalPage,
            students: students));
      } catch (e) {
        emit((state as StudentsFetchSuccess)
            .copyWith(fetchMoreInProgress: false, fetchMoreError: true));
      }
    }
  }
}
