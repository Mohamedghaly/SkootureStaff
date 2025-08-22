import 'dart:io';

import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/announcement/teacherCreateAnnouncementCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/announcement/teacherEditAnnouncementCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/teacherAnnouncement.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherAddEditAnnouncementScreen extends StatefulWidget {
  final TeacherAnnouncement? announcement;
  final List<ClassSection>? selectedClassSection;
  final TeacherSubject? selectedSubject;
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TeacherCreateAnnouncementCubit(),
        ),
        BlocProvider(
          create: (context) => TeacherEditAnnouncementCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: TeacherAddEditAnnouncementScreen(
        announcement: arguments?['announcement'],
        selectedClassSection: arguments?['selectedClassSection'],
        selectedSubject: arguments?['selectedSubject'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required TeacherAnnouncement? announcement,
      required List<ClassSection>? selectedClassSection,
      required TeacherSubject? selectedSubject}) {
    return {
      "announcement": announcement,
      "selectedClassSection": selectedClassSection,
      "selectedSubject": selectedSubject
    };
  }

  const TeacherAddEditAnnouncementScreen(
      {super.key,
      required this.announcement,
      this.selectedClassSection,
      this.selectedSubject});

  @override
  State<TeacherAddEditAnnouncementScreen> createState() =>
      _TeacherAddEditAnnouncementScreenState();
}

