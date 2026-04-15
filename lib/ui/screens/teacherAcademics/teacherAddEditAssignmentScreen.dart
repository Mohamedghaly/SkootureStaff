import 'dart:io';

import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/createAssignmentCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignment/editAssignmentCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/data/models/assignment.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCheckboxContainer.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TeacherAddEditAssignmentScreen extends StatefulWidget {
  final Assignment? assignment;
  final List<ClassSection>? selectedClassSection;
  final TeacherSubject? selectedSubject;
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CreateAssignmentCubit(),
        ),
        BlocProvider(
          create: (context) => EditAssignmentCubit(),
        ),
        BlocProvider(
          create: (context) => ClassSectionsAndSubjectsCubit(),
        ),
      ],
      child: TeacherAddEditAssignmentScreen(
        assignment: arguments?['assignment'],
        selectedClassSection: arguments?['selectedClassSection'],
        selectedSubject: arguments?['selectedSubject'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required Assignment? assignment,
      required List<ClassSection>? selectedClassSection,
      required TeacherSubject? selectedSubject}) {
    return {
      "assignment": assignment,
      "selectedClassSection": selectedClassSection,
      "selectedSubject": selectedSubject
    };
  }

  const TeacherAddEditAssignmentScreen(
      {super.key,
      required this.assignment,
      this.selectedClassSection,
      this.selectedSubject});

  @override
  State<TeacherAddEditAssignmentScreen> createState() =>
      _TeacherAddEditAssignmentScreenState();
}

