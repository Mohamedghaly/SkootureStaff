import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Tappable date field that shows a date picker.

class TaskDateField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const TaskDateField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedDate != null
        ? DateFormat('dd MMM yyyy').format(selectedDate!)
        : Utils.getTranslatedLabel(dueDateKey);

    final isPlaceholder = selectedDate == null;

    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: isPlaceholder
                ? Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.76)
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
