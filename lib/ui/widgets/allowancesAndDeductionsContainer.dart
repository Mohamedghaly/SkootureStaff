import 'package:eschool_saas_staff/data/models/staffSalary.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class AllowancesAndDeductionsContainer extends StatelessWidget {
  final List<StaffSalary> allowances;
  final List<StaffSalary> deductions;

  const AllowancesAndDeductionsContainer(
      {super.key, required this.allowances, required this.deductions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allowances.isEmpty && deductions.isEmpty
          ? [
              Padding(
                padding: EdgeInsets.all(appContentHorizontalPadding),
                child: noDataContainer(
                  titleKey: noAllowancesAndDeductionsKey,
                ),
              ),
            ]
          : [
              if (allowances.isNotEmpty)
                Column(
                  children: [
                    SizedBox(height: appContentHorizontalPadding),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: appContentHorizontalPadding * 2),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                              text: Utils.getTranslatedLabel(allowancesKey),
                              style: const TextStyle(fontSize: 16.0)),
                          TextSpan(
                              text: "(${Utils.getTranslatedLabel(currentKey)})",
                              style: const TextStyle(fontSize: 12.0)),
                        ])),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...allowances.map((staffSalary) => Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: appContentHorizontalPadding),
                          child: ListTile(
                            tileColor: Theme.of(context).colorScheme.surface,
                            title: CustomTextContainer(
                              textKey: staffSalary.payRollSetting?.name ?? "",
                              style: const TextStyle(fontSize: 15),
                            ),
                            subtitle: CustomTextContainer(
                              textKey: staffSalary
                                      .allowanceOrDeductionInPercentage()
                                  ? '${staffSalary.percentage?.toStringAsFixed(2) ?? "0"}%'
                                  : '${staffSalary.amount?.toStringAsFixed(2) ?? "0"}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )),
                    const SizedBox(height: 20),
                  ],
                ),
              if (deductions.isNotEmpty)
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: appContentHorizontalPadding * 2,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                              text: Utils.getTranslatedLabel(deductionsKey),
                              style: const TextStyle(fontSize: 16.0)),
                          TextSpan(
                              text: "(${Utils.getTranslatedLabel(currentKey)})",
                              style: const TextStyle(fontSize: 12.0)),
                        ])),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...deductions.map((staffSalary) => Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: appContentHorizontalPadding),
                          child: ListTile(
                            tileColor: Theme.of(context).colorScheme.surface,
                            title: CustomTextContainer(
                              textKey: staffSalary.payRollSetting?.name ?? "",
                              style: const TextStyle(fontSize: 15),
                            ),
                            subtitle: CustomTextContainer(
                              textKey: staffSalary
                                      .allowanceOrDeductionInPercentage()
                                  ? "${staffSalary.percentage?.toStringAsFixed(2) ?? "0"}%"
                                  : staffSalary.amount?.toStringAsFixed(2) ??
                                      "0",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )),
                  ],
                ),
            ],
    );
  }
}
