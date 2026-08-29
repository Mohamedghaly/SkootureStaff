import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Who the task is assigned to.
enum TaskAssignee {
  myself,
  staff;

  /// Value sent to the create/update task API.
  String get apiValue {
    switch (this) {
      case TaskAssignee.myself:
        return 'myself';
      case TaskAssignee.staff:
        return 'staff';
    }
  }
}

/// Radio-style toggle: "Myself" | "Staff".

class TaskAssigneeToggle extends StatelessWidget {
  final TaskAssignee selectedAssignee;
  final ValueChanged<TaskAssignee> onAssigneeChanged;

  const TaskAssigneeToggle({
    super.key,
    required this.selectedAssignee,
    required this.onAssigneeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RadioOption(
            labelKey: myselfKey,
            isSelected: selectedAssignee == TaskAssignee.myself,
            onTap: () => onAssigneeChanged(TaskAssignee.myself),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _RadioOption(
            labelKey: staffKey,
            isSelected: selectedAssignee == TaskAssignee.staff,
            onTap: () => onAssigneeChanged(TaskAssignee.staff),
          ),
        ),
      ],
    );
  }
}

/// Single radio option tile.
class _RadioOption extends StatelessWidget {
  final String labelKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.labelKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE0EDF6)
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                Utils.getTranslatedLabel(labelKey),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 24 / 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _CustomRadioIndicator(
                isSelected: isSelected,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom radio circle indicator.
class _CustomRadioIndicator extends StatelessWidget {
  final bool isSelected;
  final Color activeColor;

  const _CustomRadioIndicator({
    required this.isSelected,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? activeColor : const Color(0xFF6D6E6F),
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                ),
              ),
            )
          : null,
    );
  }
}
