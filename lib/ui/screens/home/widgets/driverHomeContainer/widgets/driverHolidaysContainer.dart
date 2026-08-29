import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/data/models/driverDashboardResponse.dart'
    as driver_models;
import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/ui/screens/holidaysScreen.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/holidayContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverHolidaysContainer extends StatelessWidget {
  final List<driver_models.Holiday> driverHolidays;

  const DriverHolidaysContainer({
    super.key,
    required this.driverHolidays,
  });

  @override
  Widget build(BuildContext context) {
    // Convert driver holidays to standard Holiday model
    List<Holiday> allHolidays =
        _convertDriverHolidaysToStandardHolidays(driverHolidays);

    // Show only 2 holidays as requested for display
    List<Holiday> displayHolidays =
        allHolidays.length > 2 ? allHolidays.sublist(0, 2) : allHolidays;

    return Column(
      children: [
        const SizedBox(height: 15),
        ContentTitleWithViewMoreButton(
          contentTitleKey: holidaysKey,
          showViewMoreButton: allHolidays.isNotEmpty,
          viewMoreOnTap: allHolidays.isNotEmpty
              ? () {
                  Get.toNamed(Routes.holidaysScreen,
                      arguments:
                          HolidaysScreen.buildArguments(holidays: allHolidays));
                }
              : null,
        ),
        const SizedBox(height: 15),
        if (allHolidays.isEmpty)
          Container(
            margin:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Holiday icon with emoji
                const Text(
                  "🎉",
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                CustomTextContainer(
                  textKey: noUpcomingHolidaysKey,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextContainer(
                  textKey: holidaysEmptyMessageKey,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 125,
            child: ListView.builder(
              itemCount: displayHolidays.length,
              scrollDirection: Axis.horizontal,
              padding:
                  EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
              itemBuilder: (context, index) {
                return HolidayContainer(
                    holiday: displayHolidays[index],
                    margin: const EdgeInsetsDirectional.only(end: 25),
                    width: MediaQuery.of(context).size.width * (0.85));
              },
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Converts driver dashboard holidays to standard Holiday model
  List<Holiday> _convertDriverHolidaysToStandardHolidays(
      List<driver_models.Holiday> driverHolidays) {
    return driverHolidays.map((driverHoliday) {
      return Holiday(
        id: driverHoliday.id,
        date: driverHoliday.date,
        title: driverHoliday.title,
        description: driverHoliday.description,
        schoolId: driverHoliday.schoolId,
        createdAt: driverHoliday.createdAt,
        updatedAt: driverHoliday.updatedAt,
        defaultDateFormat: driverHoliday.defaultDateFormat,
        dmyFormat: driverHoliday.dmyFormat,
      );
    }).toList();
  }
}
