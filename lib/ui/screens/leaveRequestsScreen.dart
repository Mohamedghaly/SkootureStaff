import 'package:eschool_saas_staff/cubits/leave/approveOrRejectLeaveRequestCubit.dart';
import 'package:eschool_saas_staff/cubits/leave/leaveRequestsCubit.dart';
import 'package:eschool_saas_staff/data/models/leaveRequest.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/homeContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  static Widget getRouteInstance() => BlocProvider(
        create: (context) => LeaveRequestsCubit(),
        child: const LeaveRequestsScreen(),
      );

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<LeaveRequestsCubit>().getLeaveRequests();
      }
    });
  }

  void rejectOrApproveLeave(
      {required LeaveRequest leaveRequest, required bool approveLeave}) {
    Utils.showBottomSheet(
            child: BlocProvider(
              create: (context) => ApproveOrRejectLeaveRequestCubit(),
              child: LeaveRequestDetailsBottomsheet(
                approveLeave: approveLeave,
                leaveRequest: leaveRequest,
              ),
            ),
            context: context)
        .then((value) {
      final refreshLeaveRequests = (value as bool?) ?? false;
      if (refreshLeaveRequests) {
        if (mounted) {
          context.read<LeaveRequestsCubit>().getLeaveRequests();
        }
      }
    });
  }

  Widget _buildLeaveRequestDetails({required LeaveRequest leaveRequest}) {
    final titleTextStyle = TextStyle(
        fontSize: 13.0,
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.75));
    const dateTextStyle =
        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileImageContainer(
                imageUrl: leaveRequest.user?.image ?? "",
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextContainer(
                    textKey: leaveRequest.user?.fullName ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                ],
              )),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 7.5),
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    child: CustomTextContainer(
                      textKey:
                          (leaveRequest.leaveDetail?.length ?? 1).toString(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18.0),
                    ),
                  ),
                  CustomTextContainer(
                    textKey: totalKey,
                    style: TextStyle(
                        fontSize: 13.0,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.76)),
                  ),
                ],
              )
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextContainer(
                    textKey: fromDateKey,
                    style: titleTextStyle,
                  ),
                  CustomTextContainer(
                      textKey:
                          Utils.parseDateSafely(leaveRequest.fromDate ?? "") !=
                                  null
                              ? Utils.formatDate(Utils.parseDateSafely(
                                  leaveRequest.fromDate ?? "")!)
                              : (leaveRequest.fromDate ?? ""),
                      style: dateTextStyle),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextContainer(
                    textKey: toDateKey,
                    style: titleTextStyle,
                  ),
                  CustomTextContainer(
                      textKey: Utils.parseDateSafely(
                                  leaveRequest.toDate ?? "") !=
                              null
                          ? Utils.formatDate(
                              Utils.parseDateSafely(leaveRequest.toDate ?? "")!)
                          : (leaveRequest.toDate ?? ""),
                      style: dateTextStyle),
                ],
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextContainer(
                textKey: leaveReasonKey,
                style: titleTextStyle,
              ),
              CustomTextContainer(
                textKey: leaveRequest.reason ?? "",
                style: dateTextStyle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(
            height: 10,
          ),
          LayoutBuilder(builder: (context, boxConstraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: boxConstraints.maxWidth * (0.48),
                  child: CustomRoundedButton(
                    radius: 5,
                    height: 40,
                    widthPercentage: 1.0,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    buttonTitle: rejectKey,
                    borderColor: Theme.of(context).colorScheme.secondary,
                    titleColor: Theme.of(context).colorScheme.secondary,
                    showBorder: true,
                    onTap: () {
                      rejectOrApproveLeave(
                          leaveRequest: leaveRequest, approveLeave: false);
                    },
                  ),
                ),
                SizedBox(
                  width: boxConstraints.maxWidth * (0.48),
                  child: CustomRoundedButton(
                    radius: 5,
                    height: 40,
                    widthPercentage: 1.0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: approveKey,
                    showBorder: false,
                    onTap: () {
                      rejectOrApproveLeave(
                          leaveRequest: leaveRequest, approveLeave: true);
                    },
                  ),
                )
              ],
            );
          })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        BlocConsumer<LeaveRequestsCubit, LeaveRequestsState>(
          listener: (context, state) {
            if (state is LeaveRequestsFetchSuccess) {
              HomeContainer.widgetKey.currentState?.updateLeaveRequestCount(
                  totalLeaveRequests: state.leaveRequests.length);
            }
          },
          builder: (context, state) {
            if (state is LeaveRequestsFetchSuccess) {
              if (state.leaveRequests.isEmpty) {
                return Center(
                  child: noDataContainer(
                    titleKey: noLeaveRequestsKey,
                  ),
                );
              }
              return Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      left: appContentHorizontalPadding,
                      right: appContentHorizontalPadding,
                      top: Utils.appContentTopScrollPadding(context: context) +
                          25),
                  child: Column(
                    children: state.leaveRequests
                        .map((leaveRequest) => _buildLeaveRequestDetails(
                            leaveRequest: leaveRequest))
                        .toList(),
                  ),
                ),
              );
            }
            if (state is LeaveRequestsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context.read<LeaveRequestsCubit>().getLeaveRequests();
                  },
                ),
              );
            }

            return Center(
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
        const Align(
          alignment: Alignment.topCenter,
          child: CustomAppbar(titleKey: leaveRequestKey),
        )
      ],
    ));
  }
}

