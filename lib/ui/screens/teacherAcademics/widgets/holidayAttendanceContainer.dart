import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

class HolidayAttendanceContainer extends StatelessWidget {
  final Holiday holiday;
  const HolidayAttendanceContainer({super.key, required this.holiday});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: double.maxFinite,
      padding: EdgeInsets.all(appContentHorizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomTextContainer(
            textKey: holidayKey,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          CustomTextContainer(
            textKey: holiday.title ?? "",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          CustomTextContainer(
            textKey: holiday.description ?? "",
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          CustomTextContainer(
            textKey: attendanceViewEditNotPossibleKey,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.redColor!,
            ),
          ),
        ],
      ),
    );
  }
}
