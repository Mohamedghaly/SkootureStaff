// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:eschool_saas_staff/data/repositories/assignmentSubmissionsRepository.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class EditAssignmentSubmissionState {}

class EditAssignmentSubmissionInitial extends EditAssignmentSubmissionState {}

class EditAssignmentSubmissionInProgress
    extends EditAssignmentSubmissionState {}

class EditAssignmentSubmissionSuccess extends EditAssignmentSubmissionState {}

class EditAssignmentSubmissionFailure extends EditAssignmentSubmissionState {
  final String errorMessage;
  EditAssignmentSubmissionFailure({
    required this.errorMessage,
  });
}

class EditAssignmentSubmissionCubit
    extends Cubit<EditAssignmentSubmissionState> {
  final AssignmentSubmissionsRepository _reviewAssignmentRepository =
      AssignmentSubmissionsRepository();
  EditAssignmentSubmissionCubit() : super(EditAssignmentSubmissionInitial());

  Future<void> updateAssignmentSubmission({
    required int assignmentSubmissionId,
    required int assignmentSubmissionStatus,
    String? assignmentSubmissionPoints,
    String? assignmentSubmissionFeedBack,
  }) async {
    try {
      emit(EditAssignmentSubmissionInProgress());
      await _reviewAssignmentRepository.updateAssignmentSubmission(
        assignmentSubmissionId: assignmentSubmissionId,
        assignmentSubmissionStatus: assignmentSubmissionStatus,
        assignmentSubmissionPoints: assignmentSubmissionPoints!.isNotEmpty
            ? int.parse(assignmentSubmissionPoints)
            : 0,
        assignmentSubmissionFeedBack: assignmentSubmissionFeedBack!,
      );
      emit(EditAssignmentSubmissionSuccess());
    } catch (e) {
      emit(EditAssignmentSubmissionFailure(errorMessage: e.toString()));
    }
  }
}
