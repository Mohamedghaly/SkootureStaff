import 'dart:async';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/academics/classesAndSessionYearsCubit.dart';
import 'package:eschool_saas_staff/cubits/student/studentsCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class StudentDiarySelectionScreen extends StatefulWidget {
  const StudentDiarySelectionScreen({super.key});

  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ClassesAndSessionYearsCubit(),
          ),
          BlocProvider(
            create: (context) => StudentsCubit(),
          ),
        ],
        child: const StudentDiarySelectionScreen(),
      );

  @override
  State<StudentDiarySelectionScreen> createState() =>
      _StudentDiarySelectionScreenState();
}

class _StudentDiarySelectionScreenState
    extends State<StudentDiarySelectionScreen> {
  ClassSection? _selectedClassSection;
  SessionYear? _selectedSessionYear;
  Set<int> _selectedStudents = {};
  bool _isAllSelected = false;
  // Add a flag to track if we're in initialization phase
  bool _isInitializing = true;
  // Store the originally selected students to maintain them across class/session changes
  List<StudentDetails> _originallySelectedStudents = [];

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
        // Check if we received arguments from addNoteScreen
        final arguments = Get.arguments as Map<String, dynamic>?;
        if (arguments != null) {
          final previouslySelectedStudents =
              arguments['selectedStudents'] as List<dynamic>?;
          if (previouslySelectedStudents != null) {
            _originallySelectedStudents =
                previouslySelectedStudents.cast<StudentDetails>();
            _selectedStudents = previouslySelectedStudents
                .map<int>((student) => student.id as int)
                .toSet();
          }
          _selectedClassSection = arguments['classSection'] as ClassSection?;
          _selectedSessionYear = arguments['sessionYear'] as SessionYear?;
        }

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
      waitForNextRequestSearchQueryTimeInMilliSeconds =
          (nextSearchRequestQueryTimeInMilliSeconds -
              searchRequestPerodicMilliSeconds);
    }
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
    // Only clear selected students if this is not during initialization
    // and the class section is actually changing
    if (!_isInitializing && _selectedClassSection?.id != classSection.id) {
      _selectedStudents.clear();
      _isAllSelected = false;
    }
    _selectedClassSection = classSection;
    setState(() {});
  }

  void changeSelectedSessionYear(SessionYear sessionYear) {
    // Only clear selected students if this is not during initialization
    // and the session year is actually changing
    if (!_isInitializing && _selectedSessionYear?.id != sessionYear.id) {
      _selectedStudents.clear();
      _isAllSelected = false;
    }
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

  void toggleSelectAll() {
    final currentState = context.read<StudentsCubit>().state;
    if (currentState is StudentsFetchSuccess) {
      if (_isAllSelected) {
        _selectedStudents.clear();
        _isAllSelected = false;
      } else {
        _selectedStudents =
            currentState.students.map((student) => student.id!).toSet();
        _isAllSelected = true;
      }
      setState(() {});
    }
  }

  void toggleStudentSelection(int studentId) {
    if (_selectedStudents.contains(studentId)) {
      _selectedStudents.remove(studentId);
    } else {
      _selectedStudents.add(studentId);
    }

    final currentState = context.read<StudentsCubit>().state;
    if (currentState is StudentsFetchSuccess) {
      _isAllSelected = _selectedStudents.length == currentState.students.length;
    }
    setState(() {});
  }

  void navigateBackWithSelectedStudents() {
    final currentState = context.read<StudentsCubit>().state;
    if (currentState is StudentsFetchSuccess) {
      // Get the selected students from the current fetched list
      final selectedStudentsFromCurrentList = currentState.students
          .where((student) => _selectedStudents.contains(student.id))
          .toList();

      // Also include any originally selected students that might not be in the current list
      // (in case they were from a different class/session)
      final selectedStudentsData = <StudentDetails>[];

      // Add students from current list
      selectedStudentsData.addAll(selectedStudentsFromCurrentList);

      // Add originally selected students that are not in current list
      for (final originalStudent in _originallySelectedStudents) {
        final studentId = originalStudent.id;
        if (studentId != null && _selectedStudents.contains(studentId)) {
          // Check if this student is already in the selectedStudentsFromCurrentList
          final alreadyAdded = selectedStudentsFromCurrentList
              .any((student) => student.id == studentId);
          if (!alreadyAdded) {
            selectedStudentsData.add(originalStudent);
          }
        }
      }

      Get.back(result: {
        'selectedStudents': selectedStudentsData,
        'classSection': _selectedClassSection,
        'sessionYear': _selectedSessionYear,
      });
    } else {
      Get.back();
    }
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
              // If we don't have a selected class/session, set the default ones
              if (_selectedClassSection == null) {
                changeSelectedClassSection(context
                    .read<ClassesAndSessionYearsCubit>()
                    .getClasses()
                    .first);
              }
              if (_selectedSessionYear == null) {
                changeSelectedSessionYear(state.sessionYears
                    .where((element) => element.isThisDefault())
                    .first);
              }

              // Mark initialization as complete
              _isInitializing = false;

              getStudents();
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: studentDiaryKey),
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

  Widget _buildSelectAllButton() {
    return BlocBuilder<StudentsCubit, StudentsState>(
      builder: (context, state) {
        if (state is StudentsFetchSuccess && state.students.isNotEmpty) {
          return Container(
            width: double.maxFinite,
            margin:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            child: ElevatedButton(
              onPressed: toggleSelectAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAllSelected
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: CustomTextContainer(
                textKey: _isAllSelected ? deselectAllKey : selectAllKey,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildStudents() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
          top: Utils.appContentTopScrollPadding(context: context) + 60,
          bottom:
              100), // Add bottom padding to prevent content from being hidden behind the button
      child: Column(
        children: [
          SearchContainer(
            additionalCallback: () {
              getStudents();
            },
            textEditingController: _textEditingController,
          ),
          const SizedBox(height: 15),
          _buildSelectAllButton(),
          const SizedBox(height: 15),
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
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Theme.of(context).colorScheme.surface,
                      padding: EdgeInsets.all(appContentHorizontalPadding),
                      child: Column(
                        children: List.generate(state.students.length, (index) {
                          final studentDetails = state.students[index];

                          if (index == (state.students.length - 1)) {
                            if (context.read<StudentsCubit>().hasMore()) {
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
                                  indicatorColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }
                          }

                          final isSelected =
                              _selectedStudents.contains(studentDetails.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: GestureDetector(
                              onTap: () {
                                toggleStudentSelection(studentDetails.id!);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.maxFinite,
                                height: 120,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                        width: isSelected ? 2 : 1),
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.05)
                                        : Theme.of(context).colorScheme.surface,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : null),
                                child: LayoutBuilder(
                                    builder: (context, boxConstraints) {
                                  return Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                                appContentHorizontalPadding),
                                            width: boxConstraints.maxWidth,
                                            height: boxConstraints.maxHeight,
                                            child: Row(
                                              children: [
                                                ProfileImageContainer(
                                                  imageUrl:
                                                      studentDetails.image ??
                                                          "",
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      CustomTextContainer(
                                                        textKey: studentDetails
                                                                .fullName ??
                                                            "-",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: isSelected
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      CustomTextContainer(
                                                        textKey:
                                                            "GR No : ${studentDetails.student?.admissionNo ?? '-'}",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary
                                                                  .withValues(
                                                                      alpha:
                                                                          0.76),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            ),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Check if we came from addNoteScreen
        final arguments = Get.arguments as Map<String, dynamic>?;
        if (arguments != null) {
          navigateBackWithSelectedStudents();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
          body: Stack(
        children: [
          SafeArea(
            child: BlocBuilder<ClassesAndSessionYearsCubit,
                ClassesAndSessionYearsState>(
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
          ),
          _buildAppbarAndFilters(),

          // Fixed Continue Button at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: _buildFixedContinueButton()),
          ),
        ],
      )),
    );
  }

  Widget _buildFixedContinueButton() {
    return BlocBuilder<StudentsCubit, StudentsState>(
      builder: (context, state) {
        if (state is StudentsFetchSuccess && _selectedStudents.isNotEmpty) {
          return Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(appContentHorizontalPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: CustomRoundedButton(
              onTap: () {
                final selectedStudentsData = state.students
                    .where((student) => _selectedStudents.contains(student.id))
                    .toList();

                Get.toNamed(
                  Routes.addNoteScreen,
                  arguments: {
                    'selectedStudents': selectedStudentsData,
                    'classSection': _selectedClassSection,
                    'sessionYear': _selectedSessionYear,
                  },
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: continueKey,
              showBorder: false,
              widthPercentage: 1.0,
              height: 50,
              radius: 8,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
