import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:eschool_saas_staff/data/models/trip.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/userAvatar.dart';
import 'package:eschool_saas_staff/utils/constants.dart';

class AttendanceBottomSheet extends StatefulWidget {
  final Stop stop;
  final String tripType; // "pickup" or "drop"
  final Function(List<Map<String, dynamic>> records) onMarkReached;

  const AttendanceBottomSheet({
    super.key,
    required this.stop,
    required this.tripType,
    required this.onMarkReached,
  });

  @override
  State<AttendanceBottomSheet> createState() => _AttendanceBottomSheetState();
}

class _AttendanceBottomSheetState extends State<AttendanceBottomSheet> {
  final Map<int, String> _attendanceStatus = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize all passengers as present by default
    for (var passenger in widget.stop.passengers) {
      if (passenger.id != null) {
        _attendanceStatus[passenger.id!] = 'present';
      }
    }
  }

  void _toggleAttendance(int userId, String status) {
    setState(() {
      _attendanceStatus[userId] = status;
    });
  }

  void _markAllPresent() {
    setState(() {
      for (var passenger in widget.stop.passengers) {
        if (passenger.id != null) {
          _attendanceStatus[passenger.id!] = 'present';
        }
      }
    });
  }

  void _markAllAbsent() {
    setState(() {
      for (var passenger in widget.stop.passengers) {
        if (passenger.id != null) {
          _attendanceStatus[passenger.id!] = 'absent';
        }
      }
    });
  }

  int get _presentCount {
    return _attendanceStatus.values
        .where((status) => status == 'present')
        .length;
  }

  int get _absentCount {
    return _attendanceStatus.values
        .where((status) => status == 'absent')
        .length;
  }

  void _handleMarkReached() {
    final records = _attendanceStatus.entries
        .map((entry) => {
              'user_id': entry.key,
              'status': entry.value,
            })
        .toList();

    setState(() => _isLoading = true);
    widget.onMarkReached(records);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(appContentHorizontalPadding),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextContainer(
                        textKey: widget.stop.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CustomTextContainer(
                        textKey:
                            "${widget.stop.passengers.length} Students • ${widget.stop.scheduledTime}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _markAllPresent,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const CustomTextContainer(
                      textKey: "Mark All Present",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _markAllAbsent,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const CustomTextContainer(
                      textKey: "Mark All Absent",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Attendance Summary
          Container(
            margin:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CustomTextContainer(
                        textKey: "$_presentCount Present",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CustomTextContainer(
                        textKey: "$_absentCount Absent",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomTextContainer(
                    textKey:
                        Utils.getTranslatedLabel(attendanceConfirmedLabelKey),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Students List
          Expanded(
            child: ListView.builder(
              padding:
                  EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
              itemCount: widget.stop.passengers.length,
              itemBuilder: (context, index) {
                final passenger = widget.stop.passengers[index];
                if (passenger.id == null) return const SizedBox.shrink();

                final isPresent = _attendanceStatus[passenger.id!] == 'present';
                final isAbsent = _attendanceStatus[passenger.id!] == 'absent';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPresent
                          ? Colors.green.shade300
                          : isAbsent
                              ? Colors.red.shade300
                              : Colors.grey.shade300,
                      width: isPresent || isAbsent ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Profile Avatar with Status
                      UserAvatarWithStatus(
                        imageUrl: passenger.imageUrl,
                        name: passenger.name,
                        role: passenger.role ?? 'Student',
                        radius: 20,
                        statusColor: isPresent
                            ? Colors.green
                            : isAbsent
                                ? Colors.red
                                : null,
                        statusText: isPresent
                            ? 'P'
                            : isAbsent
                                ? 'A'
                                : null,
                      ),

                      const SizedBox(width: 12),

                      // Name and Role
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextContainer(
                              textKey: passenger.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            CustomTextContainer(
                              textKey: passenger.role ?? 'Student',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Attendance Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Present Button
                          GestureDetector(
                            onTap: () =>
                                _toggleAttendance(passenger.id!, 'present'),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isPresent
                                    ? Colors.green
                                    : Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green,
                                  width: isPresent ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: CustomTextContainer(
                                  textKey: "P",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isPresent ? Colors.white : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Absent Button
                          GestureDetector(
                            onTap: () =>
                                _toggleAttendance(passenger.id!, 'absent'),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isAbsent
                                    ? Colors.red
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red,
                                  width: isAbsent ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: CustomTextContainer(
                                  textKey: "A",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isAbsent ? Colors.white : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Mark Reached Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(appContentHorizontalPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleMarkReached,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const CustomTextContainer(
                        textKey: "Mark Reached",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
