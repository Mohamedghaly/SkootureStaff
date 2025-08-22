import 'package:eschool_saas_staff/data/repositories/assignmentRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteAssignmentState {}

class DeleteAssignmentInitial extends DeleteAssignmentState {}

class DeleteAssignmentInProgress extends DeleteAssignmentState {}

class DeleteAssignmentSuccess extends DeleteAssignmentState {}

class DeleteAssignmentFailure extends DeleteAssignmentState {
  final String errorMessage;
  DeleteAssignmentFailure(this.errorMessage);
}

class DeleteAssignmentCubit extends Cubit<DeleteAssignmentState> {
  final AssignmentRepository _assignmentRepository = AssignmentRepository();

  DeleteAssignmentCubit() : super(DeleteAssignmentInitial());

  Future<void> deleteAssignment({
    required int assignmentId,
  }) async {
    try {
      emit(DeleteAssignmentInProgress());
      await _assignmentRepository
          .deleteAssignment(assignmentId: assignmentId)
          .then((_) => emit(DeleteAssignmentSuccess()));
    } catch (e) {
      emit(DeleteAssignmentFailure(e.toString()));
    }
  }
}
