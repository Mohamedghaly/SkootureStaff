import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class WeekdaysContainer extends StatelessWidget {
  final String selectedDayKey;
  final Function(String newSelection) onSelectionChange;
  const WeekdaysContainer(
      {super.key,
      required this.selectedDayKey,
      required this.onSelectionChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
            bottom: BorderSide(color: Theme.of(context).colorScheme.tertiary)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: Utils.weekDays.map((dayKey) {
            final isSelected = dayKey == selectedDayKey;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 12.5),
              child: GestureDetector(
                onTap: () {
                  if (isSelected) {
                    return;
                  }
                  onSelectionChange(dayKey);
                },
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  child: CustomTextContainer(
                    textKey: dayKey,
                    style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
