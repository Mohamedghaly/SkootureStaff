import 'package:eschool_saas_staff/data/models/staffMember.dart';
import 'package:eschool_saas_staff/ui/screens/tasksScreen/widgets/selectedStaffList.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// "Assign Task" section shown when admin selects "Staff" assignee.
/// Includes the "Select Staff" button and the selected staff member.
class AssignTaskSection extends StatelessWidget {
  final VoidCallback onSelectStaff;
  final StaffMember? selectedStaff;
  final VoidCallback? onRemoveStaff;

  const AssignTaskSection({
    super.key,
    required this.onSelectStaff,
    this.selectedStaff,
    this.onRemoveStaff,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          Utils.getTranslatedLabel(assignTaskKey),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 24 / 16,
          ),
        ),
        const SizedBox(height: 16),

        // "Select Staff For this Task" button
        GestureDetector(
          onTap: onSelectStaff,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF57CC99).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle,
                  size: 20,
                  color: Color(0xFF57CC99),
                ),
                const SizedBox(width: 4),
                Text(
                  Utils.getTranslatedLabel(selectStaffForTaskKey),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                    color: Color(0xFF57CC99),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Selected staff member
        if (selectedStaff != null && onRemoveStaff != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SelectedStaffItem(
              staff: selectedStaff!,
              onRemove: onRemoveStaff!,
            ),
          ),
      ],
    );
  }
}
