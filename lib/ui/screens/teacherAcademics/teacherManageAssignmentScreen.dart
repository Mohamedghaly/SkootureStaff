import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/assignmentCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/deleteAssignmentCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/data/models/assignment.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddEditAssignmentScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherManageAssignmentSubmissionScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/confirmDeleteDialog.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customExpandableContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customTitleDescriptionContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherManageAssignmentScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AssignmentCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: const TeacherManageAssignmentScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherManageAssignmentScreen({super.key});

  @override
  State<TeacherManageAssignmentScreen> createState() =>
      _TeacherManageAssignmentScreenState();
}

class _TeacherManageAssignmentScreenState
    extends State<TeacherManageAssignmentScreen> {
  List<ClassSection>? _selectedClassSection;
  TeacherSubject? _selectedSubject;
  Function? classSectionListener;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  void _getClassSectionAndSubjects() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
                teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _getClassSectionAndSubjects();
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (context.read<AssignmentCubit>().hasMore()) {
        getMoreAssignments();
      }
    }
  }

  void changeSelectedClassSection(List<ClassSection>? classSections,
      {bool fetchNewSubjects = true}) {
    if (_selectedClassSection != classSections) {
      _selectedClassSection = classSections;

      if (fetchNewSubjects &&
          _selectedClassSection != null &&
          _selectedClassSection!.isNotEmpty) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getNewSubjectsFromSelectedClassSectionIndex(
                teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0,
                newClassSectionId:
                    _selectedClassSection!.map((e) => e.id ?? 0).toList())
            .then((value) {
          if (mounted) {
            if (context.read<ClassSectionsAndSubjectsCubit>().state
                is ClassSectionsAndSubjectsFetchSuccess) {
              final successState = context
                  .read<ClassSectionsAndSubjectsCubit>()
                  .state as ClassSectionsAndSubjectsFetchSuccess;
              if (successState.subjects.isNotEmpty) {
                changeSelectedTeacherSubject(successState.subjects.first);
              } else {
                changeSelectedTeacherSubject(null);
              }
            }
          }
        });
      }
      setState(() {});
    }
  }

  void changeSelectedTeacherSubject(TeacherSubject? teacherSubject) {
    if (_selectedSubject != teacherSubject) {
      _selectedSubject = teacherSubject;
      setState(() {});
      getAssignments();
    }
  }

  void getAssignments() {
    if (_selectedSubject != null &&
        _selectedClassSection != null &&
        _selectedClassSection!.isNotEmpty) {
      context.read<AssignmentCubit>().fetchAssignment(
          subjectId: _selectedSubject?.classSubjectId ?? 0,
          classSectionId: _selectedClassSection?.first.id ?? 0);
    }
  }

  void getMoreAssignments() {
    if (_selectedSubject != null &&
        _selectedClassSection != null &&
        _selectedClassSection!.isNotEmpty) {
      context.read<AssignmentCubit>().fetchMoreAssignment(
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          classSectionId: _selectedClassSection?.first.id ?? 0);
    }
  }

  Widget _buildAssignmentItem({required Assignment assignment}) {
    return BlocProvider<DeleteAssignmentCubit>(
      create: (context) => DeleteAssignmentCubit(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<DeleteAssignmentCubit, DeleteAssignmentState>(
              listener: (context, state) {
            if (state is DeleteAssignmentSuccess) {
              context.read<AssignmentCubit>().deleteAssignment(assignment.id);
            } else if (state is DeleteAssignmentFailure) {
              Utils.showSnackBar(
                context: context,
                message: unableToDeleteAssignmentKey,
              );
            }
          }, builder: (context, state) {
            return CustomExpandableContainer(
                key: ValueKey(assignment.id),
                customActionContainer: InkWell(
                  onTap: () {
                    Get.toNamed(
                      Routes.teacherManageAssignmentSubmissionScreen,
                      arguments: TeacherManageAssignmentSubmissionScreen
                          .buildArguments(
                        assignment: assignment,
                      ),
                    );
                  },
                  child: CustomTextContainer(
                    textKey: submissionsKey,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                contractedContentWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTitleDescriptionContainer(
                      titleKey: dueDateKey,
                      description: assignment.dueDate,
                    ),
                    if (assignment.points != 0 ||
                        assignment.extraDaysForResubmission != 0) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          if (assignment.points != 0)
                            Expanded(
                              child: CustomTitleDescriptionContainer(
                                  titleKey: pointsKey,
                                  description: assignment.points.toString()),
                            ),
                          if (assignment.extraDaysForResubmission != 0)
                            CustomTitleDescriptionContainer(
                              titleKey: extraDaysForResubmissionKey,
                              description: assignment.extraDaysForResubmission
                                  .toString(),
                              useReadMoreForDescription: false,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
                expandedContentWidget: assignment.instructions.trim().isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTitleDescriptionContainer(
                              titleKey: instructionsKey,
                              description: assignment.instructions),
                        ],
                      )
                    : null,
                onDelete: () {
                  if (state is DeleteAssignmentInProgress) {
                    return;
                  }
                  showDialog<bool>(
                    context: context,
                    builder: (_) => const ConfirmDeleteDialog(),
                  ).then((value) {
                    if (value != null && value) {
                      if (context.mounted) {
                        context.read<DeleteAssignmentCubit>().deleteAssignment(
                              assignmentId: assignment.id,
                            );
                      }
                    }
                  });
                },
                isDeleteLoading: state is DeleteAssignmentInProgress,
                onEdit: () {
                  Get.toNamed(Routes.teacherAddEditAssignmentScreen,
                          arguments:
                              TeacherAddEditAssignmentScreen.buildArguments(
                                  assignment: assignment,
                                  selectedClassSection: _selectedClassSection,
                                  selectedSubject: _selectedSubject))
                      ?.then((value) {
                    if (value != null && value is bool && value) {
                      //re-fetch assignments if they edit or add
                      getAssignments();
                    }
                  });
                },
                isStudyMaterialFile: true,
                studyMaterials: assignment.studyMaterial,
                titleText: assignment.name);
          });
        },
      ),
    );
  }

  Widget _buildAssignmentList() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(
            bottom: 70,
            top: Utils.appContentTopScrollPadding(context: context) + 40),
        child: BlocBuilder<AssignmentCubit, AssignmentState>(
          builder: (context, state) {
            if (state is AssignmentsFetchSuccess) {
              if (state.assignment.isEmpty) {
                return const noDataContainer(titleKey: noAssignmentKey);
              }
              return Container(
                padding: EdgeInsets.all(appContentHorizontalPadding),
                color: Theme.of(context).colorScheme.surface,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    const CustomTextContainer(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textKey: assignmentListKey,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ...List.generate(
                      state.assignment.length,
                      (index) => _buildAssignmentItem(
                          assignment: state.assignment[index]),
                    ),
                  ],
                ),
              );
            } else if (state is AssignmentFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      getAssignments();
                    },
                  ),
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(appContentHorizontalPadding),
        decoration: BoxDecoration(boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 1, spreadRadius: 1)
        ], color: Theme.of(context).colorScheme.surface),
        width: MediaQuery.of(context).size.width,
        height: 70,
        child: CustomRoundedButton(
          height: 40,
          widthPercentage: 1.0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          buttonTitle: createAssignmentKey,
          showBorder: false,
          onTap: () {
            Get.toNamed(Routes.teacherAddEditAssignmentScreen,
                    arguments: TeacherAddEditAssignmentScreen.buildArguments(
                        assignment: null,
                        selectedClassSection: _selectedClassSection,
                        selectedSubject: _selectedSubject))
                ?.then((value) {
              if (value != null && value is bool && value) {
                //re-fetch assignments if they edit or add
                getAssignments();
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildAppbarAndFilters() {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocConsumer<ClassSectionsAndSubjectsCubit,
          ClassSectionsAndSubjectsState>(
        listener: (context, state) {
          if (state is ClassSectionsAndSubjectsFetchSuccess) {
            if (_selectedClassSection == null &&
                state.classSections.isNotEmpty) {
              final firstClassSection = state.classSections.first;

              changeSelectedClassSection([firstClassSection],
                  fetchNewSubjects: false);
            }
            if (_selectedSubject == null && state.subjects.isNotEmpty) {
              changeSelectedTeacherSubject(state.subjects.first);
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: manageAssignmentKey),
              AppbarFilterBackgroundContainer(
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilterButton(
                        onTap: () {
                          if (state is ClassSectionsAndSubjectsFetchSuccess &&
                              state.classSections.isNotEmpty) {
                            Utils.showBottomSheet(
                              child: FilterSelectionBottomsheet<ClassSection>(
                                onSelection: (value) {
                                  changeSelectedClassSection([value!]);
                                  Get.back();
                                },
                                selectedValue: _selectedClassSection?.first ??
                                    (state.classSections.isNotEmpty
                                        ? state.classSections.first
                                        : null),
                                titleKey: classKey,
                                values: state.classSections,
                              ),
                              context: context,
                            );
                          }
                        },
                        titleKey: _selectedClassSection == null ||
                                _selectedClassSection!.isEmpty
                            ? classKey
                            : (_selectedClassSection!.first.fullName ?? ""),
                        width: boxConstraints.maxWidth * (0.48),
                      ),
                      FilterButton(
                          onTap: () {
                            if (state is ClassSectionsAndSubjectsFetchSuccess &&
                                state.subjects.isNotEmpty) {
                              Utils.showBottomSheet(
                                  child: FilterSelectionBottomsheet<
                                      TeacherSubject>(
                                    selectedValue: _selectedSubject ??
                                        (state.subjects.isNotEmpty
                                            ? state.subjects.first
                                            : null),
                                    titleKey: subjectKey,
                                    values: state.subjects,
                                    onSelection: (value) {
                                      changeSelectedTeacherSubject(value!);
                                      Get.back();
                                    },
                                  ),
                                  context: context);
                            }
                          },
                          titleKey: _selectedSubject?.id == null
                              ? subjectKey
                              : _selectedSubject?.subject
                                      .getSybjectNameWithType() ??
                                  "",
                          width: boxConstraints.maxWidth * (0.48)),
                    ],
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: BlocListener<ClassSectionsAndSubjectsCubit,
                ClassSectionsAndSubjectsState>(
              listener: (context, state) {
                if (state is ClassSectionsAndSubjectsFetchSuccess) {
                  if (state.classSections.isNotEmpty) {
                    if (_selectedClassSection == null) {
                      changeSelectedClassSection([state.classSections.first]);
                    }
                  }

                  if (state.subjects.isNotEmpty) {
                    if (_selectedSubject == null) {
                      changeSelectedTeacherSubject(state.subjects.first);
                    }
                  } else {
                    changeSelectedTeacherSubject(null);
                  }
                }
              },
              child: BlocBuilder<ClassSectionsAndSubjectsCubit,
                  ClassSectionsAndSubjectsState>(
                builder: (context, state) {
                  if (state is ClassSectionsAndSubjectsFetchSuccess) {
                    if (state.classSections.isEmpty) {
                      return const noDataContainer(titleKey: noClassSectionKey);
                    }
                    if (state.subjects.isEmpty) {
                      return const noDataContainer(titleKey: noSubjectsKey);
                    }
                    return _buildAssignmentList();
                  }

                  if (state is ClassSectionsAndSubjectsFetchFailure) {
                    return Center(
                        child: ErrorContainer(
                      errorMessage: state.errorMessage,
                      onTapRetry: () {
                        context
                            .read<ClassSectionsAndSubjectsCubit>()
                            .getClassSectionsAndSubjects(
                                classSectionId: [_selectedClassSection],
                                teacherId: context
                                        .read<AuthCubit>()
                                        .getUserDetails()
                                        .id ??
                                    0);
                      },
                    ));
                  }

                  if (state is ClassSectionsAndSubjectsInitial) {
                    return Center(
                      child: CustomCircularProgressIndicator(
                        indicatorColor: Theme.of(context).colorScheme.primary,
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
            ),
          ),
          SafeArea(child: _buildSubmitButton()),
          _buildAppbarAndFilters(),
        ],
      ),
    );
  }
}
