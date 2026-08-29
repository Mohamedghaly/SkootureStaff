import 'package:eschool_saas_staff/data/models/staffMember.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/assignTaskSection.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskAssigneeToggle.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskDateField.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskStatusDropdown.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

/// Form containing Task Name, Description, Due Date fields.
///
/// When [canAssign] is true, shows:
/// - "Myself / Staff" assignee toggle at the top.
/// - "Assign Task" section when "Staff" is selected.
///
/// When [showStatusField] is true (editing a completed task), shows:
/// - A status dropdown with "Pending" and "In Progress" options.
class AddTaskForm extends StatelessWidget {
  final TextEditingController taskNameController;
  final TextEditingController descriptionController;
  final DateTime? selectedDueDate;
  final ValueChanged<DateTime> onDueDateSelected;
  final bool canAssign;
  final TaskAssignee selectedAssignee;
  final ValueChanged<TaskAssignee>? onAssigneeChanged;
  final VoidCallback? onSelectStaff;
  final StaffMember? selectedStaff;
  final VoidCallback? onRemoveStaff;

  /// Whether to show the status change dropdown (for completed tasks).
  final bool showStatusField;

  /// Currently selected status (for completed tasks being re-opened).
  final EditableTaskStatus? selectedStatus;

  /// Called when the user selects a new status.
  final ValueChanged<EditableTaskStatus?>? onStatusChanged;

  const AddTaskForm({
    super.key,
    required this.taskNameController,
    required this.descriptionController,
    required this.selectedDueDate,
    required this.onDueDateSelected,
    this.canAssign = false,
    this.selectedAssignee = TaskAssignee.myself,
    this.onAssigneeChanged,
    this.onSelectStaff,
    this.selectedStaff,
    this.onRemoveStaff,
    this.showStatusField = false,
    this.selectedStatus,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: appContentHorizontalPadding,
        vertical: 16,
      ),
      child: Column(
        children: [
          // Admin-only: Myself / Staff radio toggle
          if (canAssign && onAssigneeChanged != null) ...[
            TaskAssigneeToggle(
              selectedAssignee: selectedAssignee,
              onAssigneeChanged: onAssigneeChanged!,
            ),
            const SizedBox(height: 16),
          ],

          // Task Name field
          CustomTextFieldContainer(
            hintTextKey: taskNameKey,
            textEditingController: taskNameController,
            bottomPadding: 16,
          ),

          // Description field — multiline, 100px height
          CustomTextFieldContainer(
            hintTextKey: descriptionKey,
            textEditingController: descriptionController,
            maxLines: 4,
            height: 100,
            bottomPadding: 16,
          ),

          // Due Date field
          TaskDateField(
            selectedDate: selectedDueDate,
            onDateSelected: onDueDateSelected,
          ),

          // Status dropdown — only for completed tasks in edit mode
          if (showStatusField && onStatusChanged != null) ...[
            const SizedBox(height: 16),
            TaskStatusDropdown(
              selectedStatus: selectedStatus,
              onStatusChanged: onStatusChanged!,
            ),
          ],

          // Admin-only: Assign Task section (when "Staff" selected)
          if (canAssign &&
              selectedAssignee == TaskAssignee.staff &&
              onSelectStaff != null) ...[
            const SizedBox(height: 16),
            AssignTaskSection(
              onSelectStaff: onSelectStaff!,
              selectedStaff: selectedStaff,
              onRemoveStaff: onRemoveStaff,
            ),
          ],
        ],
      ),
    );
  }
}
