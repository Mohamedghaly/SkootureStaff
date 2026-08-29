import 'package:eschool_saas_staff/data/models/taskStatus.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskFilterChip.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

/// Horizontal scrollable filter bar with "All" + status chips.

class TaskFilterBar extends StatelessWidget {
  final TaskStatus? selectedFilter;
  final ValueChanged<TaskStatus?> onFilterSelected;

  const TaskFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            TaskFilterChip(
              labelKey: allKey,
              isSelected: selectedFilter == null,
              onTap: () => onFilterSelected(null),
            ),
            const SizedBox(width: 12),
            ...TaskStatus.values.where((s) => s != TaskStatus.rejected).map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TaskFilterChip(
                      labelKey: status.labelKey,
                      isSelected: selectedFilter == status,
                      onTap: () => onFilterSelected(status),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
