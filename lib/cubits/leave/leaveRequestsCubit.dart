import 'package:eschool_saas_staff/data/models/leaveRequest.dart';
import 'package:eschool_saas_staff/data/repositories/leaveRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LeaveRequestsState {}

class LeaveRequestsInitial extends LeaveRequestsState {}

class LeaveRequestsFetchInProgress extends LeaveRequestsState {}

class LeaveRequestsFetchSuccess extends LeaveRequestsState {
  final List<LeaveRequest> leaveRequests;

  LeaveRequestsFetchSuccess({required this.leaveRequests});
}

class LeaveRequestsFetchFailure extends LeaveRequestsState {
  final String errorMessage;

  LeaveRequestsFetchFailure(this.errorMessage);
}

class LeaveRequestsCubit extends Cubit<LeaveRequestsState> {
  final LeaveRepository _leaveRepository = LeaveRepository();

  LeaveRequestsCubit() : super(LeaveRequestsInitial());

  void getLeaveRequests() async {
    try {
      emit(LeaveRequestsFetchInProgress());

      final leaveRequests = await _leaveRepository.getLeaveRequests();

      emit(LeaveRequestsFetchSuccess(leaveRequests: leaveRequests));
    } catch (e) {
      emit(LeaveRequestsFetchFailure(e.toString()));
    }
  }
}
