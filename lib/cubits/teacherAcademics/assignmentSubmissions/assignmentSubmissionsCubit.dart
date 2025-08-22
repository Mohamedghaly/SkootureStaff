// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:eschool_saas_staff/data/models/assignmentSubmission.dart';
import 'package:eschool_saas_staff/data/repositories/assignmentSubmissionsRepository.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class AssignmentSubmissionsState {}

class AssignmentSubmissionsInitial extends AssignmentSubmissionsState {}

class AssignmentSubmissionsFetchInProcess extends AssignmentSubmissionsState {}

class AssignmentSubmissionsFetchedSuccess extends AssignmentSubmissionsState {
  final List<AssignmentSubmission> reviewAssignment;

  AssignmentSubmissionsFetchedSuccess({
    required this.reviewAssignment,
  });
}

class AssignmentSubmissionsFetchFailure extends AssignmentSubmissionsState {
  final String errorMessage;
  AssignmentSubmissionsFetchFailure({
    required this.errorMessage,
  });
}

class AssignmentSubmissionsCubit extends Cubit<AssignmentSubmissionsState> {
  final AssignmentSubmissionsRepository _reviewAssignmentRepository =
      AssignmentSubmissionsRepository();
  AssignmentSubmissionsCubit() : super(AssignmentSubmissionsInitial());

  Future<void> fetchAssignmentSubmissions({
    required int assignmentId,
  }) async {
    try {
      emit(AssignmentSubmissionsFetchInProcess());
      await _reviewAssignmentRepository
          .fetchAssignmentSubmissions(assignmentId: assignmentId)
          .then((value) {
        emit(
          AssignmentSubmissionsFetchedSuccess(
            reviewAssignment: value,
          ),
        );
      });
    } catch (e) {
      emit(AssignmentSubmissionsFetchFailure(errorMessage: e.toString()));
    }
  }

  Future<void> updateReviewAssignment({
    required AssignmentSubmission updatedReviewAssignmentSubmission,
  }) async {
    try {
      List<AssignmentSubmission> currentAssignment =
          (state as AssignmentSubmissionsFetchedSuccess).reviewAssignment;
      List<AssignmentSubmission> updateAssignment =
          List.from(currentAssignment);
      int reviewAssignmentIndex = currentAssignment.indexWhere(
        (element) => element.id == updatedReviewAssignmentSubmission.id,
      );
      updateAssignment[reviewAssignmentIndex] =
          updatedReviewAssignmentSubmission;
      emit(AssignmentSubmissionsFetchedSuccess(
          reviewAssignment: updateAssignment));
    } catch (e) {
      emit(AssignmentSubmissionsFetchFailure(errorMessage: e.toString()));
    }
  }

  List<AssignmentSubmission> reviewAssignment() {
    return (state as AssignmentSubmissionsFetchedSuccess).reviewAssignment;
  }
}
