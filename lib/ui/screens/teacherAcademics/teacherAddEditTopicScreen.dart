import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/lessonsCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/topic/createTopicCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/topic/editTopicCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/lesson.dart';
import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/data/models/topic.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/addStudyMaterialBottomsheet.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/addedStudyMaterialFileContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterMultiSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherAddEditTopicScreen extends StatefulWidget {
  final Topic? topic;
  final List<ClassSection>? selectedClassSection;
  final TeacherSubject? selectedSubject;
  final Lesson? selectedLesson;
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EditTopicCubit(),
        ),
        BlocProvider(
          create: (context) => CreateTopicCubit(),
        ),
        BlocProvider(
          create: (context) => LessonsCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: TeacherAddEditTopicScreen(
        topic: arguments?['topic'],
        selectedClassSection: arguments?['selectedClassSection'],
        selectedSubject: arguments?['selectedSubject'],
        selectedLesson: arguments?['selectedLesson'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required Topic? topic,
      required List<ClassSection>? selectedClassSection,
      required TeacherSubject? selectedSubject,
      required Lesson? selectedLesson}) {
    return {
      "topic": topic,
      "selectedClassSection": selectedClassSection,
      "selectedSubject": selectedSubject,
      "selectedLesson": selectedLesson,
    };
  }

  const TeacherAddEditTopicScreen(
      {super.key,
      required this.topic,
      this.selectedClassSection,
      this.selectedSubject,
      this.selectedLesson});

  @override
  State<TeacherAddEditTopicScreen> createState() =>
      _TeacherAddEditTopicScreenState();
}

class _TeacherAddEditTopicScreenState extends State<TeacherAddEditTopicScreen> {
  late TeacherSubject? _selectedSubject = widget.selectedSubject;
  late Lesson? _selectedLesson = widget.selectedLesson;
  late List<ClassSection>? _selectedClassSections = widget.selectedClassSection;

  //This will determine if need to refresh the previous page
  //topics data. If teacher remove the the any study material
  //so we need to fetch the list again
  late bool refreshTopicsInPreviousPage = false;

  late final TextEditingController _topicNameTextEditingController =
      TextEditingController(
    text: widget.topic?.name,
  );
  late final TextEditingController _topicDescriptionTextEditingController =
      TextEditingController(
    text: widget.topic?.description,
  );

  List<PickedStudyMaterial> _addedStudyMaterials = [];