class _TeacherAddEditAssignmentScreenState
    extends State<TeacherAddEditAssignmentScreen> {
  late List<ClassSection>? _selectedClassSections = widget.selectedClassSection;

  late TeacherSubject? _selectedSubject = widget.selectedSubject;

  bool isUrlSelected = false;
  final TextEditingController _urlController = TextEditingController();

  //This will determine if need to refresh the previous page
  //assignments data. If teacher remove the the any file
  //so we need to fetch the list again
  late bool refreshAssignmentsInPreviousPage = false;

  late final TextEditingController _assignmentNameTextEditingController =
      TextEditingController(
    text: widget.assignment?.name,
  );
  late final TextEditingController _assignmentInstructionTextEditingController =
      TextEditingController(
    text: widget.assignment?.instructions,
  );

  late final TextEditingController _assignmentPointsTextEditingController =
      TextEditingController(
    text: widget.assignment?.points.toString(),
  );

  late final TextEditingController _extraResubmissionDaysTextEditingController =
      TextEditingController(
    text: widget.assignment?.extraDaysForResubmission.toString(),
  );
  late bool _allowedReSubmissionOfRejectedAssignment =
      widget.assignment?.resubmission == 1;

  late DateTime? dueDate = widget.assignment != null
      ? _parseDateFromCustomFormat(widget.assignment!.dueDate)
      : null;

  // Helper method for date parsing
  DateTime? _parseDateFromCustomFormat(String dateString) {
    try {
      // Parse the custom format "20-09-2025 01:14 PM"
      final DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
      return formatter.parse(dateString);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  late TimeOfDay? dueTime = widget.assignment != null
      ? _parseTimeFromCustomFormat(widget.assignment!.dueDate)
      : null;

  // Helper method to parse the custom date format
  TimeOfDay? _parseTimeFromCustomFormat(String dateString) {
    try {
      // Parse the custom format "20-09-2025 01:14 PM"
      final DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
      final DateTime parsedDate = formatter.parse(dateString);
      return TimeOfDay.fromDateTime(parsedDate);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  // Helper method to format TimeOfDay to 12-hour format with AM/PM for display
  String formatTimeOfDayFor12Hour(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat('hh:mm a').format(dateTime);
  }

  // Helper method to format TimeOfDay for API (12-hour with AM/PM)
  String formatTimeOfDayForAPI(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat('hh:mm a').format(dateTime);
  }

  // URL validation method
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  List<PlatformFile> uploadedFiles = [];

  late List<StudyMaterial> assignmentAttachments =
      widget.assignment?.studyMaterial ?? [];

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
    _assignmentNameTextEditingController.dispose();
    _assignmentInstructionTextEditingController.dispose();
    _assignmentPointsTextEditingController.dispose();
    _extraResubmissionDaysTextEditingController.dispose();
    _urlController.dispose();

    super.dispose();
  }

  Future<void> _addFiles() async {
    final result = await Utils.openFilePicker(
      context: context,
    );
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

  Future<void> openDatePicker() async {
    final temp = await Utils.openDatePicker(context: context);
    if (temp != null) {
      dueDate = temp;
      setState(() {});
    }
  }

  Future<void> openTimePicker() async {
    final temp = await Utils.openTimePicker(context: context);
    if (temp != null) {
      dueTime = temp;
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
          final state = context.read<ClassSectionsAndSubjectsCubit>().state;
          if (state is ClassSectionsAndSubjectsFetchSuccess) {
            changeSelectedTeacherSubject(state.subjects.firstOrNull);
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

  void createAssignment() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_selectedSubject == null) {
      showErrorMessage(Utils.getTranslatedLabel(noSubjectSelectedKey));
      return;
    }

    if (_selectedClassSections!.isEmpty) {
      showErrorMessage(Utils.getTranslatedLabel(noClassSectionSelectedKey));
      return;
    }

    if (_assignmentNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(Utils.getTranslatedLabel(pleaseEnterAssignmentNameKey));
      return;
    }
    if (_assignmentPointsTextEditingController.text.length >= 10) {
      showErrorMessage(Utils.getTranslatedLabel(invalidPointsLengthKey));
      return;
    }
    if (dueDate == null) {
      showErrorMessage(Utils.getTranslatedLabel(pleaseSelectDateKey));
      return;
    }
    if (dueTime == null) {
      showErrorMessage(Utils.getTranslatedLabel(pleaseSelectTimeKey));
      return;
    }
    if (_extraResubmissionDaysTextEditingController.text.trim().isEmpty &&
        _allowedReSubmissionOfRejectedAssignment) {
      showErrorMessage(pleaseEnterExtraDaysForResubmissionKey);
      return;
    }

    // Updated URL validation
    if (isUrlSelected) {
      if (_urlController.text.trim().isEmpty) {
        showErrorMessage("Please enter a URL");
        return;
      }
      if (!_isValidUrl(_urlController.text.trim())) {
        showErrorMessage("Please enter a valid URL");
        return;
      }
    }

    // Updated datetime format to match your expected format
    final formattedDateTime =
        "${DateFormat('dd-MM-yyyy').format(dueDate!)} ${formatTimeOfDayForAPI(dueTime!)}";

    context.read<CreateAssignmentCubit>().createAssignment(
          classSectionId:
              _selectedClassSections!.map((e) => e.id ?? 0).toList(),
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          name: _assignmentNameTextEditingController.text.trim(),
          dateTime: formattedDateTime,
          extraDayForResubmission:
              _extraResubmissionDaysTextEditingController.text.trim(),
          instruction: _assignmentInstructionTextEditingController.text.trim(),
          points: _assignmentPointsTextEditingController.text.trim(),
          resubmission: _allowedReSubmissionOfRejectedAssignment,
          file: uploadedFiles,
          url: _urlController.text.trim(),
        );
  }

  void editAssignment() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_assignmentNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterAssignmentNameKey);
      return;
    }
    if (dueDate == null) {
      showErrorMessage(pleaseSelectDateKey);
      return;
    }
    if (_assignmentPointsTextEditingController.text.length >= 10) {
      showErrorMessage(invalidPointsLengthKey);
      return;
    }
    if (dueTime == null) {
      showErrorMessage(pleaseSelectDateKey);
      return;
    }
    if (_extraResubmissionDaysTextEditingController.text.trim().isEmpty &&
        _allowedReSubmissionOfRejectedAssignment) {
      showErrorMessage(pleaseEnterExtraDaysForResubmissionKey);
      return;
    }

    // Updated URL validation for edit
    if (isUrlSelected) {
      if (_urlController.text.trim().isEmpty) {
        showErrorMessage("Please enter a URL");
        return;
      }
      if (!_isValidUrl(_urlController.text.trim())) {
        showErrorMessage("Please enter a valid URL");
        return;
      }
    }

    // Updated datetime format to match your expected format
    final formattedDateTime =
        "${DateFormat('dd-MM-yyyy').format(dueDate!)} ${formatTimeOfDayForAPI(dueTime!)}";

    context.read<EditAssignmentCubit>().editAssignment(
          classSelectionId:
              _selectedClassSections!.map((e) => e.id ?? 0).toList(),
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          name: _assignmentNameTextEditingController.text.trim(),
          dateTime: formattedDateTime,
          extraDayForResubmission:
              _extraResubmissionDaysTextEditingController.text.trim(),
          instruction: _assignmentInstructionTextEditingController.text.trim(),
          points: _assignmentPointsTextEditingController.text.trim(),
          resubmission: _allowedReSubmissionOfRejectedAssignment ? 1 : 0,
          filePaths: uploadedFiles,
          assignmentId: widget.assignment!.id,
          url: _urlController.text.trim(),
        );
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
        Text(Utils.getTranslatedLabel(addUrlKey)),
      ],
    );
  }

  Widget _buildUrlInputForm() {
    return isUrlSelected
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(Utils.getTranslatedLabel(addUrlTitleKey)),
              const SizedBox(height: 5),
              CustomTextFieldContainer(
                textEditingController: _urlController,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                hintTextKey: addUrlFiedKey,
              ),
              // Optional: Show URL format hint for invalid URLs
              if (_urlController.text.isNotEmpty &&
                  !_isValidUrl(_urlController.text))
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "Please enter a valid URL (e.g., https://example.com)",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
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
        child: widget.assignment != null
            ? BlocConsumer<EditAssignmentCubit, EditAssignmentState>(
                listener: (context, state) {
                  debugPrint("this is the state ${state}");
                  if (state is EditAssignmentSuccess) {
                    Get.back(result: true);
                    Utils.showSnackBar(
                        context: context,
                        message: assignmentEditedSuccessfullyKey);
                  } else if (state is EditAssignmentFailure) {
                    debugPrint(
                        "this is the error message ${state.errorMessage}");
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
                        if (state is EditAssignmentInProgress) {
                          return;
                        }
                        editAssignment();
                      },
                      child: state is EditAssignmentInProgress
                          ? const CustomCircularProgressIndicator(
                              strokeWidth: 2,
                              widthAndHeight: 20,
                            )
                          : null);
                },
              )
            : BlocConsumer<CreateAssignmentCubit, CreateAssignmentState>(
                listener: (context, state) {
                  if (state is CreateAssignmentSuccess) {
                    Get.back(result: true);
                    Utils.showSnackBar(
                        context: context,
                        message: assignmentAddedSuccessfullyKey);
                  } else if (state is CreateAssignmentFailure) {
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
                        if (state is CreateAssignmentInProcess) {
                          return;
                        }
                        createAssignment();
                      },
                      child: state is CreateAssignmentInProcess
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

  Widget _buildAddEditAssignmentForm() {
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
                        isDisabled: widget.assignment !=
                            null, //if user is editing, they can't change class
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
                        isDisabled: widget.assignment !=
                            null, //if user is editing, they can't change subject
                        onTap: () {
                          if (state is ClassSectionsAndSubjectsFetchSuccess) {
                            Utils.showBottomSheet(
                              child: FilterSelectionBottomsheet<TeacherSubject>(
                                showFilterByLabel: false,
                                selectedValue: _selectedSubject!,
                                titleKey: subjectKey,
                                values: state.subjects,
                                onSelection: (value) {
                                  changeSelectedTeacherSubject(value!);
                                  Get.back();
                                },
                              ),
                              context: context,
                            );
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
                              _assignmentNameTextEditingController,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          hintTextKey: assignmentNameKey),
                      CustomTextFieldContainer(
                          textEditingController:
                              _assignmentInstructionTextEditingController,
                          maxLines: 5,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          hintTextKey: instructionsKey),
                      Row(
                        children: [
                          Expanded(
                            child: CustomSelectionDropdownSelectionButton(
                              onTap: () {
                                openDatePicker();
                              },
                              titleKey: dueDate != null
                                  ? Utils.getFormattedDate(dueDate!)
                                  : dueDateKey,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: CustomSelectionDropdownSelectionButton(
                              onTap: () {
                                openTimePicker();
                              },
                              titleKey: dueTime != null
                                  ? formatTimeOfDayFor12Hour(dueTime!)
                                  : dueTimeKey,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      CustomTextFieldContainer(
                        keyboardType: TextInputType.number,
                        textEditingController:
                            _assignmentPointsTextEditingController,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        hintTextKey: pointsKey,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      CustomCheckboxContainer(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        titleKey: resubmissionAllowedKey,
                        value: _allowedReSubmissionOfRejectedAssignment,
                        onValueChanged: (bool? value) {
                          if (value != null) {
                            setState(() {
                              _allowedReSubmissionOfRejectedAssignment = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      if (_allowedReSubmissionOfRejectedAssignment) ...[
                        CustomTextFieldContainer(
                            textEditingController:
                                _extraResubmissionDaysTextEditingController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            hintTextKey: extraDaysForResubmissionKey),
                      ],

                      _buildUrlOption(),
                      _buildUrlInputForm(),

                      //pre-added study materials
                      widget.assignment != null
                          ? Column(
                              children: assignmentAttachments
                                  .map(
                                    (studyMaterial) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: StudyMaterialContainer(
                                        onDeleteStudyMaterial: (fileId) {
                                          assignmentAttachments.removeWhere(
                                              (element) =>
                                                  element.id == fileId);
                                          refreshAssignmentsInPreviousPage =
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
        Get.back(result: refreshAssignmentsInPreviousPage);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            _buildAddEditAssignmentForm(),
            _buildSubmitButton(),
            Align(
              alignment: Alignment.topCenter,
              child: CustomAppbar(
                titleKey: widget.assignment != null
                    ? editAssignmentKey
                    : createAssignmentKey,
                onBackButtonTap: () {
                  Get.back(result: refreshAssignmentsInPreviousPage);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
