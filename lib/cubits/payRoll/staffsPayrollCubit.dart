import 'package:eschool_saas_staff/data/models/staffPayRoll.dart';
import 'package:eschool_saas_staff/data/repositories/payRollRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StaffsPayrollState {}

class StaffsPayrollInitial extends StaffsPayrollState {}

class StaffsPayrollFetchInProgress extends StaffsPayrollState {}

class StaffsPayrollFetchSuccess extends StaffsPayrollState {
  final List<StaffPayRoll> staffsPayRoll;
  final double allowedLeaves;

  StaffsPayrollFetchSuccess(
      {required this.allowedLeaves, required this.staffsPayRoll});
}

class StaffsPayrollFetchFailure extends StaffsPayrollState {
  final String errorMessage;

  StaffsPayrollFetchFailure(this.errorMessage);
}

class StaffsPayrollCubit extends Cubit<StaffsPayrollState> {
  final PayRollRepository _payRollRepository = PayRollRepository();

  StaffsPayrollCubit() : super(StaffsPayrollInitial());

  void getStaffsPayroll({required int year, required int month}) async {
    try {
      emit(StaffsPayrollFetchInProgress());
      final result =
          await _payRollRepository.getStaffsPayroll(year: year, month: month);
      emit(StaffsPayrollFetchSuccess(
          allowedLeaves: result.allowedLeaves,
          staffsPayRoll: result.staffsPayRoll));
    } catch (e) {
      emit(StaffsPayrollFetchFailure(e.toString()));
    }
  }

  List<StaffPayRoll> staffsPayRoll() {
    if (state is StaffsPayrollFetchSuccess) {
      return (state as StaffsPayrollFetchSuccess).staffsPayRoll;
    }

    return [];
  }

  double allowedLeaves() {
    if (state is StaffsPayrollFetchSuccess) {
      return (state as StaffsPayrollFetchSuccess).allowedLeaves;
    }
    return 0.0;
  }
}
