import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/data/repositories/studentRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StudentAttendanceForStaffState {}

class StudentAttendanceForStaffInitial extends StudentAttendanceForStaffState {}

class StudentAttendanceForStaffFetchInProgress
    extends StudentAttendanceForStaffState {}

class StudentAttendanceForStaffFetchSuccess
    extends StudentAttendanceForStaffState {
  final int totalPage;
  final int currentPage;
  final List<StudentAttendance> studentAttendances;

  final bool fetchMoreError;
  final bool fetchMoreInProgress;
  final bool isholiday;

  StudentAttendanceForStaffFetchSuccess({
    required this.currentPage,
    required this.studentAttendances,
    required this.fetchMoreError,
    required this.fetchMoreInProgress,
    required this.totalPage,
    required this.isholiday,
  });

  StudentAttendanceForStaffFetchSuccess copyWith({
    int? currentPage,
    bool? fetchMoreError,
    bool? fetchMoreInProgress,
    int? totalPage,
    List<StudentAttendance>? studentAttendances,
    bool? isholiday,
  }) {
    return StudentAttendanceForStaffFetchSuccess(
      currentPage: currentPage ?? this.currentPage,
      studentAttendances: studentAttendances ?? this.studentAttendances,
      fetchMoreError: fetchMoreError ?? this.fetchMoreError,
      fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
      totalPage: totalPage ?? this.totalPage,
      isholiday: isholiday ?? this.isholiday,
    );
  }
}

class StudentAttendanceForStaffFetchFailure
    extends StudentAttendanceForStaffState {
  final String errorMessage;

  StudentAttendanceForStaffFetchFailure(this.errorMessage);
}

class StudentAttendanceForStaffCubit
    extends Cubit<StudentAttendanceForStaffState> {
  final StudentRepository _studentRepository = StudentRepository();

  StudentAttendanceForStaffCubit() : super(StudentAttendanceForStaffInitial());

  void getStudentAttendance({
    required int classSectionId,
    required DateTime date,
    int? status,
  }) async {
    emit(StudentAttendanceForStaffFetchInProgress());
    try {
      final result = await _studentRepository.getStudentAttendance(
        classSectionId: classSectionId,
        date: "${date.year}-${date.month}-${date.day}",
        status: status,
      );

      final bool isHoliday =
          result.studentAttendances.any((attendance) => attendance.isHoliday());

      emit(StudentAttendanceForStaffFetchSuccess(
        currentPage: result.currentPage,
        studentAttendances: result.studentAttendances,
        fetchMoreError: false,
        fetchMoreInProgress: false,
        totalPage: result.totalPage,
        isholiday: isHoliday,
      ));
    } catch (e) {
      emit(StudentAttendanceForStaffFetchFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is StudentAttendanceForStaffFetchSuccess) {
      return (state as StudentAttendanceForStaffFetchSuccess).currentPage <
          (state as StudentAttendanceForStaffFetchSuccess).totalPage;
    }
    return false;
  }

  void fetchMore({
    required int classSectionId,
    required DateTime date,
    int? status,
  }) async {
    if (state is StudentAttendanceForStaffFetchSuccess) {
      if ((state as StudentAttendanceForStaffFetchSuccess)
          .fetchMoreInProgress) {
        return;
      }
      try {
        emit((state as StudentAttendanceForStaffFetchSuccess)
            .copyWith(fetchMoreInProgress: true));

        final result = await _studentRepository.getStudentAttendance(
          classSectionId: classSectionId,
          date: "${date.year}-${date.month}-${date.day}",
          status: status,
          page:
              (state as StudentAttendanceForStaffFetchSuccess).currentPage + 1,
        );

        final currentState = (state as StudentAttendanceForStaffFetchSuccess);
        List<StudentAttendance> studentAttendances =
            currentState.studentAttendances;

        studentAttendances.addAll(result.studentAttendances);

        // Recalculate isHoliday
        final bool isHoliday =
            studentAttendances.any((attendance) => attendance.isHoliday());

        emit(StudentAttendanceForStaffFetchSuccess(
          currentPage: result.currentPage,
          fetchMoreError: false,
          fetchMoreInProgress: false,
          totalPage: result.totalPage,
          studentAttendances: studentAttendances,
          isholiday: isHoliday, // Update holiday status
        ));
      } catch (e) {
        emit((state as StudentAttendanceForStaffFetchSuccess).copyWith(
          fetchMoreInProgress: false,
          fetchMoreError: true,
        ));
      }
    }
  }
}
