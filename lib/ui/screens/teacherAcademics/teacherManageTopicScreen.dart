import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/lessonsCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/topic/deleteTopicCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/topic/topicsCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/lesson.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/data/models/topic.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddEditTopicScreen.dart';
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

class TeacherManageTopicScreen extends StatefulWidget {
  //if user comes from a lesson item, this'll be not null
  final List<ClassSection>? selectedClassSection;
  final TeacherSubject? selectedSubject;
  final Lesson? selectedLesson;
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LessonsCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
        BlocProvider(
          create: (context) => TopicsCubit(),
        ),
      ],
      child: TeacherManageTopicScreen(
        selectedClassSection: arguments?['selectedClassSection'],
        selectedSubject: arguments?['selectedSubject'],
        selectedLesson: arguments?['selectedLesson'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required List<ClassSection>? selectedClassSection,
      required TeacherSubject? selectedSubject,
      required Lesson? selectedLesson}) {
    return {
      "selectedClassSection": selectedClassSection,
      "selectedSubject": selectedSubject,
      "selectedLesson": selectedLesson,
    };
  }

  const TeacherManageTopicScreen(
      {super.key,
      this.selectedClassSection,
      this.selectedSubject,
      this.selectedLesson});

  @override
  State<TeacherManageTopicScreen> createState() =>
      _TeacherManageTopicScreenState();
}

class _TeacherManageTopicScreenState extends State<TeacherManageTopicScreen> {
  List<ClassSection>? _selectedClassSection;
  TeacherSubject? _selectedSubject;
  Lesson? _selectedLesson;

  //this will be used to refresh previous page (if the user is from lessons)
  bool didCreateNewTopic = false;

