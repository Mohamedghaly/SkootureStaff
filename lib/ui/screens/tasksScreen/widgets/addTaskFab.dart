import 'package:eschool_saas_staff/app/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// FAB for adding a new task.
///
/// Navigates to the Add Task screen on tap.
/// Returns the navigation result so the parent screen
/// can decide whether to refresh its data.
class AddTaskFab extends StatelessWidget {
  /// Optional callback when a task was successfully created.
  final VoidCallback? onTaskCreated;

  const AddTaskFab({super.key, this.onTaskCreated});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () async {
          final result =
              await Get.toNamed(Routes.addTaskScreen);
          if (result == true) {
            onTaskCreated?.call();
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }
}
