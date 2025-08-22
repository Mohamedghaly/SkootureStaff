import 'dart:math';

import 'package:eschool_saas_staff/cubits/fee/downloadStudentFeeReceiptCubit.dart';
import 'package:eschool_saas_staff/cubits/fee/sessionYearAndFeesCubit.dart';
import 'package:eschool_saas_staff/cubits/fee/studentsFeeStatusCubit.dart';
import 'package:eschool_saas_staff/data/models/fee.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
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
import 'package:get/route_manager.dart';
import 'package:open_filex/open_filex.dart';

class PaidFeesScreen extends StatefulWidget {
  const PaidFeesScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SessionYearAndFeesCubit(),
        ),
        BlocProvider(
          create: (context) => StudentsFeeStatusCubit(),
        ),
      ],
      child: const PaidFeesScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<PaidFeesScreen> createState() => _PaidFeesScreenState();
}

class _PaidFeesScreenState extends State<PaidFeesScreen> {
  String _selectedFeeStatus = "";
  Fee? _selectedFee;
  SessionYear? _selectedSessionYear;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<SessionYearAndFeesCubit>().getSessionYearsAndFees();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<StudentsFeeStatusCubit>().hasMore()) {
        getMoreStudentFees();
      }
    }
  }

  void getStudentFees() {
    context.read<StudentsFeeStatusCubit>().getStudentFeePaymentStatus(
        sessionYearId: _selectedSessionYear?.id ?? 0,
        status: _selectedFeeStatus == paidKey ? 1 : 0,
        feeId: _selectedFee?.id ?? 0);
  }

  void getMoreStudentFees() {
    context.read<StudentsFeeStatusCubit>().fetchMore(
        sessionYearId: _selectedSessionYear?.id ?? 0,
        status: _selectedFeeStatus == paidKey ? 1 : 0,
        feeId: _selectedFee?.id ?? 0);
  }

  void changeSelectedSessionYear(SessionYear value) {
    setState(() {
      _selectedSessionYear = value;
    });
  }

  void changeSelectedFeeStatus(String value) {
    setState(() {
      _selectedFeeStatus = value;
    });
  }

  void changeSelectedFee(Fee value) {
    setState(() {
      _selectedFee = value;
    });
  }

  Widget _buildStudents() {
    return BlocBuilder<StudentsFeeStatusCubit, StudentsFeeStatusState>(
      builder: (context, state) {
        if (state is StudentsFeeStatusFetchSuccess) {
          if (state.students.isEmpty) {
            return const SizedBox();
          }
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                  bottom: 50,
                  top:
                      Utils.appContentTopScrollPadding(context: context) + 160),
              child: Container(
                padding: EdgeInsets.all(appContentHorizontalPadding),
                color: Theme.of(context).colorScheme.surface,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: appContentHorizontalPadding),
                      height: 40,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).colorScheme.tertiary),
                      child: LayoutBuilder(builder: (context, boxConstraints) {
                        return Row(
                          children: [
                            SizedBox(
                              width: boxConstraints.maxWidth * (0.2),
                              child: const CustomTextContainer(textKey: "#"),
                            ),
                            SizedBox(
                              width: boxConstraints.maxWidth * (0.8),
                              child:
                                  const CustomTextContainer(textKey: nameKey),
                            ),
                          ],
                        );
                      }),
                    ),
                    Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              left: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.tertiary)),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5)),
                          color: Theme.of(context).colorScheme.surface),
                      child: Column(
                        children: List.generate(state.students.length, (index) {
                          if (context
                              .read<StudentsFeeStatusCubit>()
                              .hasMore()) {
                            if (index == (state.students.length - 1)) {
                              if (state.fetchMoreError) {
                                return Center(
                                  child: CustomTextButton(
                                      buttonTextKey: retryKey,
                                      onTapButton: () {
                                        getMoreStudentFees();
                                      }),
                                );
                              }
                              return Center(
                                child: CustomCircularProgressIndicator(
                                  indicatorColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }
                          }

                          return StudentPaidFeeDetailsContainer(
                            index: index,
                            compolsoryFeeAmount: state.compolsoryFeeAmount,
                            optionalFeeAmount: state.optionalFeeAmount,
                            studentDetails: state.students[index],
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        if (state is StudentsFeeStatusFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                getStudentFees();
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        BlocBuilder<SessionYearAndFeesCubit, SessionYearAndFeesState>(
          builder: (context, state) {
            if (state is SessionYearAndFeesFetchSuccess) {
              if (state.fees.isEmpty) {
                return const noDataContainer(titleKey: noFeesKey);
              }
              if (state.sessionYears.isEmpty) {
                return const noDataContainer(titleKey: noSessionYearsKey);
              }

              return _buildStudents();
            }
            if (state is SessionYearAndFeesFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context
                        .read<SessionYearAndFeesCubit>()
                        .getSessionYearsAndFees();
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
        Align(
          alignment: Alignment.topCenter,
          child: BlocConsumer<SessionYearAndFeesCubit, SessionYearAndFeesState>(
            listener: (context, state) {
              if (state is SessionYearAndFeesFetchSuccess) {
                if (state.fees.isNotEmpty && state.sessionYears.isNotEmpty) {
                  changeSelectedFee(state.fees.first);
                  changeSelectedSessionYear(state.sessionYears
                      .where((element) => element.isThisDefault())
                      .toList()
                      .first);
                  changeSelectedFeeStatus(paidKey);
                  getStudentFees();
                }
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  const CustomAppbar(titleKey: paidFeesKey),
                  AppbarFilterBackgroundContainer(
                      child: LayoutBuilder(builder: (context, boxConstraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilterButton(
                            onTap: () {
                              if (state is SessionYearAndFeesFetchSuccess &&
                                  state.sessionYears.isNotEmpty) {
                                Utils.showBottomSheet(
                                    child:
                                        FilterSelectionBottomsheet<SessionYear>(
                                            onSelection: (value) {
                                              changeSelectedSessionYear(value!);
                                              getStudentFees();
                                              Get.back();
                                            },
                                            selectedValue: _selectedSessionYear,
                                            titleKey: sessionYearKey,
                                            values: state.sessionYears),
                                    context: context);
                              }
                            },
                            titleKey: _selectedSessionYear?.name ?? yearKey,
                            width: boxConstraints.maxWidth * (0.49)),
                        FilterButton(
                            onTap: () {
                              if (state is SessionYearAndFeesFetchSuccess) {
                                Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet<String>(
                                        onSelection: (value) {
                                          changeSelectedFeeStatus(value!);
                                          getStudentFees();
                                          Get.back();
                                        },
                                        selectedValue: _selectedFeeStatus,
                                        titleKey: statusKey,
                                        values: const [paidKey, unpaidKey]),
                                    context: context);
                              }
                            },
                            titleKey: _selectedFeeStatus.isEmpty
                                ? statusKey
                                : _selectedFeeStatus,
                            width: boxConstraints.maxWidth * (0.49)),
                      ],
                    );
                  })),
                  AppbarFilterBackgroundContainer(
                      child: LayoutBuilder(builder: (context, boxConstraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilterButton(
                            onTap: () {
                              if (state is SessionYearAndFeesFetchSuccess &&
                                  state.fees.isNotEmpty) {
                                Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet<Fee>(
                                        onSelection: (value) {
                                          changeSelectedFee(value!);
                                          getStudentFees();
                                          Get.back();
                                        },
                                        selectedValue: _selectedFee!,
                                        titleKey: feeKey,
                                        values: state.fees),
                                    context: context);
                              }
                            },
                            titleKey: _selectedFee?.name ?? feeKey,
                            width: boxConstraints.maxWidth),
                      ],
                    );
                  })),
                ],
              );
            },
          ),
        )
      ],
    ));
  }
}

