import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/task/deleteTaskCubit.dart';
import 'package:eschool_saas_staff/cubits/task/tasksCubit.dart';
import 'package:eschool_saas_staff/cubits/task/updateTaskStatusCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/data/models/taskStatus.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/addTaskFab.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskFilterBar.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskListBody.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskTypeTabBar.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen._();

  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => TasksCubit()),
          BlocProvider(create: (_) => DeleteTaskCubit()),
          BlocProvider(create: (_) => UpdateTaskStatusCubit()),
        ],
        child: const MyTasksScreen._(),
      );

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  TaskStatus? _selectedFilter;
  TaskType _selectedTaskType = TaskType.myTask;

  /// Whether the logged-in user is a school admin.
  bool get _isSchoolAdmin =>
      context.read<AuthCubit>().getUserDetails().isSchoolAdmin();

  /// Checks if the logged-in user has the given task permission.
  /// Both teachers and staff use their actual API permissions.
  bool _hasPermission(String permission) {
    return context
        .read<StaffAllowedPermissionsAndModulesCubit>()
        .isPermissionGiven(permission: permission);
  }

  bool get _canCreate => _hasPermission(createTaskPermissionKey);
  bool get _canEdit => _hasPermission(editTaskPermissionKey);
  bool get _canDelete => _hasPermission(deleteTaskPermissionKey);
  bool get _canAssign => _hasPermission(assignTaskPermissionKey);

  /// Returns the API `type` param based on the selected tab.
  String get _apiTypeParam =>
      _selectedTaskType == TaskType.staffTask ? 'staff' : 'my_tasks';

  /// Returns the API `status` param based on the selected filter.
  String? get _apiStatusParam {
    if (_selectedFilter == null) return null;
    switch (_selectedFilter!) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.overdue:
        return 'overdue';
      case TaskStatus.rejected:
        return 'rejected';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  /// Fetches tasks from the API with current filters.
  /// Always forces — filter / tab change must refetch.
  void _fetchTasks() {
    context.read<TasksCubit>().getTasks(
          type: _apiTypeParam,
          status: _apiStatusParam,
          forceRefresh: true,
        );
  }

  void _onFilterSelected(TaskStatus? status) {
    setState(() => _selectedFilter = status);
    _fetchTasks();
  }

  void _onTaskTypeSelected(TaskType type) {
    setState(() {
      _selectedTaskType = type;
      _selectedFilter = null; // Reset filter on tab switch
    });
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    // Admin or staff with task-assign can see the staff task tab.
    final showStaffTab = _isSchoolAdmin || _canAssign;

    return Scaffold(
      body: BlocListener<DeleteTaskCubit, DeleteTaskState>(
        listener: _handleDeleteState,
        child: Column(
          children: [
            // AppBar: "Manage Task" for admin/assign, "My Tasks" for others
            CustomAppbar(
              titleKey: showStaffTab ? manageTaskKey : myTasksKey,
            ),

            // Staff task tab: visible to admin or staff with assign permission
            if (showStaffTab)
              TaskTypeTabBar(
                selectedType: _selectedTaskType,
                onTypeSelected: _onTaskTypeSelected,
              ),

            // Status filter chips
            TaskFilterBar(
              selectedFilter: _selectedFilter,
              onFilterSelected: _onFilterSelected,
            ),

            // Task list driven by cubit state
            Expanded(
              child: BlocBuilder<TasksCubit, TasksState>(
                builder: (context, state) {
                  if (state is TasksFetchInProgress) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is TasksFetchFailure) {
                    return Center(
                      child: Text(state.errorMessage),
                    );
                  }

                  if (state is TasksFetchSuccess) {
                    return _TaskListView(
                      tasks: state.tasks,
                      showAssignmentInfo: showStaffTab &&
                          _selectedTaskType == TaskType.staffTask,
                      canEdit: _canEdit,
                      canDelete: _canDelete,
                      hasMore: context.read<TasksCubit>().hasMore(),
                      fetchMoreInProgress: state.fetchMoreInProgress,
                      onFetchMore: () {
                        context.read<TasksCubit>().fetchMore(
                              type: _apiTypeParam,
                              status: _apiStatusParam,
                            );
                      },
                      onRefresh: _fetchTasks,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _canCreate ? AddTaskFab(onTaskCreated: _fetchTasks) : null,
    );
  }

  void _handleDeleteState(
    BuildContext context,
    DeleteTaskState state,
  ) {
    if (state is DeleteTaskSuccess) {
      context.read<TasksCubit>().deleteTaskLocally(taskId: state.taskId);
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
  }
}

/// Wraps [TaskListBody] with a [NotificationListener] for pagination.
class _TaskListView extends StatelessWidget {
  final List<StaffTask> tasks;
  final bool showAssignmentInfo;
  final bool canEdit;
  final bool canDelete;
  final bool hasMore;
  final bool fetchMoreInProgress;
  final VoidCallback onFetchMore;
  final VoidCallback onRefresh;

  const _TaskListView({
    required this.tasks,
    required this.showAssignmentInfo,
    required this.canEdit,
    required this.canDelete,
    required this.hasMore,
    required this.fetchMoreInProgress,
    required this.onFetchMore,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 100 &&
            hasMore &&
            !fetchMoreInProgress) {
          onFetchMore();
        }
        return false;
      },
      child: TaskListBody(
        tasks: tasks,
        showAssignmentInfo: showAssignmentInfo,
        canEdit: canEdit,
        canDelete: canDelete,
        fetchMoreInProgress: fetchMoreInProgress,
        onRefresh: onRefresh,
      ),
    );
  }
}
