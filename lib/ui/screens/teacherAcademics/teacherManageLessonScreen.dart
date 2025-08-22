import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/deleteLessonCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/lessonsCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/lesson.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddEditLessonScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherManageTopicScreen.dart';
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

class TeacherManageLessonScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LessonsCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: const TeacherManageLessonScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherManageLessonScreen({super.key});

  @override
  State<TeacherManageLessonScreen> createState() =>
      _TeacherManageLessonScreenState();
}

class _TeacherManageLessonScreenState extends State<TeacherManageLessonScreen> {
  List<ClassSection>? _selectedClassSection;
  TeacherSubject? _selectedSubject;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
                teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0);
      }
    });
    super.initState();
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
      getLessons();
    }
  }

  void getLessons() {
    if (_selectedSubject != null &&
        _selectedClassSection != null &&
        _selectedClassSection!.isNotEmpty) {
      context.read<LessonsCubit>().fetchLessons(
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          classSectionId: _selectedClassSection?.first.id ?? 0);
    }
  }

  Widget _buildLessonItem({required Lesson lesson}) {
    return BlocProvider(
      create: (context) => DeleteLessonCubit(),
      child: Builder(builder: (context) {
        return BlocConsumer<DeleteLessonCubit, DeleteLessonState>(
          listener: (context, state) {
            if (state is DeleteLessonSuccess) {
              context.read<LessonsCubit>().deleteLesson(lesson.id);
            } else if (state is DeleteLessonFailure) {
              Utils.showSnackBar(
                context: context,
                message:
                    "${Utils.getTranslatedLabel(unableToDeleteLessonKey)} ${lesson.name}",
              );
            }
          },
          builder: (context, state) {
            return CustomExpandableContainer(
              key: ValueKey(lesson.id),
              studyMaterials: lesson.studyMaterials,
              isDeleteLoading: state is DeleteLessonInProgress,
              titleText: lesson.name,
              contractedContentWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTitleDescriptionContainer(
                      titleKey: descriptionKey,
                      description: lesson.description),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        Routes.teacherManageTopicScreen,
                        arguments: TeacherManageTopicScreen.buildArguments(
                            selectedLesson: lesson,
                            selectedClassSection: _selectedClassSection,
                            selectedSubject: _selectedSubject),
                      )?.then((value) {
                        if (value != null && value is bool && value) {
                          getLessons();
                        }
                      });
                    },
                    child: CustomTextContainer(
                      textKey:
                          "${Utils.getTranslatedLabel(viewTopicsKey)}${lesson.topicsCount != 0 ? ' (${lesson.topicsCount})' : ''}",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              onDelete: () {
                if (state is DeleteLessonInProgress) {
                  return;
                }
                showDialog<bool>(
                  context: context,
                  builder: (_) => const ConfirmDeleteDialog(),
                ).then((value) {
                  if (value != null && value) {
                    if (context.mounted) {
                      context.read<DeleteLessonCubit>().deleteLesson(lesson.id);
                    }
                  }
                });
              },
              onEdit: () {
                Get.toNamed(Routes.teacherAddEditLessonScreen,
                        arguments: TeacherAddEditLessonScreen.buildArguments(
                            lesson: lesson,
                            selectedClassSection: _selectedClassSection,
                            selectedSubject: _selectedSubject))
                    ?.then((value) {
                  if (value != null && value is bool && value) {
                    //re-fetch lessons if they edit or add
                    getLessons();
                  }
                });
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildLessonList() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: 70,
            top: Utils.appContentTopScrollPadding(context: context) + 70),
        child: BlocBuilder<LessonsCubit, LessonsState>(
          builder: (context, state) {
            if (state is LessonsFetchSuccess) {
              if (state.lessons.isEmpty) {
                return const noDataContainer(titleKey: noLessonKey);
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
                      textKey: lessonListLey,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ...List.generate(
                      state.lessons.length,
                      (index) => _buildLessonItem(lesson: state.lessons[index]),
                    ),
                  ],
                ),
              );
            } else if (state is LessonsFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      getLessons();
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
          buttonTitle: createLessonKey,
          showBorder: false,
          onTap: () {
            if (_selectedClassSection != null &&
                _selectedClassSection!.isNotEmpty) {
              Get.toNamed(Routes.teacherAddEditLessonScreen,
                      arguments: TeacherAddEditLessonScreen.buildArguments(
                          lesson: null,
                          selectedClassSection: _selectedClassSection,
                          selectedSubject: _selectedSubject))
                  ?.then((value) {
                if (value != null && value is bool && value) {
                  //re-fetch lessons if they edit or add
                  getLessons();
                }
              });
            } else {
              Utils.showSnackBar(
                context: context,
                message: Utils.getTranslatedLabel(noClassSectionSelectedKey),
              );
            }
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
              const CustomAppbar(titleKey: manageLessonKey),
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
                        titleKey: _selectedClassSection?.first.id == null
                            ? classKey
                            : (_selectedClassSection?.first.fullName ?? ""),
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
                                        state.subjects.first,
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
                  return _buildLessonList();
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

                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          SafeArea(child: _buildSubmitButton()),
          _buildAppbarAndFilters(),
        ],
      ),
    );
  }
}