class _TeacherAddEditAnnouncementScreenState
    extends State<TeacherAddEditAnnouncementScreen> {
  late TeacherSubject? _selectedSubject = widget.selectedSubject;
  // List<ClassSection> _selectedClassSections = [];
  late List<ClassSection> _selectedClassSections =
      widget.selectedClassSection ?? [];

  //This will determine if need to refresh the previous page
  //announcement data. If teacher remove the the any files
  //so we need to fetch the list again
  late bool refreshAnnouncementsInPreviousPage = false;

  bool isUrlSelected = false;
  final TextEditingController _urlController = TextEditingController();

  late final TextEditingController _announcementTitleTextEditingController =
      TextEditingController(
    text: widget.announcement?.title,
  );
  late final TextEditingController
      _announcementDescriptionTextEditingController = TextEditingController(
    text: widget.announcement?.description,
  );

  List<PlatformFile> uploadedFiles = [];

  late List<StudyMaterial> announcementAttachments =
      widget.announcement?.files ?? [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        // Only call API if we have selected class sections
        if (_selectedClassSections.isNotEmpty) {
          context
              .read<ClassSectionsAndSubjectsCubit>()
              .getClassSectionsAndSubjects(classSectionId: [
            _selectedClassSections.first.id ?? 0
          ], teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _announcementTitleTextEditingController.dispose();
    _announcementDescriptionTextEditingController.dispose();
    _urlController.dispose();

    super.dispose();
  }

  Future<void> _addFiles() async {
    final result = await Utils.openFilePicker(context: context);
    if (result != null) {
      uploadedFiles.addAll(result.files);
      setState(() {});
    }
  }

  Future<void> _addImages() async {
    final result = await Utils.openFilePicker(
        context: context, type: FileType.image, allowMultiple: true);

    if (result != null) {
      uploadedFiles.addAll(result.files);
      setState(() {});
    }
  }

  void showErrorMessage(String errorMessageKey) {
    Utils.showSnackBar(
      context: context,
      message: errorMessageKey,
    );
  }

  List<int> _getClassSectionIds() {
    return _selectedClassSections.map((e) => e.id ?? 0).toList();
  }

  void changeSelectedClassSection(List<ClassSection>? classSection,
      {bool fetchNewSubjects = true}) {
    _selectedClassSections = classSection ?? [];
    if (fetchNewSubjects && _selectedClassSections.isNotEmpty) {
      context
          .read<ClassSectionsAndSubjectsCubit>()
          .getNewSubjectsFromSelectedClassSectionIndex(
              teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0,
              newClassSectionId: _getClassSectionIds())
          .then((value) {
        if (mounted) {
          final state = context.read<ClassSectionsAndSubjectsCubit>().state;
          if (state is ClassSectionsAndSubjectsFetchSuccess) {
            _changeSelectedTeacherSubject(state.subjects.firstOrNull);
          }
        }
      });
    }
    setState(() {});
  }

  void _changeSelectedTeacherSubject(TeacherSubject? teacherSubject) {
    if (_selectedSubject != teacherSubject) {
      _selectedSubject = teacherSubject;
      setState(() {});
    }
  }

  void createAnnouncement() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_selectedSubject == null) {
      showErrorMessage(Utils.getTranslatedLabel(noSubjectSelectedKey));
      return;
    }

    if (_selectedClassSections.isEmpty) {
      showErrorMessage(Utils.getTranslatedLabel(noClassSectionSelectedKey));
      return;
    }

    if (_announcementTitleTextEditingController.text.trim().isEmpty) {
      showErrorMessage(Utils.getTranslatedLabel(pleaseAddAnnouncementTitleKey));
      return;
    }
    if (_announcementDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
          Utils.getTranslatedLabel(pleaseAddAnnouncementDescriptionKey));
      return;
    }

    if (isUrlSelected && _urlController.text.trim().isEmpty) {
      showErrorMessage(pleaseAddaValidUrl);
      return;
    }

    context.read<TeacherCreateAnnouncementCubit>().createAnnouncement(
          classSectionId: _selectedClassSections.map((e) => e.id ?? 0).toList(),
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          title: _announcementTitleTextEditingController.text,
          description: _announcementDescriptionTextEditingController.text,
          attachments: uploadedFiles,
          url: _urlController.text.trim(),
        );
  }

  void editAnnouncement() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_announcementTitleTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseAddAnnouncementTitleKey);
      return;
    }
    if (_announcementDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseAddAnnouncementDescriptionKey);
      return;
    }

    // Handle URL validation during edit
    if (isUrlSelected && _urlController.text.trim().isEmpty) {
      showErrorMessage("Please add a valid URL");
      return;
    }
    context.read<TeacherEditAnnouncementCubit>().editAnnouncement(
        classSectionId: _selectedClassSections.map((e) => e.id ?? 0).toList(),
        announcementId: widget.announcement?.id ?? 0,
        classSubjectId: _selectedSubject?.classSubjectId ?? 0,
        title: _announcementTitleTextEditingController.text,
        description: _announcementDescriptionTextEditingController.text,
        attachments: uploadedFiles,
        url: _urlController.text.trim());
  }

  Widget _buildUrlOption() {
    return Row(
      children: [
        Checkbox(
          value: isUrlSelected,
          onChanged: (value) {
            setState(() {
              isUrlSelected = value ?? false;
            });
          },
        ),
        Text(Utils.getTranslatedLabel(addUrlAnnouncementFiedKey)),
      ],
    );
  }

  Widget _buildUrlInputForm() {
    return isUrlSelected
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              CustomTextFieldContainer(
                textEditingController: _urlController,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                hintTextKey: addUrlFiedKey,
              ),
            ],
          )
        : const SizedBox();
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
        child: widget.announcement != null
            ? BlocConsumer<TeacherEditAnnouncementCubit,
                TeacherEditAnnouncementState>(
                listener: (context, state) {
                  if (state is TeacherEditAnnouncementSuccess) {
                    Get.back(result: true);
                    Utils.showSnackBar(
                        context: context,
                        message: announcementEditedSuccessfullyKey);
                  } else if (state is TeacherEditAnnouncementFailure) {
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
                        if (state is TeacherEditAnnouncementInProgress) {
                          return;
                        }
                        editAnnouncement();
                      },
                      child: state is TeacherEditAnnouncementInProgress
                          ? const CustomCircularProgressIndicator(
                              strokeWidth: 2,
                              widthAndHeight: 20,
                            )
                          : null);
                },
              )
            : BlocConsumer<TeacherCreateAnnouncementCubit,
                TeacherCreateAnnouncementState>(
                listener: (context, state) {
                  if (state is TeacherCreateAnnouncementSuccess) {
                    Utils.showSnackBar(
                        context: context,
                        message: announcementAddedSuccessfullyKey);
                    _announcementTitleTextEditingController.text = "";
                    _announcementDescriptionTextEditingController.text = "";
                    uploadedFiles = [];
                    announcementAttachments = [];
                    refreshAnnouncementsInPreviousPage = true;
                    setState(() {});
                  } else if (state is TeacherCreateAnnouncementFailure) {
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
                        if (state is TeacherCreateAnnouncementInProgress) {
                          return;
                        }
                        createAnnouncement();
                      },
                      child: state is TeacherCreateAnnouncementInProgress
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

  Widget _buildAddEditAnnouncementForm() {
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
              if (_selectedClassSections.isEmpty &&
                  state.classSections.isNotEmpty) {
                final firstClassSection = state.classSections.first;
                changeSelectedClassSection([firstClassSection],
                    fetchNewSubjects: false);
              }
              if (_selectedSubject == null && state.subjects.isNotEmpty) {
                _changeSelectedTeacherSubject(state.subjects.first);
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
                          teacherId:
                              context.read<AuthCubit>().getUserDetails().id ??
                                  0,
                        );
                      },
                    ),
                  )
                : Column(
                    children: [
                      CustomSelectionDropdownSelectionButton(
                        isDisabled: widget.announcement != null,
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
                                selectedValues: _selectedClassSections,
                                titleKey: classKey,
                                values: state.classSections,
                              ),
                              context: context,
                            );
                          }
                        },
                        titleKey: _selectedClassSections.isEmpty
                            ? classKey
                            : _selectedClassSections
                                .map((e) => e.fullName ?? "")
                                .join(", "),
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      CustomSelectionDropdownSelectionButton(
                        isDisabled: widget.announcement != null,
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
                                    _changeSelectedTeacherSubject(value!);
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
                            _announcementTitleTextEditingController,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        hintTextKey: titleKey,
                      ),
                      CustomTextFieldContainer(
                          textEditingController:
                              _announcementDescriptionTextEditingController,
                          maxLines: 5,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          hintTextKey: descriptionKey),

                      _buildUrlOption(),
                      _buildUrlInputForm(),

                      widget.announcement != null
                          ? Column(
                              children: announcementAttachments
                                  .map(
                                    (studyMaterial) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: StudyMaterialContainer(
                                        onDeleteStudyMaterial: (fileId) {
                                          announcementAttachments.removeWhere(
                                              (element) =>
                                                  element.id == fileId);
                                          refreshAnnouncementsInPreviousPage =
                                              true;
                                          setState(() {});
                                        },
                                        showOnlyStudyMaterialTitles: true,
                                        showEditAndDeleteButton: true,
                                        studyMaterial: studyMaterial,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            )
                          : const SizedBox(),

                      UploadImageOrFileButton(
                        uploadFile: true,
                        includeImageFileOnlyAllowedNote: false,
                        onTap: () {
                          _addFiles();
                        },
                      ),
                      SizedBox(height: 10),
                      if (Platform.isIOS)
                        UploadImageOrFileButton(
                          uploadFile: false,
                          includeImageFileOnlyAllowedNote: true,
                          onTap: () {
                            _addImages();
                          },
                        ),

                      //user's added study materials
                      ...List.generate(uploadedFiles.length, (index) => index)
                          .map(
                        (index) => Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: CustomFileContainer(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            onDelete: () {
                              uploadedFiles.removeAt(index);
                              setState(() {});
                            },
                            title: uploadedFiles[index].name,
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
        Get.back(result: refreshAnnouncementsInPreviousPage);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            _buildAddEditAnnouncementForm(),
            SafeArea(child: _buildSubmitButton()),
            Align(
              alignment: Alignment.topCenter,
              child: CustomAppbar(
                titleKey: widget.announcement != null
                    ? editAnnouncementKey
                    : addAnnouncementKey,
                onBackButtonTap: () {
                  Get.back(result: refreshAnnouncementsInPreviousPage);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
