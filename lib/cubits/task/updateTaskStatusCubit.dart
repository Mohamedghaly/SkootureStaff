import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/data/repositories/taskRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── States ──────────────────────────────────────────────────

abstract class UpdateTaskStatusState {}

class UpdateTaskStatusInitial extends UpdateTaskStatusState {}

class UpdateTaskStatusInProgress extends UpdateTaskStatusState {}

class UpdateTaskStatusSuccess extends UpdateTaskStatusState {
  final StaffTask updatedTask;

  UpdateTaskStatusSuccess({required this.updatedTask});
}

class UpdateTaskStatusFailure extends UpdateTaskStatusState {
  final String errorMessage;

  UpdateTaskStatusFailure(this.errorMessage);
}

// ─── Cubit ───────────────────────────────────────────────────

/// Handles updating a task's status via the API.
///
/// Used for "Start Task" (`in_progress`) and
/// "Mark as Complete" (`completed`) actions.
class UpdateTaskStatusCubit
    extends Cubit<UpdateTaskStatusState> {
  final TaskRepository _taskRepository = TaskRepository();

  UpdateTaskStatusCubit()
      : super(UpdateTaskStatusInitial());

  /// Updates a task's status.
  ///
  /// [taskId] — ID of the task to update.
  /// [status] — `"in_progress"` or `"completed"`.
  void updateStatus({
    required int taskId,
    required String status,
  }) async {
    try {
      emit(UpdateTaskStatusInProgress());
      final updatedTask =
          await _taskRepository.updateTaskStatus(
        taskId: taskId,
        status: status,
      );
      emit(UpdateTaskStatusSuccess(
        updatedTask: updatedTask,
      ));
    } catch (e) {
      emit(UpdateTaskStatusFailure(e.toString()));
    }
  }
}
