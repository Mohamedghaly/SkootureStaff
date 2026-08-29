import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/data/repositories/taskRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── States ──────────────────────────────────────────────────

abstract class UpdateTaskState {}

class UpdateTaskInitial extends UpdateTaskState {}

class UpdateTaskInProgress extends UpdateTaskState {}

class UpdateTaskSuccess extends UpdateTaskState {
  final StaffTask task;

  UpdateTaskSuccess({required this.task});
}

class UpdateTaskFailure extends UpdateTaskState {
  final String errorMessage;

  UpdateTaskFailure(this.errorMessage);
}

// ─── Cubit ───────────────────────────────────────────────────

/// Handles updating an existing task via the API.
class UpdateTaskCubit extends Cubit<UpdateTaskState> {
  final TaskRepository _taskRepository = TaskRepository();

  UpdateTaskCubit() : super(UpdateTaskInitial());

  /// Updates a task.
  ///
  /// [taskId] — ID of the task to update.
  /// [userId] — ID of the user to assign the task to.
  /// [title] — updated title.
  /// [description] — updated description.
  /// [dueDate] — updated due date in `"yyyy-MM-dd"` format.
  /// [type] — `"myself"` or `"staff"` based on assignee toggle.
  /// [status] — optional new status (`"pending"` or `"in_progress"`)
  ///            for re-opening a completed task.
  void updateTask({
    required int taskId,
    required int userId,
    required String title,
    required String description,
    required String dueDate,
    required String type,
    String? status,
  }) async {
    try {
      emit(UpdateTaskInProgress());
      final task = await _taskRepository.updateTask(
        taskId: taskId,
        userId: userId,
        title: title,
        description: description,
        dueDate: dueDate,
        type: type,
        status: status,
      );
      emit(UpdateTaskSuccess(task: task));
    } catch (e) {
      emit(UpdateTaskFailure(e.toString()));
    }
  }
}
