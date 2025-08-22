import 'package:eschool_saas_staff/data/repositories/payRollRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PayRollYearsState {}

class PayRollYearsInitial extends PayRollYearsState {}

class PayRollYearsFetchInProgress extends PayRollYearsState {}

class PayRollYearsFetchSuccess extends PayRollYearsState {
  final List<String> years;

  PayRollYearsFetchSuccess({required this.years});
}

class PayRollYearsFetchFailure extends PayRollYearsState {
  final String errorMessage;

  PayRollYearsFetchFailure(this.errorMessage);
}

class PayRollYearsCubit extends Cubit<PayRollYearsState> {
  final PayRollRepository _payRollRepository = PayRollRepository();

  PayRollYearsCubit() : super(PayRollYearsInitial());

  void getPayRollYears() async {
    try {
      emit(PayRollYearsFetchInProgress());
      emit(PayRollYearsFetchSuccess(
          years: await _payRollRepository.getPayRollYears()));
    } catch (e) {
      emit(PayRollYearsFetchFailure(e.toString()));
    }
  }
}
