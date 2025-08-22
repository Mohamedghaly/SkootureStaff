import 'dart:math';

import 'package:eschool_saas_staff/cubits/exam/downloadStudentResultCubit.dart';
import 'package:eschool_saas_staff/data/models/studentResult.dart';
import 'package:eschool_saas_staff/ui/screens/offlineResult/widgets/downloadStudentResultDialog.dart';
import 'package:eschool_saas_staff/ui/screens/offlineResult/widgets/studentResultSubjectMarksBottomsheet.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class StudentOfflineResultContainer extends StatefulWidget {
  final StudentResult studentResult;
  final String examName;
  final int index;
  const StudentOfflineResultContainer(
      {super.key,
      required this.studentResult,
      required this.index,
      required this.examName});

  @override
  State<StudentOfflineResultContainer> createState() =>
      _StudentOfflineResultContainerState();
}

class _StudentOfflineResultContainerState
    extends State<StudentOfflineResultContainer> with TickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: tileCollapsedDuration);

  late final Animation<double> _heightAnimation =
      Tween<double>(begin: 85, end: 300).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.0, 0.5)));

  late final Animation<double> _opacityAnimation =
      Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.5, 1.0)));

  late final Animation<double> _iconAngleAnimation =
      Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut));

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildResultDetailsContainer(
      {required double width,
      required String value,
      required String title,
      required Color backgroundColor}) {
    return Container(
      width: width,
      height: 80,
      padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding, vertical: 12.5),
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(5.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextContainer(
            textKey: value,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
          ),
          CustomTextContainer(
            textKey: title,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              if (_animationController.isAnimating) {
                return;
              }

              if (_animationController.isCompleted) {
                _animationController.reverse();
              } else {
                _animationController.forward();
              }
            },
            child: Container(
              height: _heightAnimation.value,
              padding: EdgeInsets.symmetric(
                  vertical: appContentHorizontalPadding,
                  horizontal: appContentHorizontalPadding),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary))),
              child: LayoutBuilder(builder: (context, boxConstraints) {
                return Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: boxConstraints.maxWidth * (0.15),
                          child: CustomTextContainer(
                              textKey: (widget.index + 1)
                                  .toString()
                                  .padLeft(2, '0')),
                        ),
                        SizedBox(
                          width: boxConstraints.maxWidth * (0.85),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextContainer(
                                    textKey: widget.studentResult.studentDetails
                                            ?.fullName ??
                                        "-",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  CustomTextContainer(
                                    textKey: widget.examName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              )),
                              Transform.rotate(
                                angle: (pi * _iconAngleAnimation.value) / 180,
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    _animationController.value > 0.5
                        ? Opacity(
                            opacity: _opacityAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildResultDetailsContainer(
                                          width:
                                              boxConstraints.maxWidth * (0.48),
                                          value: widget.studentResult.totalMarks
                                                  ?.toStringAsFixed(2) ??
                                              "-",
                                          title: totalMarksKey,
                                          backgroundColor: Theme.of(context)
                                              .extension<CustomColors>()!
                                              .leaveRequestOverviewBackgroundColor!
                                              .withValues(alpha: 0.15)),
                                      _buildResultDetailsContainer(
                                          width:
                                              boxConstraints.maxWidth * (0.48),
                                          value: widget
                                                  .studentResult.obtainedMarks
                                                  ?.toStringAsFixed(2) ??
                                              "-",
                                          title: obtainedMarksKey,
                                          backgroundColor: Theme.of(context)
                                              .extension<CustomColors>()!
                                              .totalStaffOverviewBackgroundColor!
                                              .withValues(alpha: 0.15)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildResultDetailsContainer(
                                          width:
                                              boxConstraints.maxWidth * (0.48),
                                          value: widget.studentResult.percentage
                                                  ?.toStringAsFixed(2) ??
                                              "-",
                                          title: percentageKey,
                                          backgroundColor: Theme.of(context)
                                              .extension<CustomColors>()!
                                              .totalStudentOverviewBackgroundColor!
                                              .withValues(alpha: 0.15)),
                                      _buildResultDetailsContainer(
                                          width:
                                              boxConstraints.maxWidth * (0.48),
                                          value:
                                              widget.studentResult.grade ?? "-",
                                          title: gradeKey,
                                          backgroundColor: Theme.of(context)
                                              .extension<CustomColors>()!
                                              .totalTeacherOverviewBackgroundColor!
                                              .withValues(alpha: 0.15)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomTextButton(
                                          textStyle: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          buttonTextKey: viewDetailsKey,
                                          onTapButton: () {
                                            Utils.showBottomSheet(
                                                child: StudentResultSubjectMarksBottomsheet(
                                                    subjectResults: widget
                                                            .studentResult
                                                            .studentDetails
                                                            ?.offlineExamMarks ??
                                                        []),
                                                context: context);
                                          }),
                                      const Spacer(),
                                      CustomTextButton(
                                          textStyle: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          buttonTextKey: downloadResultKey,
                                          onTapButton: () {
                                            Get.dialog(
                                              BlocProvider(
                                                create: (_) =>
                                                    DownloadStudentResultCubit(),
                                                child:
                                                    DownloadStudentResultDialog(
                                                        childId: widget
                                                                .studentResult
                                                                .studentId ??
                                                            0,
                                                        examId: widget
                                                                .studentResult
                                                                .examId ??
                                                            0),
                                              ),
                                            );
                                          })
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                );
              }),
            ),
          );
        });
  }
}
