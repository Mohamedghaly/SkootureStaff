import 'package:eschool_saas_staff/data/models/transportDashboard.dart';
import 'package:eschool_saas_staff/data/repositories/transportRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TransportDashboardState {}

class TransportDashboardInitial extends TransportDashboardState {}

class TransportDashboardFetchInProgress extends TransportDashboardState {}

class TransportDashboardFetchSuccess extends TransportDashboardState {
  final TransportDashboard transportDashboard;

  TransportDashboardFetchSuccess({required this.transportDashboard});
}

class TransportDashboardFetchFailure extends TransportDashboardState {
  final String errorMessage;

  TransportDashboardFetchFailure(this.errorMessage);
}

class TransportDashboardCubit extends Cubit<TransportDashboardState> {
  final TransportRepository _transportRepository = TransportRepository();

  TransportDashboardCubit() : super(TransportDashboardInitial());

  Future<void> fetchDashboard({
    required int userId,
  }) async {
    emit(TransportDashboardFetchInProgress());

    try {
      final transportDashboard = await _transportRepository.getDashboard(
        userId: userId,
      );

      emit(TransportDashboardFetchSuccess(
          transportDashboard: transportDashboard));
    } catch (e) {
      emit(TransportDashboardFetchFailure(e.toString()));
    }
  }

  // Helper method to get transport plan data
  TransportPlan? getTransportPlan() {
    if (state is TransportDashboardFetchSuccess) {
      return (state as TransportDashboardFetchSuccess).transportDashboard.plan;
    }
    return null;
  }

  // Helper method to get bus info data
  BusInfo? getBusInfo() {
    if (state is TransportDashboardFetchSuccess) {
      return (state as TransportDashboardFetchSuccess)
          .transportDashboard
          .busInfo;
    }
    return null;
  }

  // Helper method to get live summary data
  LiveSummary? getLiveSummary() {
    if (state is TransportDashboardFetchSuccess) {
      return (state as TransportDashboardFetchSuccess)
          .transportDashboard
          .liveSummary;
    }
    return null;
  }

  // Helper method to get today's attendance data
  List<TodayAttendance> getTodayAttendance() {
    if (state is TransportDashboardFetchSuccess) {
      return (state as TransportDashboardFetchSuccess)
          .transportDashboard
          .todayAttendance;
    }
    return [];
  }

  // Helper method to get first attendance record (for backward compatibility)
  TodayAttendance? getFirstTodayAttendance() {
    final attendanceList = getTodayAttendance();
    return attendanceList.isNotEmpty ? attendanceList.first : null;
  }

  // Helper method to check if plan is expiring soon
  bool isPlanExpiringSoon({int warningDays = 7}) {
    final plan = getTransportPlan();
    if (plan?.expiresInDays != null) {
      return plan!.expiresInDays! <= warningDays;
    }
    return false;
  }

  // Helper method to get plan status color
  Map<String, dynamic> getPlanStatusStyle() {
    final plan = getTransportPlan();
    final status = plan?.status?.toLowerCase();

    switch (status) {
      case 'active':
        return {
          'background': const Color(0xFFDFF6E2),
          'foreground': const Color(0xFF37C748),
          'text': 'Active',
        };
      case 'expired':
        return {
          'background': const Color(0xFFFFE8E8),
          'foreground': const Color(0xFFE53935),
          'text': 'Expired',
        };
      case 'inactive':
        return {
          'background': const Color(0xFFF5F5F5),
          'foreground': const Color(0xFF9E9E9E),
          'text': 'Inactive',
        };
      default:
        return {
          'background': const Color(0xFFE0EDF6),
          'foreground': const Color(0xFF29638A),
          'text': 'Unknown',
        };
    }
  }

  // Helper method to get attendance status style
  Map<String, dynamic> getAttendanceStatusStyle() {
    final attendance = getFirstTodayAttendance();
    final status = attendance?.status?.toUpperCase();

    switch (status) {
      case 'P':
        return {
          'background': const Color(0xFFDFF6E2),
          'foreground': const Color(0xFF37C748),
          'text': 'Present',
        };
      case 'A':
        return {
          'background': const Color(0xFFFFE8E8),
          'foreground': const Color(0xFFE53935),
          'text': 'Absent',
        };
      case 'W':
        return {
          'background': const Color(0xFFE0EDF6),
          'foreground': const Color(0xFF29638A),
          'text': 'Waiting',
        };
      default:
        return {
          'background': const Color(0xFFF5F5F5),
          'foreground': const Color(0xFF9E9E9E),
          'text': 'Not Marked',
        };
    }
  }

  // Helper method to check if there's no plan found
  bool hasNoPlan() {
    if (state is TransportDashboardFetchSuccess) {
      return (state as TransportDashboardFetchSuccess)
          .transportDashboard
          .hasNoPlan;
    }
    return false;
  }

  // Helper method to get status message
  String? getStatusMessage() {
    if (state is TransportDashboardFetchSuccess) {
      return (state as TransportDashboardFetchSuccess)
          .transportDashboard
          .status;
    }
    return null;
  }

  // Helper method to get transport requests data
  TransportRequest? getTransportRequests() {
    if (state is TransportDashboardFetchSuccess) {
      return (state as TransportDashboardFetchSuccess)
          .transportDashboard
          .requests;
    }
    return null;
  }
}
