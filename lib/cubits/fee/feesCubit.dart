import 'package:eschool_saas_staff/data/models/fee.dart';
import 'package:eschool_saas_staff/data/repositories/feeRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FeesState {}

class FeesInitial extends FeesState {}

class FeesFetchInProgress extends FeesState {}

class FeesFetchSuccess extends FeesState {
  final List<Fee> fees;

  FeesFetchSuccess({required this.fees});
}

class FeesFetchFailure extends FeesState {
  final String errorMessage;

  FeesFetchFailure(this.errorMessage);
}

class FeesCubit extends Cubit<FeesState> {
  final FeeRepository _feeRepository = FeeRepository();
  FeesCubit() : super(FeesInitial());

  void getFees() async {
    try {
      emit(FeesFetchInProgress());

      emit(FeesFetchSuccess(fees: await _feeRepository.getFees()));
    } catch (e) {
      emit(FeesFetchFailure(e.toString()));
    }
  }
}
