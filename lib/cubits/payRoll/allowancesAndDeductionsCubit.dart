import 'package:eschool_saas_staff/data/models/staffSalary.dart';
import 'package:eschool_saas_staff/data/repositories/payRollRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AllowancesAndDeductionsState {}

class AllowancesAndDeductionsInitial extends AllowancesAndDeductionsState {}

class AllowancesAndDeductionsFetchInProgress
    extends AllowancesAndDeductionsState {}

class AllowancesAndDeductionsFetchSuccess extends AllowancesAndDeductionsState {
  final List<StaffSalary> allowances;
  final List<StaffSalary> deductions;

  AllowancesAndDeductionsFetchSuccess(
      {required this.allowances, required this.deductions});
}

class AllowancesAndDeductionsFetchFailure extends AllowancesAndDeductionsState {
  final String errorMessage;

  AllowancesAndDeductionsFetchFailure(this.errorMessage);
}

class AllowancesAndDeductionsCubit extends Cubit<AllowancesAndDeductionsState> {
  final PayRollRepository _payRollRepository = PayRollRepository();

  AllowancesAndDeductionsCubit() : super(AllowancesAndDeductionsInitial());

  void fetchAllowancesAndDeductions() async {
    emit(AllowancesAndDeductionsFetchInProgress());
    try {
      final result = await _payRollRepository.getAllowancesAndDeductions();

      emit(AllowancesAndDeductionsFetchSuccess(
          allowances: result.allowances, deductions: result.deductions));
    } catch (e) {
      emit(AllowancesAndDeductionsFetchFailure(e.toString()));
    }
  }
}
