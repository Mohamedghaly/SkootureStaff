import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Tappable date field with a trailing calendar icon, matching the create /
/// edit form. Opens a date picker bounded by [firstDate] / [lastDate].
class OnlineClassDateField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String hintKey;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const OnlineClassDateField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.hintKey,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final first = firstDate ?? now;
    final initial = selectedDate ?? first;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: lastDate ?? now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final isPlaceholder = selectedDate == null;
    final text = isPlaceholder
        ? Utils.getTranslatedLabel(hintKey)
        : DateFormat('d-M-yyyy').format(selectedDate!);

    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        width: double.maxFinite,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isPlaceholder
                      ? secondary.withValues(alpha: 0.6)
                      : secondary,
                ),
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 20, color: secondary),
          ],
        ),
      ),
    );
  }
}
