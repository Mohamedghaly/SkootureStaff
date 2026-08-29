import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/data/repositories/taskRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── States ──────────────────────────────────────────────────

abstract class CreateTaskState {}

class CreateTaskInitial extends CreateTaskState {}

class CreateTaskInProgress extends CreateTaskState {}

class CreateTaskSuccess extends CreateTaskState {
  final StaffTask task;

  CreateTaskSuccess({required this.task});
}

class CreateTaskFailure extends CreateTaskState {
  final String errorMessage;

  CreateTaskFailure(this.errorMessage);
}

// ─── Cubit ───────────────────────────────────────────────────

/// Handles creating a new task via the API.
class CreateTaskCubit extends Cubit<CreateTaskState> {
  final TaskRepository _taskRepository = TaskRepository();

  CreateTaskCubit() : super(CreateTaskInitial());

  /// Creates a new task.
  ///
  /// [userId] — ID of the user to assign the task to.
  /// [title] — task title.
  /// [description] — task description.
  /// [dueDate] — due date in `"yyyy-MM-dd"` format.
  /// [type] — `"myself"` or `"staff"` based on assignee toggle.
  void createTask({
    required int userId,
    required String title,
    required String description,
    required String dueDate,
    required String type,
  }) async {
    try {
      emit(CreateTaskInProgress());
      final task = await _taskRepository.createTask(
        userId: userId,
        title: title,
        description: description,
        dueDate: dueDate,
        type: type,
      );
      emit(CreateTaskSuccess(task: task));
    } catch (e) {
      emit(CreateTaskFailure(e.toString()));
    }
  }
}
