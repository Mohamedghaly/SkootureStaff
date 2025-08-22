import 'package:eschool_saas_staff/data/repositories/leaveRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ApproveOrRejectLeaveRequestState {}

class ApproveOrRejectLeaveRequestInitial
    extends ApproveOrRejectLeaveRequestState {}

class ApproveOrRejectLeaveRequestInProgress
    extends ApproveOrRejectLeaveRequestState {}

class ApproveOrRejectLeaveRequestSuccess
    extends ApproveOrRejectLeaveRequestState {}

class ApproveOrRejectLeaveRequestFailure
    extends ApproveOrRejectLeaveRequestState {
  final String errorMessage;

  ApproveOrRejectLeaveRequestFailure(this.errorMessage);
}

class ApproveOrRejectLeaveRequestCubit
    extends Cubit<ApproveOrRejectLeaveRequestState> {
  final LeaveRepository _leaveRepository = LeaveRepository();

  ApproveOrRejectLeaveRequestCubit()
      : super(ApproveOrRejectLeaveRequestInitial());

  void approveOrRejectLeaveRequest(
      {required int leaveRequestId, required bool approveLeave}) async {
    try {
      emit(ApproveOrRejectLeaveRequestInProgress());
      await _leaveRepository.approveOrRejectLeaveRequest(
          leaveRequestId: leaveRequestId, status: approveLeave ? 1 : 2);
      //// 0 -> Pending, 1 -> Approved, 2 -> Rejected
      emit(ApproveOrRejectLeaveRequestSuccess());
    } catch (e) {
      emit(ApproveOrRejectLeaveRequestFailure(e.toString()));
    }
  }
}
