import 'package:eschool_saas_staff/data/models/taskStatus.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

/// Represents a task assigned to or created by a staff member.
class StaffTask {
  final int? id;
  final String? title;
  final String? description;
  final TaskStatus status;
  final DateTime? dueDate;
  /// Pre-formatted completion date from API (e.g. `"2026-05-14"`).
  final String? completedDate;
  final int? overdueDays;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? userId;

  /// The user ID of the person who created/assigned this task.
  final int? assignedBy;

  /// `true` → task is "My Task" (admin assigned to themselves).
  /// `false` → task is "Staff Task" (admin assigned to another staff member).
  final bool isAssignedByAdmin;

  /// Name of the staff member this task is assigned to.
  final String? assigneeName;

  /// Role of the staff member this task is assigned to (e.g. "Teacher").
  final String? assigneeRole;

  /// Profile image URL of the assignee.
  final String? assigneeImage;

  /// Mobile number of the assignee (from user.mobile).
  final String? assigneeMobile;

  /// ID of the assignee user (from user.id) — used for chat navigation.
  final int? assigneeId;

  /// Whether the task creator and assignee are the same user.
  bool get isSelfAssigned =>
      assignedBy != null && userId != null && assignedBy == userId;

  const StaffTask({
    this.id,
    this.title,
    this.description,
    this.status = TaskStatus.pending,
    this.dueDate,
    this.completedDate,
    this.overdueDays,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.assignedBy,
    this.isAssignedByAdmin = false,
    this.assigneeName,
    this.assigneeRole,
    this.assigneeImage,
    this.assigneeMobile,
    this.assigneeId,
  });

  /// Creates a [StaffTask] from the API JSON response.
  ///
  /// The API returns dates in `"dd-MM-yyyy"` or
  /// `"dd-MM-yyyy hh:mm a"` format, so we use
  /// [Utils.parseDateSafely] for parsing.
  StaffTask.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        title = json['title'] as String?,
        description = json['description'] as String?,
        status = TaskStatus.fromString(
          (json['status'] as String?) ?? 'pending',
        ),
        dueDate = json['date_format'] != null
            ? Utils.parseDateSafely(json['date_format'].toString())
            : null,
        completedDate = json['completed_date'] as String?,
        overdueDays = switch (json['overdue_days']) {
          int v => v,
          double v => v.toInt(),
          String v => int.tryParse(v),
          _ => null,
        },
        createdAt = json['created_at'] != null
            ? Utils.parseDateSafely(json['created_at'].toString())
            : null,
        updatedAt = json['updated_at'] != null
            ? Utils.parseDateSafely(json['updated_at'].toString())
            : null,
        userId = json['user_id'] is int
            ? json['user_id'] as int
            : int.tryParse(json['user_id']?.toString() ?? ''),
        assignedBy = json['assigned_by'] is int
            ? json['assigned_by'] as int
            : int.tryParse(json['assigned_by']?.toString() ?? ''),
        isAssignedByAdmin = (json['is_admin_assigned'] as bool?) ?? false,
        assigneeName = json['user'] is Map
            ? (json['user']['full_name'] as String?)
            : (json['assignee_name'] as String?),
        assigneeRole =
            json['user'] is Map ? (json['user']['role'] as String?) : null,
        assigneeImage =
            json['user'] is Map ? (json['user']['image'] as String?) : null,
        assigneeMobile =
            json['user'] is Map ? (json['user']['mobile'] as String?) : null,
        assigneeId = json['user'] is Map
            ? (json['user']['id'] is int
                ? json['user']['id'] as int
                : int.tryParse(json['user']['id']?.toString() ?? ''))
            : null;

  /// Converts the model to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.name,
        'due_date': dueDate?.toIso8601String(),
        'completed_date': completedDate,
        'overdue_days': overdueDays,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'user_id': userId,
        'assigned_by': assignedBy,
        'is_admin_assigned': isAssignedByAdmin,
        'assignee_name': assigneeName,
      };

  /// Creates a copy of this task with modified fields.
  StaffTask copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? dueDate,
    String? completedDate,
    int? overdueDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? userId,
    int? assignedBy,
    bool? isAssignedByAdmin,
    String? assigneeName,
    String? assigneeRole,
    String? assigneeImage,
    String? assigneeMobile,
    int? assigneeId,
  }) {
    return StaffTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      overdueDays: overdueDays ?? this.overdueDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      assignedBy: assignedBy ?? this.assignedBy,
      isAssignedByAdmin: isAssignedByAdmin ?? this.isAssignedByAdmin,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeRole: assigneeRole ?? this.assigneeRole,
      assigneeImage: assigneeImage ?? this.assigneeImage,
      assigneeMobile: assigneeMobile ?? this.assigneeMobile,
      assigneeId: assigneeId ?? this.assigneeId,
    );
  }
}