class StudentPaidFeeDetailsContainer extends StatefulWidget {
  final int index;
  final StudentDetails studentDetails;
  final double compolsoryFeeAmount;
  final double optionalFeeAmount;
  const StudentPaidFeeDetailsContainer(
      {super.key,
      required this.index,
      required this.studentDetails,
      required this.compolsoryFeeAmount,
      required this.optionalFeeAmount});

  @override
  State<StudentPaidFeeDetailsContainer> createState() =>
      _StudentPaidFeeDetailsContainerState();
}

class _StudentPaidFeeDetailsContainerState
    extends State<StudentPaidFeeDetailsContainer>
    with TickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: tileCollapsedDuration);

  late final Animation<double> _heightAnimation =
      Tween<double>(begin: 65, end: 265).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.0, 0.5)));

  late final Animation<double> _opacityAnimation =
      Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.5, 1.0)));

  late final Animation<double> _iconAngleAnimation =
      Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut));

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  ///[To display days, start and to date for the applied leave]
  Widget _buildLeaveDaysAndDateContainer(
      {required String title, required String value}) {
    final titleStyle = TextStyle(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.76));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Row(
          children: [
            SizedBox(
              width: boxConstraints.maxWidth * (0.5),
              child: CustomTextContainer(
                textKey: title,
                style: titleStyle,
              ),
            ),
            CustomTextContainer(
              textKey: ":",
              style: titleStyle,
            ),
            const Spacer(),
            CustomTextContainer(
              textKey: value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              if (_animationController.isAnimating) {
                return;
              }

              if (_animationController.isCompleted) {
                _animationController.reverse();
              } else {
                _animationController.forward();
              }
            },
            child: Container(
              height: _heightAnimation.value,
              padding: EdgeInsets.symmetric(
                  vertical: appContentHorizontalPadding,
                  horizontal: appContentHorizontalPadding),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary))),
              child: LayoutBuilder(builder: (context, boxConstraints) {
                return Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: boxConstraints.maxWidth * (0.2),
                          child: CustomTextContainer(
                              textKey: (widget.index + 1)
                                  .toString()
                                  .padLeft(2, '0')),
                        ),
                        SizedBox(
                          width: boxConstraints.maxWidth * (0.8),
                          child: Row(
                            children: [
                              CustomTextContainer(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textKey:
                                      widget.studentDetails.fullName ?? "-"),
                              const Spacer(),
                              Transform.rotate(
                                angle: (pi * _iconAngleAnimation.value) / 180,
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    _animationController.value > 0.5
                        ? Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(top: 5.0),
                              padding: const EdgeInsets.all(15),
                              width: boxConstraints.maxWidth,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                              child: Opacity(
                                opacity: _opacityAnimation.value,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLeaveDaysAndDateContainer(
                                      title: dateKey,
                                      value: (widget
                                                      .studentDetails
                                                      .paidFeeDetails
                                                      ?.createdAt ??
                                                  "")
                                              .isEmpty
                                          ? "-"
                                          : Utils.extractDateFromDateString(
                                              widget.studentDetails
                                                  .paidFeeDetails!.createdAt!),
                                    ),
                                    _buildLeaveDaysAndDateContainer(
                                        title: classKey,
                                        value: widget.studentDetails.student
                                                ?.classSection?.fullName ??
                                            "-"),
                                    _buildLeaveDaysAndDateContainer(
                                        title: compulsoryFeeKey,
                                        value: widget.compolsoryFeeAmount
                                            .toStringAsFixed(2)),
                                    _buildLeaveDaysAndDateContainer(
                                        title: optionalFeeKey,
                                        value: widget.optionalFeeAmount
                                            .toStringAsFixed(2)),
                                    _buildLeaveDaysAndDateContainer(
                                        title: paidAmountKey,
                                        value: (widget.studentDetails
                                                    .paidFeeDetails?.amount ??
                                                0.0)
                                            .toStringAsFixed(2)),
                                    widget.studentDetails.paidFeeDetails
                                                ?.feesId !=
                                            null
                                        ? CustomTextButton(
                                            buttonTextKey:
                                                downloadFeeReceiptKey,
                                            textStyle: TextStyle(
                                                fontSize: 13.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                            onTapButton: () {
                                              Get.dialog(BlocProvider(
                                                create: (context) =>
                                                    DownloadStudentFeeReceiptCubit(),
                                                child:
                                                    DownloadStudentFeeReceiptDialog(
                                                        studentDetails: widget
                                                            .studentDetails),
                                              ));
                                            })
                                        : const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                );
              }),
            ),
          );
        });
  }
}

