import 'dart:math';

import 'package:eschool_saas_staff/cubits/payRoll/downloadPayRollSlipCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/staffPayRoll.dart';
import 'package:eschool_saas_staff/ui/screens/managePayrolls/widgets/allowanceAndDeductionsBottomsheet.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/downloadPayRollSlipDialog.dart';
import 'package:eschool_saas_staff/ui/widgets/textWithFadedBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class StaffPayrollDetailsContainer extends StatefulWidget {
  final StaffPayRoll staffPayRoll;
  final bool isSelected;
  final Function onTapCheckBox;
  final double allowedMonthlyLeaves;

  const StaffPayrollDetailsContainer(
      {super.key,
      required this.staffPayRoll,
      required this.allowedMonthlyLeaves,
      required this.isSelected,
      required this.onTapCheckBox});

  @override
  State<StaffPayrollDetailsContainer> createState() =>
      StaffPayrollDetailsContainerState();
}

class StaffPayrollDetailsContainerState
    extends State<StaffPayrollDetailsContainer> with TickerProviderStateMixin {
  late final TextEditingController _netSalaryTextEditingController =
      TextEditingController();

  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: tileCollapsedDuration);

  //
  late final Animation<double> _heightAnimation =
      Tween<double>(begin: 170, end: 385).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.0, 0.5)));

  late final Animation<double> _opacityAnimation =
      Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.5, 1.0)));

  late final Animation<double> _iconAngleAnimation =
      Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();

    _netSalaryTextEditingController.text = widget.staffPayRoll
        .getNetSalaryAmount(allowedMonthlyLeaves: widget.allowedMonthlyLeaves)
        .toStringAsFixed(2);
  }

  @override
  void dispose() {
    _netSalaryTextEditingController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  double getNetSalary() {
    return double.parse(_netSalaryTextEditingController.text.trim());
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
              constraints: BoxConstraints(
                  minHeight: 170,
                  maxHeight: _animationController.isCompleted
                      ? 400
                      : _heightAnimation.value),
              padding: EdgeInsets.symmetric(
                  vertical: appContentHorizontalPadding,
                  horizontal: appContentHorizontalPadding),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary))),
              child: LayoutBuilder(builder: (context, boxConstraints) {
                final createPayRollPermissionGiven = context
                    .read<StaffAllowedPermissionsAndModulesCubit>()
                    .isPermissionGiven(permission: createPayRollPermissionKey);

                final editPayRollPermissionGiven = context
                    .read<StaffAllowedPermissionsAndModulesCubit>()
                    .isPermissionGiven(
                        permission: editPayrollEditPermissionKey);

                bool showCheckSelectionBox = false;

                if (widget.staffPayRoll.receivedPayroll()) {
                  if (editPayRollPermissionGiven) {
                    showCheckSelectionBox = true;
                  }
                } else {
                  if (createPayRollPermissionGiven) {
                    showCheckSelectionBox = true;
                  }
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          showCheckSelectionBox
                              ? GestureDetector(
                                  onTap: () {
                                    widget.onTapCheckBox.call();
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary)),
                                    child: widget.isSelected
                                        ? Icon(
                                            Icons.check,
                                            size: 15.0,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          )
                                        : const SizedBox(),
                                  ),
                                )
                              : const SizedBox(
                                  width: 20,
                                ),
                          const Spacer(),
                          SizedBox(
                            width: boxConstraints.maxWidth * (0.5),
                            child: CustomTextContainer(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textKey:
                                    widget.staffPayRoll.userDetails?.fullName ??
                                        "-"),
                          ),
                          SizedBox(
                            width: boxConstraints.maxWidth * (0.375),
                            child: Row(
                              children: [
                                TextWithFadedBackgroundContainer(
                                    backgroundColor: widget.staffPayRoll
                                            .receivedPayroll()
                                        ? Theme.of(context)
                                            .extension<CustomColors>()!
                                            .totalStaffOverviewBackgroundColor!
                                            .withValues(alpha: 0.1)
                                        : Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withValues(alpha: 0.1),
                                    textColor: widget.staffPayRoll
                                            .receivedPayroll()
                                        ? Theme.of(context)
                                            .extension<CustomColors>()!
                                            .totalStaffOverviewBackgroundColor!
                                        : Theme.of(context).colorScheme.error,
                                    titleKey:
                                        widget.staffPayRoll.receivedPayroll()
                                            ? paidKey
                                            : unpaidKey),
                                const Spacer(),
                                Transform.rotate(
                                  angle: (pi * _iconAngleAnimation.value) / 180,
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      Divider(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: boxConstraints.maxWidth * (0.48),
                                child: CustomTextContainer(
                                  textKey: basicSalaryKey,
                                  style: TextStyle(
                                      fontSize: 13.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.76)),
                                )),
                            SizedBox(
                                width: boxConstraints.maxWidth * (0.48),
                                child: CustomTextContainer(
                                  textKey: netSalaryKey,
                                  style: TextStyle(
                                      fontSize: 13.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.76)),
                                )),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: boxConstraints.maxWidth * (0.48),
                              child: CustomTextFieldContainer(
                                  enabled: false,
                                  height: 40,
                                  hintTextKey: widget.staffPayRoll.salary
                                          ?.toStringAsFixed(2) ??
                                      "-")),
                          SizedBox(
                              width: boxConstraints.maxWidth * (0.48),
                              child: CustomTextFieldContainer(
                                  textEditingController:
                                      _netSalaryTextEditingController,
                                  height: 40,
                                  hintTextKey: "000"))
                        ],
                      ),
                      _animationController.value > 0.5
                          ? Container(
                              margin: const EdgeInsets.only(top: 10.0),
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
                                        title: monthlyAllowedPaidLeavesKey,
                                        value: widget.allowedMonthlyLeaves
                                            .toStringAsFixed(2)),
                                    _buildLeaveDaysAndDateContainer(
                                        title: monthlyTakenLeavesKey,
                                        value: widget.staffPayRoll
                                            .totalTakenLeaves()
                                            .toStringAsFixed(2)),
                                    _buildLeaveDaysAndDateContainer(
                                        title: monthlyLeaveDeductionKey,
                                        value: widget.staffPayRoll
                                            .getPossibleSalaryDeductionAmount(
                                                allowedLeaves:
                                                    widget.allowedMonthlyLeaves)
                                            .toStringAsFixed(2)),
                                    CustomTextButton(
                                        buttonTextKey: widget.staffPayRoll
                                                .receivedPayroll()
                                            ? downloadSalarySlipKey
                                            : allowancesAndDeductionsKey,
                                        textStyle: TextStyle(
                                            fontSize: 13.0,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        onTapButton: () {
                                          if (widget.staffPayRoll
                                              .receivedPayroll()) {
                                            Get.dialog(BlocProvider(
                                              create: (context) =>
                                                  DownloadPayRollSlipCubit(),
                                              child: DownloadPayRollSlipDialog(
                                                  payRoll: widget.staffPayRoll
                                                      .payRolls!.first),
                                            ));
                                          } else {
                                            Utils.showBottomSheet(
                                                child:
                                                    AllowanceAndDeductionsBottomsheet(
                                                        allowances: widget
                                                            .staffPayRoll
                                                            .getAllowances(),
                                                        deductions: widget
                                                            .staffPayRoll
                                                            .getDeductions()),
                                                context: context);
                                          }
                                        })
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                );
              }),
            ),
          );
        });
  }
}
