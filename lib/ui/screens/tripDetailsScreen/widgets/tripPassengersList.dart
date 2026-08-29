import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:eschool_saas_staff/data/models/tripDetails.dart';
import 'package:eschool_saas_staff/data/models/trip.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/userAvatar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TripPassengersList extends StatefulWidget {
  final TripDetails tripDetails;
  final Trip? originalTrip;
  final Function(String stopId, String passengerId, PassengerStatus status)
      onPassengerAttendanceUpdate;
  final Function(String stopId) onMarkAttendance;
  final Function(String stopId, bool expand) onGroupExpansionChanged;

  const TripPassengersList({
    super.key,
    required this.tripDetails,
    this.originalTrip,
    required this.onPassengerAttendanceUpdate,
    required this.onMarkAttendance,
    required this.onGroupExpansionChanged,
  });

  @override
  State<TripPassengersList> createState() => _TripPassengersListState();
}

class _TripPassengersListState extends State<TripPassengersList> {
  final Set<String> _expandedGroups = {};

  void _toggleGroupExpansion(String stopId) {
    setState(() {
      if (_expandedGroups.contains(stopId)) {
        _expandedGroups.remove(stopId);
      } else {
        _expandedGroups.add(stopId);
      }
    });
    widget.onGroupExpansionChanged(stopId, _expandedGroups.contains(stopId));
  }

  bool _isStopReached(String stopId) {
    // Check if this stop is marked as "Reached" in the original trip data
    if (widget.originalTrip == null) return false;

    final stop = widget.originalTrip!.stops.firstWhere(
      (s) => s.id?.toString() == stopId,
      orElse: () => Stop(name: 'Unknown', scheduledTime: ''),
    );

    return stop.isReached; // This checks if estimated_time == "Reached"
  }

  Map<String, int> _getAttendanceCounts(String stopId) {
    final group = widget.tripDetails.passengerGroups.firstWhere(
      (g) => g.stopId == stopId,
      orElse: () => PassengerGroup(
          stopId: stopId, stopName: '', time: '', passengers: []),
    );

    int presentCount = 0;
    int absentCount = 0;

    for (final passenger in group.passengers) {
      if (passenger.attendanceStatus == PassengerStatus.present) {
        presentCount++;
      } else if (passenger.attendanceStatus == PassengerStatus.absent) {
        absentCount++;
      }
    }

    return {
      'present': presentCount,
      'absent': absentCount,
    };
  }

  Color _getAttendanceColor(PassengerStatus status) {
    switch (status) {
      case PassengerStatus.present:
        return Colors.green;
      case PassengerStatus.absent:
        return Colors.red;
      case PassengerStatus.notMarked:
        return Colors.grey;
    }
  }

  Color _getAttendanceBackgroundColor(PassengerStatus status) {
    return _getAttendanceColor(status).withValues(alpha: 0.1);
  }

  String _getAttendanceText(PassengerStatus status) {
    switch (status) {
      case PassengerStatus.present:
        return "P";
      case PassengerStatus.absent:
        return "A";
      case PassengerStatus.notMarked:
        return "";
    }
  }

