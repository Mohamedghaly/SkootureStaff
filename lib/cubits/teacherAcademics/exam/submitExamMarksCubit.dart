// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:eschool_saas_staff/data/repositories/studentRepository.dart';

abstract class SubmitExamMarksState {}

class SubmitExamMarksInitial extends SubmitExamMarksState {}

class SubmitExamMarksSubmitInProgress extends SubmitExamMarksState {}

class SubmitExamMarksSubmitSuccess extends SubmitExamMarksState {}

class SubmitExamMarksSubmitFailure extends SubmitExamMarksState {
  final String errorMessage;

  SubmitExamMarksSubmitFailure({required this.errorMessage});
}

class SubmitExamMarksCubit extends Cubit<SubmitExamMarksState> {
  final StudentRepository studentRepository = StudentRepository();

  SubmitExamMarksCubit() : super(SubmitExamMarksInitial());

  Future<void> submitOfflineExamMarks({
    required int classSubjectId,
    required int examId,
    required List<({double obtainedMarks, int studentId})> marksDetails,
  }) async {
    emit(SubmitExamMarksSubmitInProgress());
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
      );
      emit(SubmitExamMarksSubmitSuccess());
    } catch (e) {
      emit(SubmitExamMarksSubmitFailure(errorMessage: e.toString()));
    }
  }
}
