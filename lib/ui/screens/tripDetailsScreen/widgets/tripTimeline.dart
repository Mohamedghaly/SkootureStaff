import 'package:eschool_saas_staff/ui/styles/colors.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:eschool_saas_staff/data/models/tripDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TripTimeline extends StatelessWidget {
  final TripDetails tripDetails;
  final Function(String stopId) onStopReached;

  const TripTimeline({
    super.key,
    required this.tripDetails,
    required this.onStopReached,
  });

  // Timeline layout metrics (kept in one place so the rail, the dots and the
  // content stay perfectly aligned across screen sizes).
  static const double _railWidth = 24; // width reserved for the dot + line
  static const double _railGap = 20; // gap between the rail and the content
  static const double _topLineHeight = 20; // connector above a node
  static const double _itemBottomSpacing = 35; // gap below a node's content
  static const double _markerBandHeight =
      20; // height of the band used to vertically center a marker's time

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              for (int index = 0; index < tripDetails.stops.length; index++)
                _buildTimelineItem(context, tripDetails.stops[index], index),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(BuildContext context, TripStop stop, int index) {
    final isLast = index == tripDetails.stops.length - 1;
    final isFirst = index == 0;

    // Shift start/end nodes only carry a time (no name, passengers or note),
    // so they use a dedicated layout that keeps the time vertically centered
    // with the dot instead of pushing it below an empty name line.
    if (_isTimeOnlyStop(stop)) {
      return _buildMarkerItem(
        context,
        stop,
        index,
        isFirst: isFirst,
        isLast: isLast,
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column (Left side) - Fixed width for perfect alignment
          SizedBox(
            width: _railWidth,
            child: Column(
              children: [
                // Top connecting line (if not first)
                if (!isFirst)
                  _buildConnector(index - 1, index, height: _topLineHeight),

                // Stop Node/Icon
                _buildStopNode(context, stop, index),

                // Bottom connecting line (if not last)
                if (!isLast) Expanded(child: _buildConnector(index, index + 1)),
              ],
            ),
          ),

          const SizedBox(width: _railGap),

          // Content Column (Right side)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : _itemBottomSpacing,
                top: 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stop Name
                  CustomTextContainer(
                    textKey: stop.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: stop.status == StopStatus.current
                          ? tripTimelineGreenColor // Current stop also green
                          : Colors.black87,
                    ),
                  ),

                  // Passenger count (if any) or arrival note
                  if (stop.passengerCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: CustomTextContainer(
                        textKey:
                            "${stop.passengerCount} ${Utils.getTranslatedLabel(stop.passengerCount > 1 ? passengersKey : passengerKey)}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  else if (stop.arrivalNote != null &&
                      stop.arrivalNote!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: CustomTextContainer(
                        textKey: stop.arrivalNote!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Time Row
                  _buildTimeRow(stop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a shift start/end marker whose only content is a time.
  ///
  /// The dot and the time are each placed inside a band of the same fixed
  /// height ([_markerBandHeight]) and centered within it, which keeps the time
  /// vertically centered with the dot regardless of the device text scale.
  Widget _buildMarkerItem(
    BuildContext context,
    TripStop stop,
    int index, {
    required bool isFirst,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail (line + dot)
          SizedBox(
            width: _railWidth,
            child: Column(
              children: [
                if (!isFirst)
                  _buildConnector(index - 1, index, height: _topLineHeight),
                SizedBox(
                  height: _markerBandHeight,
                  child: Center(child: _buildStopNode(context, stop, index)),
                ),
                if (!isLast) Expanded(child: _buildConnector(index, index + 1)),
              ],
            ),
          ),

          const SizedBox(width: _railGap),

          // Time, centered against the dot via a matching band height
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isFirst) const SizedBox(height: _topLineHeight),
                SizedBox(
                  height: _markerBandHeight,
                  child: _buildTimeRow(stop),
                ),
                if (!isLast) const SizedBox(height: _itemBottomSpacing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Planned time (left, grey) and, when available, the actual time
  /// (right, coloured by arrival status).
  Widget _buildTimeRow(TripStop stop) {
    return Row(
      children: [
        // Planned Time (Left, Grey)
        CustomTextContainer(
          textKey: stop.time,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),

        const Spacer(),

        // Actual Time (Right, Green)
        if (stop.actualTime != null)
          CustomTextContainer(
            textKey: stop.actualTime!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getActualTimeColor(stop),
            ),
          ),
      ],
    );
  }

  /// A shift start/end marker carries only a time: no name, passengers or note.
  bool _isTimeOnlyStop(TripStop stop) {
    final hasNote =
        stop.arrivalNote != null && stop.arrivalNote!.trim().isNotEmpty;
    return stop.name.trim().isEmpty && stop.passengerCount <= 0 && !hasNote;
  }

  Widget _buildStopNode(BuildContext context, TripStop stop, int index) {
    if (stop.status == StopStatus.current) {
      // Current stop - Green circle with bus icon
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: tripTimelineGreenColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/bus.svg',
            width: 12,
            height: 12,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      );
    } else if (stop.status == StopStatus.completed) {
      // Completed stop - Solid green circle
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: tripTimelineGreenColor,
          shape: BoxShape.circle,
        ),
        child: stop.isSchoolCampus
            ? Center(
                child: Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 8,
                ),
              )
            : null,
      );
    } else {
      // Upcoming stop - Hollow grey circle
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: stop.isSchoolCampus
            ? Center(
                child: Icon(
                  Icons.school,
                  color: Colors.grey.shade400,
                  size: 6,
                ),
              )
            : null,
      );
    }
  }

  bool _shouldShowSolidLine(int fromIndex, int toIndex) {
    final fromStop = tripDetails.stops[fromIndex];
    final toStop = tripDetails.stops[toIndex];

    // Show solid green line only between completed stops
    // or from completed to current stop
    return (fromStop.status == StopStatus.completed &&
            toStop.status == StopStatus.completed) ||
        (fromStop.status == StopStatus.completed &&
            toStop.status == StopStatus.current);
  }

  /// A vertical connector between two nodes: solid green when the route
  /// between them is completed, otherwise a dashed grey line.
  ///
  /// When [height] is null the connector fills the available space (used
  /// inside an [Expanded]); otherwise it draws a fixed-height segment.
  Widget _buildConnector(int fromIndex, int toIndex, {double? height}) {
    final isSolid = _shouldShowSolidLine(fromIndex, toIndex);
    return SizedBox(
      width: 3,
      height: height,
      child: isSolid
          ? Container(color: tripTimelineGreenColor)
          : CustomPaint(
              painter: DottedLinePainter(
                color: Colors.grey.shade400,
                dashWidth: 2,
                dashSpace: 2,
              ),
            ),
    );
  }

  Color _getActualTimeColor(TripStop stop) {
    // All actual times should be green in your image
    if (stop.arrivalNote != null &&
        stop.arrivalNote!.toLowerCase().contains('late')) {
      return Colors.red.shade600; // Late arrivals in red
    } else {
      return tripTimelineGreenColor; // On-time arrivals in green`
    }
  }
}

/// Custom painter for creating dashed vertical lines (1px width, 2,2 pattern)
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DottedLinePainter({
    required this.color,
    this.dashWidth = 2.0,
    this.dashSpace = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0 // Fixed 1px width
      ..strokeCap = StrokeCap.square; // Square caps for clean dashes

    // Draw down the vertical center of the available width
    final double x = size.width / 2;
    double startY = 0;
    while (startY < size.height) {
      // Draw each dash segment
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace; // Move to next dash position
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
