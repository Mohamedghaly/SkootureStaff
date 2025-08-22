import 'package:eschool_saas_staff/data/models/studentResult.dart';
import 'package:eschool_saas_staff/data/repositories/examRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class OfflineExamStudentResultsState {}

class OfflineExamStudentResultsInitial extends OfflineExamStudentResultsState {}

class OfflineExamStudentResultsFetchInProgress
    extends OfflineExamStudentResultsState {}

class OfflineExamStudentResultsFetchSuccess
    extends OfflineExamStudentResultsState {
  final int totalPage;
  final int currentPage;
  final List<StudentResult> studentResults;

  final bool fetchMoreError;
  final bool fetchMoreInProgress;

  OfflineExamStudentResultsFetchSuccess(
      {required this.currentPage,
      required this.studentResults,
      required this.fetchMoreError,
      required this.fetchMoreInProgress,
      required this.totalPage});

  OfflineExamStudentResultsFetchSuccess copyWith(
      {int? currentPage,
      bool? fetchMoreError,
      bool? fetchMoreInProgress,
      int? totalPage,
      List<StudentResult>? studentResults}) {
    return OfflineExamStudentResultsFetchSuccess(
        currentPage: currentPage ?? this.currentPage,
        studentResults: studentResults ?? this.studentResults,
        fetchMoreError: fetchMoreError ?? this.fetchMoreError,
        fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
        totalPage: totalPage ?? this.totalPage);
  }
}

class OfflineExamStudentResultsFetchFailure
    extends OfflineExamStudentResultsState {
  final String errorMessage;

  OfflineExamStudentResultsFetchFailure(this.errorMessage);
}

class OfflineExamStudentResultsCubit
    extends Cubit<OfflineExamStudentResultsState> {
  final ExamRepository _examRepository = ExamRepository();

  OfflineExamStudentResultsCubit() : super(OfflineExamStudentResultsInitial());

  void getStudentResults(
      {required int sessionYearId,
      required int classSectionId,
      required int examId}) async {
    emit(OfflineExamStudentResultsFetchInProgress());
    try {
      final result = await _examRepository.getOfflineExamStudentResults(
          sessionYearId: sessionYearId,
          classSectionId: classSectionId,
          examId: examId);
      emit(OfflineExamStudentResultsFetchSuccess(
          currentPage: result.currentPage,
          studentResults: result.results,
          fetchMoreError: false,
          fetchMoreInProgress: false,
          totalPage: result.totalPage));
    } catch (e) {
      emit(OfflineExamStudentResultsFetchFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is OfflineExamStudentResultsFetchSuccess) {
      return (state as OfflineExamStudentResultsFetchSuccess).currentPage <
          (state as OfflineExamStudentResultsFetchSuccess).totalPage;
    }
    return false;
  }

  void fetchMore(
      {required int sessionYearId,
      required int classSectionId,
      required int examId}) async {
    //
    if (state is OfflineExamStudentResultsFetchSuccess) {
      if ((state as OfflineExamStudentResultsFetchSuccess)
          .fetchMoreInProgress) {
        return;
      }
      try {
        emit((state as OfflineExamStudentResultsFetchSuccess)
            .copyWith(fetchMoreInProgress: true));

        final result = await _examRepository.getOfflineExamStudentResults(
            classSectionId: classSectionId,
            examId: examId,
            sessionYearId: sessionYearId,
            page: (state as OfflineExamStudentResultsFetchSuccess).currentPage +
                1);

        final currentState = (state as OfflineExamStudentResultsFetchSuccess);
        List<StudentResult> studentResults = currentState.studentResults;

        studentResults.addAll(result.results);

        emit(OfflineExamStudentResultsFetchSuccess(
            currentPage: result.currentPage,
            fetchMoreError: false,
            fetchMoreInProgress: false,
            totalPage: result.totalPage,
            studentResults: studentResults));
      } catch (e) {
        emit((state as OfflineExamStudentResultsFetchSuccess)
            .copyWith(fetchMoreInProgress: false, fetchMoreError: true));
      }
    }
  }
}
