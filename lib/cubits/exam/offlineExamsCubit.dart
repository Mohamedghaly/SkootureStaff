import 'package:eschool_saas_staff/data/models/offlineExam.dart';
import 'package:eschool_saas_staff/data/repositories/examRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class OfflineExamsState {}

class OfflineExamsInitial extends OfflineExamsState {}

class OfflineExamsFetchInProgress extends OfflineExamsState {}

class OfflineExamsFetchSuccess extends OfflineExamsState {
  final List<OfflineExam> offlineExams;

  OfflineExamsFetchSuccess({required this.offlineExams});
}

class OfflineExamsFetchFailure extends OfflineExamsState {
  final String errorMessage;

  OfflineExamsFetchFailure(this.errorMessage);
}

class OfflineExamsCubit extends Cubit<OfflineExamsState> {
  final ExamRepository _examRepository = ExamRepository();

  OfflineExamsCubit() : super(OfflineExamsInitial());

  ///[ 0- Upcoming, 1-On Going, 2-Completed, 3-All Details]
  void getOfflineExams({int? sessionYearId, int? mediumId, int? status}) async {
    try {
      emit(OfflineExamsFetchInProgress());

      emit(OfflineExamsFetchSuccess(
          offlineExams: await _examRepository.getOfflineExams(
              status: status,
              mediumId: mediumId,
              sessionYearId: sessionYearId)));
    } catch (e) {
      emit(OfflineExamsFetchFailure(e.toString()));
    }
  }
}
