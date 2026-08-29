import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/data/repositories/taskRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── States ──────────────────────────────────────────────────

abstract class TasksState {}

class TasksInitial extends TasksState {}

class TasksFetchInProgress extends TasksState {}

class TasksFetchSuccess extends TasksState {
  final List<StaffTask> tasks;
  final int currentPage;
  final int totalPage;
  final bool fetchMoreInProgress;
  final bool fetchMoreError;

  TasksFetchSuccess({
    required this.tasks,
    required this.currentPage,
    required this.totalPage,
    required this.fetchMoreInProgress,
    required this.fetchMoreError,
  });

  TasksFetchSuccess copyWith({
    List<StaffTask>? tasks,
    int? currentPage,
    int? totalPage,
    bool? fetchMoreInProgress,
    bool? fetchMoreError,
  }) {
    return TasksFetchSuccess(
      tasks: tasks ?? this.tasks,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      fetchMoreInProgress:
          fetchMoreInProgress ?? this.fetchMoreInProgress,
      fetchMoreError: fetchMoreError ?? this.fetchMoreError,
    );
  }
}

class TasksFetchFailure extends TasksState {
  final String errorMessage;

  TasksFetchFailure(this.errorMessage);
}

// ─── Cubit ───────────────────────────────────────────────────

/// Manages paginated task list state.
///
/// Supports filtering by [type] (`my_tasks` / `staff`)
/// and [status] (`pending`, `in_progress`, `completed`, `overdue`).
class TasksCubit extends Cubit<TasksState> {
  final TaskRepository _taskRepository = TaskRepository();

  TasksCubit() : super(TasksInitial());

  /// Fetches the first page of tasks.
  ///
  /// [type] — `"my_tasks"` or `"staff"`.
  /// [status] — status filter or `null` for all.
  /// [userId] — restrict result to a single user's tasks.
  /// [forceRefresh] — when false (default), skip if data is already loaded
  /// or a fetch is already running. Set true for pull-to-refresh.
  void getTasks({
    String? type,
    String? status,
    int? userId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        (state is TasksFetchSuccess || state is TasksFetchInProgress)) {
      return;
    }
    emit(TasksFetchInProgress());
    try {
      final result = await _taskRepository.getTasks(
        type: type,
        status: status,
        userId: userId,
      );
      emit(TasksFetchSuccess(
        tasks: result.tasks,
        currentPage: result.currentPage,
        totalPage: result.totalPage,
        fetchMoreInProgress: false,
        fetchMoreError: false,
      ));
    } catch (e) {
      emit(TasksFetchFailure(e.toString()));
    }
  }

  /// Whether more pages are available.
  bool hasMore() {
    if (state is TasksFetchSuccess) {
      final s = state as TasksFetchSuccess;
      return s.currentPage < s.totalPage;
    }
    return false;
  }

  /// Fetches the next page and appends results.
  void fetchMore({String? type, String? status, int? userId}) async {
    if (state is! TasksFetchSuccess) return;

    final currentState = state as TasksFetchSuccess;
    if (currentState.fetchMoreInProgress) return;

    try {
      emit(currentState.copyWith(fetchMoreInProgress: true));

      final result = await _taskRepository.getTasks(
        page: currentState.currentPage + 1,
        type: type,
        status: status,
        userId: userId,
      );

      final updatedTasks = List<StaffTask>.from(currentState.tasks)
        ..addAll(result.tasks);

      emit(TasksFetchSuccess(
        tasks: updatedTasks,
        currentPage: result.currentPage,
        totalPage: result.totalPage,
        fetchMoreInProgress: false,
        fetchMoreError: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        fetchMoreInProgress: false,
        fetchMoreError: true,
      ));
    }
  }

  /// Removes a task from the local list after successful deletion.
  void deleteTaskLocally({required int taskId}) {
    if (state is TasksFetchSuccess) {
      final currentState = state as TasksFetchSuccess;
      final updatedTasks = currentState.tasks
          .where((task) => task.id != taskId)
          .toList();
      emit(currentState.copyWith(tasks: updatedTasks));
    }
  }

  /// Prepends a newly created task to the local list.
  void addTaskLocally({required StaffTask task}) {
    if (state is TasksFetchSuccess) {
      final currentState = state as TasksFetchSuccess;
      final updatedTasks = [task, ...currentState.tasks];
      emit(currentState.copyWith(tasks: updatedTasks));
    }
  }

  /// Updates a task in the local list after a successful edit.
  void updateTaskLocally({required StaffTask updatedTask}) {
    if (state is TasksFetchSuccess) {
      final currentState = state as TasksFetchSuccess;
      final updatedTasks = currentState.tasks.map((task) {
        return task.id == updatedTask.id ? updatedTask : task;
      }).toList();
      emit(currentState.copyWith(tasks: updatedTasks));
    }
  }
}
