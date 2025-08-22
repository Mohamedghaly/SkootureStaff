import 'package:eschool_saas_staff/data/repositories/assignmentRepository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateAssignmentState {}

class CreateAssignmentInitial extends CreateAssignmentState {}

class CreateAssignmentInProcess extends CreateAssignmentState {}

class CreateAssignmentSuccess extends CreateAssignmentState {}

class CreateAssignmentFailure extends CreateAssignmentState {
  final String errorMessage;
  CreateAssignmentFailure({
    required this.errorMessage,
  });
}

class CreateAssignmentCubit extends Cubit<CreateAssignmentState> {
  final AssignmentRepository _assignmentRepository = AssignmentRepository();

  CreateAssignmentCubit() : super(CreateAssignmentInitial());

  Future<void> createAssignment({
    required List<int> classSectionId,
    required int classSubjectId,
    required String name,
    required String instruction,
    required String dateTime,
    required String points,
    required bool resubmission,
    required String extraDayForResubmission,
    List<PlatformFile>? file,
    required String url
  }) async {
    emit(CreateAssignmentInProcess());
    try {
      await _assignmentRepository
          .createAssignment(
            classSectionId: classSectionId,
            classSubjectId: classSubjectId,
            name: name,
            dateTime: dateTime,
            resubmission: resubmission,
            extraDayForResubmission: int.parse(
              extraDayForResubmission.isEmpty ? "0" : extraDayForResubmission,
            ),
            filePaths: file,
            instruction: instruction,
            points: int.parse(points.isEmpty ? "0" : points),
            url: url
          )
          .then((value) => emit(CreateAssignmentSuccess()));
    } catch (e) {
      emit(CreateAssignmentFailure(errorMessage: e.toString()));
    }
  }
}
