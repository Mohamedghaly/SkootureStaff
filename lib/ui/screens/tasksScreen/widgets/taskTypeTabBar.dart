import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Enum for task type tabs shown to school admin.
enum TaskType { myTask, staffTask }

class TaskTypeTabBar extends StatelessWidget {
  final TaskType selectedType;
  final ValueChanged<TaskType> onTypeSelected;

  const TaskTypeTabBar({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              labelKey: myTaskKey,
              isSelected: selectedType == TaskType.myTask,
              onTap: () => onTypeSelected(TaskType.myTask),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _TabButton(
              labelKey: staffTaskLabelKey,
              isSelected: selectedType == TaskType.staffTask,
              onTap: () => onTypeSelected(TaskType.staffTask),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual tab button.
class _TabButton extends StatelessWidget {
  final String labelKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.labelKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          border: isSelected
              ? null
              : Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          Utils.getTranslatedLabel(labelKey),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
