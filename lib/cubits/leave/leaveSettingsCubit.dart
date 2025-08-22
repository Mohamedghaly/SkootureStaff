import 'package:eschool_saas_staff/data/models/leaveSettings.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:eschool_saas_staff/data/repositories/leaveRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LeaveSettingsAndSessionYearsState {}

class LeaveSettingsAndSessionYearsInitial
    extends LeaveSettingsAndSessionYearsState {}

class LeaveSettingsAndSessionYearsFetchInProgress
    extends LeaveSettingsAndSessionYearsState {}

class LeaveSettingsAndSessionYearsFetchSuccess
    extends LeaveSettingsAndSessionYearsState {
  final LeaveSettings leaveSettings;
  final List<SessionYear> sessionYears;

  LeaveSettingsAndSessionYearsFetchSuccess(
      {required this.leaveSettings, required this.sessionYears});
}

class LeaveSettingsAndSessionYearsFetchFailure
    extends LeaveSettingsAndSessionYearsState {
  final String errorMessage;

  LeaveSettingsAndSessionYearsFetchFailure(this.errorMessage);
}

class LeaveSettingsAndSessionYearsCubit extends Cubit<LeaveSettingsAndSessionYearsState> {
  final LeaveRepository _leaveRepository = LeaveRepository();
  final AcademicRepository _settingsRepository = AcademicRepository();

  LeaveSettingsAndSessionYearsCubit() : super(LeaveSettingsAndSessionYearsInitial());

  void getLeaveSettingsAndSessionYears() async {
    emit(LeaveSettingsAndSessionYearsFetchInProgress());
    try {
      emit(LeaveSettingsAndSessionYearsFetchSuccess(
          sessionYears: await _settingsRepository.getSessionYears(),
          leaveSettings: await _leaveRepository.getLeaveSettings()));
    } catch (e) {
      emit(LeaveSettingsAndSessionYearsFetchFailure(e.toString()));
    }
  }

  SessionYear getCurrentSessionYear() {
    if (state is LeaveSettingsAndSessionYearsFetchSuccess) {
      return (state as LeaveSettingsAndSessionYearsFetchSuccess)
          .sessionYears
          .firstWhere((element) => element.isThisDefault());
    }
    return SessionYear.fromJson({});
  }

  ///[It will get the day number of the holiday Ex. if sunday and staurday is holiday then it will return 6,7 ]
  List<int> getHolidayWeekDays() {
    if (state is LeaveSettingsAndSessionYearsFetchSuccess) {
      List<String> holidayDays =
          (state as LeaveSettingsAndSessionYearsFetchSuccess)
                  .leaveSettings
                  .holiday
                  ?.split(",") ??
              <String>[];
      List<int> holidayWeekDays = [];
      for (var holidayDay in holidayDays) {
        holidayWeekDays.add(weekDays.indexOf(holidayDay) + 1);
      }

      return holidayWeekDays;
    }
    return [];
  }
}
