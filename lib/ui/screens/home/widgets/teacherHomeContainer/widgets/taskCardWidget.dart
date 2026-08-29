import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/data/models/taskStatus.dart';
import 'package:eschool_saas_staff/ui/widgets/circularStaffAvatar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCardWidget extends StatelessWidget {
  final StaffTask task;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  /// When true, shows the assignment info row (avatar + assignee
  /// name + "Assigned By Admin" badge). Used on admin's Staff Task tab.
  final bool showAssignmentInfo;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.onTap,
    this.backgroundColor,
    this.showAssignmentInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = backgroundColor ?? Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusAndDateRow(task: task),
            const _TaskDivider(),
            const SizedBox(height: 12),
            _TaskContent(task: task),
            if (showAssignmentInfo && task.assigneeName != null)
              _AssignmentFooter(task: task),
            if (task.overdueDays != null && task.overdueDays! > 0)
              _OverdueFooter(overdueDays: task.overdueDays!)
            else if (task.status == TaskStatus.completed &&
                task.completedDate != null &&
                task.completedDate!.isNotEmpty)
              _CompletedFooter(
                completedDate: task.completedDate!,
                cardBackgroundColor: cardBg,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusAndDateRow extends StatelessWidget {
  final StaffTask task;

  const _StatusAndDateRow({required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatusBadge(status: task.status),
        _DateBadge(dueDate: task.dueDate),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomTextContainer(
        textKey: status.labelKey,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: status.textColor,
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime? dueDate;

  const _DateBadge({required this.dueDate});

  String _formatDate() {
    if (dueDate == null) return '-';
    return DateFormat('dd MMM').format(dueDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _formatDate(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _TaskDivider extends StatelessWidget {
  const _TaskDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}

class _TaskContent extends StatelessWidget {
  final StaffTask task;

  const _TaskContent({required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextContainer(
          textKey: task.title ?? '',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        CustomTextContainer(
          textKey: task.description ?? '',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
            color: _labelColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Assignment info footer for admin "Staff Task" tab.

class _AssignmentFooter extends StatelessWidget {
  final StaffTask task;

  const _AssignmentFooter({required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          // Left: avatar + assign info
          Expanded(
            child: Row(
              children: [
                // Avatar
                CircularStaffAvatar(imageUrl: task.assigneeImage),
                const SizedBox(width: 8),
                // "Assign To" + name
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Utils.getTranslatedLabel(assignToKey),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 16 / 12,
                          color: _labelColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.assigneeName ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 16 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right: "Assigned By Admin" badge
          if (task.isAssignedByAdmin)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Color(0xFF56B35A),
                ),
                const SizedBox(width: 4),
                Text(
                  Utils.getTranslatedLabel(assignedByAdminKey),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Footer for completed tasks showing completion time.
/// Uses contrasting bg color based on card background.
class _CompletedFooter extends StatelessWidget {
  final String completedDate;
  final Color cardBackgroundColor;

  const _CompletedFooter({
    required this.completedDate,
    required this.cardBackgroundColor,
  });

  String _formatCompletedText() {
    return Utils.getTranslatedLabel(youCompleteTaskOnKey)
        .replaceAll('@date', completedDate)
        .replaceAll(', @time', '')
        .replaceAll('@time', '')
        .trim();
  }

  Color _getFooterColor(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final surfaceBg = Theme.of(context).colorScheme.surface;
    if (cardBackgroundColor == scaffoldBg) return surfaceBg;
    return scaffoldBg;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getFooterColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatCompletedText(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 16 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer for overdue tasks showing overdue days.
class _OverdueFooter extends StatelessWidget {
  final int overdueDays;

  const _OverdueFooter({required this.overdueDays});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFEEED7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              Utils.getTranslatedLabel(taskOverdueByDaysKey).replaceAll(
                '@days',
                overdueDays.toString(),
              ),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 16 / 12,
                color: Color(0xFFF89E1B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const Color _labelColor = Color(0xFF6D6E6F);