class DownloadStudentFeeReceiptDialog extends StatefulWidget {
  final StudentDetails studentDetails;
  const DownloadStudentFeeReceiptDialog(
      {super.key, required this.studentDetails});

  @override
  State<DownloadStudentFeeReceiptDialog> createState() =>
      _DownloadStudentFeeReceiptDialogState();
}

class _DownloadStudentFeeReceiptDialogState
    extends State<DownloadStudentFeeReceiptDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<DownloadStudentFeeReceiptCubit>()
            .downloadStudentFeeReceipt(
                feeId: widget.studentDetails.paidFeeDetails?.feesId ?? 0,
                studentId: widget.studentDetails.id ?? 0,
                studentName: widget.studentDetails.fullName ?? "-");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownloadStudentFeeReceiptCubit,
        DownloadStudentFeeReceiptState>(
      listener: (context, state) {
        if (state is DownloadStudentFeeReceiptSuccess) {
          Get.back();
          OpenFilex.open(state.downloadedFilePath);
        } else if (state is DownloadStudentFeeReceiptFailure) {
          Get.back();
          Utils.showSnackBar(message: state.errorMessage, context: context);
        }
      },
      child: AlertDialog(
        content: SizedBox(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomCircularProgressIndicator(
                widthAndHeight: 15.0,
                strokeWidth: 2.0,
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10.0),
              const Flexible(
                  child:
                      CustomTextContainer(textKey: downloadingFeeReceiptKey)),
            ],
          ),
        ),
      ),
    );
  }
}
