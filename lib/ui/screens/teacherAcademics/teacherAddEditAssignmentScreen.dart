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
      ? _parseDateFromApiDate(widget.assignment!.dueDate)
      : null;

  late TimeOfDay? dueTime = widget.assignment != null
      ? _parseTimeFromApiDate(widget.assignment!.dueDate)
      : null;

  List<PlatformFile> uploadedFiles = [];

  late List<StudyMaterial> assignmentAttachments =
      widget.assignment?.studyMaterial ?? [];

  // Helper method to safely parse date from API date string
  DateTime? _parseDateFromApiDate(String apiDateString) {
    try {
      // Extract date part using the utility method
      String datePart = Utils.extractDateFromDateString(apiDateString);

      // Handle slash-separated dates
      if (datePart.contains('/')) {
        final dateParts = datePart.split('/');
        if (dateParts.length == 3) {
          // Check if first part is a year (4 digits) - Y/d/m format like "2025/21/07"
          if (dateParts[0].length == 4) {
            int year = int.parse(dateParts[0]);
            int day = int.parse(dateParts[1]);
            int month = int.parse(dateParts[2]);

            // Ensure valid ranges
            if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
              try {
                return DateTime(year, month, day);
              } catch (e) {
                print('Error creating DateTime from Y/d/m format: $e');
              }
            }
          } else {
            // d/m/Y format like "21/07/2025"
            int day = int.parse(dateParts[0]);
            int month = int.parse(dateParts[1]);
            int year = int.parse(dateParts[2]);

            // Ensure valid ranges
            if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
              try {
                return DateTime(year, month, day);
              } catch (e) {
                print('Error creating DateTime from d/m/Y format: $e');
              }
            }
          }
        }
      }

      // Handle formats like "2025-07-18" (YYYY-MM-DD with hyphens)
      if (datePart.contains('-')) {
        final dateParts = datePart.split('-');
        if (dateParts.length == 3) {
          int year = int.parse(dateParts[0]);
          int month = int.parse(dateParts[1]);
          int day = int.parse(dateParts[2]);

          // Fix common date format issues (like swapped day/month)
          if (month > 12 && day <= 12) {
            // Swap month and day if month is invalid
            int temp = month;
            month = day;
            day = temp;
          }

          // Ensure valid ranges
          if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            try {
              return DateTime(year, month, day);
            } catch (e) {
              print('Error creating DateTime from hyphen format: $e');
            }
          }
        }
      }

      // Try standard parsing as fallback
      final parsedDate = DateTime.tryParse(datePart);
      if (parsedDate != null) {
        return parsedDate;
      }

      return null;
    } catch (e) {
      print('Error parsing date from API: $e');
      return null;
    }
  }

  // Helper method to safely parse time from API date string
  TimeOfDay? _parseTimeFromApiDate(String apiDateString) {
    try {
      // Try to parse the date string using DateTime.tryParse first
      final parsedDate = DateTime.tryParse(apiDateString);
      if (parsedDate != null) {
        return TimeOfDay.fromDateTime(parsedDate);
      }

      // If standard parsing fails, try to extract time from common formats
      // Handle formats like "2025-17-07 03:33 PM" or similar
      final timeRegex =
          RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?', caseSensitive: false);
      final match = timeRegex.firstMatch(apiDateString);

      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        String? amPm = match.group(3)?.toUpperCase();

        // Convert to 24-hour format if AM/PM is present
        if (amPm != null) {
          if (amPm == 'PM' && hour != 12) {
            hour += 12;
          } else if (amPm == 'AM' && hour == 12) {
            hour = 0;
          }
        }

        return TimeOfDay(hour: hour, minute: minute);
      }

      return null;
    } catch (e) {
      print('Error parsing time from API date: $e');
      return null;
    }
  }

  // Helper method to get the date part from API due_date string
  String _getDateFromApiDueDate() {
    if (widget.assignment?.dueDate != null &&
        widget.assignment!.dueDate.isNotEmpty) {
      // Extract date part from the API due_date string (e.g., "23-07-2025 02:36 PM" -> "23-07-2025")
      final parts = widget.assignment!.dueDate.split(' ');
      if (parts.isNotEmpty) {
        return parts[0]; // Return the date part
      }
    }
    return '';
  }

  // Helper method to get the time part from API due_date string
  String _getTimeFromApiDueDate() {
    if (widget.assignment?.dueDate != null &&
        widget.assignment!.dueDate.isNotEmpty) {
      // Extract time part from the API due_date string (e.g., "23-07-2025 02:36 PM" -> "02:36 PM")
      final parts = widget.assignment!.dueDate.split(' ');
      if (parts.length >= 2) {
        // Combine time and AM/PM if present
        if (parts.length >= 3) {
          return '${parts[1]} ${parts[2]}';
        }
        return parts[1];
      }
    }
    return '';
  }

  @override
  void initState() {
    // Initialize URL controller with existing assignment URL if editing
    if (widget.assignment != null) {
      _urlController.text = widget.assignment!.url;
      isUrlSelected = widget.assignment!.url.isNotEmpty;
    }

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

    if (isUrlSelected && _urlController.text.trim().isEmpty) {
      showErrorMessage(pleaseAddaValidUrl);
      return;
    }

    context.read<CreateAssignmentCubit>().createAssignment(
          classSectionId:
              _selectedClassSections!.map((e) => e.id ?? 0).toList(),
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          name: _assignmentNameTextEditingController.text.trim(),
          dateTime:
              "${DateFormat('dd-MM-yyyy').format(dueDate!).toString()} ${dueTime!.hour}:${dueTime!.minute}",
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
    }
    if (dueDate == null) {
      showErrorMessage(pleaseSelectDateKey);
    }
    if (_assignmentPointsTextEditingController.text.length >= 10) {
      showErrorMessage(invalidPointsLengthKey);
      return;
    }
    if (dueTime == null) {
      showErrorMessage(pleaseSelectDateKey);
    }
    if (_extraResubmissionDaysTextEditingController.text.trim().isEmpty &&
        _allowedReSubmissionOfRejectedAssignment) {
      showErrorMessage(pleaseEnterExtraDaysForResubmissionKey);
      return;
    }

    context.read<EditAssignmentCubit>().editAssignment(
          classSelectionId:
              _selectedClassSections!.map((e) => e.id ?? 0).toList(),
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          name: _assignmentNameTextEditingController.text.trim(),
          dateTime:
              "${DateFormat('dd-MM-yyyy').format(dueDate!).toString()} ${dueTime!.hour}:${dueTime!.minute}",
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
        child: widget.assignment != null
            ? BlocConsumer<EditAssignmentCubit, EditAssignmentState>(
                listener: (context, state) {
                  if (state is EditAssignmentSuccess) {
                    Get.back(result: true);
                    Utils.showSnackBar(
                        context: context,
                        message: assignmentEditedSuccessfullyKey);
                  } else if (state is EditAssignmentFailure) {
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
                    Utils.showSnackBar(
                        context: context,
                        message: assignmentAddedSuccessfullyKey);
                    _assignmentNameTextEditingController.text = "";
                    _assignmentInstructionTextEditingController.text = "";
                    _assignmentPointsTextEditingController.text = "";
                    _extraResubmissionDaysTextEditingController.text = "";
                    _allowedReSubmissionOfRejectedAssignment = false;
                    dueDate = null;
                    dueTime = null;
                    uploadedFiles = [];
                    assignmentAttachments = [];
                    refreshAssignmentsInPreviousPage = true;
                    setState(() {});
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
                              titleKey: widget.assignment != null
                                  ? _getDateFromApiDueDate()
                                  : (dueDate != null
                                      ? Utils.getFormattedDate(dueDate!)
                                      : dueDateKey),
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
                              titleKey: widget.assignment != null
                                  ? _getTimeFromApiDueDate()
                                  : (dueTime != null
                                      ? Utils.getFormattedDayOfTime(dueTime!)
                                      : dueTimeKey),
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
            SafeArea(child: _buildSubmitButton()),
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
