import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/studentsByClassSectionCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/exam/examCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/exam/submitExamMarksCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/exam.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';

import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherExamResultScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
        BlocProvider(
          create: (context) => ExamsCubit(),
        ),
        BlocProvider(
          create: (context) => StudentsByClassSectionCubit(),
        ),
        BlocProvider(
          create: (context) => SubmitExamMarksCubit(),
        ),
      ],
      child: const TeacherExamResultScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherExamResultScreen({super.key});

  @override
  State<TeacherExamResultScreen> createState() =>
      _TeacherExamResultScreenState();
}

class _TeacherExamResultScreenState extends State<TeacherExamResultScreen> {
  ClassSection? _selectedClassSection;
  ExamTimeTable? _selectedExamTimetableSubject;
  Exam? _selectedExam;

  List<TextEditingController> marksControllers = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ClassesCubit>().getClasses();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    for (var element in marksControllers) {
      element.dispose();
    }
    super.dispose();
  }

  void changeSelectedClassSection(ClassSection? classSection,
      {bool fetchNewSubjects = true}) {
    if (_selectedClassSection != classSection) {
      _selectedClassSection = classSection;
      getExams();
      setState(() {});
    }
  }

  void getExams() {
    context.read<ExamsCubit>().fetchExamsList(
          examStatus: 2, //exam should be finished
          publishStatus: 0, //exam should not be published
          classSectionId: _selectedClassSection?.id ?? 0,
        );
  }

  bool _isAllRequiredDataAvailable() {
    return _selectedClassSection?.id != null &&
        _selectedExam?.examID != null &&
        _selectedExamTimetableSubject?.subjectId != null &&
        _selectedExamTimetableSubject!.subjectId.toString().isNotEmpty;
  }

  void getStudents() {
    // Only call API if all required data is available
    if (!_isAllRequiredDataAvailable()) {
      return;
    }

    context.read<StudentsByClassSectionCubit>().fetchStudents(
        status: StudentListStatus.active,
        classSectionId: _selectedClassSection?.id ?? 0,
        examId: _selectedExam!.examID,
        classSubjectId: _selectedExamTimetableSubject!.subjectId);
  }

  void setupMarksInitialValues(List<StudentDetails> students) {
    for (var element in marksControllers) {
      element.dispose();
    }
    marksControllers.clear();
    for (int i = 0; i < students.length; i++) {
      //pre-filling marks if already there for the user for selected subject
      marksControllers.add(TextEditingController(
          text: students[i]
              .examMarks
              ?.firstWhereOrNull((element) =>
                  element.examTimetableId == _selectedExamTimetableSubject?.id)
              ?.obtainedMarks
              .toString()));
    }
  }

  Widget _buildStudentContainer({
    required StudentDetails studentDetails,
    required TextEditingController controller,
    required int index,
  }) {
    final border = BorderSide(color: Theme.of(context).colorScheme.tertiary);

    final TextInputFormatter decimalFormatter = TextInputFormatter.withFunction(
      (oldValue, newValue) {
        final regExp = RegExp(r'^\d*\.?\d*');
        if (regExp.hasMatch(newValue.text)) {
          return newValue;
        }
        return oldValue;
      },
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 65,
      padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding, vertical: 10),
      decoration: BoxDecoration(
          border: Border(left: border, bottom: border, right: border)),
      child: Row(
        children: [
          CustomTextContainer(textKey: (index + 1).toString().padLeft(2, '0')),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: CustomTextContainer(
              textKey: studentDetails.fullName ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          SizedBox(
            width: 100,
            height: 50,
            child: CustomTextFieldContainer(
              hintTextKey: "",
              inputFormatters: [
                decimalFormatter,
              ],
              bottomPadding: 0,
              textEditingController: controller,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsContainer() {
    const titleStyle = TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600);
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: Utils.appContentTopScrollPadding(context: context) + 150,
            bottom: 90),
        child: BlocConsumer<StudentsByClassSectionCubit,
            StudentsByClassSectionState>(
          listener: (context, state) {
            if (state is StudentsByClassSectionFetchSuccess) {
              //Setting up marks text editing controllers before build
              setupMarksInitialValues(state.studentDetailsList);
            }
          },
          builder: (context, state) {
            // Check if all required data is available
            if (!_isAllRequiredDataAvailable()) {
              String messageKey;
              if (_selectedExam?.examID == null) {
                messageKey = noExamKey;
              } else if (_selectedExamTimetableSubject?.subjectId == null ||
                  _selectedExamTimetableSubject!.subjectId.toString().isEmpty) {
                messageKey = noSubjectKey;
              } else {
                messageKey = noStudentFoundKey;
              }

              return Center(
                child: noDataContainer(titleKey: messageKey),
              );
            }

            if (state is StudentsByClassSectionFetchSuccess) {
              if (state.studentDetailsList.isEmpty) {
                return const Center(
                  child: noDataContainer(
                    titleKey: noStudentFoundKey,
                  ),
                );
              }
              return Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(appContentHorizontalPadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 45,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(5.0),
                                  topLeft: Radius.circular(5.0)),
                              color: Theme.of(context).colorScheme.tertiary),
                          padding: EdgeInsets.symmetric(
                              horizontal: appContentHorizontalPadding,
                              vertical: 10),
                          child: Row(
                            children: [
                              const CustomTextContainer(
                                textKey: "#",
                                style: titleStyle,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              const Expanded(
                                child: CustomTextContainer(
                                  textKey: nameKey,
                                  style: titleStyle,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              CustomTextContainer(
                                textKey:
                                    "${Utils.getTranslatedLabel(totalMarksKey)} ${_selectedExamTimetableSubject?.totalMarks}",
                                style: titleStyle,
                              ),
                            ],
                          ),
                        ),
                        ...List.generate(state.studentDetailsList.length,
                            (index) {
                          return _buildStudentContainer(
                            controller: marksControllers[index],
                            studentDetails: state.studentDetailsList[index],
                            index: index,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is StudentsByClassSectionFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      // Only retry if all required data is available
                      if (_isAllRequiredDataAvailable()) {
                        getStudents();
                      }
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

  // ── Validation helpers ──────────────────────────────────────────────────────

  /// Validates marks for a full publish. Returns an error message key or null.
  String? _validateForPublish() {
    for (int i = 0; i < marksControllers.length; i++) {
      final text = marksControllers[i].text.trim();
      if (text.isEmpty) {
        return pleaseAddMarksToAllStudentsKey;
      }
      final double? val = double.tryParse(text);
      if (val == null) {
        return pleaseAddMarksToAllStudentsKey;
      }
      if (val > (_selectedExamTimetableSubject?.totalMarks ?? 0)) {
        return cannotAddMoreMarksThenTotalKey;
      }
    }
    return null; // All good
  }

  /// Validates marks for a draft save.
  /// At least one mark must be entered. Only non-empty fields are checked
  /// for value validity / exceeding total.
  String? _validateForDraft() {
    // Guard: at least one field must have a value
    final bool allEmpty = marksControllers.every((c) => c.text.trim().isEmpty);
    if (allEmpty) {
      return pleaseAddAtLeastOneMarkForDraftKey;
    }

    for (int i = 0; i < marksControllers.length; i++) {
      final text = marksControllers[i].text.trim();
      if (text.isEmpty) continue; // Empty is fine for draft
      final double? val = double.tryParse(text);
      if (val == null) {
        return pleaseAddMarksToAllStudentsKey;
      }
      if (val > (_selectedExamTimetableSubject?.totalMarks ?? 0)) {
        return cannotAddMoreMarksThenTotalKey;
      }
    }
    return null;
  }

  /// Builds the marks payload to send to the API.
  ///
  /// For draft (`isDraft: true`): only students whose mark field is non-empty
  /// are included. Empty fields are completely excluded from the request —
  /// no sentinel values are ever sent.
  ///
  /// For publish (`isDraft: false`): all students are included (validation
  /// guarantees every field is filled at this point).
  List<({double obtainedMarks, int studentId})> _buildMarksPayload(
      List<StudentDetails> studentList,
      {required bool isDraft}) {
    final result = <({double obtainedMarks, int studentId})>[];
    for (int i = 0; i < marksControllers.length; i++) {
      final text = marksControllers[i].text.trim();
      // For draft: skip students whose mark field is empty
      if (isDraft && text.isEmpty) continue;
      result.add((
        obtainedMarks: double.tryParse(text) ?? 0,
        studentId: studentList[i].id ?? 0,
      ));
    }
    return result;
  }

  // ── Bottom action bar (Save Draft + Submit & Publish) ───────────────────────

  Widget _buildActionButtons() {
    return BlocBuilder<StudentsByClassSectionCubit,
        StudentsByClassSectionState>(
      builder: (context, studentState) {
        if (!_isAllRequiredDataAvailable()) {
          return const SizedBox.shrink();
        }
        if (studentState is! StudentsByClassSectionFetchSuccess) {
          return const SizedBox.shrink();
        }
        if (studentState.studentDetailsList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.bottomCenter,
          child: BlocConsumer<SubmitExamMarksCubit, SubmitExamMarksState>(
            listener: (context, state) {
              if (state is SubmitExamMarksSubmitSuccess) {
                Utils.showSnackBar(
                    message: resultAddedSuccessfullyKey, context: context);
              } else if (state is SubmitExamMarksDraftSuccess) {
                Utils.showSnackBar(
                    message: draftSavedSuccessfullyKey, context: context);
              } else if (state is SubmitExamMarksSubmitFailure) {
                Utils.showSnackBar(
                    message: state.errorMessage,
                    context: context,
                    snackDuration: const Duration(seconds: 5));
              }
            },
            builder: (context, state) {
              final bool anyLoading = state is SubmitExamMarksSubmitInProgress;
              final bool isDraftLoading =
                  state is SubmitExamMarksSubmitInProgress && state.status == 0;
              final bool isPublishLoading =
                  state is SubmitExamMarksSubmitInProgress && state.status == 1;

              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: appContentHorizontalPadding,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 4, spreadRadius: 1)
                  ],
                  color: Theme.of(context).colorScheme.surface,
                ),
                width: double.infinity,
                height: 66, // fixed bar height: 46 button + 2×10 padding
                child: Row(
                  children: [
                    // ── Save as Draft ──────────────────────────────────────
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: anyLoading
                              ? null
                              : () => _onTapSaveAsDraft(
                                  studentState.studentDetailsList),
                          style: OutlinedButton.styleFrom(
                            fixedSize: const Size.fromHeight(46),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: isDraftLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : CustomTextContainer(
                                  textKey: saveAsDraftKey,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ── Submit & Publish ───────────────────────────────────
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: anyLoading
                              ? null
                              : () => _onTapSubmitAndPublish(
                                  studentState.studentDetailsList),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size.fromHeight(46),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            disabledBackgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            elevation: 0,
                          ),
                          child: isPublishLoading
                              ? const CustomCircularProgressIndicator(
                                  strokeWidth: 2,
                                  widthAndHeight: 20,
                                )
                              : Text(
                                  Utils.getTranslatedLabel(submitAndPublishKey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onTapSaveAsDraft(List<StudentDetails> studentList) {
    final error = _validateForDraft();
    if (error != null) {
      Utils.showSnackBar(
          message: error,
          context: context,
          snackDuration: const Duration(seconds: 5));
      return;
    }
    context.read<SubmitExamMarksCubit>().submitOfflineExamMarks(
          classSubjectId: _selectedExamTimetableSubject?.subjectId ?? 0,
          examId: _selectedExam?.examID ?? 0,
          status: 0,
          marksDetails: _buildMarksPayload(studentList, isDraft: true),
        );
  }

  void _onTapSubmitAndPublish(List<StudentDetails> studentList) {
    final error = _validateForPublish();
    if (error != null) {
      Utils.showSnackBar(
          message: error,
          context: context,
          snackDuration: const Duration(seconds: 5));
      return;
    }
    context.read<SubmitExamMarksCubit>().submitOfflineExamMarks(
          classSubjectId: _selectedExamTimetableSubject?.subjectId ?? 0,
          examId: _selectedExam?.examID ?? 0,
          status: 1,
          marksDetails: _buildMarksPayload(studentList, isDraft: false),
        );
  }

  Widget _buildAppbarAndFilters() {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocConsumer<ClassesCubit, ClassesState>(
        listener: (context, state) {
          if (state is ClassesFetchSuccess) {
            if (_selectedClassSection == null) {
              changeSelectedClassSection(
                  context.read<ClassesCubit>().getAllClasses().firstOrNull,
                  fetchNewSubjects: false);
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: offlineExamResultKey),
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
                                if (state is ClassesFetchSuccess &&
                                    context
                                        .read<ClassesCubit>()
                                        .getAllClasses()
                                        .isNotEmpty) {
                                  Utils.showBottomSheet(
                                      child: FilterSelectionBottomsheet<
                                          ClassSection>(
                                        onSelection: (value) {
                                          changeSelectedClassSection(value!);
                                          Get.back();
                                        },
                                        selectedValue: _selectedClassSection!,
                                        titleKey: classKey,
                                        values: context
                                            .read<ClassesCubit>()
                                            .getAllClasses(),
                                      ),
                                      context: context);
                                }
                              },
                              titleKey: _selectedClassSection?.id == null
                                  ? classKey
                                  : (_selectedClassSection?.fullName ?? ""),
                              width: boxConstraints.maxWidth * (0.48),
                            ),
                            BlocConsumer<ExamsCubit, ExamsState>(
                              listener: (context, state) {
                                if (state is ExamsFetchSuccess) {
                                  _selectedExam = state.examList.firstOrNull;
                                  _selectedExamTimetableSubject =
                                      _selectedExam?.examTimetable?.firstOrNull;
                                  setState(() {});

                                  // Only call getStudents if all required data is available
                                  if (_isAllRequiredDataAvailable()) {
                                    getStudents();
                                  }
                                }
                              },
                              builder: (context, state) {
                                return FilterButton(
                                  onTap: () {
                                    if (state is ExamsFetchSuccess &&
                                        state.examList.isNotEmpty) {
                                      Utils.showBottomSheet(
                                          child:
                                              FilterSelectionBottomsheet<Exam>(
                                            selectedValue: _selectedExam!,
                                            titleKey: examKey,
                                            values: state.examList,
                                            onSelection: (value) {
                                              Get.back();
                                              if (value != _selectedExam) {
                                                _selectedExam = value;
                                                _selectedExamTimetableSubject =
                                                    _selectedExam?.examTimetable
                                                        ?.firstOrNull;
                                                setState(() {});
                                                // Only call getStudents if all required data is available
                                                if (_isAllRequiredDataAvailable()) {
                                                  getStudents();
                                                }
                                              }
                                            },
                                          ),
                                          context: context);
                                    }
                                  },
                                  titleKey: _selectedExam?.examID == null
                                      ? examKey
                                      : _selectedExam?.examName ?? "",
                                  width: boxConstraints.maxWidth * 0.48,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 40,
                        child: BlocBuilder<ExamsCubit, ExamsState>(
                          builder: (context, examState) {
                            return FilterButton(
                                onTap: () {
                                  if (examState is ExamsFetchSuccess) {
                                    if (_selectedExam?.examTimetable == null ||
                                        (_selectedExam
                                                ?.examTimetable?.isEmpty ??
                                            true)) {
                                      Utils.showSnackBar(
                                        context: context,
                                        message: noSubjectKey,
                                      );
                                      return;
                                    }
                                    if (_selectedExamTimetableSubject != null) {
                                      Utils.showBottomSheet(
                                          child: FilterSelectionBottomsheet<
                                              ExamTimeTable>(
                                            selectedValue:
                                                _selectedExamTimetableSubject!,
                                            titleKey: subjectKey,
                                            values:
                                                _selectedExam?.examTimetable ??
                                                    [],
                                            onSelection: (value) {
                                              _selectedExamTimetableSubject =
                                                  value;
                                              Get.back();
                                              setState(() {});
                                              // Only call getStudents if all required data is available
                                              if (_isAllRequiredDataAvailable()) {
                                                getStudents();
                                              }
                                            },
                                          ),
                                          context: context);
                                    } else {
                                      // If no subject is selected, select the first one
                                      _selectedExamTimetableSubject =
                                          _selectedExam
                                              ?.examTimetable?.firstOrNull;
                                      if (_selectedExamTimetableSubject !=
                                          null) {
                                        getStudents();
                                        setState(() {});
                                      }
                                    }
                                  }
                                },
                                titleKey:
                                    _selectedExamTimetableSubject?.id == null
                                        ? subjectKey
                                        : _selectedExamTimetableSubject
                                                ?.subjectName ??
                                            "",
                                width: boxConstraints.maxWidth);
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
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ExamsCubit, ExamsState>(builder: (context, examState) {
            return BlocBuilder<ClassesCubit, ClassesState>(
              builder: (context, state) {
                if (state is ClassesFetchSuccess &&
                    examState is ExamsFetchSuccess) {
                  if (context.read<ClassesCubit>().getAllClasses().isEmpty) {
                    return const noDataContainer(titleKey: noClassSectionKey);
                  }
                  if (examState.examList.isEmpty) {
                    return const noDataContainer(titleKey: noExamKey);
                  }
                  return Stack(
                    children: [
                      _buildStudentsContainer(),
                      _buildActionButtons(),
                    ],
                  );
                }
                if (state is ClassesFetchFailure) {
                  return Center(
                      child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context.read<ClassesCubit>().getClasses();
                    },
                  ));
                }
                if (examState is ExamsFetchFailure) {
                  return Center(
                      child: ErrorContainer(
                    errorMessage: examState.errorMessage,
                    onTapRetry: () {
                      getExams();
                    },
                  ));
                }
                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            );
          }),
          _buildAppbarAndFilters(),
        ],
      ),
    );
  }
}
