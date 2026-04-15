import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class MonthSelectorWidget extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime? sessionStartDate;
  final DateTime? sessionEndDate;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final bool isPreviousMonthDisabled;
  final bool isNextMonthDisabled;

  const MonthSelectorWidget({
    Key? key,
    required this.selectedDate,
    this.sessionStartDate,
    this.sessionEndDate,
    this.onPreviousMonth,
    this.onNextMonth,
    required this.isPreviousMonthDisabled,
    required this.isNextMonthDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String monthName = months[selectedDate.month - 1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Month Button
          GestureDetector(
            onTap: isPreviousMonthDisabled ? null : onPreviousMonth,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPreviousMonthDisabled
                    ? Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ),

          // Month and Year Display
          CustomTextContainer(
            textKey: "$monthName ${selectedDate.year}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          // Next Month Button
          GestureDetector(
            onTap: isNextMonthDisabled ? null : onNextMonth,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isNextMonthDisabled
                    ? Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
