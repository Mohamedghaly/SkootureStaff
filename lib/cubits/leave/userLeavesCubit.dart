import 'package:eschool_saas_staff/data/models/leaveRequest.dart';
import 'package:eschool_saas_staff/data/repositories/leaveRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UserLeavesState {}

class UserLeavesInitial extends UserLeavesState {}

class UserLeavesFetchInProgress extends UserLeavesState {}

class UserLeavesFetchSuccess extends UserLeavesState {
  final List<LeaveRequest> leaves;
  final double takenLeaves;
  final double monthlyAllowedLeaves;

  UserLeavesFetchSuccess(
      {required this.leaves,
      required this.monthlyAllowedLeaves,
      required this.takenLeaves});
}

class UserLeavesFetchFailure extends UserLeavesState {
  final String errorMessage;

  UserLeavesFetchFailure(this.errorMessage);
}

class UserLeavesCubit extends Cubit<UserLeavesState> {
  final LeaveRepository _leaveRepository = LeaveRepository();

  UserLeavesCubit() : super(UserLeavesInitial());

  void getUserLeaves(
      {required int userId,
      required int sessionYearId,
      int? monthNumber}) async {
    try {
      emit(UserLeavesFetchInProgress());
      final result = await _leaveRepository.getUserLeaves(
          sessionYearId: sessionYearId,
          userId: userId,
          monthNumber: monthNumber);

      emit(UserLeavesFetchSuccess(
          leaves: result.leaves,
          monthlyAllowedLeaves: result.monthlyAllowedLeaves,
          takenLeaves: result.takenLeaves));
    } catch (e) {
      emit(UserLeavesFetchFailure(e.toString()));
    }
  }

  double getTakenLeavesCount({required int monthNumber}) {
    if (state is UserLeavesFetchSuccess) {
      double total = 0;
      for (final leaveRequest in (state as UserLeavesFetchSuccess).leaves) {
        if (getLeaveRequestStatusEnumFromValue(leaveRequest.status!) ==
            LeaveRequestStatus.approved) {
          for (var leaveDetail in leaveRequest.leaveDetail!) {
            final parsedDate = Utils.parseDateSafely(leaveDetail.date!);
            if (parsedDate != null && parsedDate.month == monthNumber) {
              if (leaveDetail.isFullLeave()) {
                total = total + 1.0;
              } else {
                total = total + 0.5;
              }
            }
          }
        }
      }

      return total;
    }
    return 0;
  }
}
