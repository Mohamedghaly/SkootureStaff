import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/data/repositories/feeRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StudentsFeeStatusState {}

class StudentsFeeStatusInitial extends StudentsFeeStatusState {}

class StudentsFeeStatusFetchInProgress extends StudentsFeeStatusState {}

class StudentsFeeStatusFetchSuccess extends StudentsFeeStatusState {
  final int totalPage;
  final int currentPage;
  final List<StudentDetails> students;

  final bool fetchMoreError;
  final bool fetchMoreInProgress;
  final double compolsoryFeeAmount;
  final double optionalFeeAmount;

  StudentsFeeStatusFetchSuccess(
      {required this.currentPage,
      required this.students,
      required this.fetchMoreError,
      required this.fetchMoreInProgress,
      required this.totalPage,
      required this.compolsoryFeeAmount,
      required this.optionalFeeAmount});

  StudentsFeeStatusFetchSuccess copyWith(
      {int? currentPage,
      bool? fetchMoreError,
      bool? fetchMoreInProgress,
      int? totalPage,
      List<StudentDetails>? students,
      double? compolsoryFeeAmount,
      double? optionalFeeAmount}) {
    return StudentsFeeStatusFetchSuccess(
        compolsoryFeeAmount: compolsoryFeeAmount ?? this.compolsoryFeeAmount,
        optionalFeeAmount: optionalFeeAmount ?? this.optionalFeeAmount,
        currentPage: currentPage ?? this.currentPage,
        students: students ?? this.students,
        fetchMoreError: fetchMoreError ?? this.fetchMoreError,
        fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
        totalPage: totalPage ?? this.totalPage);
  }
}

class StudentsFeeStatusFetchFailure extends StudentsFeeStatusState {
  final String errorMessage;

  StudentsFeeStatusFetchFailure(this.errorMessage);
}

class StudentsFeeStatusCubit extends Cubit<StudentsFeeStatusState> {
  final FeeRepository _feeRepository = FeeRepository();

  StudentsFeeStatusCubit() : super(StudentsFeeStatusInitial());

  void getStudentFeePaymentStatus(
      {required int sessionYearId,
      required int status,
      required int feeId}) async {
    emit(StudentsFeeStatusFetchInProgress());
    try {
      final result = await _feeRepository.getStudentsFeePaymentStatus(
          sessionYearId: sessionYearId, status: status, feeId: feeId);
      emit(StudentsFeeStatusFetchSuccess(
          currentPage: result.currentPage,
          students: result.students,
          fetchMoreError: false,
          fetchMoreInProgress: false,
          compolsoryFeeAmount: result.compolsoryFeeAmount,
          optionalFeeAmount: result.optionalFeeAmount,
          totalPage: result.totalPage));
    } catch (e) {
      emit(StudentsFeeStatusFetchFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is StudentsFeeStatusFetchSuccess) {
      return (state as StudentsFeeStatusFetchSuccess).currentPage <
          (state as StudentsFeeStatusFetchSuccess).totalPage;
    }
    return false;
  }

  void fetchMore(
      {required int sessionYearId,
      required int status,
      required int feeId}) async {
    //
    if (state is StudentsFeeStatusFetchSuccess) {
      if ((state as StudentsFeeStatusFetchSuccess).fetchMoreInProgress) {
        return;
      }
      try {
        emit((state as StudentsFeeStatusFetchSuccess)
            .copyWith(fetchMoreInProgress: true));

        final result = await _feeRepository.getStudentsFeePaymentStatus(
            feeId: feeId,
            sessionYearId: sessionYearId,
            status: status,
            page: (state as StudentsFeeStatusFetchSuccess).currentPage + 1);

        final currentState = (state as StudentsFeeStatusFetchSuccess);
        List<StudentDetails> students = currentState.students;

        students.addAll(result.students);

        emit(StudentsFeeStatusFetchSuccess(
            compolsoryFeeAmount: result.compolsoryFeeAmount,
            optionalFeeAmount: result.optionalFeeAmount,
            currentPage: result.currentPage,
            fetchMoreError: false,
            fetchMoreInProgress: false,
            totalPage: result.totalPage,
            students: students));
      } catch (e) {
        emit((state as StudentsFeeStatusFetchSuccess)
            .copyWith(fetchMoreInProgress: false, fetchMoreError: true));
      }
    }
  }
}
