import 'dart:math';

import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/roundedBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/timetableSlotContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherTodaysTimetableContainer extends StatefulWidget {
  const TeacherTodaysTimetableContainer({super.key});

  @override
  State<TeacherTodaysTimetableContainer> createState() =>
      _TeacherTodaysTimetableContainerState();
}

class _TeacherTodaysTimetableContainerState
    extends State<TeacherTodaysTimetableContainer>
    with TickerProviderStateMixin {
  final int itemsToShowWithoutExpansion = 2;
  int appearDisappearAnimationDurationMilliseconds = 600;

  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);

  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _iconAngleAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      duration:
          Duration(milliseconds: appearDisappearAnimationDurationMilliseconds),
      vsync: this,
    );
    _iconAngleAnimation = Tween<double>(begin: 0, end: 180)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    super.initState();
  }

  @override
  void dispose() {
    _isExpanded.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleContainer() {
    if (_animation.status != AnimationStatus.completed) {
      _controller.forward();
      _isExpanded.value = true;
    } else {
      _controller.animateBack(
        0,
        duration: Duration(
            milliseconds: appearDisappearAnimationDurationMilliseconds),
        curve: Curves.fastLinearToSlowEaseIn,
      );
      _isExpanded.value = false;
    }
  }

  Widget _viewMoreViewLessContainer(
      {required bool isExpanded, required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          width: double.maxFinite,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextContainer(
                textKey: isExpanded ? viewLessKey : viewMoreKey,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AnimatedBuilder(
                animation: _iconAngleAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: (pi * _iconAngleAnimation.value) / 180,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherMyTimetableCubit, TeacherMyTimetableState>(
      builder: (context, state) {
        if (state is TeacherMyTimetableFetchSuccess) {
          final slots = state.timeTableSlots
              .where((element) =>
                  element.day == weekDays[DateTime.now().weekday - 1])
              .toList();

          if (slots.isEmpty) {
            return const SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: RoundedBackgroundContainer(
              child: Column(
                children: [
                  const ContentTitleWithViewMoreButton(
                      showViewMoreButton: false,
                      contentTitleKey: todaysTimetableKey),
                  const SizedBox(
                    height: 15,
                  ),
                  ...List.generate(
                    slots.length > itemsToShowWithoutExpansion
                        ? itemsToShowWithoutExpansion
                        : slots.length,
                    (index) {
                      final timeTableSlot = slots[index];
                      return TimetableSlotContainer(
                        note: timeTableSlot.note ?? "",
                        endTime: timeTableSlot.endTime ?? "",
                        isForClass: false,
                        classSectionName:
                            timeTableSlot.classSection?.fullName ?? "-",
                        startTime: timeTableSlot.startTime ?? "",
                        subjectName: timeTableSlot.subject?.name ?? "-",
                      );
                    },
                  ),
                  if (slots.length > itemsToShowWithoutExpansion)
                    SizeTransition(
                      sizeFactor: _animation,
                      axis: Axis.vertical,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          ...List.generate(
                            slots.length > itemsToShowWithoutExpansion
                                ? slots.length - itemsToShowWithoutExpansion
                                : 0,
                            (index) {
                              final timeTableSlot =
                                  slots[index + itemsToShowWithoutExpansion];
                              return TimetableSlotContainer(
                                note: timeTableSlot.note ?? "",
                                endTime: timeTableSlot.endTime ?? "",
                                isForClass: false,
                                classSectionName:
                                    timeTableSlot.classSection?.fullName ?? "-",
                                startTime: timeTableSlot.startTime ?? "",
                                subjectName: timeTableSlot.subject?.name ?? "-",
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  if (slots.length > itemsToShowWithoutExpansion)
                    ValueListenableBuilder(
                      valueListenable: _isExpanded,
                      builder: (context, isExpanded, _) {
                        return _viewMoreViewLessContainer(
                            isExpanded: isExpanded,
                            onTap: () {
                              _toggleContainer();
                            });
                      },
                    ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
