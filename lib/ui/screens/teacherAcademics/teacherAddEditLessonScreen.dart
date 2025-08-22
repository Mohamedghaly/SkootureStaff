import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/createLessonCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/lesson/editLessonCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/lesson.dart';
import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/addStudyMaterialBottomsheet.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/addedStudyMaterialFileContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/FilterMultiSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherAddEditLessonScreen extends StatefulWidget {
  final Lesson? lesson;
  final List<ClassSection>? selectedClassSection;
  final TeacherSubject? selectedSubject;
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CreateLessonCubit(),
        ),
        BlocProvider(
          create: (context) => EditLessonCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: TeacherAddEditLessonScreen(
        lesson: arguments?['lesson'],
        selectedClassSection: arguments?['selectedClassSection'],
        selectedSubject: arguments?['selectedSubject'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required Lesson? lesson,
      required List<ClassSection>? selectedClassSection,
      required TeacherSubject? selectedSubject}) {
    return {
      "lesson": lesson,
      "selectedClassSection": selectedClassSection,
      "selectedSubject": selectedSubject
    };
  }

  const TeacherAddEditLessonScreen(
      {super.key,
      required this.lesson,
      this.selectedClassSection,
      this.selectedSubject});

  @override
  State<TeacherAddEditLessonScreen> createState() =>
      _TeacherAddEditLessonScreenState();
}

