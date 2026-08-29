import 'package:eschool_saas_staff/cubits/task/deleteTaskCubit.dart';
import 'package:eschool_saas_staff/cubits/task/updateTaskStatusCubit.dart';
import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskDetailsButtons.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskDetailsContent.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Possible actions returned from the bottom sheet.
enum TaskSheetAction {
  /// User tapped "Edit" — the caller should navigate to the
  /// edit screen.
  edit,

  /// A delete was confirmed and dispatched via the cubit.
  deleted,

  /// Task status was changed (started or completed).
  /// The caller should refresh the list.
  statusChanged,
}

/// Shows the task details bottom sheet.
///
/// Returns a [TaskSheetAction] so the caller can decide
/// what to do next (navigate to edit, refresh list, etc.).
///
/// [canEdit] — whether to show the edit button.
/// [canDelete] — whether to show the delete button.
/// [showAssignmentInfo] — whether to show the assignee row
/// (true for "Staff Task" tab, false for "My Task" tab).
Future<TaskSheetAction?> showTaskDetailsBottomSheet({
  required BuildContext context,
  required StaffTask task,
  bool canEdit = true,
  bool canDelete = true,
  bool showAssignmentInfo = false,
}) {
  return showModalBottomSheet<TaskSheetAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<DeleteTaskCubit>(),
        ),
        BlocProvider.value(
          value: context.read<UpdateTaskStatusCubit>(),
        ),
      ],
      child: _TaskDetailsSheet(
        task: task,
        canEdit: canEdit,
        canDelete: canDelete,
        showAssignmentInfo: showAssignmentInfo,
      ),
    ),
  );
}

class _TaskDetailsSheet extends StatelessWidget {
  final StaffTask task;
  final bool canEdit;
  final bool canDelete;
  final bool showAssignmentInfo;

  const _TaskDetailsSheet({
    required this.task,
    this.canEdit = true,
    this.canDelete = true,
    this.showAssignmentInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateTaskStatusCubit, UpdateTaskStatusState>(
      listener: _handleStatusUpdate,
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SheetHeader(
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 24),
                  TaskDetailsContent(
                    task: task,
                    showAssignmentInfo: showAssignmentInfo,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<UpdateTaskStatusCubit, UpdateTaskStatusState>(
                    builder: (context, statusState) {
                      final isLoading =
                          statusState is UpdateTaskStatusInProgress;
                      return TaskActionButtons(
                        status: task.status,
                        onStartTask: isLoading
                            ? null
                            : () {
                                context
                                    .read<UpdateTaskStatusCubit>()
                                    .updateStatus(
                                      taskId: task.id!,
                                      status: 'in_progress',
                                    );
                              },
                        onMarkComplete: isLoading
                            ? null
                            : () {
                                context
                                    .read<UpdateTaskStatusCubit>()
                                    .updateStatus(
                                      taskId: task.id!,
                                      status: 'completed',
                                    );
                              },
                        onEditTask: (!canEdit || isLoading)
                            ? null
                            : () {
                                Navigator.of(context).pop(TaskSheetAction.edit);
                              },
                        onDeleteTask: (!canDelete || isLoading)
                            ? null
                            : () {
                                _showDeleteConfirmation(context);
                              },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles status update API response.
  void _handleStatusUpdate(
    BuildContext context,
    UpdateTaskStatusState state,
  ) {
    if (state is UpdateTaskStatusSuccess) {
      final isCompleted = state.updatedTask.status.name == 'completed';
      Utils.showSnackBar(
        message: isCompleted ? taskCompletedSuccessKey : taskStartedSuccessKey,
        context: context,
      );
      // Close sheet and tell caller to refresh.
      Navigator.of(context).pop(TaskSheetAction.statusChanged);
    } else if (state is UpdateTaskStatusFailure) {
      Utils.showSnackBar(
        message: state.errorMessage,
        context: context,
      );
    }
  }

  /// Shows a confirmation dialog before deleting.
  void _showDeleteConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          Utils.getTranslatedLabel(deleteTaskKey),
        ),
        content: Text(
          Utils.getTranslatedLabel(deleteTaskConfirmKey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              Utils.getTranslatedLabel(cancelKey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<DeleteTaskCubit>().deleteTask(taskId: task.id!);
              Navigator.of(context).pop(TaskSheetAction.deleted);
            },
            child: Text(
              Utils.getTranslatedLabel(deleteKey),
              style: const TextStyle(
                color: Color(0xFFBA1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header row with title and close button.
class _SheetHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _SheetHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              Utils.getTranslatedLabel(taskDetailsKey),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 24 / 16,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, size: 24),
          ),
        ],
      ),
    );
  }
}
