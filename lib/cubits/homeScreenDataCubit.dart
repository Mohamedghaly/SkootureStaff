import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/data/models/leaveDetails.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/data/repositories/leaveRepository.dart';
import 'package:eschool_saas_staff/data/repositories/settingsRepository.dart';
import 'package:eschool_saas_staff/data/repositories/statisticsRepository.dart';
import 'package:eschool_saas_staff/data/repositories/teacherRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HomeScreenDataState {}

class HomeScreenDataInitial extends HomeScreenDataState {}

class HomeScreenDataFetchInProgress extends HomeScreenDataState {}

class HomeScreenDataFetchSuccess extends HomeScreenDataState {
  final int totalStudents;
  final int totalStaffs;
  final int totalTeachers;
  final int totalLeaveRequests;
  final List<UserDetails> teachers;
  final List<LeaveDetails> todaysLeave;
  final List<Holiday> holidays;

  HomeScreenDataFetchSuccess(
      {required this.totalLeaveRequests,
      required this.teachers,
      required this.totalTeachers,
      required this.totalStaffs,
      required this.holidays,
      required this.totalStudents,
      required this.todaysLeave});

  HomeScreenDataFetchSuccess copyWith(
      {int? totalLeaveRequests,
      int? totalStaffs,
      int? totalTeachers,
      int? totalStudents,
      List<UserDetails>? teachers,
      List<LeaveDetails>? todaysLeave,
      List<Holiday>? holidays}) {
    return HomeScreenDataFetchSuccess(
        totalLeaveRequests: totalLeaveRequests ?? this.totalLeaveRequests,
        teachers: teachers ?? this.teachers,
        totalTeachers: totalTeachers ?? this.totalTeachers,
        totalStaffs: totalStaffs ?? this.totalStaffs,
        holidays: holidays ?? this.holidays,
        totalStudents: totalStudents ?? this.totalStudents,
        todaysLeave: todaysLeave ?? this.todaysLeave);
  }
}

class HomeScreenDataFetchFailure extends HomeScreenDataState {
  final String errorMessage;

  HomeScreenDataFetchFailure(this.errorMessage);
}

class HomeScreenDataCubit extends Cubit<HomeScreenDataState> {
  final StatisticsRepository _statisticsRepository = StatisticsRepository();
  final TeacherRepository _teacherRepository = TeacherRepository();
  final LeaveRepository _leaveRepository = LeaveRepository();
  final SettingsRepository _settingsRepository = SettingsRepository();

  HomeScreenDataCubit() : super(HomeScreenDataInitial());

  void getHomeScreenData({
    required bool listTeacherTimetablePermission,
    required bool isTeacher,
    required bool holidayModuleEnabled,
    required bool staffLeaveModuleEnabled,
    bool forceRefresh = false,
  }) async {
    // Skip if data already loaded or fetch already running.
    // Caller passes forceRefresh: true for pull-to-refresh.
    if (!forceRefresh &&
        (state is HomeScreenDataFetchSuccess ||
            state is HomeScreenDataFetchInProgress)) {
      return;
    }
    try {
      emit(HomeScreenDataFetchInProgress());

      // Start all independent fetches before awaiting any — true parallelism.
      // Futures are assigned to typed variables so no dynamic casts needed.
      final statsFuture = _statisticsRepository.getSystemStatistics();
      final teachersFuture = listTeacherTimetablePermission
          ? _teacherRepository.getTeachers()
          : Future.value(<UserDetails>[]);
      final leavesFuture = staffLeaveModuleEnabled
          ? _leaveRepository.getLeaves(leaveDayType: LeaveDayType.today)
          : Future.value(<LeaveDetails>[]);
      final holidaysFuture = holidayModuleEnabled
          ? _settingsRepository.getHolidays()
          : Future.value(<Holiday>[]);

      final stats = await statsFuture;
      final teachers = await teachersFuture;
      final todaysLeave = await leavesFuture;
      final holidays = await holidaysFuture;

      emit(HomeScreenDataFetchSuccess(
          holidays: holidays,
          todaysLeave: todaysLeave,
          teachers: teachers,
          totalLeaveRequests: stats.totalLeaveRequests,
          totalTeachers: stats.totalTeachers,
          totalStaffs: stats.totalStaffs,
          totalStudents: stats.totalStudents));
    } catch (e) {
      emit(HomeScreenDataFetchFailure(e.toString()));
    }
  }

  int getTotalStudents() {
    if (state is HomeScreenDataFetchSuccess) {
      return (state as HomeScreenDataFetchSuccess).totalStudents;
    }
    return 0;
  }

  void updateLeaveRequest({required int totalLeaveRequests}) {
    if (state is HomeScreenDataFetchSuccess) {
      emit((state as HomeScreenDataFetchSuccess)
          .copyWith(totalLeaveRequests: totalLeaveRequests));
    }
  }

  int getTotalLeaveRequests() {
    if (state is HomeScreenDataFetchSuccess) {
      return (state as HomeScreenDataFetchSuccess).totalLeaveRequests;
    }
    return 0;
  }

  int getTotalStaffs() {
    if (state is HomeScreenDataFetchSuccess) {
      return (state as HomeScreenDataFetchSuccess).totalStaffs;
    }
    return 0;
  }

  int getTotalTeachers() {
    if (state is HomeScreenDataFetchSuccess) {
      return (state as HomeScreenDataFetchSuccess).totalTeachers;
    }
    return 0;
  }

  List<UserDetails> getTeachers() {
    if (state is HomeScreenDataFetchSuccess) {
      return (state as HomeScreenDataFetchSuccess).teachers;
    }
    return [];
  }

  List<LeaveDetails> getTodayLeaves() {
    if (state is HomeScreenDataFetchSuccess) {
      return (state as HomeScreenDataFetchSuccess).todaysLeave;
    }
    return [];
  }

  List<Holiday> getHolidays() {
    if (state is HomeScreenDataFetchSuccess) {
      return (state as HomeScreenDataFetchSuccess).holidays;
    }
    return [];
  }
}
