// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:eschool_saas_staff/data/repositories/studentRepository.dart';

abstract class SubmitExamMarksState {}

class SubmitExamMarksInitial extends SubmitExamMarksState {}

class SubmitExamMarksSubmitInProgress extends SubmitExamMarksState {
  final int status; // 0 = Draft, 1 = Published
  SubmitExamMarksSubmitInProgress({required this.status});
}


/// Emitted when marks are fully published (status = 1)
class SubmitExamMarksSubmitSuccess extends SubmitExamMarksState {}

/// Emitted when marks are saved as draft (status = 0)
class SubmitExamMarksDraftSuccess extends SubmitExamMarksState {}

class SubmitExamMarksSubmitFailure extends SubmitExamMarksState {
  final String errorMessage;

  SubmitExamMarksSubmitFailure({required this.errorMessage});
}

class SubmitExamMarksCubit extends Cubit<SubmitExamMarksState> {
  final StudentRepository studentRepository = StudentRepository();

  SubmitExamMarksCubit() : super(SubmitExamMarksInitial());

  /// [status] → 0 = Draft, 1 = Published
  Future<void> submitOfflineExamMarks({
    required int classSubjectId,
    required int examId,
    required List<({double obtainedMarks, int studentId})> marksDetails,
    required int status,
  }) async {
    emit(SubmitExamMarksSubmitInProgress(status: status));
    try {
      var parameter = {
        "marks_data": List.generate(
            marksDetails.length,
            (index) => {
                  "student_id": marksDetails[index].studentId,
                  "obtained_marks": marksDetails[index].obtainedMarks,
                })
      };
      await studentRepository.addOfflineExamMarks(
        examId: examId,
        marksDataValue: parameter,
        classSubjectId: classSubjectId,
        status: status,
      );
      if (status == 0) {
        emit(SubmitExamMarksDraftSuccess());
      } else {
        emit(SubmitExamMarksSubmitSuccess());
      }
    } catch (e) {
      emit(SubmitExamMarksSubmitFailure(errorMessage: e.toString()));
    }
  }
}
