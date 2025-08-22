import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SessionYearsState {}

class SessionYearsInitial extends SessionYearsState {}

class SessionYearsFetchInProgress extends SessionYearsState {}

class SessionYearsFetchSuccess extends SessionYearsState {
  final List<SessionYear> sessionYears;

  SessionYearsFetchSuccess({required this.sessionYears});
}

class SessionYearsFetchFailure extends SessionYearsState {
  final String errorMessage;

  SessionYearsFetchFailure(this.errorMessage);
}

class SessionYearsCubit extends Cubit<SessionYearsState> {
  final AcademicRepository _academicRepository = AcademicRepository();

  SessionYearsCubit() : super(SessionYearsInitial());

  void getSessionYears() async {
    try {
      emit(SessionYearsFetchInProgress());
      emit(SessionYearsFetchSuccess(
        sessionYears: await _academicRepository.getSessionYears()
      ));
    } catch (e) {
      emit(SessionYearsFetchFailure(e.toString()));
    }
  }
}
