import 'package:eschool_saas_staff/data/models/staffAttendance.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for marking attendance status
/// Matches the design from the provided image
class StaffAttendanceStatusBottomSheet extends StatefulWidget {
  final StaffAttendanceStatus? initialStatus;
  final String? initialReason;
  final Function(StaffAttendanceStatus status, String? reason) onStatusSelected;
  final List<StaffAttendanceRecord>? selectedStaffRecords;

  const StaffAttendanceStatusBottomSheet({
    super.key,
    this.initialStatus,
    this.initialReason,
    required this.onStatusSelected,
    this.selectedStaffRecords,
  });

  @override
  State<StaffAttendanceStatusBottomSheet> createState() =>
      _StaffAttendanceStatusBottomSheetState();
}

class _StaffAttendanceStatusBottomSheetState
    extends State<StaffAttendanceStatusBottomSheet> {
  late StaffAttendanceStatus _selectedStatus;
  StaffAttendanceStatus? _selectedHalfDay;
  final TextEditingController _reasonController = TextEditingController();

  /// Check if any selected staff has admin-approved first half leave
  /// If true, hide First Half option and only allow Second Half
  /// This only checks for admin_leave, not attendance_created_leave
  bool get _hasAnyFirstHalfLeave {
    return widget.selectedStaffRecords
            ?.any((record) => record.hasAdminFirstHalfLeave()) ??
        false;
  }

  /// Check if any selected staff has admin-approved second half leave
  /// If true, hide Second Half option and only allow First Half
  /// This only checks for admin_leave, not attendance_created_leave
  bool get _hasAnySecondHalfLeave {
    return widget.selectedStaffRecords
            ?.any((record) => record.hasAdminSecondHalfLeave()) ??
        false;
  }

  /// Check if full day present option should be disabled
  /// Returns true if any selected staff has admin-approved first half OR second half leave
  /// When half-day leave exists, only Absent and Half Day options should be available
  bool get _isFullDayPresentDisabled {
    return _hasAnyFirstHalfLeave || _hasAnySecondHalfLeave;
  }

  /// Get the most common current status among selected staff
  /// This helps pre-select the appropriate option in the bottom sheet
  StaffAttendanceStatus? get _mostCommonStatus {
    if (widget.selectedStaffRecords == null ||
        widget.selectedStaffRecords!.isEmpty) {
      return null;
    }

    // Count occurrences of each status
    final Map<StaffAttendanceStatus, int> statusCounts = {};
    for (final record in widget.selectedStaffRecords!) {
      if (record.currentStatus != null &&
          record.currentStatus != StaffAttendanceStatus.notMarked) {
        statusCounts[record.currentStatus!] =
            (statusCounts[record.currentStatus!] ?? 0) + 1;
      }
    }

    // Return the most common status
    if (statusCounts.isEmpty) return null;

    return statusCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  @override
  void initState() {
    super.initState();

    // Use the provided initial status or most common status
    StaffAttendanceStatus initialStatus = widget.initialStatus ??
        _mostCommonStatus ??
        StaffAttendanceStatus.present;

    _selectedStatus = initialStatus;

    // Initialize half-day selection if needed
    if (_selectedStatus == StaffAttendanceStatus.firstHalfPresent ||
        _selectedStatus == StaffAttendanceStatus.secondHalfPresent) {
      _selectedHalfDay = _selectedStatus;
      _selectedStatus =
          StaffAttendanceStatus.firstHalfPresent; // Use as half-day indicator
    }

    // Auto-select appropriate half-day based on leave status
    // If first half leave exists, auto-select second half
    // If second half leave exists, auto-select first half
    if (_hasAnyFirstHalfLeave && !_hasAnySecondHalfLeave) {
      _selectedHalfDay = StaffAttendanceStatus.secondHalfPresent;
    } else if (_hasAnySecondHalfLeave && !_hasAnyFirstHalfLeave) {
      _selectedHalfDay = StaffAttendanceStatus.firstHalfPresent;
    }

    // If Present option is disabled (due to half-day leave) and current selection is Present,
    // auto-switch to Half Day option
    if (_isFullDayPresentDisabled &&
        _selectedStatus == StaffAttendanceStatus.present) {
      _selectedStatus = StaffAttendanceStatus.firstHalfPresent;
      // Set appropriate half-day based on leave type
      if (_hasAnyFirstHalfLeave && !_hasAnySecondHalfLeave) {
        _selectedHalfDay = StaffAttendanceStatus.secondHalfPresent;
      } else if (_hasAnySecondHalfLeave && !_hasAnyFirstHalfLeave) {
        _selectedHalfDay = StaffAttendanceStatus.firstHalfPresent;
      }
    }

    // Pre-fill the reason text field if an initial reason is provided
    if (widget.initialReason != null && widget.initialReason!.isNotEmpty) {
      _reasonController.text = widget.initialReason!;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    StaffAttendanceStatus finalStatus = _selectedStatus;

    // If half-day is selected, use the specific half-day status
    if (_selectedStatus == StaffAttendanceStatus.firstHalfPresent ||
        _selectedStatus == StaffAttendanceStatus.secondHalfPresent) {
      finalStatus = _selectedHalfDay ?? StaffAttendanceStatus.firstHalfPresent;
    }

    // Get reason text if applicable
    String? reason;
    if (_selectedStatus == StaffAttendanceStatus.absentWithReason ||
        _selectedStatus == StaffAttendanceStatus.absentWithoutReason ||
        _reasonController.text.trim().isNotEmpty) {
      reason = _reasonController.text.trim();
    }

    widget.onStatusSelected(finalStatus, reason);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            CustomTextContainer(
              textKey: Utils.getTranslatedLabel(markAttendanceKey),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 24),

            const SizedBox(height: 24),
            CustomTextContainer(
              textKey: Utils.getTranslatedLabel(attendanceStatusKey),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Present Option
            _buildStatusRadioTile(
              status: StaffAttendanceStatus.present,
              title: Utils.getTranslatedLabel(presentKey),
              subtitle: Utils.getTranslatedLabel(fullWorkingDayKey),
              icon: Icons.check_circle_outline,
              color: const Color(0xFF4CAF50),
              isDisabled: _isFullDayPresentDisabled,
            ),

            const SizedBox(height: 12),

            // Absent Option
            _buildStatusRadioTile(
              status: StaffAttendanceStatus.absentWithoutReason,
              title: Utils.getTranslatedLabel(absentKey),
              subtitle: Utils.getTranslatedLabel(
                  willAutomaticallyCreateLeaveEntryKey),
              icon: Icons.cancel_outlined,
              color: const Color(0xFFF44336),
            ),

            const SizedBox(height: 12),

            // Half Day Option
            _buildStatusRadioTile(
              status: StaffAttendanceStatus.firstHalfPresent,
              title: Utils.getTranslatedLabel(halfDayKey),
              subtitle: Utils.getTranslatedLabel(halfDayPresentKey),
              icon: Icons.access_time,
              color: const Color(0xFFFF9800),
            ),

            // Half Day Sub-options (shown when Half Day is selected)
            if (_selectedStatus == StaffAttendanceStatus.firstHalfPresent ||
                _selectedStatus == StaffAttendanceStatus.secondHalfPresent) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextContainer(
                      textKey: Utils.getTranslatedLabel(whichHalfWasPresentKey),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // First Half option - disabled if staff has first half leave
                    _buildHalfDayOption(
                      status: StaffAttendanceStatus.firstHalfPresent,
                      title: Utils.getTranslatedLabel(firstHalfKey),
                      subtitle:
                          Utils.getTranslatedLabel(morningSessionPresentKey),
                      isDisabled: _hasAnyFirstHalfLeave,
                    ),
                    const SizedBox(height: 8),
                    // Second Half option - disabled if staff has second half leave
                    _buildHalfDayOption(
                      status: StaffAttendanceStatus.secondHalfPresent,
                      title: Utils.getTranslatedLabel(secondHalfKey),
                      subtitle:
                          Utils.getTranslatedLabel(afternoonSessionPresentKey),
                      isDisabled: _hasAnySecondHalfLeave,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Reason Section (Optional) - Only show for Absent or Half Day
            if (_selectedStatus == StaffAttendanceStatus.absentWithoutReason ||
                _selectedStatus == StaffAttendanceStatus.absentWithReason ||
                _selectedStatus == StaffAttendanceStatus.firstHalfPresent ||
                _selectedStatus == StaffAttendanceStatus.secondHalfPresent) ...[
              // Reason Section (Optional)
              CustomTextContainer(
                textKey: Utils.getTranslatedLabel(reasonOptionalKey),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 8),

              // Reason Text Field
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: Utils.getTranslatedLabel(reasonPlaceholderKey),
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 12),

              // Helper text
              Text(
                Utils.getTranslatedLabel(reasonHelperTextKey),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),
            ],

            // Submit Button
            CustomRoundedButton(
              height: 50,
              widthPercentage: 1.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: submitKey,
              showBorder: false,
              onTap: _handleSubmit,
            ),

            // Bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRadioTile({
    required StaffAttendanceStatus status,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isDisabled = false,
  }) {
    final bool isSelected = _selectedStatus == status;

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                setState(() {
                  _selectedStatus = status;
                  if (status != StaffAttendanceStatus.firstHalfPresent &&
                      status != StaffAttendanceStatus.secondHalfPresent) {
                    _selectedHalfDay = null;
                  } else {
                    _selectedHalfDay = StaffAttendanceStatus.firstHalfPresent;
                  }

                  // Clear reason text if switching to Present status
                  if (status == StaffAttendanceStatus.present) {
                    _reasonController.clear();
                  }
                });
              },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDisabled
                  ? Colors.grey[300]!
                  : (isSelected ? color : Colors.grey[300]!),
              width: isSelected && !isDisabled ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDisabled
                ? Colors.grey.withValues(alpha: 0.05)
                : (isSelected
                    ? color.withValues(alpha: 0.05)
                    : Colors.transparent),
          ),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDisabled
                        ? Colors.grey[400]!
                        : (isSelected ? color : Colors.grey[400]!),
                    width: 2,
                  ),
                  color: isSelected && !isDisabled ? color : Colors.transparent,
                ),
                child: isSelected && !isDisabled
                    ? const Center(
                        child: Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDisabled
                            ? Colors.grey
                            : (isSelected ? color : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDisabled
                            ? Colors.grey
                            : (isSelected
                                ? color.withValues(alpha: 0.8)
                                : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHalfDayOption({
    required StaffAttendanceStatus status,
    required String title,
    required String subtitle,
    bool isDisabled = false,
  }) {
    final bool isSelected = _selectedHalfDay == status;

    // Show option as disabled (grayed out) based on leave status
    // User can see it but cannot select it

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                setState(() {
                  _selectedHalfDay = status;
                });
              },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDisabled
                  ? Colors.grey[300]!
                  : (isSelected ? const Color(0xFFFF9800) : Colors.grey[300]!),
              width: isSelected && !isDisabled ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDisabled
                ? Colors.grey.withValues(alpha: 0.05)
                : (isSelected
                    ? const Color(0xFFFF9800).withValues(alpha: 0.05)
                    : Colors.transparent),
          ),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected && !isDisabled
                        ? const Color(0xFFFF9800)
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected && !isDisabled
                      ? const Color(0xFFFF9800)
                      : Colors.transparent,
                ),
                child: isSelected && !isDisabled
                    ? const Center(
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDisabled
                            ? Colors.grey
                            : (isSelected
                                ? const Color(0xFFFF9800)
                                : Colors.black87),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDisabled
                            ? Colors.grey
                            : (isSelected
                                ? const Color(0xFFFF9800).withValues(alpha: 0.8)
                                : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
