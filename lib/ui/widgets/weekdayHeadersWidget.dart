import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class WeekdayHeadersWidget extends StatelessWidget {
  const WeekdayHeadersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const weekdays = [
      sundayKey,
      mondayKey,
      tuesdayKey,
      wednesdayKey,
      thursdayKey,
      fridayKey,
      saturdayKey
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: weekdays
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      Utils.getTranslatedLabel(day).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
