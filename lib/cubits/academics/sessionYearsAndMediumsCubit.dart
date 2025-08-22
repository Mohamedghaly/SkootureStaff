import 'package:eschool_saas_staff/data/models/medium.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SessionYearsAndMediumsState {}

class SessionYearsAndMediumsInitial extends SessionYearsAndMediumsState {}

class SessionYearsAndMediumsFetchInProgress
    extends SessionYearsAndMediumsState {}

class SessionYearsAndMediumsFetchSuccess extends SessionYearsAndMediumsState {
  final List<SessionYear> sessionYears;
  final List<Medium> mediums;

  SessionYearsAndMediumsFetchSuccess(
      {required this.mediums, required this.sessionYears});
}

class SessionYearsAndMediumsFetchFailure extends SessionYearsAndMediumsState {
  final String errorMessage;

  SessionYearsAndMediumsFetchFailure(this.errorMessage);
}

class SessionYearsAndMediumsCubit extends Cubit<SessionYearsAndMediumsState> {
  final AcademicRepository _academicRepository = AcademicRepository();

  SessionYearsAndMediumsCubit() : super(SessionYearsAndMediumsInitial());

  void getSessionYearsAndMediums() async {
    if (state is SessionYearsAndMediumsFetchInProgress) {
      return;
    }
    try {
      emit(SessionYearsAndMediumsFetchInProgress());
      emit(SessionYearsAndMediumsFetchSuccess(
          mediums: await _academicRepository.getMediums(),
          sessionYears: await _academicRepository.getSessionYears()));
    } catch (e) {
      emit(SessionYearsAndMediumsFetchFailure(e.toString()));
    }
  }
}
