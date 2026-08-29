import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/taskCardWidget.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskDetailsBottomSheet.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Displays a scrollable list of task cards.
///
/// Shows a loading indicator at the bottom when
/// [fetchMoreInProgress] is true (pagination).
class TaskListBody extends StatelessWidget {
  final List<StaffTask> tasks;

  /// When true, shows assignment info row on each card
  /// (admin "Staff Task" tab).
  final bool showAssignmentInfo;

  /// Whether the user has permission to edit tasks.
  final bool canEdit;

  /// Whether the user has permission to delete tasks.
  final bool canDelete;

  /// Whether more tasks are being fetched (pagination).
  final bool fetchMoreInProgress;

  /// Called to refresh the task list (e.g., after edit/delete).
  final VoidCallback? onRefresh;

  const TaskListBody({
    super.key,
    required this.tasks,
    this.showAssignmentInfo = false,
    this.canEdit = true,
    this.canDelete = true,
    this.fetchMoreInProgress = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return noDataContainer(titleKey: noTasksFoundKey);
    }

    // Extra item for the loading indicator when paginating.
    final itemCount = fetchMoreInProgress ? tasks.length + 1 : tasks.length;

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: appContentHorizontalPadding,
        vertical: 16,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        // Show loading indicator as last item during pagination.
        if (index >= tasks.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final task = tasks[index];
        return TaskCardWidget(
          task: task,
          showAssignmentInfo: showAssignmentInfo,
          onTap: () => _handleCardTap(context, task),
        );
      },
    );
  }

  Future<void> _handleCardTap(
    BuildContext context,
    StaffTask task,
  ) async {
    final action = await showTaskDetailsBottomSheet(
      context: context,
      task: task,
      canEdit: canEdit,
      canDelete: canDelete,
      showAssignmentInfo: showAssignmentInfo,
    );

    if (action == null) return;

    switch (action) {
      case TaskSheetAction.edit:
        // Navigate to edit screen and wait for it to close.
        final editResult = await Get.toNamed(
          Routes.addTaskScreen,
          arguments: task,
        );
        if (editResult == true) {
          onRefresh?.call();
        }
        break;

      case TaskSheetAction.deleted:
        // Delete cubit was already dispatched from the sheet.
        // The BlocListener in MyTasksScreen handles the
        // local removal and snackbar. No action needed here.
        break;

      case TaskSheetAction.statusChanged:
        // Status was updated via the API. Re-fetch the list
        // so the task card reflects the new status.
        onRefresh?.call();
        break;
    }
  }
}
