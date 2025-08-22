import 'dart:async';

import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/teacher/teachersCubit.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/leavesScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherProfileScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherTimeTableDetailsScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/searchContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

enum TeacherNavigationType { leave, profile, timetable }

class TeachersScreen extends StatefulWidget {
  final TeacherNavigationType teacherNavigationType;
  const TeachersScreen({super.key, required this.teacherNavigationType});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => TeachersCubit(),
      child: TeachersScreen(
        teacherNavigationType: arguments['teacherNavigationType'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required TeacherNavigationType teacherNavigationType}) {
    return {"teacherNavigationType": teacherNavigationType};
  }

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  late final TextEditingController _textEditingController =
      TextEditingController()..addListener(searchQueryTextControllerListener);

  late int waitForNextRequestSearchQueryTimeInMilliSeconds =
      nextSearchRequestQueryTimeInMilliSeconds;

  Timer? waitForNextSearchRequestTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getTeachers();
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    waitForNextSearchRequestTimer?.cancel();
    super.dispose();
  }

  void getTeachers() {
    context.read<TeachersCubit>().getTeachers(
        search: _textEditingController.text.trim().isEmpty
            ? null
            : _textEditingController.text.trim());
  }

  void searchQueryTextControllerListener() {
    if (_textEditingController.text.trim().isEmpty) {
      return;
    }
    waitForNextSearchRequestTimer?.cancel();
    setWaitForNextSearchRequestTimer();
  }

  void setWaitForNextSearchRequestTimer() {
    if (waitForNextRequestSearchQueryTimeInMilliSeconds !=
        (waitForNextRequestSearchQueryTimeInMilliSeconds -
            searchRequestPerodicMilliSeconds)) {
      //
      waitForNextRequestSearchQueryTimeInMilliSeconds =
          (nextSearchRequestQueryTimeInMilliSeconds -
              searchRequestPerodicMilliSeconds);
    }
    //
    waitForNextSearchRequestTimer = Timer.periodic(
        Duration(milliseconds: searchRequestPerodicMilliSeconds), (timer) {
      if (waitForNextRequestSearchQueryTimeInMilliSeconds == 0) {
        timer.cancel();
        getTeachers();
      } else {
        waitForNextRequestSearchQueryTimeInMilliSeconds =
            waitForNextRequestSearchQueryTimeInMilliSeconds -
                searchRequestPerodicMilliSeconds;
      }
    });
  }

  String getNavigationTitleKey() {
    if (widget.teacherNavigationType == TeacherNavigationType.leave) {
      return viewLeavesKey;
    }
    if (widget.teacherNavigationType == TeacherNavigationType.timetable) {
      return timetableKey;
    }
    return viewProfileKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                top: Utils.appContentTopScrollPadding(context: context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: SearchContainer(
                    additionalCallback: () {
                      getTeachers();
                    },
                    textEditingController: _textEditingController,
                  ),
                ),
                BlocBuilder<TeachersCubit, TeachersState>(
                  builder: (context, state) {
                    if (state is TeachersFetchSuccess) {
                      if (state.teachers.isEmpty) {
                        return Center(
                          child: noDataContainer(
                            titleKey: noTeachersKey,
                          ),
                        );
                      }
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(appContentHorizontalPadding),
                        color: Theme.of(context).colorScheme.surface,
                        child:
                            LayoutBuilder(builder: (context, boxConstraints) {
                          return Wrap(
                            spacing: boxConstraints.maxWidth * (0.04),
                            runSpacing: 15,
                            children: state.teachers
                                .map((teacher) => Container(
                                      height: 200,
                                      padding: const EdgeInsets.all(15),
                                      width: boxConstraints.maxWidth * (0.48),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Column(
                                        children: [
                                          ProfileImageContainer(
                                            imageUrl: teacher.image ?? "",
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0),
                                            child: CustomTextContainer(
                                              textKey: teacher.fullName ?? "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 7.5),
                                            child: CustomTextContainer(
                                              textKey: teacher.isActive()
                                                  ? activeKey
                                                  : inactiveKey,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 13.0),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (widget
                                                      .teacherNavigationType ==
                                                  TeacherNavigationType.leave) {
                                                Get.toNamed(Routes.leavesScreen,
                                                    arguments: LeavesScreen
                                                        .buildArguments(
                                                            showMyLeaves: false,
                                                            userDetails:
                                                                teacher));
                                              } else if (widget
                                                      .teacherNavigationType ==
                                                  TeacherNavigationType
                                                      .timetable) {
                                                Get.toNamed(
                                                    Routes
                                                        .teacherTimeTableDetailsScreen,
                                                    arguments:
                                                        TeacherTimeTableDetailsScreen
                                                            .buildArguments(
                                                                teacherDetails:
                                                                    teacher));
                                              } else {
                                                Get.toNamed(
                                                    Routes.teacherProfileScreen,
                                                    arguments:
                                                        TeacherProfileScreen
                                                            .buildArguments(
                                                                userDetails:
                                                                    teacher));
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              width: double.maxFinite,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: CustomTextContainer(
                                                      textKey:
                                                          getNavigationTitleKey(),
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Icon(
                                                    Utils.isRTLEnabled(context)
                                                        ? CupertinoIcons
                                                            .arrow_left
                                                        : CupertinoIcons
                                                            .arrow_right,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    size: 18,
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ))
                                .toList(),
                          );
                        }),
                      );
                    }
                    if (state is TeachersFetchFailure) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: topPaddingOfErrorAndLoadingContainer),
                          child: ErrorContainer(
                            errorMessage: state.errorMessage,
                            onTapRetry: () {
                              getTeachers();
                            },
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.only(
                          top: topPaddingOfErrorAndLoadingContainer),
                      child: Center(
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const Align(
          alignment: Alignment.topCenter,
          child: CustomAppbar(titleKey: teachersKey),
        ),
      ],
    ));
  }
}
