import 'dart:async';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/academics/classesAndSessionYearsCubit.dart';
import 'package:eschool_saas_staff/cubits/student/studentsCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/ui/screens/studentProfileScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
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

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ClassesAndSessionYearsCubit(),
          ),
          BlocProvider(
            create: (context) => StudentsCubit(),
          ),
        ],
        child: const StudentsScreen(),
      );

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  ClassSection? _selectedClassSection;
  SessionYear? _selectedSessionYear;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  late final TextEditingController _textEditingController =
      TextEditingController()..addListener(searchQueryTextControllerListener);

  late int waitForNextRequestSearchQueryTimeInMilliSeconds =
      nextSearchRequestQueryTimeInMilliSeconds;

  Timer? waitForNextSearchRequestTimer;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ClassesAndSessionYearsCubit>().getClassesAndSessionYears();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _textEditingController.dispose();
    waitForNextSearchRequestTimer?.cancel();
    super.dispose();
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
        getStudents();
      } else {
        waitForNextRequestSearchQueryTimeInMilliSeconds =
            waitForNextRequestSearchQueryTimeInMilliSeconds -
                searchRequestPerodicMilliSeconds;
      }
    });
  }

  void scrollListener() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (context.read<StudentsCubit>().hasMore()) {
        getMoreStudents();
      }
    }
  }

  void changeSelectedClassSection(ClassSection classSection) {
    _selectedClassSection = classSection;
    setState(() {});
  }

  void changeSelectedSessionYear(SessionYear sessionYear) {
    _selectedSessionYear = sessionYear;
    setState(() {});
  }

  void getStudents() {
    context.read<StudentsCubit>().getStudents(
        search: _textEditingController.text.trim().isEmpty
            ? null
            : _textEditingController.text.trim(),
        classSectionId: _selectedClassSection?.id ?? 0,
        sessionYearId: _selectedSessionYear?.id);
  }

  void getMoreStudents() {
    context.read<StudentsCubit>().fetchMore(
        search: _textEditingController.text.trim().isEmpty
            ? null
            : _textEditingController.text.trim(),
        classSectionId: _selectedClassSection?.id ?? 0,
        sessionYearId: _selectedSessionYear?.id);
  }

  ///[This will be in use to display rollNo,class section and session year]
  Widget _buildStudentDetailsTitleAndValueContainer(
      {required double width,
      required String titleKey,
      required String value,
      required bool showBorder}) {
    return Container(
      decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ))
              : null),
      width: width,
      height: double.maxFinite,
      child: Column(
        children: [
          CustomTextContainer(
            textKey: value,
            style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          CustomTextContainer(
            textKey: titleKey,
            style: TextStyle(
                fontSize: 13.0,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.76)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAppbarAndFilters() {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocConsumer<ClassesAndSessionYearsCubit,
          ClassesAndSessionYearsState>(
        listener: (context, state) {
          if (state is ClassesAndSessionYearsFetchSuccess) {
            if (context
                    .read<ClassesAndSessionYearsCubit>()
                    .getClasses()
                    .isNotEmpty &&
                state.sessionYears.isNotEmpty) {
              changeSelectedClassSection(context
                  .read<ClassesAndSessionYearsCubit>()
                  .getClasses()
                  .first);
              changeSelectedSessionYear(state.sessionYears
                  .where((element) => element.isThisDefault())
                  .first);
              getStudents();
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: studentsKey),
              AppbarFilterBackgroundContainer(
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilterButton(
                          onTap: () {
                            if (state is ClassesAndSessionYearsFetchSuccess &&
                                context
                                    .read<ClassesAndSessionYearsCubit>()
                                    .getClasses()
                                    .isNotEmpty) {
                              Utils.showBottomSheet(
                                  child: FilterSelectionBottomsheet<
                                          ClassSection>(
                                      onSelection: (value) {
                                        changeSelectedClassSection(value!);
                                        getStudents();
                                        Get.back();
                                      },
                                      selectedValue: _selectedClassSection!,
                                      titleKey: classKey,
                                      values: context
                                          .read<ClassesAndSessionYearsCubit>()
                                          .getClasses()),
                                  context: context);
                            }
                          },
                          titleKey: _selectedClassSection?.id == null
                              ? classKey
                              : (_selectedClassSection?.fullName ?? ""),
                          width: boxConstraints.maxWidth * (0.48)),
                      FilterButton(
                          onTap: () {
                            if (state is ClassesAndSessionYearsFetchSuccess &&
                                state.sessionYears.isNotEmpty) {
                              Utils.showBottomSheet(
                                  child:
                                      FilterSelectionBottomsheet<SessionYear>(
                                    selectedValue: _selectedSessionYear!,
                                    titleKey: sessionYearKey,
                                    values: state.sessionYears,
                                    onSelection: (value) {
                                      changeSelectedSessionYear(value!);
                                      getStudents();
                                      Get.back();
                                    },
                                  ),
                                  context: context);
                            }
                          },
                          titleKey: _selectedSessionYear?.id == null
                              ? sessionYearKey
                              : _selectedSessionYear!.name ?? "",
                          width: boxConstraints.maxWidth * (0.48)),
                    ],
                  );
                }),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudents() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
          top: Utils.appContentTopScrollPadding(context: context) + 90),
      child: Column(
        children: [
          SearchContainer(
            additionalCallback: () {
              getStudents();
            },
            textEditingController: _textEditingController,
          ),
          const SizedBox(
            height: 25,
          ),
          BlocBuilder<StudentsCubit, StudentsState>(
            builder: (context, state) {
              if (state is StudentsFetchSuccess) {
                if (state.students.isEmpty) {
                  return Center(
                    child: noDataContainer(
                      titleKey: noStudentsKey,
                    ),
                  );
                }
                return Column(
                  children: [
                    state.students.isEmpty
                        ? const Center(
                            child: noDataContainer(titleKey: noStudentsKey),
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            color: Theme.of(context).colorScheme.surface,
                            padding:
                                EdgeInsets.all(appContentHorizontalPadding),
                            child: Column(
                              children:
                                  List.generate(state.students.length, (index) {
                                final studentDetails = state.students[index];

                                if (index == (state.students.length - 1)) {
                                  //
                                  if (context.read<StudentsCubit>().hasMore()) {
                                    //
                                    if (state.fetchMoreError) {
                                      return Center(
                                        child: CustomTextButton(
                                            buttonTextKey: retryKey,
                                            onTapButton: () {
                                              getMoreStudents();
                                            }),
                                      );
                                    }
                                    return Center(
                                      child: CustomCircularProgressIndicator(
                                        indicatorColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    );
                                  }
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.studentProfileScreen,
                                          arguments: StudentProfileScreen
                                              .buildArguments(
                                                  classSection:
                                                      _selectedClassSection ??
                                                          ClassSection.fromJson(
                                                              {}),
                                                  sessionYear:
                                                      _selectedSessionYear ??
                                                          SessionYear.fromJson(
                                                              {}),
                                                  studentDetails:
                                                      studentDetails));
                                    },
                                    child: Container(
                                      width: double.maxFinite,
                                      height: 160,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary)),
                                      child: LayoutBuilder(
                                          builder: (context, boxConstraints) {
                                        return Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      appContentHorizontalPadding),
                                              width: boxConstraints.maxWidth,
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .tertiary))),
                                              height: boxConstraints.maxHeight *
                                                  (0.55),
                                              child: Row(
                                                children: [
                                                  ProfileImageContainer(
                                                    imageUrl:
                                                        studentDetails.image ??
                                                            "",
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                      child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      CustomTextContainer(
                                                        textKey: studentDetails
                                                                .fullName ??
                                                            "-",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      CustomTextContainer(
                                                        textKey:
                                                            "GR No : ${studentDetails.student?.admissionNo ?? '-'}",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary
                                                                .withValues(
                                                                    alpha:
                                                                        0.76)),
                                                      ),
                                                    ],
                                                  )),
                                                  CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                                alpha: 0.1),
                                                    child: Icon(
                                                      Utils.isRTLEnabled(
                                                              context)
                                                          ? CupertinoIcons
                                                              .arrow_left
                                                          : CupertinoIcons
                                                              .arrow_right,
                                                      size: 17.5,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: boxConstraints.maxHeight *
                                                  (0.45),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    appContentHorizontalPadding),
                                                child: LayoutBuilder(builder:
                                                    (context,
                                                        innnerBoxconstraints) {
                                                  return Row(
                                                    children: [
                                                      _buildStudentDetailsTitleAndValueContainer(
                                                          showBorder: false,
                                                          width:
                                                              innnerBoxconstraints
                                                                      .maxWidth *
                                                                  (0.325),
                                                          titleKey: rollNoKey,
                                                          value: studentDetails
                                                                  .student
                                                                  ?.rollNumber
                                                                  ?.toString() ??
                                                              "-"),
                                                      _buildStudentDetailsTitleAndValueContainer(
                                                          showBorder: true,
                                                          width:
                                                              innnerBoxconstraints
                                                                      .maxWidth *
                                                                  (0.35),
                                                          titleKey: statusKey,
                                                          value: studentDetails
                                                                  .isActive()
                                                              ? activeKey
                                                              : inactiveKey),
                                                      _buildStudentDetailsTitleAndValueContainer(
                                                          showBorder: false,
                                                          width:
                                                              innnerBoxconstraints
                                                                      .maxWidth *
                                                                  (0.325),
                                                          titleKey: genderKey,
                                                          value: studentDetails
                                                              .getGender()),
                                                    ],
                                                  );
                                                }),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                  ],
                );
              }
              if (state is StudentsFetchFailure) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: topPaddingOfErrorAndLoadingContainer),
                    child: ErrorContainer(
                      errorMessage: state.errorMessage,
                      onTapRetry: () {
                        getStudents();
                      },
                    ),
                  ),
                );
              }
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        BlocBuilder<ClassesAndSessionYearsCubit, ClassesAndSessionYearsState>(
          builder: (context, state) {
            if (state is ClassesAndSessionYearsFetchSuccess) {
              if (context
                  .read<ClassesAndSessionYearsCubit>()
                  .getClasses()
                  .isEmpty) {
                return const noDataContainer(titleKey: noStudentsKey);
              }
              if (state.sessionYears.isNotEmpty &&
                  context
                      .read<ClassesAndSessionYearsCubit>()
                      .getClasses()
                      .isNotEmpty) {
                return _buildStudents();
              }

              return const SizedBox();
            }

            if (state is ClassesAndSessionYearsFetchFailure) {
              return Center(
                  child: ErrorContainer(
                errorMessage: state.errorMessage,
                onTapRetry: () {
                  context
                      .read<ClassesAndSessionYearsCubit>()
                      .getClassesAndSessionYears();
                },
              ));
            }

            return Center(
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
        _buildAppbarAndFilters(),
      ],
    ));
  }
}
