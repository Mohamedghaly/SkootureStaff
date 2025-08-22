import 'package:eschool_saas_staff/cubits/teacherAcademics/assignmentSubmissions/editAssignmetSubmissionCubit.dart';
import 'package:eschool_saas_staff/data/models/assignmentSubmission.dart';

import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherEditAssignmentSubmissionScreen extends StatefulWidget {
  final AssignmentSubmission assignmentSubmission;
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return BlocProvider(
      create: (context) => EditAssignmentSubmissionCubit(),
      child: TeacherEditAssignmentSubmissionScreen(
        assignmentSubmission: arguments?['assignmentSubmission'] ?? false,
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required AssignmentSubmission assignmentSubmission}) {
    return {"assignmentSubmission": assignmentSubmission};
  }

  const TeacherEditAssignmentSubmissionScreen(
      {super.key, required this.assignmentSubmission});

  @override
  State<TeacherEditAssignmentSubmissionScreen> createState() =>
      _TeacherEditAssignmentSubmissionScreenState();
}

class _TeacherEditAssignmentSubmissionScreenState
    extends State<TeacherEditAssignmentSubmissionScreen> {
  bool isAccepting = true;
  late final TextEditingController _feedbackTextEditingController =
      TextEditingController();
  late final TextEditingController _pointsTextEditingController =
      TextEditingController();

  @override
  void dispose() {
    _feedbackTextEditingController.dispose();
    _pointsTextEditingController.dispose();
    super.dispose();
  }

  void showErrorMessage(String errorMessageKey) {
    Utils.showSnackBar(
      context: context,
      message: errorMessageKey,
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
        child: BlocConsumer<EditAssignmentSubmissionCubit,
            EditAssignmentSubmissionState>(
          listener: (context, state) {
            if (state is EditAssignmentSubmissionSuccess) {
              Get.back(
                result: widget.assignmentSubmission.copyWith(
                  id: widget.assignmentSubmission.id,
                  feedback: _feedbackTextEditingController.text.trim(),
                  status: isAccepting ? 1 : 2,
                  points: int.tryParse(_pointsTextEditingController.text) ?? 0,
                ),
              );
              Utils.showSnackBar(
                context: context,
                message: assignmentReviewAddedSuccessfullyKey,
              );
            }
            if (state is EditAssignmentSubmissionFailure) {
              Utils.showSnackBar(
                context: context,
                message: assignmentReviewAddingFailedKey,
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
                if (isAccepting &&
                    widget.assignmentSubmission.assignment.points != 0) {
                  if (_pointsTextEditingController.text.trim().isEmpty) {
                    showErrorMessage(
                        Utils.getTranslatedLabel(pleaseEnterPointsKey));
                    return;
                  } else if ((int.tryParse(
                              _pointsTextEditingController.text.trim()) ??
                          0) >
                      widget.assignmentSubmission.assignment.points) {
                    showErrorMessage(Utils.getTranslatedLabel(
                        cannotGiveMorePointsThenTotalKey));
                    return;
                  }
                }
                if (_feedbackTextEditingController.text.trim().isEmpty) {
                  showErrorMessage(
                      Utils.getTranslatedLabel(pleaseEnterFeedbackKey));
                  return;
                }

                context
                    .read<EditAssignmentSubmissionCubit>()
                    .updateAssignmentSubmission(
                      assignmentSubmissionId: widget.assignmentSubmission.id,
                      assignmentSubmissionStatus: isAccepting ? 1 : 2,
                      assignmentSubmissionPoints:
                          (widget.assignmentSubmission.assignment.points <=
                                      0) ||
                                  !isAccepting
                              ? "0"
                              : _pointsTextEditingController.text.trim(),
                      assignmentSubmissionFeedBack:
                          _feedbackTextEditingController.text.trim(),
                    );
              },
              child: state is EditAssignmentSubmissionInProgress
                  ? const CustomCircularProgressIndicator(
                      strokeWidth: 2,
                      widthAndHeight: 20,
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isNonEditable =
        widget.assignmentSubmission.submissionStatus.filter ==
                AssignmentSubmissionFilters.accepted ||
            widget.assignmentSubmission.submissionStatus.filter ==
                AssignmentSubmissionFilters.rejected;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: 100,
                  left: appContentHorizontalPadding,
                  right: appContentHorizontalPadding,
                  top: Utils.appContentTopScrollPadding(context: context) + 20),
              child: BlocBuilder<EditAssignmentSubmissionCubit,
                  EditAssignmentSubmissionState>(
                builder: (context, state) {
                  return IgnorePointer(
                    ignoring: state is EditAssignmentSubmissionInProgress,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextFieldContainer(
                            enabled: false,
                            borderColor: Theme.of(context).colorScheme.primary,
                            labelTextKey: assignmentNameKey,
                            initialValue:
                                widget.assignmentSubmission.assignment.name,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            hintTextKey: assignmentNameKey),
                        CustomTextFieldContainer(
                            enabled: false,
                            borderColor: Theme.of(context).colorScheme.primary,
                            labelTextKey: subjectKey,
                            initialValue: widget
                                .assignmentSubmission.assignment.subject
                                .getSybjectNameWithType(),
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            hintTextKey: subjectKey),
                        CustomTextFieldContainer(
                            enabled: false,
                            borderColor: Theme.of(context).colorScheme.primary,
                            labelTextKey: studentNameKey,
                            initialValue:
                                widget.assignmentSubmission.student.fullName,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            hintTextKey: studentNameKey),
                        CustomSelectionDropdownSelectionButton(
                          onTap: () {
                            if (isNonEditable) {
                              return;
                            }
                            Utils.showBottomSheet(
                                child: FilterSelectionBottomsheet<String>(
                                    onSelection: (value) {
                                      Get.back();
                                      isAccepting = value == acceptKey;
                                      if (!isAccepting) {
                                        _pointsTextEditingController.text = "";
                                      }
                                      setState(() {});
                                    },
                                    selectedValue:
                                        isAccepting ? acceptKey : rejectKey,
                                    titleKey: statusKey,
                                    showFilterByLabel: false,
                                    values: const [acceptKey, rejectKey]),
                                context: context);
                          },
                          titleKey: isNonEditable
                              ? widget.assignmentSubmission.submissionStatus
                                  .titleKey
                              : isAccepting
                                  ? acceptKey
                                  : rejectKey,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        if ((isAccepting ||
                                (isNonEditable &&
                                    widget.assignmentSubmission.submissionStatus
                                            .filter ==
                                        AssignmentSubmissionFilters
                                            .accepted)) &&
                            widget.assignmentSubmission.assignment.points != 0)
                          CustomTextFieldContainer(
                            enabled: !isNonEditable,
                            textEditingController: isNonEditable
                                ? null
                                : _pointsTextEditingController,
                            initialValue: isNonEditable
                                ? widget.assignmentSubmission.points.toString()
                                : null,
                            borderColor: Theme.of(context).colorScheme.primary,
                            labelTextKey:
                                "${Utils.getTranslatedLabel(pointsKey)} ${Utils.getTranslatedLabel(outOfKey)} ${widget.assignmentSubmission.assignment.points}",
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            hintTextKey: pointsKey,
                          ),
                        CustomTextFieldContainer(
                            enabled: !isNonEditable,
                            initialValue: isNonEditable
                                ? widget.assignmentSubmission.feedback
                                : null,
                            textEditingController: isNonEditable
                                ? null
                                : _feedbackTextEditingController,
                            maxLines: 3,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            hintTextKey: feedbackKey),
                        Text(
                          Utils.getTranslatedLabel(filesKey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.76),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        //pre-added study materials
                        Column(
                          children: widget.assignmentSubmission.file
                              .map(
                                (studyMaterial) => Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: StudyMaterialContainer(
                                    showOnlyStudyMaterialTitles: true,
                                    showEditAndDeleteButton: false,
                                    studyMaterial: studyMaterial,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          //they can not accept/reject it again if already reviewed
          if (!isNonEditable) _buildSubmitButton(),
          const Align(
            alignment: Alignment.topCenter,
            child: CustomAppbar(
              titleKey: reviewAssignmentSubmissionKey,
            ),
          ),
        ],
      ),
    );
  }
}
