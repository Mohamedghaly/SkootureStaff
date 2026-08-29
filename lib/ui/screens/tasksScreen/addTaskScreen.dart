import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/task/createTaskCubit.dart';
import 'package:eschool_saas_staff/cubits/task/updateTaskCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/staffMember.dart';
import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/data/models/taskStatus.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/addTaskForm.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskAssigneeToggle.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/taskStatusDropdown.dart';
import 'package:eschool_saas_staff/ui/screens/selectStaffScreen/selectStaffScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen._({this.taskToEdit});

  /// When non-null, the screen operates in **edit mode**.
  final StaffTask? taskToEdit;

  /// Route builder.
  ///
  /// Pass [StaffTask] via `Get.arguments` to enter edit mode.
  static Widget getRouteInstance() {
    final args = Get.arguments;
    final StaffTask? taskToEdit = args is StaffTask ? args : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CreateTaskCubit()),
        BlocProvider(create: (_) => UpdateTaskCubit()),
      ],
      child: AddTaskScreen._(taskToEdit: taskToEdit),
    );
  }

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  TaskAssignee _selectedAssignee = TaskAssignee.myself;
  StaffMember? _selectedStaff;
  EditableTaskStatus? _selectedStatus;

  /// True when editing an existing task.
  bool get _isEditMode => widget.taskToEdit != null;

  /// True when the task being edited has `completed` status.
  /// Used to show the status dropdown for re-opening the task.
  bool get _isCompletedTask =>
      _isEditMode && widget.taskToEdit!.status == TaskStatus.completed;

  bool get _isSchoolAdmin =>
      context.read<AuthCubit>().getUserDetails().isSchoolAdmin();

  /// Whether the user can assign tasks to others.
  /// School admins always can. Teachers and staff need the
  /// explicit `task-assign` permission from the API.
  bool get _canAssign {
    if (_isSchoolAdmin) return true;
    return context
        .read<StaffAllowedPermissionsAndModulesCubit>()
        .isPermissionGiven(permission: assignTaskPermissionKey);
  }

  @override
  void initState() {
    super.initState();
    _prefillForEdit();
  }

  /// Prefills the form fields when in edit mode.
  void _prefillForEdit() {
    final task = widget.taskToEdit;
    if (task == null) return;

    _taskNameController.text = task.title ?? '';
    _descriptionController.text = task.description ?? '';
    _selectedDueDate = task.dueDate;

    // Determine if this is a "Staff" task (assigned to someone else).
    //
    // Priority: use `assigned_by` vs `user_id` when available.
    // Fallback: use `is_admin_assigned` for legacy API data
    // where `assigned_by` may be null.
    final isStaffTask = task.assignedBy != null
        ? !task.isSelfAssigned // New API: compare IDs
        : task.isAssignedByAdmin; // Legacy: fall back to flag

    if (isStaffTask && task.userId != null) {
      _selectedAssignee = TaskAssignee.staff;
      _selectedStaff = StaffMember(
        id: task.userId!,
        name: task.assigneeName ?? '',
        role: task.assigneeRole ?? '',
        imageUrl: task.assigneeImage,
      );
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onDueDateSelected(DateTime date) {
    setState(() => _selectedDueDate = date);
  }

  void _onAssigneeChanged(TaskAssignee assignee) {
    setState(() {
      _selectedAssignee = assignee;
      // Clear selected staff when switching to "Myself"
      if (assignee == TaskAssignee.myself) {
        _selectedStaff = null;
      }
    });
  }

  Future<void> _onSelectStaff() async {
    final result = await Get.toNamed(
      Routes.selectStaffScreen,
      arguments: SelectStaffScreen.buildArguments(
        preselected: _selectedStaff,
      ),
    );
    if (result is StaffMember) {
      setState(() => _selectedStaff = result);
    }
  }

  void _onRemoveStaff() {
    setState(() => _selectedStaff = null);
  }

  void _onStatusChanged(EditableTaskStatus? status) {
    setState(() => _selectedStatus = status);
  }

  /// Validates form fields before submission.
  bool _validate() {
    if (_taskNameController.text.trim().isEmpty) {
      Utils.showSnackBar(
        message: pleaseEnterTaskNameKey,
        context: context,
      );
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      Utils.showSnackBar(
        message: pleaseEnterDescriptionTaskKey,
        context: context,
      );
      return false;
    }
    if (_selectedDueDate == null) {
      Utils.showSnackBar(
        message: pleaseSelectDueDateKey,
        context: context,
      );
      return false;
    }
    // Admin chose "Staff" but hasn't selected anyone.
    if (_selectedAssignee == TaskAssignee.staff && _selectedStaff == null) {
      Utils.showSnackBar(
        message: pleaseSelectStaffKey,
        context: context,
      );
      return false;
    }
    // Must select a new status when editing a completed task.
    if (_isCompletedTask && _selectedStatus == null) {
      Utils.showSnackBar(
        message: pleaseSelectStatusKey,
        context: context,
      );
      return false;
    }
    return true;
  }

  /// Returns the user ID to pass to the API.
  ///
  /// For "Myself" → logged-in user's ID.
  /// For "Staff"  → selected staff member's ID.
  int _resolveUserId() {
    if (_selectedAssignee == TaskAssignee.staff && _selectedStaff != null) {
      return _selectedStaff!.id;
    }
    return context.read<AuthCubit>().getUserDetails().id ?? 0;
  }

  void _onSubmit() {
    if (!_validate()) return;

    final userId = _resolveUserId();
    final title = _taskNameController.text.trim();
    final description = _descriptionController.text.trim();
    final dueDate = DateFormat('yyyy-MM-dd').format(_selectedDueDate!);

    final type = _selectedAssignee.apiValue;

    if (_isEditMode) {
      context.read<UpdateTaskCubit>().updateTask(
            taskId: widget.taskToEdit!.id!,
            userId: userId,
            title: title,
            description: description,
            dueDate: dueDate,
            type: type,
            status: _selectedStatus?.apiValue,
          );
    } else {
      context.read<CreateTaskCubit>().createTask(
            userId: userId,
            title: title,
            description: description,
            dueDate: dueDate,
            type: type,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAssign = _canAssign;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: MultiBlocListener(
        listeners: [
          BlocListener<CreateTaskCubit, CreateTaskState>(
            listener: _handleCreateState,
          ),
          BlocListener<UpdateTaskCubit, UpdateTaskState>(
            listener: _handleUpdateState,
          ),
        ],
        child: Column(
          children: [
            CustomAppbar(
              titleKey: _isEditMode ? editTaskKey : addTaskKey,
            ),
            Expanded(
              child: AddTaskForm(
                taskNameController: _taskNameController,
                descriptionController: _descriptionController,
                selectedDueDate: _selectedDueDate,
                onDueDateSelected: _onDueDateSelected,
                canAssign: canAssign,
                selectedAssignee: _selectedAssignee,
                onAssigneeChanged: _onAssigneeChanged,
                onSelectStaff: _onSelectStaff,
                selectedStaff: _selectedStaff,
                onRemoveStaff: _onRemoveStaff,
                showStatusField: _isCompletedTask,
                selectedStatus: _selectedStatus,
                onStatusChanged: _onStatusChanged,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SubmitButton(
        isEditMode: _isEditMode,
        onTap: _onSubmit,
      ),
    );
  }

  void _handleCreateState(
    BuildContext context,
    CreateTaskState state,
  ) {
    if (state is CreateTaskSuccess) {
      Utils.showSnackBar(
        message: taskCreatedSuccessKey,
        context: context,
      );
      Get.back(result: true);
    } else if (state is CreateTaskFailure) {
      Utils.showSnackBar(
        message: state.errorMessage,
        context: context,
      );
    }
  }

  void _handleUpdateState(
    BuildContext context,
    UpdateTaskState state,
  ) {
    if (state is UpdateTaskSuccess) {
      Utils.showSnackBar(
        message: taskUpdatedSuccessKey,
        context: context,
      );
      Get.back(result: true);
    } else if (state is UpdateTaskFailure) {
      Utils.showSnackBar(
        message: state.errorMessage,
        context: context,
      );
    }
  }
}

/// Sticky bottom button with loading state awareness.
class _SubmitButton extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.isEditMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1C1D).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: double.maxFinite,
            height: 40,
            child: BlocBuilder<CreateTaskCubit, CreateTaskState>(
              builder: (context, createState) {
                return BlocBuilder<UpdateTaskCubit, UpdateTaskState>(
                  builder: (context, updateState) {
                    final isLoading = createState is CreateTaskInProgress ||
                        updateState is UpdateTaskInProgress;

                    return ElevatedButton(
                      onPressed: isLoading ? null : onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 20 / 14,
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              Utils.getTranslatedLabel(
                                isEditMode ? editTaskKey : addTaskKey,
                              ),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
