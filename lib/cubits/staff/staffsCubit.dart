import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/data/repositories/staffRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StaffsState {}

class StaffsInitial extends StaffsState {}

class StaffsFetchInProgress extends StaffsState {}

class StaffsFetchSuccess extends StaffsState {
  final List<UserDetails> saffs;

  StaffsFetchSuccess({required this.saffs});
}

class StaffsFetchFailure extends StaffsState {
  final String errorMessage;

  StaffsFetchFailure(this.errorMessage);
}

class StaffsCubit extends Cubit<StaffsState> {
  final StaffRepository _staffRepository = StaffRepository();

  StaffsCubit() : super(StaffsInitial());

  void getStaffs({String? search, int? status}) async {
    try {
      emit(StaffsFetchInProgress());

      emit(StaffsFetchSuccess(
          saffs: await _staffRepository.getStaffs(
              search: search, status: status)));
    } catch (e) {
      emit(StaffsFetchFailure(e.toString()));
    }
  }
}
