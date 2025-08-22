import 'package:eschool_saas_staff/data/models/staffSalary.dart';
import 'package:eschool_saas_staff/ui/widgets/allowancesAndDeductionsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

class AllowanceAndDeductionsBottomsheet extends StatelessWidget {
  final List<StaffSalary> allowances;
  final List<StaffSalary> deductions;
  const AllowanceAndDeductionsBottomsheet(
      {super.key, required this.allowances, required this.deductions});

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
        titleLabelKey: allowancesAndDeductionsKey,
        child: AllowancesAndDeductionsContainer(
            allowances: allowances, deductions: deductions));
  }
}
