import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/offlineExam.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:eschool_saas_staff/data/repositories/examRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class OfflineExamsWithClassesAndSessionYearsState {}

class OfflineExamsWithClassesAndSessionYearsInitial
    extends OfflineExamsWithClassesAndSessionYearsState {}

class OfflineExamsWithClassesAndSessionYearsFetchInProgress
    extends OfflineExamsWithClassesAndSessionYearsState {}

class OfflineExamsWithClassesAndSessionYearsFetchSuccess
    extends OfflineExamsWithClassesAndSessionYearsState {
  final List<SessionYear> sessionYears;
  final List<OfflineExam> offlineExams;
  final List<ClassSection> classes;
  final List<ClassSection> primaryClasses;

  OfflineExamsWithClassesAndSessionYearsFetchSuccess(
      {required this.classes,
      required this.primaryClasses,
      required this.offlineExams,
      required this.sessionYears});
}

class OfflineExamsWithClassesAndSessionYearsFetchFailure
    extends OfflineExamsWithClassesAndSessionYearsState {
  final String errorMessage;

  OfflineExamsWithClassesAndSessionYearsFetchFailure(this.errorMessage);
}

class OfflineExamsWithClassesAndSessionYearsCubit
    extends Cubit<OfflineExamsWithClassesAndSessionYearsState> {
  final ExamRepository _examRepository = ExamRepository();
  final AcademicRepository _academicRepository = AcademicRepository();

  OfflineExamsWithClassesAndSessionYearsCubit()
      : super(OfflineExamsWithClassesAndSessionYearsInitial());

  ///[ 0- Upcoming, 1-On Going, 2-Completed, 3-All Details]
  void getOfflineExamsWithSessionYearsAndClasses({int? sesstionYearId}) async {
    try {
      List<ClassSection> classes = List<ClassSection>.of([]);

      List<ClassSection> primaryClasses = List<ClassSection>.of([]);
      List<SessionYear> sessionYears = List<SessionYear>.of([]);

      if (state is OfflineExamsWithClassesAndSessionYearsFetchSuccess) {
        classes = (state as OfflineExamsWithClassesAndSessionYearsFetchSuccess)
            .classes;
        sessionYears =
            (state as OfflineExamsWithClassesAndSessionYearsFetchSuccess)
                .sessionYears;
        primaryClasses =
            (state as OfflineExamsWithClassesAndSessionYearsFetchSuccess)
                .primaryClasses;
      }

      emit(OfflineExamsWithClassesAndSessionYearsFetchInProgress());

      if (classes.isEmpty && primaryClasses.isEmpty) {
        final classesResult = await _academicRepository.getClasses();

        classes = classesResult.classes;
        primaryClasses = classesResult.primaryClasses;
      }

      emit(OfflineExamsWithClassesAndSessionYearsFetchSuccess(
          primaryClasses: primaryClasses,
          classes: classes,
          offlineExams: await _examRepository.getOfflineExams(
              status: 2, sessionYearId: sesstionYearId),
          sessionYears: sessionYears.isEmpty
              ? await _academicRepository.getSessionYears()
              : sessionYears));
    } catch (e) {
      emit(OfflineExamsWithClassesAndSessionYearsFetchFailure(e.toString()));
    }
  }

  List<ClassSection> getAllClasses() {
    if (state is OfflineExamsWithClassesAndSessionYearsFetchSuccess) {
      List<ClassSection> classes = List<ClassSection>.from(
          (state as OfflineExamsWithClassesAndSessionYearsFetchSuccess)
              .classes);
      classes.addAll(List<ClassSection>.from(
          (state as OfflineExamsWithClassesAndSessionYearsFetchSuccess)
              .primaryClasses));
      return classes;
    }
    return [];
  }
}
