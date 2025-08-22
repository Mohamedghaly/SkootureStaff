import 'package:eschool_saas_staff/data/models/fee.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:eschool_saas_staff/data/repositories/feeRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SessionYearAndFeesState {}

class SessionYearAndFeesInitial extends SessionYearAndFeesState {}

class SessionYearAndFeesFetchInProgress extends SessionYearAndFeesState {}

class SessionYearAndFeesFetchSuccess extends SessionYearAndFeesState {
  final List<SessionYear> sessionYears;
  final List<Fee> fees;

  SessionYearAndFeesFetchSuccess(
      {required this.fees, required this.sessionYears});
}

class SessionYearAndFeesFetchFailure extends SessionYearAndFeesState {
  final String errorMessage;

  SessionYearAndFeesFetchFailure(this.errorMessage);
}

class SessionYearAndFeesCubit extends Cubit<SessionYearAndFeesState> {
  final FeeRepository _feeRepository = FeeRepository();
  final AcademicRepository _academicRepository = AcademicRepository();

  SessionYearAndFeesCubit() : super(SessionYearAndFeesInitial());

  void getSessionYearsAndFees() async {
    try {
      emit(SessionYearAndFeesFetchInProgress());

      emit(SessionYearAndFeesFetchSuccess(
          fees: await _feeRepository.getFees(),
          sessionYears: await _academicRepository.getSessionYears()));
    } catch (e) {
      emit(SessionYearAndFeesFetchFailure(e.toString()));
    }
  }
}