  late List<StudyMaterial> studyMaterials = widget.topic?.studyMaterials ?? [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
          classSectionId: [_selectedClassSections!.first.id ?? 0],
          teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0,
        );
      }
    });
  }

  @override
  void dispose() {
    _topicNameTextEditingController.dispose();
    _topicDescriptionTextEditingController.dispose();
    super.dispose();
  }

  void deleteStudyMaterial(int studyMaterialId) {
    studyMaterials.removeWhere((element) => element.id == studyMaterialId);
    refreshTopicsInPreviousPage = true;
    setState(() {});
  }

  List<int> _getClassSectionIds() {
    return _selectedClassSections!.map((e) => e.id ?? 0).toList();
  }

  void changeSelectedClassSection(List<ClassSection>? classSection,
      {bool fetchNewSubjects = true}) {
    _selectedClassSections = classSection ?? [];
    if (fetchNewSubjects && _selectedClassSections!.isNotEmpty) {
      context
          .read<ClassSectionsAndSubjectsCubit>()
          .getNewSubjectsFromSelectedClassSectionIndex(
              teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0,
              newClassSectionId: _getClassSectionIds())
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

  void updateStudyMaterials(StudyMaterial studyMaterial) {
    final studyMaterialIndex =
        studyMaterials.indexWhere((element) => element.id == studyMaterial.id);
    studyMaterials[studyMaterialIndex] = studyMaterial;
    refreshTopicsInPreviousPage = true;
    setState(() {});
  }

  void _addStudyMaterial(PickedStudyMaterial pickedStudyMaterial) {
    setState(() {
      _addedStudyMaterials.add(pickedStudyMaterial);
    });
  }

  void showErrorMessage(String errorMessageKey) {
    Utils.showSnackBar(
      context: context,
      message: errorMessageKey,
    );
  }

  void editTopic() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_topicNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(Utils.getTranslatedLabel(pleaseEnterTopicNameKey));
      return;
    }

    if (_topicDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
          Utils.getTranslatedLabel(pleaseEnterTopicDescriptionKey));
      return;
    }

    context.read<EditTopicCubit>().editTopic(
          topicDescription: _topicDescriptionTextEditingController.text.trim(),
          topicName: _topicNameTextEditingController.text.trim(),
          lessonId: _selectedLesson?.id ?? 0,
          classSectionId:
              _selectedClassSections!.map((e) => e.id ?? 0).toList(),
          subjectId: _selectedSubject?.classSubjectId ?? 0,
          topicId: widget.topic?.id ?? 0,
          files: _addedStudyMaterials,
        );
  }

  void createTopic() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_selectedSubject == null) {
      showErrorMessage(Utils.getTranslatedLabel(noSubjectSelectedKey));
      return;
    }
    if (_selectedLesson == null) {
      showErrorMessage(Utils.getTranslatedLabel(noLessonSelectedKey));
      return;
    }
    if (_selectedClassSections!.isEmpty) {
      showErrorMessage(Utils.getTranslatedLabel(noClassSectionSelectedKey));
      return;
    }
    if (_topicNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(Utils.getTranslatedLabel(pleaseEnterTopicNameKey));
      return;
    }

    if (_topicDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
          Utils.getTranslatedLabel(pleaseEnterTopicDescriptionKey));
      return;
    }

    context.read<CreateTopicCubit>().createTopic(
          topicName: _topicNameTextEditingController.text.trim(),
          lessonId: _selectedLesson?.id ?? 0,
          classSectionId:
              _selectedClassSections!.map((e) => e.id ?? 0).toList(),
          subjectId: _selectedSubject?.classSubjectId ?? 0,
          topicDescription: _topicDescriptionTextEditingController.text.trim(),
          files: _addedStudyMaterials,
        );
  }

  void changeSelectedTeacherSubject(TeacherSubject? teacherSubject) {
    if (_selectedSubject != teacherSubject) {
      _selectedSubject = teacherSubject;
      setState(() {});
      getLessons();
    }
  }

  void getLessons() {
    context.read<LessonsCubit>().fetchLessons(
        classSubjectId: _selectedSubject?.classSubjectId ?? 0,
        classSectionId: _selectedClassSections!.first.id ?? 0);
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
        child: widget.topic != null
            ? BlocConsumer<EditTopicCubit, EditTopicState>(
                listener: (context, state) {
                  if (state is EditTopicSuccess) {
                    Get.back(result: true);
                    Utils.showSnackBar(
                        context: context, message: topicEditedSuccessfullyKey);
                  } else if (state is EditTopicFailure) {
                    Utils.showSnackBar(
                        context: context, message: state.errorMessage);
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                      height: 40,
                      widthPercentage: 1.0,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      buttonTitle: submitKey,
                      showBorder: false,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (state is EditTopicInProgress) {
                          return;
                        }
                        editTopic();
                      },
                      child: state is EditTopicInProgress
                          ? const CustomCircularProgressIndicator(
                              strokeWidth: 2,
                              widthAndHeight: 20,
                            )
                          : null);
                },
              )
            : BlocConsumer<CreateTopicCubit, CreateTopicState>(
                listener: (context, state) {
                  if (state is CreateTopicSuccess) {
                    Utils.showSnackBar(
                        context: context, message: topicAddedSuccessfullyKey);
                    _topicNameTextEditingController.text = "";
                    _topicDescriptionTextEditingController.text = "";
                    _addedStudyMaterials = [];
                    refreshTopicsInPreviousPage = true;
                    setState(() {});
                  } else if (state is CreateTopicFailure) {
                    Utils.showSnackBar(
                      context: context,
                      message: state.errorMessage,
                    );
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                      height: 40,
                      widthPercentage: 1.0,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      buttonTitle: submitKey,
                      showBorder: false,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (state is CreateTopicInProgress) {
                          return;
                        }
                        createTopic();
                      },
                      child: state is CreateTopicInProgress
                          ? const CustomCircularProgressIndicator(
                              strokeWidth: 2,
                              widthAndHeight: 20,
                            )
                          : null);
                },
              ),
      ),
    );
  }

  Widget _buildAddEditTopicForm() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: 100,
            left: appContentHorizontalPadding,
            right: appContentHorizontalPadding,
            top: Utils.appContentTopScrollPadding(context: context) + 20),
        child: BlocConsumer<ClassSectionsAndSubjectsCubit,
            ClassSectionsAndSubjectsState>(
          listener: (context, state) {
            if (state is ClassSectionsAndSubjectsFetchSuccess) {
              if (_selectedClassSections!.isEmpty &&
                  state.classSections.isNotEmpty) {
                final firstClassSection = state.classSections.first;
                changeSelectedClassSection([firstClassSection],
                    fetchNewSubjects: false);
              }
              if (_selectedSubject == null) {
                changeSelectedTeacherSubject(state.subjects.firstOrNull);
              }
            }
          },
          builder: (context, state) {
            return BlocConsumer<LessonsCubit, LessonsState>(
              listener: (context, lessonState) {
                if (lessonState is LessonsFetchSuccess) {
                  if (lessonState.lessons.isNotEmpty) {
                    _selectedLesson = lessonState.lessons.first;
                    setState(() {});
                  }
                  if (lessonState.lessons.isEmpty) {
                    _selectedLesson = null;
                  }
                }
              },
              builder: (context, lessonState) {
                return state is ClassSectionsAndSubjectsFetchFailure ||
                        lessonState is LessonsFetchFailure
                    ? Center(
                        child: ErrorContainer(
                        errorMessage: state
                                is ClassSectionsAndSubjectsFetchFailure
                            ? state.errorMessage
                            : (lessonState as LessonsFetchFailure).errorMessage,
                        onTapRetry: () {
                          if (state is ClassSectionsAndSubjectsFetchFailure) {
                            context
                                .read<ClassSectionsAndSubjectsCubit>()
                                .getClassSectionsAndSubjects(
                                    classSectionId: [_selectedClassSections],
                                    teacherId: context
                                            .read<AuthCubit>()
                                            .getUserDetails()
                                            .id ??
                                        0);
                          }
                          if (lessonState is LessonsFetchFailure) {
                            getLessons();
                          }
                        },
                      ))
                    : Column(
                        children: [
                          CustomSelectionDropdownSelectionButton(
                            isDisabled: widget.topic !=
                                null, // if user is editing, they can't change class
                            onTap: () {
                              if (state
                                  is ClassSectionsAndSubjectsFetchSuccess) {
                                Utils.showBottomSheet(
                                  child: FilterMultiSelectionBottomsheet<
                                      ClassSection>(
                                    onSelection: (value) {
                                      changeSelectedClassSection(value,
                                          fetchNewSubjects: true);
                                      Get.back(result: value);
                                    },
                                    selectedValues: _selectedClassSections ??
                                        [], // Only show the selected class, not all
                                    titleKey: classKey,
                                    values: state.classSections,
                                  ),
                                  context: context,
                                ).then((value) {
                                  if (value != null && value is ClassSection) {
                                    final selectedClassSection = value;
                                    if (selectedClassSection.id !=
                                        _selectedClassSections!.first.id) {
                                      changeSelectedClassSection(
                                          [selectedClassSection]);
                                    }
                                  } else {
                                    if (kDebugMode) {
                                      print(
                                          "No class section selected or invalid value returned.");
                                    }
                                  }
                                });
                              }
                            },
                            titleKey: _selectedClassSections!.isEmpty
                                ? classKey
                                : _selectedClassSections!
                                    .map((e) => e.fullName ?? "")
                                    .join(", "),
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                          ),

                          const SizedBox(
                            height: 15,
                          ),
                          CustomSelectionDropdownSelectionButton(
                            isDisabled: widget.topic !=
                                null, //if user is editing, they can't change subject
                            onTap: () {
                              if (state
                                  is ClassSectionsAndSubjectsFetchSuccess) {
                                Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet<
                                        TeacherSubject>(
                                      showFilterByLabel: false,
                                      selectedValue: _selectedSubject!,
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
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomSelectionDropdownSelectionButton(
                            isDisabled: widget.topic !=
                                null, // if user is editing, they can't change the lesson
                            onTap: () {
                              final lessonCubit = context.read<LessonsCubit>();

                              // Fetch lessons if not already fetched
                              if (lessonCubit.state is! LessonsFetchSuccess) {
                                lessonCubit.fetchLessons(
                                    classSubjectId:
                                        _selectedSubject?.classSubjectId ?? 0,
                                    classSectionId:
                                        _selectedClassSections!.first.id ?? 0);
                              }

                              final lessonState = lessonCubit.state;

                              if (lessonState is LessonsFetchSuccess) {
                                Utils.showBottomSheet(
                                  child: FilterSelectionBottomsheet<Lesson>(
                                    showFilterByLabel: false,
                                    selectedValue: _selectedLesson!,
                                    titleKey: lessonKey,
                                    values: lessonState.lessons,
                                    onSelection: (value) {
                                      if (_selectedLesson != value) {
                                        _selectedLesson = value;
                                        setState(() {});
                                      }
                                      Get.back();
                                    },
                                  ),
                                  context: context,
                                );
                              } else if (lessonState is LessonsFetchFailure) {
                                if (kDebugMode) {
                                  print(
                                      "Failed to fetch lessons: ${lessonState.errorMessage}");
                                }
                              } else if (lessonState
                                  is LessonsFetchInProgress) {
                                if (kDebugMode) {
                                  print("Lessons are being fetched...");
                                }
                              } else {
                                if (kDebugMode) {
                                  print("Lessons state is not ready.");
                                }
                              }
                            },
                            titleKey: _selectedLesson?.id == null
                                ? lessonKey
                                : _selectedLesson?.name ?? "",
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomTextFieldContainer(
                              textEditingController:
                                  _topicNameTextEditingController,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              hintTextKey: topicNameKey),
                          CustomTextFieldContainer(
                              textEditingController:
                                  _topicDescriptionTextEditingController,
                              maxLines: 5,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              hintTextKey: descriptionKey),

                          //pre-added study materials
                          widget.topic != null
                              ? Column(
                                  children: studyMaterials
                                      .map(
                                        (studyMaterial) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 15),
                                          child: StudyMaterialContainer(
                                            onDeleteStudyMaterial:
                                                deleteStudyMaterial,
                                            onEditStudyMaterial:
                                                updateStudyMaterials,
                                            showEditAndDeleteButton: true,
                                            studyMaterial: studyMaterial,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : const SizedBox(),

                          //user study material picker
                          UploadImageOrFileButton(
                            uploadFile: true,
                            customTitleKey: addStudyMaterialKey,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              Utils.showBottomSheet(
                                child: AddStudyMaterialBottomsheet(
                                  editFileDetails: false,
                                  onTapSubmit: _addStudyMaterial,
                                ),
                                context: context,
                              );
                            },
                          ),

                          //user's added study materials
                          ...List.generate(
                                  _addedStudyMaterials.length, (index) => index)
                              .map(
                            (index) => Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: AddedStudyMaterialContainer(
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                onDelete: (index) {
                                  _addedStudyMaterials.removeAt(index);
                                  setState(() {});
                                },
                                onEdit: (index, file) {
                                  _addedStudyMaterials[index] = file;
                                  setState(() {});
                                },
                                file: _addedStudyMaterials[index],
                                fileIndex: index,
                              ),
                            ),
                          ),
                        ],
                      );
              },
            );
          },
        ),
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
        Get.back(result: refreshTopicsInPreviousPage);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            _buildAddEditTopicForm(),
            SafeArea(child: _buildSubmitButton()),
            Align(
              alignment: Alignment.topCenter,
              child: CustomAppbar(
                titleKey: widget.topic != null ? editTopicKey : createTopicKey,
                onBackButtonTap: () {
                  Get.back(result: refreshTopicsInPreviousPage);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
