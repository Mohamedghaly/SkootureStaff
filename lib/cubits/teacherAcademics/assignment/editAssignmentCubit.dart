import 'package:eschool_saas_staff/data/repositories/assignmentRepository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EditAssignmentState {}

class EditAssignmentInitial extends EditAssignmentState {}

class EditAssignmentInProgress extends EditAssignmentState {}

class EditAssignmentSuccess extends EditAssignmentState {}

class EditAssignmentFailure extends EditAssignmentState {
  final String errorMessage;

  EditAssignmentFailure(this.errorMessage);
}

class EditAssignmentCubit extends Cubit<EditAssignmentState> {
  final AssignmentRepository _assignmentRepository = AssignmentRepository();

  EditAssignmentCubit() : super(EditAssignmentInitial());

  Future<void> editAssignment({
    required int assignmentId,
    required List<int> classSelectionId,
    required int classSubjectId,
    required String name,
    required String dateTime,
    required String instruction,
    required String points,
    required int resubmission,
    required String extraDayForResubmission,
    required List<PlatformFile> filePaths,
    required String url,
  }) async {
    emit(EditAssignmentInProgress());
    try {
      await _assignmentRepository.editAssignment(
        assignmentId: assignmentId,
        classSelectionId: classSelectionId,
        dateTime: dateTime,
        name: name,
        classSubjectId: classSubjectId,
        extraDayForResubmission: int.parse(
          extraDayForResubmission.isEmpty ? "0" : extraDayForResubmission,
        ),
        instruction: instruction,
        points: int.parse(points.isEmpty ? "0" : points),
        resubmission: resubmission,
        filePaths: filePaths,
        url: url,
      );
      emit(EditAssignmentSuccess());
    } catch (e) {
      emit(EditAssignmentFailure(e.toString()));
    }
  }
}
