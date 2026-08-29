import 'package:eschool_saas_staff/data/models/teacherAttendance.dart';
import 'package:eschool_saas_staff/data/models/teacherLeave.dart';
import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/ui/widgets/monthSelectorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/weekdayHeadersWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/calendarGridWidget.dart';
import 'package:flutter/material.dart';

class AttendanceCalendarContainer extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime? sessionStartDate;
  final DateTime? sessionEndDate;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final bool isPreviousMonthDisabled;
  final bool isNextMonthDisabled;
  final List<TeacherAttendance> attendance;
  final List<Holiday>? holidays;
  final List<DateTime>? weeklyOffDates;
  final List<TeacherLeaveDetail>? leaveDetails;

  const AttendanceCalendarContainer({
    Key? key,
    required this.selectedDate,
    this.sessionStartDate,
    this.sessionEndDate,
    this.onPreviousMonth,
    this.onNextMonth,
    required this.isPreviousMonthDisabled,
    required this.isNextMonthDisabled,
    required this.attendance,
    this.holidays,
    this.weeklyOffDates,
    this.leaveDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          MonthSelectorWidget(
            selectedDate: selectedDate,
            sessionStartDate: sessionStartDate,
            sessionEndDate: sessionEndDate,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            isPreviousMonthDisabled: isPreviousMonthDisabled,
            isNextMonthDisabled: isNextMonthDisabled,
          ),
          const WeekdayHeadersWidget(),
          CalendarGridWidget(
            selectedDate: selectedDate,
            attendance: attendance,
            holidays: holidays,
            weeklyOffDates: weeklyOffDates,
            leaveDetails: leaveDetails,
          ),
        ],
      ),
    );
  }
}
