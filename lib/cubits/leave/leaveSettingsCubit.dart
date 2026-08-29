import 'package:eschool_saas_staff/data/models/leaveSettings.dart';
import 'package:eschool_saas_staff/data/models/publicHoliday.dart';
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
  final List<PublicHoliday> publicHolidays;

  LeaveSettingsAndSessionYearsFetchSuccess(
      {required this.leaveSettings,
      required this.sessionYears,
      required this.publicHolidays});
}

class LeaveSettingsAndSessionYearsFetchFailure
    extends LeaveSettingsAndSessionYearsState {
  final String errorMessage;

  LeaveSettingsAndSessionYearsFetchFailure(this.errorMessage);
}

class LeaveSettingsAndSessionYearsCubit
    extends Cubit<LeaveSettingsAndSessionYearsState> {
  final LeaveRepository _leaveRepository = LeaveRepository();
  final AcademicRepository _settingsRepository = AcademicRepository();

  LeaveSettingsAndSessionYearsCubit()
      : super(LeaveSettingsAndSessionYearsInitial());

  void getLeaveSettingsAndSessionYears() async {
    emit(LeaveSettingsAndSessionYearsFetchInProgress());
    try {
      final leaveSettingsResult = await _leaveRepository.getLeaveSettings();
      emit(LeaveSettingsAndSessionYearsFetchSuccess(
          sessionYears: await _settingsRepository.getSessionYears(),
          leaveSettings: leaveSettingsResult.leaveSettings,
          publicHolidays: leaveSettingsResult.publicHolidays));
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

  /// Returns a map of normalized public holiday dates to their titles.
  /// The DateTime keys have time set to midnight for reliable comparison.
  Map<DateTime, String> getPublicHolidayDates() {
    if (state is LeaveSettingsAndSessionYearsFetchSuccess) {
      final publicHolidays =
          (state as LeaveSettingsAndSessionYearsFetchSuccess).publicHolidays;
      Map<DateTime, String> holidayMap = {};
      for (var holiday in publicHolidays) {
        if (holiday.date != null && holiday.title != null) {
          // Normalize to midnight for reliable date comparison
          final normalizedDate = DateTime(
              holiday.date!.year, holiday.date!.month, holiday.date!.day);
          holidayMap[normalizedDate] = holiday.title!;
        }
      }
      return holidayMap;
    }
    return {};
  }
}
