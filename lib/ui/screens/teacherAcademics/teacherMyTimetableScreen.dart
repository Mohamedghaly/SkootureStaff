import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/timetableSlotContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/weekdaysContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherMyTimetableScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    return const TeacherMyTimetableScreen();
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherMyTimetableScreen({super.key});

  @override
  State<TeacherMyTimetableScreen> createState() =>
      _TeacherMyTimetableScreenState();
}

class _TeacherMyTimetableScreenState extends State<TeacherMyTimetableScreen> {
  late String _selectedDayKey = Utils.weekDays[DateTime.now().weekday - 1];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<TeacherMyTimetableCubit>().getTeacherMyTimetable();
      }
    });
  }

  Widget _buildDaysContainer() {
    return WeekdaysContainer(
      selectedDayKey: _selectedDayKey,
      onSelectionChange: (String newSelection) {
        setState(() {
          _selectedDayKey = newSelection;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<TeacherMyTimetableCubit, TeacherMyTimetableState>(
            builder: (context, state) {
              if (state is TeacherMyTimetableFetchSuccess) {
                final slots = state.timeTableSlots
                    .where((element) =>
                        element.day ==
                        weekDays[Utils.weekDays.indexOf(_selectedDayKey)])
                    .toList();

                if (slots.isEmpty) {
                  return const noDataContainer(titleKey: noTimeTableKey);
                }
                return Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        bottom: 25,
                        top:
                            Utils.appContentTopScrollPadding(context: context) +
                                110),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(appContentHorizontalPadding),
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        children: slots
                            .map((timeTableSlot) => TimetableSlotContainer(
                                  note: timeTableSlot.note ?? "",
                                  endTime: timeTableSlot.endTime ?? "",
                                  isForClass: false,
                                  classSectionName:
                                      timeTableSlot.classSection?.fullName ??
                                          "-",
                                  startTime: timeTableSlot.startTime ?? "",
                                  subjectName: timeTableSlot.subject
                                          ?.getSybjectNameWithType() ??
                                      "-",
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                );
              }

              if (state is TeacherMyTimetableFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context
                          .read<TeacherMyTimetableCubit>()
                          .getTeacherMyTimetable();
                    },
                  ),
                );
              }

              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const CustomAppbar(titleKey: myTimetableKey),
                _buildDaysContainer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
