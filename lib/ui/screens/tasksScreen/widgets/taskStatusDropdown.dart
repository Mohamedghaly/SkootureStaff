import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Status options available when re-opening a completed task.
enum EditableTaskStatus {
  pending,
  inProgress;

  /// API value to send in the `status` parameter.
  String get apiValue {
    switch (this) {
      case EditableTaskStatus.pending:
        return 'pending';
      case EditableTaskStatus.inProgress:
        return 'in_progress';
    }
  }

  /// User-facing label key.
  String get labelKey {
    switch (this) {
      case EditableTaskStatus.pending:
        return pendingKey;
      case EditableTaskStatus.inProgress:
        return inProgressKey;
    }
  }
}

/// Dropdown for selecting a new status when editing a completed task.
///
/// Only shown when the task being edited has `completed` status.
/// Provides two options: Pending and In Progress.
///
/// Styled to match other form fields (same border, radius,
/// padding, and background as [TaskDateField]).
class TaskStatusDropdown extends StatelessWidget {
  final EditableTaskStatus? selectedStatus;
  final ValueChanged<EditableTaskStatus?> onStatusChanged;

  const TaskStatusDropdown({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EditableTaskStatus>(
          value: selectedStatus,
          isExpanded: true,
          hint: Text(
            Utils.getTranslatedLabel(changeStatusKey),
            style: TextStyle(
              fontSize: 15,
              color: secondaryColor.withValues(alpha: 0.76),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: secondaryColor.withValues(alpha: 0.76),
          ),
          borderRadius: BorderRadius.circular(5),
          padding: EdgeInsets.zero,
          items: EditableTaskStatus.values.map((status) {
            return DropdownMenuItem<EditableTaskStatus>(
              value: status,
              child: Text(
                Utils.getTranslatedLabel(status.labelKey),
                style: TextStyle(
                  fontSize: 15,
                  color: secondaryColor,
                ),
              ),
            );
          }).toList(),
          onChanged: onStatusChanged,
        ),
      ),
    );
  }
}
