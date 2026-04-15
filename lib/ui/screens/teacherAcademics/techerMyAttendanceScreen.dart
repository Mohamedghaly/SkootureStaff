import 'package:eschool_saas_staff/cubits/teacherAttendanceCubit.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/attendanceCalendarContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/attendanceSummaryWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/shimmerCalendarWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/shimmerSummaryWidget.dart';

import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherMyAttendanceScreen extends StatefulWidget {
  const TeacherMyAttendanceScreen({Key? key}) : super(key: key);

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => TeacherAttendanceCubit(),
      child: const TeacherMyAttendanceScreen(),
    );
  }

  @override
  State<TeacherMyAttendanceScreen> createState() =>
      _TeacherMyAttendanceScreenState();
}

class _TeacherMyAttendanceScreenState extends State<TeacherMyAttendanceScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  PageController _pageController = PageController();
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  // Session year boundaries
  DateTime? _sessionStartDate;
  DateTime? _sessionEndDate;

  @override
  void initState() {
    super.initState();

    // Initialize shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Start shimmer animation
    _shimmerController.repeat();

    // Initialize with current date, but it will be adjusted when session year data loads
    _selectedDate = DateTime.now();

    Future.delayed(Duration.zero, () {
      _fetchAttendance();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _fetchAttendance() {
    context.read<TeacherAttendanceCubit>().fetchTeacherAttendance(
          month: _selectedDate.month,
          year: _selectedDate.year,
        );
  }

  void _setSessionYearBoundaries(SessionYear sessionYear) {
    if (sessionYear.startDate != null && sessionYear.endDate != null) {
      try {
        _sessionStartDate = DateTime.parse(sessionYear.startDate!);
        _sessionEndDate = DateTime.parse(sessionYear.endDate!);

        // Adjust selected date if it's outside session boundaries
        if (_selectedDate.isBefore(_sessionStartDate!)) {
          _selectedDate = _sessionStartDate!;
        } else if (_selectedDate.isAfter(_sessionEndDate!)) {
          _selectedDate = _sessionEndDate!;
        }
      } catch (e) {
        // If date parsing fails, don't set boundaries
        debugPrint('Error parsing session year dates: $e');
      }
    }
  }

  void _previousMonth() {
    if (_sessionStartDate != null) {
      final previousMonth =
          DateTime(_selectedDate.year, _selectedDate.month - 1);
      if (previousMonth.isBefore(_sessionStartDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Cannot navigate before session start date (${_sessionStartDate!.year}-${_sessionStartDate!.month.toString().padLeft(2, '0')})'),
            duration: const Duration(seconds: 2),
          ),
        );
        return; // Don't allow navigation before session start
      }
    }

    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
    _fetchAttendance();
  }

  void _nextMonth() {
    if (_sessionEndDate != null) {
      final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1);
      if (nextMonth.isAfter(_sessionEndDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Cannot navigate after session end date (${_sessionEndDate!.year}-${_sessionEndDate!.month.toString().padLeft(2, '0')})'),
            duration: const Duration(seconds: 2),
          ),
        );
        return; // Don't allow navigation after session end
      }
    }

    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
    _fetchAttendance();
  }

  bool _isPreviousMonthDisabled() {
    if (_sessionStartDate != null) {
      final previousMonth =
          DateTime(_selectedDate.year, _selectedDate.month - 1);
      return previousMonth.isBefore(_sessionStartDate!);
    }
    return false;
  }

  bool _isNextMonthDisabled() {
    if (_sessionEndDate != null) {
      final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1);
      return nextMonth.isAfter(_sessionEndDate!);
    }

    // Also check current date as fallback
    final now = DateTime.now();
    return _selectedDate.year >= now.year && _selectedDate.month >= now.month;
  }

  Widget _buildAttendanceCalendar() {
    return BlocBuilder<TeacherAttendanceCubit, TeacherAttendanceState>(
      builder: (context, state) {
        // Show shimmer effect for initial state and loading state
        if (state is TeacherAttendanceInitial ||
            state is TeacherAttendanceFetchInProgress) {
          return Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ShimmerCalendarWidget(
                    selectedDate: _selectedDate,
                    sessionStartDate: _sessionStartDate,
                    sessionEndDate: _sessionEndDate,
                    onPreviousMonth: _previousMonth,
                    onNextMonth: _nextMonth,
                    isPreviousMonthDisabled: _isPreviousMonthDisabled(),
                    isNextMonthDisabled: _isNextMonthDisabled(),
                    shimmerAnimation: _shimmerAnimation,
                  ),
                  ShimmerSummaryWidget(
                    shimmerAnimation: _shimmerAnimation,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is TeacherAttendanceFetchFailure) {
          return Expanded(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: _fetchAttendance,
            ),
          );
        }

        if (state is TeacherAttendanceFetchSuccess) {
          // Set session year boundaries when data is first loaded
          if (_sessionStartDate == null || _sessionEndDate == null) {
            _setSessionYearBoundaries(state.sessionYear);
          }

          return Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AttendanceCalendarContainer(
                    selectedDate: _selectedDate,
                    sessionStartDate: _sessionStartDate,
                    sessionEndDate: _sessionEndDate,
                    onPreviousMonth: _previousMonth,
                    onNextMonth: _nextMonth,
                    isPreviousMonthDisabled: _isPreviousMonthDisabled(),
                    isNextMonthDisabled: _isNextMonthDisabled(),
                    attendance: state.attendance,
                    holidays: state.holidays,
                    weeklyOffDates: state.weeklyOffDates,
                    leaveDetails: state.leaveDetails,
                  ),
                  AttendanceSummaryWidget(
                    totalPresent: state.totalPresent,
                    totalAbsent: state.totalAbsent,
                  ),
                ],
              ),
            ),
          );
        }

        // Fallback shimmer for any other state
        return Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ShimmerCalendarWidget(
                  selectedDate: _selectedDate,
                  sessionStartDate: _sessionStartDate,
                  sessionEndDate: _sessionEndDate,
                  onPreviousMonth: _previousMonth,
                  onNextMonth: _nextMonth,
                  isPreviousMonthDisabled: _isPreviousMonthDisabled(),
                  isNextMonthDisabled: _isNextMonthDisabled(),
                  shimmerAnimation: _shimmerAnimation,
                ),
                ShimmerSummaryWidget(
                  shimmerAnimation: _shimmerAnimation,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(titleKey: attendanceKey),
      body: Column(
        children: [
          _buildAttendanceCalendar(),
        ],
      ),
    );
  }
}
