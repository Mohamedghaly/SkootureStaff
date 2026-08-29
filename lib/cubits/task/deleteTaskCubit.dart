import 'package:eschool_saas_staff/data/repositories/taskRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── States ──────────────────────────────────────────────────

abstract class DeleteTaskState {}

class DeleteTaskInitial extends DeleteTaskState {}

class DeleteTaskInProgress extends DeleteTaskState {}

class DeleteTaskSuccess extends DeleteTaskState {
  final int taskId;

  DeleteTaskSuccess({required this.taskId});
}

class DeleteTaskFailure extends DeleteTaskState {
  final String errorMessage;

  DeleteTaskFailure(this.errorMessage);
}

// ─── Cubit ───────────────────────────────────────────────────

/// Handles deleting a task via the API.
class DeleteTaskCubit extends Cubit<DeleteTaskState> {
  final TaskRepository _taskRepository = TaskRepository();

  DeleteTaskCubit() : super(DeleteTaskInitial());

  /// Deletes a task by [taskId].
  void deleteTask({required int taskId}) async {
    try {
      emit(DeleteTaskInProgress());
      await _taskRepository.deleteTask(taskId: taskId);
      emit(DeleteTaskSuccess(taskId: taskId));
    } catch (e) {
      emit(DeleteTaskFailure(e.toString()));
    }
  }
}
