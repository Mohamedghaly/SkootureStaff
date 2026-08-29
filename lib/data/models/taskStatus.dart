import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

enum TaskStatus {
  pending,
  inProgress,
  completed,
  rejected,
  overdue;

  /// Returns the display label for the status.
  String get labelKey {
    switch (this) {
      case TaskStatus.pending:
        return pendingKey;
      case TaskStatus.inProgress:
        return inProgressKey;
      case TaskStatus.completed:
        return completedKey;
      case TaskStatus.rejected:
        return rejectedKey;
      case TaskStatus.overdue:
        return overdueKey;
    }
  }

  /// Returns the text color for the status badge.
  Color get textColor {
    switch (this) {
      case TaskStatus.pending:
        return const Color(0xFFF89E1B); // Message/Warning
      case TaskStatus.inProgress:
        return const Color(0xFF29638A); // Colors/Primary
      case TaskStatus.completed:
        return const Color(0xFF57CC99); // Colors/Secondary
      case TaskStatus.rejected:
        return const Color(0xFFBA1A1A); // Error red
      case TaskStatus.overdue:
        return const Color(0xFFBA1A1A); // Message/Error
    }
  }

  /// Returns the background color for the status badge.
  Color get backgroundColor {
    switch (this) {
      case TaskStatus.pending:
        return const Color(0xFFFEEED7); // Message/Warning Light
      case TaskStatus.inProgress:
        return const Color(0xFFE0EDF6); // Colors/Primary Container
      case TaskStatus.completed:
        return const Color(0xFFE0F5EC); // Colors/Secondary Container
      case TaskStatus.rejected:
        return const Color(0xFFFDE8E8); // Error light
      case TaskStatus.overdue:
        return const Color(0xFFF9D2D2); // Message/Error Light
    }
  }

  /// Creates a [TaskStatus] from an API string value.
  static TaskStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return TaskStatus.pending;
      case 'in_progress':
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'rejected':
        return TaskStatus.rejected;
      case 'overdue':
        return TaskStatus.overdue;
      default:
        return TaskStatus.pending;
    }
  }
}
