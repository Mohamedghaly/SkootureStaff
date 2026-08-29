import 'package:eschool_saas_staff/data/models/onlineClass/onlineClass.dart';
import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassEnums.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassScheduleNote.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassSheetWidgets.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shows the "Online Class Summary" confirmation sheet before a class is
Future<bool?> showOnlineClassSummaryBottomSheet({
  required BuildContext context,
  required OnlineClass draft,
  String confirmLabelKey = createClassKey,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OnlineClassSummarySheet(
      draft: draft,
      confirmLabelKey: confirmLabelKey,
    ),
  );
}

class _OnlineClassSummarySheet extends StatelessWidget {
  final OnlineClass draft;
  final String confirmLabelKey;

  const _OnlineClassSummarySheet({
    required this.draft,
    required this.confirmLabelKey,
  });

  static final DateFormat _long = DateFormat('d MMMM yyyy');

  @override
  Widget build(BuildContext context) {
    final note = OnlineClassScheduleNote.build(
      repeatType: draft.repeat,
      date: draft.startDate ?? DateTime.now(),
      endDate: draft.endDate,
      startTime: draft.startTime,
      endTime: draft.endTime,
      subjectName: draft.subject,
      periodDay: draft.day,
      long: true,
    );

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnlineClassSheetHeader(
                titleKey: onlineClassSummaryKey,
                onClose: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(height: 16),
              OnlineClassDetailRow(
                labelKey: subjectKey,
                value: draft.title,
              ),
              const SizedBox(height: 16),
              OnlineClassDetailRow(
                labelKey: timeKey,
                value: draft.timeRange,
              ),
              // "No Repeat" carries no dates — the class runs on the period's
              // own timetable slot.
              if (draft.repeat != OnlineClassRepeatType.noRepeat &&
                  draft.startDate != null) ...[
                const SizedBox(height: 16),
                OnlineClassDetailRow(
                  labelKey: startDateKey,
                  value: _long.format(draft.startDate!),
                ),
              ],
              const SizedBox(height: 16),
              OnlineClassDetailRow(
                labelKey: repeatKey,
                value: Utils.getTranslatedLabel(draft.repeat.labelKey),
              ),
              if (draft.repeat.requiresEndDate && draft.endDate != null) ...[
                const SizedBox(height: 16),
                OnlineClassDetailRow(
                  labelKey: endDateKey,
                  value: _long.format(draft.endDate!),
                ),
              ],
              if (draft.note.isNotEmpty) ...[
                const SizedBox(height: 16),
                OnlineClassDetailRow(
                  labelKey: descriptionKey,
                  value: draft.note,
                ),
              ],
              const SizedBox(height: 16),
              OnlineClassSheetLinkRow(link: draft.meetingLink),
              const SizedBox(height: 16),
              OnlineClassInfoBox(text: note),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SummaryButton(
                      labelKey: cancelKey,
                      filled: false,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryButton(
                      labelKey: confirmLabelKey,
                      filled: true,
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryButton extends StatelessWidget {
  final String labelKey;
  final bool filled;
  final VoidCallback onTap;

  const _SummaryButton({
    required this.labelKey,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: filled
              ? null
              : Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Text(
          Utils.getTranslatedLabel(labelKey),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            color:
                filled ? Colors.white : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
