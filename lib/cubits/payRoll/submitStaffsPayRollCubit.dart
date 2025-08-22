import 'package:eschool_saas_staff/data/repositories/payRollRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubmitStaffsPayRollState {}

class SubmitStaffsPayRollInitial extends SubmitStaffsPayRollState {}

class SubmitStaffsPayRollInProgress extends SubmitStaffsPayRollState {}

class SubmitStaffsPayRollSuccess extends SubmitStaffsPayRollState {}

class SubmitStaffsPayRollFailure extends SubmitStaffsPayRollState {
  final String errorMessage;

  SubmitStaffsPayRollFailure(this.errorMessage);
}

class SubmitStaffsPayRollCubit extends Cubit<SubmitStaffsPayRollState> {
  final PayRollRepository _payRollRepository = PayRollRepository();

  SubmitStaffsPayRollCubit() : super(SubmitStaffsPayRollInitial());

  void submitStaffsPayRoll(
      {required int month,
      required int year,
      required double allowedLeaves,
      required List<Map<String, dynamic>> staffPayRolls}) async {
    try {
      emit(SubmitStaffsPayRollInProgress());
      await _payRollRepository.submitStaffsPayRoll(
          month: month,
          year: year,
          allowedLeaves: allowedLeaves,
          staffPayRolls: staffPayRolls);
      emit(SubmitStaffsPayRollSuccess());
    } catch (e) {
      emit(SubmitStaffsPayRollFailure(e.toString()));
    }
  }
}