class _TeacherAddEditLessonScreenState
    extends State<TeacherAddEditLessonScreen> {
  late TeacherSubject? _selectedSubject = widget.selectedSubject;
  late List<ClassSection>? _selectedClassSections = widget.selectedClassSection;

  late bool refreshLessonsInPreviousPage = false;

  late final TextEditingController _lessonNameTextEditingController =
      TextEditingController(
    text: widget.lesson?.name,
  );
  late final TextEditingController _lessonDescriptionTextEditingController =
      TextEditingController(
    text: widget.lesson?.description,
  );

  List<PickedStudyMaterial> _addedStudyMaterials = [];

  late List<StudyMaterial> studyMaterials = widget.lesson?.studyMaterials ?? [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
                classSectionId: [_selectedClassSections!.first.id ?? 0],
                teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _lessonNameTextEditingController.dispose();
    _lessonDescriptionTextEditingController.dispose();
    super.dispose();
  }

  void deleteStudyMaterial(int studyMaterialId) {
    studyMaterials.removeWhere((element) => element.id == studyMaterialId);
    refreshLessonsInPreviousPage = true;
    setState(() {});
  }

  void updateStudyMaterials(StudyMaterial studyMaterial) {
    final studyMaterialIndex =
        studyMaterials.indexWhere((element) => element.id == studyMaterial.id);
    studyMaterials[studyMaterialIndex] = studyMaterial;
    refreshLessonsInPreviousPage = true;
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
            changeSelectedTeacherSubject((context
                    .read<ClassSectionsAndSubjectsCubit>()
                    .state as ClassSectionsAndSubjectsFetchSuccess)
                .subjects
                .firstOrNull);
          }
        }
      });
    }
    setState(() {});
  }

  void changeSelectedTeacherSubject(TeacherSubject? teacherSubject,
      {bool fetchNewLessons = true}) {
    if (_selectedSubject != teacherSubject) {
      _selectedSubject = teacherSubject;
      setState(() {});
    }
  }

  void editLesson() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_selectedSubject == null) {
      showErrorMessage(Utils.getTranslatedLabel(noSubjectSelectedKey));
      return;
    }

    if (_selectedClassSections!.isEmpty) {
      showErrorMessage(Utils.getTranslatedLabel(noClassSectionSelectedKey));
      return;
    }

    if (_lessonNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(Utils.getTranslatedLabel(pleaseEnterLessonNameKey));
      return;
    }

    if (_lessonDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
          Utils.getTranslatedLabel(pleaseEnterLessonDescriptionKey));
      return;
    }

    context.read<EditLessonCubit>().editLesson(
          lessonDescription:
              _lessonDescriptionTextEditingController.text.trim(),
          lessonName: _lessonNameTextEditingController.text.trim(),
          lessonId: widget.lesson!.id,
          classSectionId:
              _selectedClassSections!.map((e) => e.id ?? 0).toList(),
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          files: _addedStudyMaterials,
        );
  }

  void createLesson() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_selectedSubject == null) {
      showErrorMessage(noSubjectSelectedKey);
      return;
    }
    if (_lessonNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterLessonNameKey);
      return;
    }

    if (_lessonDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterLessonDescriptionKey);
      return;
    }

    context.read<CreateLessonCubit>().createLesson(
          classSectionId:
              _selectedClassSections!.map((e) => e.id ?? 0).toList(),
          files: _addedStudyMaterials,
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          lessonDescription:
              _lessonDescriptionTextEditingController.text.trim(),
          lessonName: _lessonNameTextEditingController.text.trim(),
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
        child: widget.lesson != null
            ? BlocConsumer<EditLessonCubit, EditLessonState>(
                listener: (context, state) {
                  if (state is EditLessonSuccess) {
                    Get.back(result: true);
                    Utils.showSnackBar(
                        context: context, message: lessonEditedSuccessfullyKey);
                  } else if (state is EditLessonFailure) {
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
                        if (state is EditLessonInProgress) {
                          return;
                        }
                        editLesson();
                      },
                      child: state is EditLessonInProgress
                          ? const CustomCircularProgressIndicator(
                              strokeWidth: 2,
                              widthAndHeight: 20,
                            )
                          : null);
                },
              )
            : BlocConsumer<CreateLessonCubit, CreateLessonState>(
                listener: (context, state) {
                  if (state is CreateLessonSuccess) {
                    Utils.showSnackBar(
                        context: context, message: lessonAddedKey);
                    _lessonDescriptionTextEditingController.text = "";
                    _lessonNameTextEditingController.text = "";
                    _addedStudyMaterials = [];
                    refreshLessonsInPreviousPage = true;
                    setState(() {});
                  } else if (state is CreateLessonFailure) {
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
                        if (state is CreateLessonInProgress) {
                          return;
                        }
                        createLesson();
                      },
                      child: state is CreateLessonInProgress
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

  Widget _buildAddEditLessonForm() {
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
            return state is ClassSectionsAndSubjectsFetchFailure
                ? Center(
                    child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context
                          .read<ClassSectionsAndSubjectsCubit>()
                          .getClassSectionsAndSubjects(
                              classSectionId: [_selectedClassSections],
                              teacherId: context
                                      .read<AuthCubit>()
                                      .getUserDetails()
                                      .id ??
                                  0);
                    },
                  ))
                : Column(
                    children: [
                      CustomSelectionDropdownSelectionButton(
                        isDisabled: widget.lesson != null,
                        onTap: () {
                          if (state is ClassSectionsAndSubjectsFetchSuccess) {
                            Utils.showBottomSheet(
                              child:
                                  FilterMultiSelectionBottomsheet<ClassSection>(
                                onSelection: (value) {
                                  changeSelectedClassSection(value,
                                      fetchNewSubjects: true);
                                  Get.back();
                                },
                                selectedValues: _selectedClassSections ?? [],
                                titleKey: classKey,
                                values: state.classSections,
                              ),
                              context: context,
                            );
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
                        isDisabled: widget.lesson != null,
                        onTap: () {
                          if (state is ClassSectionsAndSubjectsFetchSuccess) {
                            Utils.showBottomSheet(
                                child:
                                    FilterSelectionBottomsheet<TeacherSubject>(
                                  showFilterByLabel: false,
                                  selectedValue: _selectedSubject!,
                                  titleKey: subjectKey,
                                  values: state.subjects,
                                  onSelection: (value) {
                                    changeSelectedTeacherSubject(value,
                                        fetchNewLessons: true);
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
                      CustomTextFieldContainer(
                          textEditingController:
                              _lessonNameTextEditingController,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          hintTextKey: lessonNameKey),
                      CustomTextFieldContainer(
                          textEditingController:
                              _lessonDescriptionTextEditingController,
                          maxLines: 5,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          hintTextKey: descriptionKey),

                      //pre-added study materials
                      widget.lesson != null
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
                          _addedStudyMaterials.length, (index) => index).map(
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
        Get.back(result: refreshLessonsInPreviousPage);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            _buildAddEditLessonForm(),
            SafeArea(child: _buildSubmitButton()),
            Align(
              alignment: Alignment.topCenter,
              child: CustomAppbar(
                titleKey:
                    widget.lesson != null ? editLessonKey : createLessonKey,
                onBackButtonTap: () {
                  Get.back(result: refreshLessonsInPreviousPage);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
