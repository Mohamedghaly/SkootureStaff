import 'package:eschool_saas_staff/data/models/staffMember.dart';
import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/utils/api.dart';

/// Repository for Task CRUD operations and user listing.
///
/// Endpoints:
/// - GET  `staff/tasks`            → list tasks (paginated)
/// - POST `staff/tasks`            → create a task
/// - POST `staff/tasks/update`     → update a task
/// - POST `staff/tasks/delete`     → delete a task
/// - POST `staff/tasks/status`     → update task status
/// - GET  `staff/users-role-wise`  → list users by role
class TaskRepository {
  Future<({List<StaffTask> tasks, int currentPage, int totalPage})> getTasks(
      {int? page, String? type, String? status, int? userId}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page ?? 1,
      };

      if (type != null) {
        queryParams['type'] = type;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      if (userId != null) {
        queryParams['user_id'] = userId;
      }

      final result = await Api.get(
        url: Api.getTasks,
        queryParameters: queryParams,
      );

      final data = result['data'] as Map<String, dynamic>;

      final tasks = ((data['data'] ?? []) as List)
          .map((task) => StaffTask.fromJson(Map.from(task ?? {})))
          .toList();

      return (
        tasks: tasks,
        currentPage: (data['current_page'] as int?) ?? 1,
        totalPage: (data['last_page'] as int?) ?? 1,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Creates a new task.
  ///
  /// [userId] — ID of the user this task is for.
  /// [title] — task title.
  /// [description] — task description.
  /// [dueDate] — due date in `"yyyy-MM-dd"` format.
  /// [type] — `"myself"` or `"staff"` based on assignee toggle.
  Future<StaffTask> createTask({
    required int userId,
    required String title,
    required String description,
    required String dueDate,
    required String type,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'description': description,
        'due_date': dueDate,
        'type': type,
        'user_id': userId.toString(),
      };

      final result = await Api.post(
        url: Api.createTask,
        body: body,
      );

      return StaffTask.fromJson(
        Map.from(result['data'] ?? {}),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Updates an existing task.
  ///
  /// [taskId] — ID of the task to update.
  /// [userId] — ID of the user this task is for.
  /// [title] — updated title.
  /// [description] — updated description.
  /// [dueDate] — updated due date in `"yyyy-MM-dd"` format.
  /// [type] — `"myself"` or `"staff"` based on assignee toggle.
  /// [status] — optional new status (`"pending"` or `"in_progress"`)
  ///            for re-opening a completed task.
  Future<StaffTask> updateTask({
    required int taskId,
    required int userId,
    required String title,
    required String description,
    required String dueDate,
    required String type,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{
        'task_id': taskId.toString(),
        'title': title,
        'description': description,
        'due_date': dueDate,
        'type': type,
        'user_id': userId.toString(),
      };

      if (status != null) {
        body['status'] = status;
      }

      final result = await Api.post(
        url: Api.updateTask,
        body: body,
      );

      return StaffTask.fromJson(
        Map.from(result['data'] ?? {}),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Deletes a task by its ID.
  Future<void> deleteTask({required int taskId}) async {
    try {
      await Api.post(
        url: Api.deleteTask,
        body: {'task_id': taskId.toString()},
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Updates the status of a task.
  ///
  /// [taskId] — ID of the task.
  /// [status] — new status: `"in_progress"` or `"completed"`.
  Future<StaffTask> updateTaskStatus({
    required int taskId,
    required String status,
  }) async {
    try {
      final result = await Api.post(
        url: Api.updateTaskStatus,
        body: {
          'task_id': taskId.toString(),
          'status': status,
        },
      );

      return StaffTask.fromJson(
        Map.from(result['data'] ?? {}),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Fetches users filtered by role, with pagination
  /// and optional search.
  ///
  /// [page] — 1-based page number.
  /// [roleName] — role name filter (e.g. `"Teacher"`).
  /// [search] — optional search query for user name.
  Future<
      ({
        List<StaffMember> users,
        int currentPage,
        int totalPage,
      })> getUsersRoleWise({
    int? page,
    String? roleName,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page ?? 1,
      };

      if (roleName != null && roleName.isNotEmpty) {
        queryParams['role_name'] = roleName;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final result = await Api.get(
        url: Api.getUsersRoleWise,
        queryParameters: queryParams,
      );

      final data = result['data'] as Map<String, dynamic>;

      final users = ((data['data'] ?? []) as List)
          .map(
            (user) => StaffMember.fromJson(Map.from(user ?? {})),
          )
          .toList();

      return (
        users: users,
        currentPage: (data['current_page'] as int?) ?? 1,
        totalPage: (data['last_page'] as int?) ?? 1,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
