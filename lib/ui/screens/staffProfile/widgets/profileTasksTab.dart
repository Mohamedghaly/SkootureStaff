import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/task/tasksCubit.dart';
import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/taskCardWidget.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskDetailsBottomSheet.dart';
import 'package:eschool_saas_staff/cubits/task/deleteTaskCubit.dart';
import 'package:eschool_saas_staff/cubits/task/updateTaskStatusCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// Tasks tab content for staff/teacher profile screens.
///
/// Provides its own [TasksCubit] and [DeleteTaskCubit] so it
/// can be used anywhere without the parent needing to provide them.
/// Shows task cards with assignment info visible.
class ProfileTasksTab extends StatelessWidget {
  /// User whose tasks to fetch. When null, all staff tasks are returned.
  final int? userId;

  const ProfileTasksTab({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              TasksCubit()..getTasks(type: 'staff', userId: userId),
        ),
        BlocProvider(create: (_) => DeleteTaskCubit()),
        BlocProvider(
          create: (_) => UpdateTaskStatusCubit(),
        ),
      ],
      child: _ProfileTasksTabBody(userId: userId),
    );
  }
}

class _ProfileTasksTabBody extends StatelessWidget {
  final int? userId;

  const _ProfileTasksTabBody({this.userId});

  void _refreshTasks(BuildContext context) {
    context
        .read<TasksCubit>()
        .getTasks(type: 'staff', userId: userId, forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteTaskCubit, DeleteTaskState>(
      listener: (context, state) {
        if (state is DeleteTaskSuccess) {
          context
              .read<TasksCubit>()
              .deleteTaskLocally(taskId: state.taskId);
          Utils.showSnackBar(
            message: taskDeletedSuccessKey,
            context: context,
          );
        } else if (state is DeleteTaskFailure) {
          Utils.showSnackBar(
            message: state.errorMessage,
            context: context,
          );
        }
      },
      child: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          if (state is TasksFetchInProgress) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is TasksFetchSuccess) {
            return _buildTaskList(context, state.tasks);
          }

          if (state is TasksFetchFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(state.errorMessage),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<StaffTask> tasks,
  ) {
    if (tasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CustomTextContainer(
            textKey: noTasksAssignedKey,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6D6E6F),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCardWidget(
          task: task,
          showAssignmentInfo: true,
          onTap: () => _handleCardTap(context, task),
        );
      },
    );
  }

  /// Handles card tap with proper edit/delete flow.
  Future<void> _handleCardTap(
    BuildContext context,
    StaffTask task,
  ) async {
    final action = await showTaskDetailsBottomSheet(
      context: context,
      task: task,
    );

    if (action == null) return;

    switch (action) {
      case TaskSheetAction.edit:
        final editResult = await Get.toNamed(
          Routes.addTaskScreen,
          arguments: task,
        );
        if (editResult == true && context.mounted) {
          _refreshTasks(context);
        }
        break;

      case TaskSheetAction.deleted:
        // Handled by the BlocListener above.
        break;

      case TaskSheetAction.statusChanged:
        if (context.mounted) {
          _refreshTasks(context);
        }
        break;
    }
  }
}
