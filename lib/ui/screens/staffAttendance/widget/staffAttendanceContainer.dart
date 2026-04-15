import 'package:eschool_saas_staff/data/models/staffAttendance.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/screens/staffAttendance/widget/staffAttendanceItemContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

/// Container for staff attendance list with multi-select support
class StaffAttendanceContainer extends StatelessWidget {
  final List<StaffAttendanceRecord> staffAttendanceRecords;
  final Set<String> selectedStaffIds;
  final Function(String staffId, bool isSelected)? onSelectionChanged;
  final Function(bool selectAll)? onSelectAllChanged;
  final bool showCheckbox;

  const StaffAttendanceContainer({
    super.key,
    required this.staffAttendanceRecords,
    this.selectedStaffIds = const {},
    this.onSelectionChanged,
    this.onSelectAllChanged,
    this.showCheckbox = true,
  });

  /// Check if all selectable staff are selected
  bool _isAllSelected() {
    if (staffAttendanceRecords.isEmpty) return false;

    // Get all staff IDs that can be selected (not on leave and payroll not exists)
    final selectableStaffIds = staffAttendanceRecords
        .where((record) => record.canBeSelected())
        .map((record) => record.staffId?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    if (selectableStaffIds.isEmpty) return false;

    // Check if all selectable staff are in the selected set
    return selectableStaffIds.every((id) => selectedStaffIds.contains(id));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(5.0),
                topLeft: Radius.circular(5.0),
              ),
              color: Theme.of(context).colorScheme.tertiary,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: appContentHorizontalPadding,
              vertical: 12,
            ),
            child: Row(
              children: [
                // Select All checkbox
                if (showCheckbox) ...[
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _isAllSelected(),
                      tristate: true,
                      onChanged: (value) {
                        if (onSelectAllChanged != null) {
                          // If currently all selected or some selected, deselect all
                          // Otherwise, select all
                          final shouldSelectAll = !_isAllSelected();
                          onSelectAllChanged!(shouldSelectAll);
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                const SizedBox(
                  width: 40,
                  child: CustomTextContainer(
                    textKey: "#",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: CustomTextContainer(
                    textKey: nameKey,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const CustomTextContainer(
                    textKey: statusKey,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Staff list
          ...List.generate(staffAttendanceRecords.length, (index) {
            final record = staffAttendanceRecords[index];
            final staffId = record.staffId?.toString() ?? '';
            final isSelected = selectedStaffIds.contains(staffId);

            return StaffAttendanceItemContainer(
              staffAttendanceRecord: record,
              isSelected: isSelected,
              showCheckbox: showCheckbox,
              onSelectionChanged: (isSelected) {
                if (onSelectionChanged != null && staffId.isNotEmpty) {
                  onSelectionChanged!(staffId, isSelected);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
