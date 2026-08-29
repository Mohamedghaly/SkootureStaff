import 'package:eschool_saas_staff/data/models/taskStatus.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Renders action buttons based on the task status.
///
/// - Pending → "Start Task" + "Edit Task" + "Delete Task"
/// - InProgress → "Mark as Complete" + "Edit Task" + "Delete Task"
/// - Overdue → "Mark as Complete" + "Edit Task" + "Delete Task"
/// - Completed → "Edit Task" + "Delete Task"
/// - Rejected → No buttons
class TaskActionButtons extends StatelessWidget {
  final TaskStatus status;
  final VoidCallback? onStartTask;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onEditTask;
  final VoidCallback? onDeleteTask;

  const TaskActionButtons({
    super.key,
    required this.status,
    this.onStartTask,
    this.onMarkComplete,
    this.onEditTask,
    this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      TaskStatus.pending => _PendingButtons(
          onStartTask: onStartTask,
          onEditTask: onEditTask,
          onDeleteTask: onDeleteTask,
        ),
      TaskStatus.inProgress => _InProgressButtons(
          onMarkComplete: onMarkComplete,
          onEditTask: onEditTask,
          onDeleteTask: onDeleteTask,
        ),
      TaskStatus.overdue => _InProgressButtons(
          onMarkComplete: onMarkComplete,
          onEditTask: onEditTask,
          onDeleteTask: onDeleteTask,
        ),
      TaskStatus.completed => _EditDeleteRow(
          onEditTask: onEditTask,
          onDeleteTask: onDeleteTask,
        ),
      TaskStatus.rejected => const SizedBox.shrink(),
    };
  }
}

/// Pending: "Start Task" + "Edit" + "Delete" row.
class _PendingButtons extends StatelessWidget {
  final VoidCallback? onStartTask;
  final VoidCallback? onEditTask;
  final VoidCallback? onDeleteTask;

  const _PendingButtons({
    this.onStartTask,
    this.onEditTask,
    this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FilledButton(
          labelKey: startTaskKey,
          onTap: onStartTask,
        ),
        const SizedBox(height: 12),
        _EditDeleteRow(
          onEditTask: onEditTask,
          onDeleteTask: onDeleteTask,
        ),
      ],
    );
  }
}

/// In Progress / Overdue: "Mark as Complete" + "Edit" + "Delete".
class _InProgressButtons extends StatelessWidget {
  final VoidCallback? onMarkComplete;
  final VoidCallback? onEditTask;
  final VoidCallback? onDeleteTask;

  const _InProgressButtons({
    this.onMarkComplete,
    this.onEditTask,
    this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FilledButton(
          labelKey: markAsCompleteKey,
          onTap: onMarkComplete,
        ),
        const SizedBox(height: 12),
        _EditDeleteRow(
          onEditTask: onEditTask,
          onDeleteTask: onDeleteTask,
        ),
      ],
    );
  }
}

/// Shared Edit + Delete button row used by both
/// [_PendingButtons] and [_InProgressButtons].
///
/// Hides individual buttons when their callback is null
/// (e.g., permission denied). Hides the entire row if
/// both callbacks are null.
class _EditDeleteRow extends StatelessWidget {
  final VoidCallback? onEditTask;
  final VoidCallback? onDeleteTask;

  const _EditDeleteRow({
    this.onEditTask,
    this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    // Hide the row entirely if no actions are available.
    if (onEditTask == null && onDeleteTask == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (onEditTask != null)
          Expanded(
            child: _OutlineButton(
              labelKey: editTaskKey,
              onTap: onEditTask,
              borderColor: const Color(0xFF1A1C1D),
              textColor: const Color(0xFF201A1A),
            ),
          ),
        if (onEditTask != null && onDeleteTask != null)
          const SizedBox(width: 12),
        if (onDeleteTask != null)
          Expanded(
            child: _OutlineButton(
              labelKey: deleteTaskKey,
              onTap: onDeleteTask,
              borderColor: const Color(0xFFBA1A1A),
              textColor: const Color(0xFFBA1A1A),
            ),
          ),
      ],
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String labelKey;
  final VoidCallback? onTap;

  const _FilledButton({
    required this.labelKey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
          ),
          elevation: 0,
        ),
        child: Text(Utils.getTranslatedLabel(labelKey)),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String labelKey;
  final VoidCallback? onTap;
  final Color borderColor;
  final Color textColor;

  const _OutlineButton({
    required this.labelKey,
    this.onTap,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
          ),
        ),
        child: Text(Utils.getTranslatedLabel(labelKey)),
      ),
    );
  }
}
