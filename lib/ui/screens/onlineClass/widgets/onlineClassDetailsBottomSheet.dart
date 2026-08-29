import 'package:eschool_saas_staff/data/models/onlineClass/onlineClass.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassScheduleNote.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassSheetWidgets.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Result of interacting with the class details sheet.
enum OnlineClassDetailsAction { edit, delete }

Future<OnlineClassDetailsAction?> showOnlineClassDetailsBottomSheet({
  required BuildContext context,
  required OnlineClass onlineClass,
  bool canEdit = true,
  bool canDelete = true,
}) {
  return showModalBottomSheet<OnlineClassDetailsAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OnlineClassDetailsSheet(
      onlineClass: onlineClass,
      canEdit: canEdit,
      canDelete: canDelete,
    ),
  );
}

class _OnlineClassDetailsSheet extends StatelessWidget {
  final OnlineClass onlineClass;
  final bool canEdit;
  final bool canDelete;

  const _OnlineClassDetailsSheet({
    required this.onlineClass,
    required this.canEdit,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final note = OnlineClassScheduleNote.build(
      repeatType: onlineClass.repeat,
      date: onlineClass.startDate ?? DateTime.now(),
      endDate: onlineClass.endDate,
      startTime: onlineClass.startTime,
      endTime: onlineClass.endTime,
      subjectName: onlineClass.subject,
      periodDay: onlineClass.day,
    );

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                titleKey: classDetailsKey,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              OnlineClassDetailRow(
                labelKey: subjectKey,
                value: onlineClass.title,
                trailing: OnlineClassRepeatPill(
                  labelKey: onlineClass.repeat.labelKey,
                ),
              ),
              if (onlineClass.note.isNotEmpty) ...[
                const SizedBox(height: 16),
                OnlineClassDetailRow(
                  labelKey: descriptionKey,
                  value: onlineClass.note,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  // "No Repeat" rows may carry no date (scheduled on the
                  // period's slot) — show only the time in that case.
                  if (onlineClass.startDate != null) ...[
                    Icon(Icons.calendar_today_outlined,
                        size: 16, color: secondary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('d-M-yyyy').format(onlineClass.startDate!),
                      style: TextStyle(
                          fontSize: 12, height: 16 / 12, color: secondary),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(Icons.access_time, size: 16, color: secondary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      onlineClass.timeRange,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, height: 16 / 12, color: secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OnlineClassSheetLinkRow(link: onlineClass.meetingLink),
              const SizedBox(height: 16),
              OnlineClassInfoBox(text: note),
              const SizedBox(height: 24),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (!canEdit && !canDelete) return const SizedBox.shrink();
    return Row(
      children: [
        if (canEdit)
          Expanded(
            child: _SheetButton(
              labelKey: editClassKey,
              filled: true,
              onTap: () =>
                  Navigator.of(context).pop(OnlineClassDetailsAction.edit),
            ),
          ),
        if (canEdit && canDelete) const SizedBox(width: 16),
        if (canDelete)
          Expanded(
            child: _SheetButton(
              labelKey: deleteClassKey,
              filled: false,
              danger: true,
              onTap: () => _confirmDelete(context),
            ),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(Utils.getTranslatedLabel(deleteOnlineClassKey)),
        content: Text(Utils.getTranslatedLabel(deleteOnlineClassConfirmKey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(Utils.getTranslatedLabel(cancelKey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(OnlineClassDetailsAction.delete);
            },
            child: Text(
              Utils.getTranslatedLabel(deleteKey),
              style: const TextStyle(color: Color(0xFFBA1A1A)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filled (primary) or outlined (optionally danger) sheet button.
class _SheetButton extends StatelessWidget {
  final String labelKey;
  final bool filled;
  final bool danger;
  final VoidCallback onTap;

  const _SheetButton({
    required this.labelKey,
    required this.filled,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final dangerColor = const Color(0xFFBA1A1A);
    final accent = danger ? dangerColor : primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: filled ? null : Border.all(color: accent),
        ),
        child: Text(
          Utils.getTranslatedLabel(labelKey),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            color: filled ? Colors.white : accent,
          ),
        ),
      ),
    );
  }
}
