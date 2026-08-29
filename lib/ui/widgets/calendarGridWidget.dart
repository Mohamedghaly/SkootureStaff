import 'package:eschool_saas_staff/data/models/teacherAttendance.dart';
import 'package:eschool_saas_staff/data/models/teacherLeave.dart';
import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarGridWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<TeacherAttendance> attendance;
  final List<Holiday>? holidays;
  final List<DateTime>? weeklyOffDates;
  final List<TeacherLeaveDetail>? leaveDetails;

  const CalendarGridWidget({
    Key? key,
    required this.selectedDate,
    required this.attendance,
    this.holidays,
    this.weeklyOffDates,
    this.leaveDetails,
  }) : super(key: key);

  /// Show holiday details in a dialog
  void _showHolidayDialog(BuildContext context, Holiday holiday) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.celebration_outlined,
                color: const Color(0xff9C27B0), // Purple color for holiday
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Holiday',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (holiday.title != null && holiday.title!.isNotEmpty) ...[
                  Text(
                    holiday.title!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (holiday.description != null &&
                    holiday.description!.isNotEmpty) ...[
                  Text(
                    holiday.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (holiday.dmyFormat != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        holiday.dmyFormat!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show weekly off dialog
  void _showWeeklyOffDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.weekend_outlined,
                color: Colors.grey[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Weekly Off',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This is a scheduled weekly off day.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show absent reason dialog
  void _showAbsentReasonDialog(
      BuildContext context, TeacherAttendance attendance) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.event_busy_outlined,
                color: const Color(0xffFF6768), // Red color for absent
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Absent',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reason',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                attendance.reason ?? '',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    attendance.date ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show half-day present dialog (for First Half/Second Half attendance)
  void _showHalfDayPresentDialog(
      BuildContext context, TeacherAttendance attendance) {
    // Determine if it's first half or second half
    final isFirstHalf = attendance.isFirstHalfPresent();
    final halfDayType = isFirstHalf ? 'First Half' : 'Second Half';
    final hasReason =
        attendance.reason != null && attendance.reason!.isNotEmpty;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.access_time,
                color: const Color(0xFFFF9800), // Orange color for half-day
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  halfDayType,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show reason if available
              if (hasReason) ...[
                Text(
                  'Reason',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  attendance.reason!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                // If no reason, show explanation about which half was present
                Text(
                  isFirstHalf
                      ? 'Present in the morning session'
                      : 'Present in the afternoon session',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    attendance.date ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show leave dialog for dates with approved leave
  void _showLeaveDialog(
      BuildContext context, TeacherLeaveDetail leaveDetail, int day) {
    // Determine leave type label
    String leaveTypeLabel = 'Leave';
    if (leaveDetail.isFullLeave()) {
      leaveTypeLabel = 'Full Day Leave';
    } else if (leaveDetail.isFirstHalfLeave()) {
      leaveTypeLabel = 'First Half Leave';
    } else if (leaveDetail.isSecondHalfLeave()) {
      leaveTypeLabel = 'Second Half Leave';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.event_note_outlined,
                color: const Color(0xFFFF9800), // Orange color for leave
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  leaveTypeLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have an approved leave for this date.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get first day of the month and number of days
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    // Create a map of attendance by day
    Map<int, TeacherAttendance> attendanceMap = {};
    for (var att in attendance) {
      final date = att.getAttendanceDate();
      if (date != null &&
          date.month == selectedDate.month &&
          date.year == selectedDate.year) {
        attendanceMap[date.day] = att;
      }
    }

    // Create a map of holiday days with their details from the holidays list
    // Using dmyFormat field (dd-MM-yyyy format, e.g., "17-12-2025") for accurate date matching
    Map<int, Holiday> holidayMap = {};
    if (holidays != null) {
      for (var holiday in holidays!) {
        // Use dmyFormat field for date parsing (dd-MM-yyyy format from API)
        if (holiday.dmyFormat != null && holiday.dmyFormat!.isNotEmpty) {
          try {
            // Parse date in dd-MM-yyyy format (e.g., "17-12-2025")
            final holidayDate =
                DateFormat('dd-MM-yyyy').parse(holiday.dmyFormat!);
            if (holidayDate.month == selectedDate.month &&
                holidayDate.year == selectedDate.year) {
              holidayMap[holidayDate.day] = holiday;
            }
          } catch (e) {
            debugPrint(
                'Failed to parse holiday dmyFormat: ${holiday.dmyFormat}, error: $e');
          }
        }
      }
    }

    // Create a set of weekly off days for the current month
    Set<int> weeklyOffDaySet = {};
    if (weeklyOffDates != null) {
      for (var weeklyOffDate in weeklyOffDates!) {
        if (weeklyOffDate.month == selectedDate.month &&
            weeklyOffDate.year == selectedDate.year) {
          weeklyOffDaySet.add(weeklyOffDate.day);
        }
      }
    }

    // Create a map of leave details by day for the current month
    // Each leave detail has a specific date and type (Full, First Half, Second Half)
    Map<int, TeacherLeaveDetail> leaveMap = {};
    if (leaveDetails != null) {
      for (var leaveDetail in leaveDetails!) {
        final date = leaveDetail.getLeaveDate();
        if (date != null &&
            date.month == selectedDate.month &&
            date.year == selectedDate.year) {
          leaveMap[date.day] = leaveDetail;
        }
      }
    }

    List<Widget> calendarDays = [];

    // Add previous month's last few days (faded)
    final previousMonth =
        DateTime(selectedDate.year, selectedDate.month - 1, 0);
    final daysInPreviousMonth = previousMonth.day;
    for (int i = firstWeekday - 1; i >= 0; i--) {
      final day = daysInPreviousMonth - i;
      calendarDays.add(
        Container(
          margin: const EdgeInsets.all(2),
          child: Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      );
    }

    // Add days of the current month
    for (int day = 1; day <= daysInMonth; day++) {
      final hasAttendance = attendanceMap.containsKey(day);
      final isPresent = hasAttendance ? attendanceMap[day]!.isPresent() : false;
      final isAbsent = hasAttendance ? attendanceMap[day]!.isAbsent() : false;
      final isHalfDay = hasAttendance ? attendanceMap[day]!.isHalfDay() : false;
      // Check if it's a holiday from either the attendance type or the holidays list
      final isHoliday = (hasAttendance && attendanceMap[day]!.isHoliday()) ||
          holidayMap.containsKey(day);
      // Check if it's a weekly off day
      final isWeeklyOff = weeklyOffDaySet.contains(day);
      // Check if this day has an approved leave
      final hasLeave = leaveMap.containsKey(day);
      final leaveDetail = hasLeave ? leaveMap[day] : null;
      final isToday = DateTime.now().day == day &&
          DateTime.now().month == selectedDate.month &&
          DateTime.now().year == selectedDate.year;

      // Determine if this date should be bold
      final shouldBeBold =
          day == 16 || day % 7 == 0; // Every Sunday or specific dates

      // Determine background color and decoration style
      Color backgroundColor;
      BoxShape shape;
      Border? border;

      // Priority: Weekly Off (HIGHEST) > Present/Absent > Holiday > Today > Default
      // Weekly off takes precedence over everything, including attendance data
      if (isWeeklyOff) {
        // Dark grey background for weekly off days
        backgroundColor = Colors.grey[600]!;
        shape = BoxShape.circle;
        border = null;
      } else if (isPresent) {
        backgroundColor = Color(0xff57CC99); // Green for present
        shape = BoxShape.circle;
        border = null;
      } else if (isAbsent) {
        backgroundColor = Color(0xffFF6768); // Red for absent
        shape = BoxShape.circle;
        border = null;
      } else if (hasLeave && !hasAttendance) {
        // Show leave status only if no attendance is marked yet
        // Orange background for leave dates
        backgroundColor = const Color(0xFFFF9800); // Orange for leave
        shape = BoxShape.circle;
        border = null;
      } else if (isHoliday) {
        // For holidays, use purple background with circle shape
        backgroundColor = const Color(0xff9C27B0); // Purple for holidays
        shape = BoxShape.circle;
        border = null;
      } else if (isToday) {
        backgroundColor = Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.8); // Highlight today
        shape = BoxShape.circle;
        border = null;
      } else {
        backgroundColor = Colors.transparent;
        shape = BoxShape.circle;
        border = null;
      }

      // Determine text color
      Color textColor;
      if (isWeeklyOff) {
        // White text for weekly off (dark grey background)
        textColor = Colors.white;
      } else if (isHoliday) {
        // White text for holiday (purple background)
        textColor = Colors.white;
      } else if (hasLeave && !hasAttendance) {
        // White text for leave (orange background)
        textColor = Colors.white;
      } else if (hasAttendance || isToday) {
        textColor = Colors.white;
      } else {
        textColor = Theme.of(context).colorScheme.onSurface;
      }

      // Get holiday details if this day is a holiday
      final Holiday? holidayDetails = holidayMap[day];

      Widget calendarCell = Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: shape,
          borderRadius:
              shape == BoxShape.rectangle ? BorderRadius.circular(8) : null,
          color: backgroundColor,
          border: border,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      shouldBeBold ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
            // Add a small indicator for weekly off to show they're tappable
            if (isWeeklyOff)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Add a small indicator for holidays to show they're tappable (only if not weekly off)
            if (!isWeeklyOff && isHoliday && holidayDetails != null)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Add a small indicator for absent dates with reason to show they're tappable
            if (!isWeeklyOff &&
                isAbsent &&
                hasAttendance &&
                attendanceMap[day]!.hasAbsenceReason())
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Add a small indicator for half-day dates to show they're tappable
            if (!isWeeklyOff && isHalfDay && isPresent && hasAttendance)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Add a half-day indicator (F for First Half, S for Second Half) - only if not weekly off
            if (!isWeeklyOff && isHalfDay && isPresent)
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    attendanceMap[day]!.isFirstHalfPresent() ? 'F' : 'S',
                    style: const TextStyle(
                        fontSize: 6,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
            // Add a small indicator for leave dates to show they're tappable
            if (!isWeeklyOff &&
                hasLeave &&
                !hasAttendance &&
                leaveDetail != null)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Add a leave indicator (L for Full, F for First Half, S for Second Half) - only if no attendance marked
            if (!isWeeklyOff &&
                hasLeave &&
                !hasAttendance &&
                leaveDetail != null)
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    leaveDetail.isFullLeave()
                        ? 'L'
                        : (leaveDetail.isFirstHalfLeave() ? 'F' : 'S'),
                    style: const TextStyle(
                        fontSize: 6,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      );

      // Wrap cells with GestureDetector based on priority (MUST match display color priority)
      // Priority order: Weekly Off > Attendance (Present/Absent/Half-day) > Leave > Holiday

      // 1. Weekly off takes highest priority
      if (isWeeklyOff) {
        final weeklyOffDate =
            DateTime(selectedDate.year, selectedDate.month, day);
        calendarCell = GestureDetector(
          onTap: () => _showWeeklyOffDialog(context, weeklyOffDate),
          child: calendarCell,
        );
      }
      // 2. Absent with attendance data (has reason to show)
      else if (isAbsent &&
          hasAttendance &&
          attendanceMap[day]!.hasAbsenceReason()) {
        calendarCell = GestureDetector(
          onTap: () => _showAbsentReasonDialog(context, attendanceMap[day]!),
          child: calendarCell,
        );
      }
      // 3. Half-day present with attendance data
      else if (isHalfDay && isPresent && hasAttendance) {
        calendarCell = GestureDetector(
          onTap: () => _showHalfDayPresentDialog(context, attendanceMap[day]!),
          child: calendarCell,
        );
      }
      // 4. Leave dates (only when no attendance is marked yet)
      else if (hasLeave && !hasAttendance && leaveDetail != null) {
        calendarCell = GestureDetector(
          onTap: () => _showLeaveDialog(context, leaveDetail, day),
          child: calendarCell,
        );
      }
      // 5. Holiday (lowest priority - only show if not covered by above cases)
      else if (isHoliday &&
          holidayDetails != null &&
          !hasAttendance &&
          !hasLeave) {
        calendarCell = GestureDetector(
          onTap: () => _showHolidayDialog(context, holidayDetails),
          child: calendarCell,
        );
      }

      calendarDays.add(calendarCell);
    }

    // Add next month's first few days (faded)
    final remainingCells =
        42 - calendarDays.length; // 6 rows * 7 days = 42 total cells
    for (int i = 1; i <= remainingCells; i++) {
      calendarDays.add(
        Container(
          margin: const EdgeInsets.all(2),
          child: Center(
            child: Text(
              i.toString(),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: 1,
        children: calendarDays,
      ),
    );
  }
}