  @override
  void initState() {
    if (widget.selectedLesson == null) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          context
              .read<ClassSectionsAndSubjectsCubit>()
              .getClassSectionsAndSubjects(
                  teacherId:
                      context.read<AuthCubit>().getUserDetails().id ?? 0);
        }
      });
    } else {
      //if user came from a lesson, these will be pre-added to send to next page, but user's won't be able to select/change filters
      _selectedLesson = widget.selectedLesson;
      _selectedSubject = widget.selectedSubject;
      _selectedClassSection = widget.selectedClassSection;
      getTopics();
    }
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
              final successState = (context
                  .read<ClassSectionsAndSubjectsCubit>()
                  .state as ClassSectionsAndSubjectsFetchSuccess);

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
            classSectionId: _selectedClassSection?.first.id ?? 0,
          );
    }
  }

  void getTopics() {
    if (_selectedLesson != null) {
      context
          .read<TopicsCubit>()
          .fetchTopics(lessonId: _selectedLesson?.id ?? 0);
    }
  }

  Widget _buildTopicItem({required Topic topic}) {
    return BlocProvider(
      create: (context) => DeleteTopicCubit(),
      child: Builder(builder: (context) {
        return BlocConsumer<DeleteTopicCubit, DeleteTopicState>(
          listener: (context, state) {
            if (state is DeleteTopicSuccess) {
              context.read<TopicsCubit>().deleteTopic(topic.id);
            } else if (state is DeleteTopicFailure) {
              Utils.showSnackBar(
                context: context,
                message:
                    "${Utils.getTranslatedLabel(unableToDeleteTopicKey)} ${topic.name}",
              );
            }
          },
          builder: (context, state) {
            return CustomExpandableContainer(
                key: ValueKey(topic.id),
                contractedContentWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTitleDescriptionContainer(
                        titleKey: descriptionKey,
                        description: topic.description),
                  ],
                ),
                isDeleteLoading: state is DeleteTopicInProgress,
                onDelete: () {
                  if (state is DeleteTopicInProgress) {
                    return;
                  }
                  showDialog<bool>(
                    context: context,
                    builder: (_) => const ConfirmDeleteDialog(),
                  ).then((value) {
                    if (value != null && value) {
                      if (context.mounted) {
                        context
                            .read<DeleteTopicCubit>()
                            .deleteTopic(topicId: topic.id);
                      }
                    }
                  });
                },
                onEdit: () {
                  Get.toNamed(Routes.teacherAddEditTopicScreen,
                      arguments: TeacherAddEditTopicScreen.buildArguments(
                        topic: topic,
                        selectedClassSection: _selectedClassSection,
                        selectedLesson: _selectedLesson,
                        selectedSubject: _selectedSubject,
                      ))?.then((value) {
                    if (value != null && value is bool && value) {
                      //re-fetch topics if they edit or add
                      getTopics();
                    }
                  });
                },
                studyMaterials: topic.studyMaterials,
                titleText: topic.name);
          },
        );
      }),
    );
  }

  Widget _buildTopicList() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: 120,
            top: Utils.appContentTopScrollPadding(context: context) +
                (widget.selectedLesson == null ? 105 : 25)),
        child: BlocBuilder<TopicsCubit, TopicsState>(
          builder: (context, state) {
            if (state is TopicsFetchSuccess) {
              if (state.topics.isEmpty) {
                return noDataContainer(titleKey: noTopicKey);
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
                      textKey: topicListKey,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ...List.generate(
                      state.topics.length,
                      (index) => _buildTopicItem(topic: state.topics[index]),
                    ),
                  ],
                ),
              );
            } else if (state is TopicsFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      getTopics();
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
          buttonTitle: createTopicKey,
          showBorder: false,
          onTap: () {
            if (_selectedClassSection == null ||
                _selectedClassSection!.isEmpty) {
              Utils.showSnackBar(
                context: context,
                message: Utils.getTranslatedLabel(noClassSectionSelectedKey),
              );
            } else if (_selectedLesson == null) {
              Utils.showSnackBar(
                context: context,
                message: Utils.getTranslatedLabel(noLessonSelectedKey),
              );
            } else if (_selectedSubject == null) {
              Utils.showSnackBar(
                context: context,
                message: Utils.getTranslatedLabel(noSubjectSelectedKey),
              );
            } else {
              Get.toNamed(Routes.teacherAddEditTopicScreen,
                  arguments: TeacherAddEditTopicScreen.buildArguments(
                    topic: null,
                    selectedClassSection: _selectedClassSection,
                    selectedLesson: _selectedLesson,
                    selectedSubject: _selectedSubject,
                  ))?.then((value) {
                if (value != null && value is bool && value) {
                  //re-fetch topics if they edit or add
                  getTopics();
                  didCreateNewTopic = true;
                }
              });
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
              const CustomAppbar(titleKey: manageTopicKey),
              AppbarFilterBackgroundContainer(
                height: 130,
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FilterButton(
                              onTap: () {
                                if (state
                                        is ClassSectionsAndSubjectsFetchSuccess &&
                                    state.classSections.isNotEmpty) {
                                  Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet<
                                        ClassSection>(
                                      onSelection: (value) {
                                        changeSelectedClassSection([value!]);
                                        Get.back();
                                      },
                                      selectedValue:
                                          _selectedClassSection?.first ??
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
                                  : (_selectedClassSection!.first.fullName ??
                                      ""),
                              width: boxConstraints.maxWidth * (0.48),
                            ),
                            FilterButton(
                              onTap: () {
                                if (state
                                        is ClassSectionsAndSubjectsFetchSuccess &&
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
                              width: boxConstraints.maxWidth * (0.48),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 40,
                        child: BlocConsumer<LessonsCubit, LessonsState>(
                          listener: (context, state) {
                            if (state is LessonsFetchSuccess) {
                              if (state.lessons.isEmpty) {
                                _selectedLesson = null;
                              } else if (state.lessons.isNotEmpty) {
                                _selectedLesson = state.lessons.first;
                                getTopics();
                                setState(() {});
                              }
                            }
                          },
                          builder: (context, state) {
                            return FilterButton(
                              onTap: () {
                                if (state is LessonsFetchSuccess &&
                                    state.lessons.isNotEmpty) {
                                  Utils.showBottomSheet(
                                      child: FilterSelectionBottomsheet<Lesson>(
                                        selectedValue: _selectedLesson,
                                        titleKey: lessonKey,
                                        values: state.lessons,
                                        onSelection: (value) {
                                          if (value != _selectedLesson) {
                                            _selectedLesson = value;
                                            getTopics();
                                            setState(() {});
                                          }
                                          Get.back();
                                        },
                                      ),
                                      context: context);
                                }
                              },
                              titleKey: _selectedLesson?.id == null
                                  ? lessonKey
                                  : _selectedLesson?.name ?? "",
                              width: boxConstraints.maxWidth,
                            );
                          },
                        ),
                      ),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        Get.back(result: didCreateNewTopic);
      },
      child: Scaffold(
        body: Stack(
          children: [
            if (widget.selectedLesson == null) ...[
              SafeArea(
                child: BlocBuilder<LessonsCubit, LessonsState>(
                    builder: (context, lessonState) {
                  return BlocBuilder<ClassSectionsAndSubjectsCubit,
                      ClassSectionsAndSubjectsState>(
                    builder: (context, state) {
                      if (state is ClassSectionsAndSubjectsFetchSuccess) {
                        if (state.classSections.isEmpty) {
                          return const noDataContainer(
                              titleKey: noClassSectionKey);
                        }
                        if (state.subjects.isEmpty) {
                          return const noDataContainer(titleKey: noSubjectsKey);
                        }

                        if (lessonState is LessonsFetchSuccess) {
                          if (lessonState.lessons.isEmpty) {
                            return const noDataContainer(titleKey: noLessonKey);
                          }
                          return _buildTopicList();
                        } else if (lessonState is LessonsFetchFailure) {
                          return Center(
                              child: ErrorContainer(
                            errorMessage: lessonState.errorMessage,
                            onTapRetry: () {
                              getLessons();
                            },
                          ));
                        } else {
                          // For LessonsInitial or LessonsFetchInProgress
                          return Center(
                            child: CustomCircularProgressIndicator(
                              indicatorColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }
                      }

                      if (state is ClassSectionsAndSubjectsFetchFailure) {
                        return Center(
                            child: ErrorContainer(
                          errorMessage: state.errorMessage,
                          onTapRetry: () {
                            context
                                .read<ClassSectionsAndSubjectsCubit>()
                                .getClassSectionsAndSubjects(
                                    teacherId: context
                                            .read<AuthCubit>()
                                            .getUserDetails()
                                            .id ??
                                        0);
                          },
                        ));
                      }

                      // For ClassSectionsAndSubjectsInitial or ClassSectionsAndSubjectsFetchInProgress
                      return Center(
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  );
                }),
              ),
            ] else ...[
              _buildTopicList(),
            ],
            SafeArea(child: _buildSubmitButton()),
            if (widget.selectedLesson == null) ...[
              _buildAppbarAndFilters(),
            ] else ...[
              CustomAppbar(
                titleKey: widget.selectedLesson?.name ?? "",
                onBackButtonTap: () {
                  Get.back(result: didCreateNewTopic);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
