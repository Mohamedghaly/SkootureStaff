import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/data/models/taskStatus.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/circularStaffAvatar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Shared content section of the task details bottom sheet.
/// Displays: Status + Date, divider, task source, title,
/// description, created on, and optional completion footer.
class TaskDetailsContent extends StatelessWidget {
  final StaffTask task;

  /// Whether to show the assignee info row (avatar, name,
  /// phone/chat icons). True for "Staff Task" tab, false
  /// for "My Task" tab.
  final bool showAssignmentInfo;

  const TaskDetailsContent({
    super.key,
    required this.task,
    this.showAssignmentInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final showSourceBadge = _shouldShowSourceBadge(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusDateRow(task: task),
        const SizedBox(height: 16),
        const _ContentDivider(),
        if (showSourceBadge) ...[
          const SizedBox(height: 16),
          _TaskSourceBadge(
            task: task,
            showAssignmentInfo: showAssignmentInfo,
          ),
        ],
        const SizedBox(height: 16),
        _LabelValueSection(
          labelKey: taskTitleLabelKey,
          value: task.title ?? '',
        ),
        const SizedBox(height: 16),
        _LabelValueSection(
          labelKey: descriptionKey,
          value: task.description ?? '',
        ),
        if (_shouldShowCompletedFooter) ...[
          const SizedBox(height: 16),
          _TaskFooter(task: task),
        ],
        if (_shouldShowOverdueFooter) ...[
          const SizedBox(height: 16),
          _OverdueFooter(overdueDays: task.overdueDays!),
        ],
      ],
    );
  }

  /// Whether to show the task source badge section.\n  ///
  /// Hidden for staff/teacher when the task is self-assigned
  /// (`assigned_by == user_id`). School admin always sees it.
  bool _shouldShowSourceBadge(BuildContext context) {
    if (!task.isSelfAssigned) return true;
    final isSchoolAdmin =
        context.read<AuthCubit>().getUserDetails().isSchoolAdmin();
    return isSchoolAdmin;
  }

  bool get _hasOverdueCondition =>
      task.overdueDays != null && task.overdueDays! > 0;

  bool get _shouldShowCompletedFooter =>
      task.status == TaskStatus.completed &&
      task.completedDate != null &&
      task.completedDate!.isNotEmpty &&
      !_hasOverdueCondition;

  bool get _shouldShowOverdueFooter => _hasOverdueCondition;
}

/// Status badge + date badge in a row.
class _StatusDateRow extends StatelessWidget {
  final StaffTask task;

  const _StatusDateRow({required this.task});

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

  @override
  Widget build(BuildContext context) {
    final text = dueDate != null ? DateFormat('dd MMM').format(dueDate!) : '-';
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
        text,
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

/// Thin divider line.
class _ContentDivider extends StatelessWidget {
  const _ContentDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }
}

/// Green check icon + "Assigned By Admin" or "Admin Task".
/// When [showAssignmentInfo] is true (Staff Task tab),
/// also shows the assignee info row below.
class _TaskSourceBadge extends StatelessWidget {
  final StaffTask task;
  final bool showAssignmentInfo;

  const _TaskSourceBadge({
    required this.task,
    this.showAssignmentInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge row: check icon + label
        Row(
          children: [
            const Icon(
              Icons.check_circle,
              size: 20,
              color: Color(0xFF56B35A),
            ),
            const SizedBox(width: 4),
            Text(
              Utils.getTranslatedLabel(
                task.isAssignedByAdmin ? assignedByAdminKey : adminTaskKey,
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
              ),
            ),
          ],
        ),

        // Assignee info row — only on "Staff Task" tab
        if (showAssignmentInfo &&
            task.isAssignedByAdmin &&
            task.assigneeName != null)
          _AssigneeInfoRow(
            assigneeName: task.assigneeName!,
            assigneeMobile: task.assigneeMobile,
            assigneeId: task.assigneeId,
            assigneeImage: task.assigneeImage,
          ),
      ],
    );
  }
}

/// Assignee row: Avatar + "Assigned To" / name + phone & message icons.
/// Shown only when task is assigned by admin.
class _AssigneeInfoRow extends StatelessWidget {
  final String assigneeName;
  final String? assigneeMobile;
  final int? assigneeId;
  final String? assigneeImage;

  const _AssigneeInfoRow({
    required this.assigneeName,
    this.assigneeMobile,
    this.assigneeId,
    this.assigneeImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          // Avatar
          CircularStaffAvatar(imageUrl: assigneeImage, size: 40),
          const SizedBox(width: 8),

          // "Assigned To" + name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Utils.getTranslatedLabel(assignedToKey),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 16 / 12,
                    color: Color(0xFF6D6E6F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  assigneeName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),

          // Phone icon
          _ActionIcon(
            icon: Icons.phone,
            onTap: () => Utils.launchCallLog(mobile: assigneeMobile ?? ''),
          ),
          const SizedBox(width: 8),

          // Message icon — opens chat screen
          _ActionIcon(
            icon: Icons.message_outlined,
            onTap: () {
              if (assigneeId == null) return;
              Get.toNamed(
                Routes.chatScreen,
                arguments: ChatScreen.buildArguments(
                  receiverId: assigneeId!,
                  receiverName: assigneeName,
                  receiverImage: assigneeImage ?? '',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Small icon button for phone/message actions on assignee row.
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Label (small gray) + Value (medium black) section.
class _LabelValueSection extends StatelessWidget {
  final String labelKey;
  final String value;

  const _LabelValueSection({
    required this.labelKey,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextContainer(
          textKey: labelKey,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
            letterSpacing: 0.4,
            color: Color(0xFF6D6E6F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}

/// Footer shown when task is completed — "You Complete Task On @date, @time".
class _TaskFooter extends StatelessWidget {
  final StaffTask task;

  const _TaskFooter({required this.task});

  @override
  Widget build(BuildContext context) {
    final completedDate = task.completedDate;
    if (completedDate == null || completedDate.isEmpty) {
      return const SizedBox.shrink();
    }

    final text = Utils.getTranslatedLabel(youCompleteTaskOnKey)
        .replaceAll('@date', completedDate)
        .replaceAll(', @time', '')
        .replaceAll('@time', '')
        .trim();

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 16 / 12,
        ),
      ),
    );
  }
}

/// Footer shown when task is overdue — "Task Overdue By @days Days".
class _OverdueFooter extends StatelessWidget {
  final int overdueDays;

  const _OverdueFooter({required this.overdueDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }
}
