import 'package:eschool_saas_staff/cubits/teacher/timeTableOfTeacherCubit.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/timetableSlotContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/weekdaysContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class TeacherTimeTableDetailsScreen extends StatefulWidget {
  final UserDetails teacherDetails;
  const TeacherTimeTableDetailsScreen(
      {super.key, required this.teacherDetails});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => TimeTableOfTeacherCubit(),
      child: TeacherTimeTableDetailsScreen(
        teacherDetails: arguments['teacherDetails'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required UserDetails teacherDetails}) {
    return {
      "teacherDetails": teacherDetails,
    };
  }

  @override
  State<TeacherTimeTableDetailsScreen> createState() =>
      _TeacherTimeTableDetailsScreenState();
}

class _TeacherTimeTableDetailsScreenState
    extends State<TeacherTimeTableDetailsScreen> {
  late String _selectedDayKey = Utils.weekDays.first;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<TimeTableOfTeacherCubit>()
            .getTimeTableOfTeacher(teacherId: widget.teacherDetails.id ?? 0);
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
        BlocBuilder<TimeTableOfTeacherCubit, TimeTableOfTeacherState>(
          builder: (context, state) {
            if (state is TimeTableOfTeacherFetchSuccess) {
              final slots = state.timeTableSlots
                  .where((element) =>
                      element.day ==
                      weekDays[Utils.weekDays.indexOf(_selectedDayKey)])
                  .toList();

              if (slots.isEmpty) {
                return Center(
                  child: noDataContainer(
                    titleKey: noTimeTableKey,
                  ),
                );
              }
              return Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      top: Utils.appContentTopScrollPadding(context: context) +
                          200),
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
                                    timeTableSlot.classSection?.fullName ?? "-",
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

            if (state is TimeTableOfTeacherFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context
                        .read<TimeTableOfTeacherCubit>()
                        .getTimeTableOfTeacher(
                            teacherId: widget.teacherDetails.id ?? 0);
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
              const CustomAppbar(titleKey: timetableKey),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 90,
                padding: EdgeInsets.all(appContentHorizontalPadding),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                        bottom: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary),
                        top: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary))),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextContainer(
                            textKey: widget.teacherDetails.fullName ?? "-",
                            style: const TextStyle(fontSize: 22),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    ProfileImageContainer(
                      imageUrl: widget.teacherDetails.image ?? "",
                      heightAndWidth: 60,
                    )
                  ],
                ),
              ),
              _buildDaysContainer(),
            ],
          ),
        ),
      ],
    ));
  }
}