  Widget _buildAttendanceButton(Passenger passenger, String stopId) {
    // Check if this stop is reached (attendance already submitted)
    final isStopReached = _isStopReached(stopId);

    // For reached stops or non-in-progress trips, show read-only attendance status
    if (widget.tripDetails.status != TripStatus.inProgress || isStopReached) {
      // Only show attendance container if attendance has been recorded
      if (passenger.attendanceStatus == PassengerStatus.notMarked) {
        return const SizedBox(); // No attendance recorded, show nothing
      }

      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _getAttendanceBackgroundColor(passenger.attendanceStatus),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: CustomTextContainer(
            textKey: _getAttendanceText(passenger.attendanceStatus),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getAttendanceColor(passenger.attendanceStatus),
            ),
          ),
        ),
      );
    }

    // For in-progress trips with non-reached stops, show interactive P and A buttons
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => widget.onPassengerAttendanceUpdate(
            stopId,
            passenger.id,
            PassengerStatus.present,
          ),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: passenger.attendanceStatus == PassengerStatus.present
                  ? Colors.green
                  : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: CustomTextContainer(
                textKey: "P",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: passenger.attendanceStatus == PassengerStatus.present
                      ? Colors.white
                      : Colors.green,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => widget.onPassengerAttendanceUpdate(
            stopId,
            passenger.id,
            PassengerStatus.absent,
          ),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: passenger.attendanceStatus == PassengerStatus.absent
                  ? Colors.red
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: CustomTextContainer(
                textKey: "A",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: passenger.attendanceStatus == PassengerStatus.absent
                      ? Colors.white
                      : Colors.red,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallButton(Passenger passenger) {
    if (!passenger.canCall) return const SizedBox();

    return GestureDetector(
      onTap: () {
        // Handle call action
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.call,
          size: 16,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildPassengerItem(Passenger passenger, String stopId) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          // Profile Image using UserAvatarWithStatus
          UserAvatarWithStatus(
            imageUrl: passenger.profileImage,
            name: passenger.name,
            role: passenger.type,
            radius: 20,
            statusColor: _getAttendanceColor(passenger.attendanceStatus),
            statusText: _getAttendanceText(passenger.attendanceStatus),
          ),

          const SizedBox(width: 12),

          // Name and Type
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
                  textKey: passenger.type,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Call Button
          _buildCallButton(passenger),

          const SizedBox(width: 12),

          // Attendance Button(s)
          _buildAttendanceButton(passenger, stopId),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummaryTag(String stopId) {
    final counts = _getAttendanceCounts(stopId);
    final presentCount = counts['present'] ?? 0;
    final absentCount = counts['absent'] ?? 0;

    if (presentCount == 0 && absentCount == 0) {
      return const SizedBox(); // No attendance marked
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green.shade700,
            ),
            const SizedBox(width: 8),
            CustomTextContainer(
              textKey: Utils.getTranslatedLabel(attendanceConfirmedLabelKey),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 8),
            CustomTextContainer(
              textKey: "$presentCount P, $absentCount A",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerGroup(PassengerGroup group) {
    final isExpanded = _expandedGroups.contains(group.stopId);
    final hasPassengers = group.passengers.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Group Header
          GestureDetector(
            onTap: hasPassengers
                ? () => _toggleGroupExpansion(group.stopId)
                : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reached Label at the very top (only show when attendance is marked)
                  if (_isStopReached(group.stopId)) ...[
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1976D2),
                              width: 1.5,
                            ),
                          ),
                          child: SvgPicture.asset(
                            'assets/images/transportation.svg',
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF1976D2),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomTextContainer(
                            textKey: group.stopName,
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const CustomTextContainer(
                            textKey: "Reached",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Row: Time and Stop Name (always show both) with expand icon
                  Row(
                    children: [
                      // Time
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomTextContainer(
                          textKey: group.time,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Stop Name (always show)
                      Expanded(
                        child: CustomTextContainer(
                          textKey: group.stopName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Expand/Collapse Icon (always show on second line)
                      if (hasPassengers)
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.7),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Special Notes
          if (group.pickupNote != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: group.isOnTime
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomTextContainer(
                  textKey: group.pickupNote!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: group.isOnTime
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ),
            ),

          // Attendance Summary Tag (when stop is reached and not expanded)
          if (!isExpanded && _isStopReached(group.stopId))
            _buildAttendanceSummaryTag(group.stopId),

          // Passengers List (when expanded)
          if (isExpanded && hasPassengers)
            Column(
              children: [
                const Divider(
                  height: 1,
                  endIndent: 16,
                  indent: 16,
                ),
                ...group.passengers.map((passenger) =>
                    _buildPassengerItem(passenger, group.stopId)),

                // Mark Attendance Button (for in-progress trips with non-reached stops)
                if (widget.tripDetails.status == TripStatus.inProgress &&
                    !_isStopReached(group.stopId))
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => widget.onMarkAttendance(group.stopId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const CustomTextContainer(
                        textKey: "Mark Attendance",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Attendance Summary (when stop is reached and expanded)
                if (_isStopReached(group.stopId))
                  _buildAttendanceSummaryTag(group.stopId),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Statistics
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomTextContainer(
                  textKey:
                      "Stop : ${widget.tripDetails.stops.where((stop) => !stop.name.toLowerCase().contains('school')).length}/${widget.tripDetails.totalStops}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              Expanded(
                child: CustomTextContainer(
                  textKey: "Present : ${widget.tripDetails.presentCount}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              Expanded(
                child: CustomTextContainer(
                  textKey: "Absent : ${widget.tripDetails.absentCount}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Passenger Groups
        ...widget.tripDetails.passengerGroups.map(_buildPassengerGroup),
      ],
    );
  }
}
