import 'package:eschool_saas_staff/data/models/staffAttendance.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Staff attendance item with checkbox for multi-select
class StaffAttendanceItemContainer extends StatelessWidget {
  final StaffAttendanceRecord staffAttendanceRecord;
  final bool isSelected;
  final Function(bool isSelected)? onSelectionChanged;
  final bool showCheckbox;

  const StaffAttendanceItemContainer({
    super.key,
    required this.staffAttendanceRecord,
    this.isSelected = false,
    this.onSelectionChanged,
    this.showCheckbox = true,
  });

  Color _getStatusColor(StaffAttendanceStatus status) {
    switch (status) {
      case StaffAttendanceStatus.present:
        return const Color(0xFF4CAF50);
      case StaffAttendanceStatus.absentWithReason:
      case StaffAttendanceStatus.absentWithoutReason:
        return const Color(0xFFF44336);
      case StaffAttendanceStatus.holiday:
        return const Color(0xFF9C27B0); // Purple for holiday
      case StaffAttendanceStatus.firstHalfPresent:
      case StaffAttendanceStatus.secondHalfPresent:
        return const Color(0xFFFF9800);
      case StaffAttendanceStatus.notMarked:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(StaffAttendanceStatus status) {
    final color = _getStatusColor(status);

    // Simply use the status label - no leave-based overrides
    String badgeLabel = Utils.getTranslatedLabel(status.labelKey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        badgeLabel,
        style: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: Theme.of(context).colorScheme.tertiary);

    // Check if staff can be selected (only payroll check now)
    final canBeSelected = staffAttendanceRecord.canBeSelected();

    // Use the current status directly - no leave-based overrides
    StaffAttendanceStatus currentStatus =
        staffAttendanceRecord.currentStatus ?? StaffAttendanceStatus.notMarked;

    return InkWell(
      onTap: !canBeSelected
          ? null
          : () {
              if (onSelectionChanged != null) {
                onSelectionChanged!(!isSelected);
              }
            },
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: const BoxConstraints(minHeight: 70),
        padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border(left: border, bottom: border, right: border),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox (show for all staff who can be selected)
            if (showCheckbox && canBeSelected) ...[
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    if (onSelectionChanged != null) {
                      onSelectionChanged!(value ?? false);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Serial number
            SizedBox(
              width: 40,
              child: CustomTextContainer(
                textKey:
                    staffAttendanceRecord.recordInfo?.rowNumber?.toString() ??
                        "-",
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Staff name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextContainer(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textKey: staffAttendanceRecord.staffName,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Status badge with optional leave label
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusBadge(currentStatus),
                // Show leave status label if staff has leave
                // if (staffAttendanceRecord.leave?.hasLeave() == true &&
                //     staffAttendanceRecord.leave?.detectedLeaveType != null) ...[
                //   const SizedBox(height: 4),
                //   Container(
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                //     decoration: BoxDecoration(
                //       color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                //       borderRadius: BorderRadius.circular(4),
                //     ),
                //     child: Text(
                //       staffAttendanceRecord.leave!.detectedLeaveType!,
                //       style: const TextStyle(
                //         fontSize: 10,
                //         fontWeight: FontWeight.w500,
                //         color: Color(0xFF9C27B0),
                //       ),
                //     ),
                //   ),
                // ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
