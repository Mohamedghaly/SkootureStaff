// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:eschool_saas_staff/data/models/exam.dart';
import 'package:eschool_saas_staff/data/repositories/studentRepository.dart';

abstract class ExamsState {}

class ExamsInitial extends ExamsState {}

class ExamsFetchSuccess extends ExamsState {
  final List<Exam> examList;

  ExamsFetchSuccess({required this.examList});
}

class ExamsFetchFailure extends ExamsState {
  final String errorMessage;

  ExamsFetchFailure(this.errorMessage);
}

class ExamsFetchInProgress extends ExamsState {}

class ExamsCubit extends Cubit<ExamsState> {
  final StudentRepository _studentRepository = StudentRepository();

  ExamsCubit() : super(ExamsInitial());

  ///[0- Upcoming, 1-On Going, 2-Completed, 3-All Details]
  void fetchExamsList({
    required int examStatus,
    int? classSectionId,
    int? studentId,
    int? publishStatus,
  }) {
    emit(ExamsFetchInProgress());
    _studentRepository
        .fetchExamsList(
          examStatus: examStatus,
          studentID: studentId,
          publishStatus: publishStatus,
          classSectionId: classSectionId,
        )
        .then((value) => emit(ExamsFetchSuccess(examList: value)))
        .catchError((e) => emit(ExamsFetchFailure(e.toString())));
  }

  List<Exam> getAllExams() {
    if (state is ExamsFetchSuccess) {
      return (state as ExamsFetchSuccess).examList;
    }
    return [];
  }

  List<String> getExamName() {
    return getAllExams().map((exams) => exams.getExamName()).toList();
  }

  Exam getExams({required int index}) {
    return getAllExams()[index];
  }
}
