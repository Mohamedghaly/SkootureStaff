import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/assignmentSubmissions/assignmentSubmissionsCubit.dart';
import 'package:eschool_saas_staff/data/models/assignment.dart';
import 'package:eschool_saas_staff/data/models/assignmentSubmission.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherEditAssignmentSubmission.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customExpandableContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customTitleDescriptionContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customImageWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherManageAssignmentSubmissionScreen extends StatefulWidget {
  final Assignment assignment;

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => AssignmentSubmissionsCubit(),
      child: TeacherManageAssignmentSubmissionScreen(
        assignment: arguments['assignment'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments({required Assignment assignment}) {
    return {"assignment": assignment};
  }

  const TeacherManageAssignmentSubmissionScreen(
      {super.key, required this.assignment});

  @override
  State<TeacherManageAssignmentSubmissionScreen> createState() =>
      _TeacherManageAssignmentSubmissionScreenState();
}

class _TeacherManageAssignmentSubmissionScreenState
    extends State<TeacherManageAssignmentSubmissionScreen> {
  AssignmentSubmissionStatus selectedAssignmentSubmissionFilterStatus =
      allAssignmentSubmissionStatus.first;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchAssignmentSubmissions();
    });
    super.initState();
  }

  void fetchAssignmentSubmissions() {
    context
        .read<AssignmentSubmissionsCubit>()
        .fetchAssignmentSubmissions(assignmentId: widget.assignment.id);
  }

  Widget _buildAssignmentSubmissionItem(
      {required AssignmentSubmission assignmentSubmission}) {
    final AssignmentSubmissionStatus status =
        Utils.getAssignmentSubmissionStatusFromTypeId(
            typeId: assignmentSubmission.status);

    return CustomExpandableContainer(
      customTitleWidget: Container(
        constraints: const BoxConstraints(maxHeight: 30, maxWidth: 30),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomImageWidget(
          imagePath: assignmentSubmission.student.image,
        ),
      ),
      contractedContentWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTitleDescriptionContainer(
                  titleKey: submittedOnKey,
                  description: Utils.formatDateAndTime(
                    Utils.parseDateSafely(assignmentSubmission.createdAt) ?? DateTime.now(),
                  ),
                ),
              ),
              CustomTitleDescriptionContainer(
                titleKey: statusKey,
                description: "",
                customDescriptionWidget: Container(
                  decoration: BoxDecoration(
                    color: status.color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: CustomTextContainer(
                    textKey: status.titleKey,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      expandedContentWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (assignmentSubmission.points != 0)
            CustomTitleDescriptionContainer(
              titleKey: pointsKey,
              description:
                  "${assignmentSubmission.points.toString()} / ${assignmentSubmission.assignment.points}",
            ),
          if (assignmentSubmission.points != 0 &&
              assignmentSubmission.feedback.trim().isNotEmpty)
            const SizedBox(
              height: 10,
            ),
          if (assignmentSubmission.feedback.trim().isNotEmpty)
            CustomTitleDescriptionContainer(
              titleKey: feedbackKey,
              description: assignmentSubmission.feedback,
            ),
        ],
      ),
      onEdit: () {
        Get.toNamed(Routes.teacherEditAssignmentSubmissionScreen,
                arguments: TeacherEditAssignmentSubmissionScreen.buildArguments(
                    assignmentSubmission: assignmentSubmission))
            ?.then((value) {
          if (value != null && value is AssignmentSubmission) {
            if (mounted) {
              context.read<AssignmentSubmissionsCubit>().updateReviewAssignment(
                  updatedReviewAssignmentSubmission: value);
            }
          }
        });
      },
      isStudyMaterialFile: true,
      studyMaterials: assignmentSubmission.file,
      titleText: assignmentSubmission.student.fullName,
    );
  }

  Widget _buildAssignmentSubmissionList() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: Utils.appContentTopScrollPadding(context: context) + 95),
        child:
            BlocBuilder<AssignmentSubmissionsCubit, AssignmentSubmissionsState>(
          builder: (context, state) {
            if (state is AssignmentSubmissionsFetchedSuccess) {
              final List<AssignmentSubmission> filteredAssignmentSubmissions =
                  [];
              filteredAssignmentSubmissions.addAll(state.reviewAssignment);
              if (selectedAssignmentSubmissionFilterStatus.filter !=
                  AssignmentSubmissionFilters.all) {
                //if any filter is selected, remove the items that does not apply that filter to
                filteredAssignmentSubmissions.removeWhere((element) =>
                    element.status !=
                    selectedAssignmentSubmissionFilterStatus.typeStatusId);
              }
              if (filteredAssignmentSubmissions.isEmpty) {
                return const SizedBox.shrink();
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
                      textKey: assignmentSubmissionListKey,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ...List.generate(
                      state.reviewAssignment.length,
                      (index) => _buildAssignmentSubmissionItem(
                          assignmentSubmission: state.reviewAssignment[index]),
                    ),
                  ],
                ),
              );
            } else if (state is AssignmentSubmissionsFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      fetchAssignmentSubmissions();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAssignmentSubmissionList(),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                CustomAppbar(titleKey: widget.assignment.name),
                AppbarFilterBackgroundContainer(
                  child: LayoutBuilder(
                    builder: (context, boxConstraints) {
                      return FilterButton(
                          onTap: () {
                            Utils.showBottomSheet(
                                child: FilterSelectionBottomsheet<
                                        AssignmentSubmissionStatus>(
                                    onSelection: (value) {
                                      Get.back();
                                      if (value != null) {
                                        selectedAssignmentSubmissionFilterStatus =
                                            value;
                                        setState(() {});
                                      }
                                    },
                                    selectedValue:
                                        selectedAssignmentSubmissionFilterStatus,
                                    titleKey: statusKey,
                                    values: allAssignmentSubmissionStatus),
                                context: context);
                          },
                          titleKey:
                              selectedAssignmentSubmissionFilterStatus.titleKey,
                          width: boxConstraints.maxWidth);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