class LeaveRequestDetailsBottomsheet extends StatelessWidget {
  final bool approveLeave;
  final LeaveRequest leaveRequest;
  const LeaveRequestDetailsBottomsheet(
      {super.key, required this.approveLeave, required this.leaveRequest});

  @override
  Widget build(BuildContext context) {
    final hasAttachments = leaveRequest.attachments?.isNotEmpty ?? false;
    return CustomBottomsheet(
        titleLabelKey: leaveDetailsKey,
        child: Column(
          children: [
            ...leaveRequest.leaveDetail
                    ?.map((leaveDetail) => ListTile(
                          subtitle: CustomTextContainer(
                              textKey: leaveDetail.type ?? ""),
                          title: CustomTextContainer(textKey: () {
                            final parsedDate =
                                Utils.parseDateSafely(leaveDetail.date!);
                            if (parsedDate != null) {
                              return "${Utils.formatDate(parsedDate)}, ${Utils.weekDays[parsedDate.weekday - 1].tr}";
                            }
                            return leaveDetail.date ?? "";
                          }()),
                        ))
                    .toList() ??
                [],
            const SizedBox(
              height: 25.0,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
              child: LayoutBuilder(builder: (context, boxConstraints) {
                return Row(
                  children: [
                    hasAttachments
                        ? SizedBox(
                            width: boxConstraints.maxWidth * 0.475,
                            child: CustomRoundedButton(
                                widthPercentage: 1.0,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                buttonTitle: attachmentsKey,
                                titleColor:
                                    Theme.of(context).colorScheme.secondary,
                                borderColor:
                                    Theme.of(context).colorScheme.secondary,
                                showBorder: true,
                                onTap: () {
                                  Utils.showBottomSheet(
                                      child: LeaveAttachmentsBottomsheet(
                                          files: leaveRequest.attachments!),
                                      context: context);
                                }),
                          )
                        : const SizedBox(),
                    hasAttachments ? const Spacer() : const SizedBox(),
                    BlocConsumer<ApproveOrRejectLeaveRequestCubit,
                        ApproveOrRejectLeaveRequestState>(
                      listener: (context, state) {
                        if (state is ApproveOrRejectLeaveRequestSuccess) {
                          Get.back(result: true);
                        } else if (state
                            is ApproveOrRejectLeaveRequestFailure) {
                          Utils.showSnackBar(
                              message: state.errorMessage, context: context);
                        }
                      },
                      builder: (context, state) {
                        return PopScope(
                          canPop:
                              state is! ApproveOrRejectLeaveRequestInProgress,
                          child: SizedBox(
                            width: boxConstraints.maxWidth *
                                (hasAttachments ? 0.475 : 1.0),
                            child: CustomRoundedButton(
                              widthPercentage: 1.0,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              buttonTitle:
                                  approveLeave ? approveKey : rejectKey,
                              showBorder: false,
                              child:
                                  state is ApproveOrRejectLeaveRequestInProgress
                                      ? const CustomCircularProgressIndicator()
                                      : null,
                              onTap: () {
                                if (state
                                    is ApproveOrRejectLeaveRequestInProgress) {
                                  return;
                                }
                                context
                                    .read<ApproveOrRejectLeaveRequestCubit>()
                                    .approveOrRejectLeaveRequest(
                                        leaveRequestId: leaveRequest.id ?? 0,
                                        approveLeave: approveLeave);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
            )
          ],
        ));
  }
}

class LeaveAttachmentsBottomsheet extends StatelessWidget {
  final List<StudyMaterial> files;
  const LeaveAttachmentsBottomsheet({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
        titleLabelKey: viewAttachmentsKey,
        child: Column(
          children: files
              .map((file) => Padding(
                    padding: EdgeInsets.all(appContentHorizontalPadding),
                    child: StudyMaterialContainer(
                        studyMaterial: file, showEditAndDeleteButton: false),
                  ))
              .toList(),
        ));
  }
}
