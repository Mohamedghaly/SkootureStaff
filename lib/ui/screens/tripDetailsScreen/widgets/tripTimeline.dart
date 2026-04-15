import 'package:eschool_saas_staff/ui/styles/colors.dart';
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

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column (Left side) - Fixed width for perfect alignment
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // Top connecting line (if not first)
                if (!isFirst)
                  _shouldShowSolidLine(index - 1, index)
                      ? Container(
                          width: 3,
                          height: 20,
                          color: tripTimelineGreenColor,
                        )
                      : _buildDottedLine(Colors.grey.shade400, 20),

                // Stop Node/Icon
                _buildStopNode(context, stop, index),

                // Bottom connecting line (if not last)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      child: _shouldShowSolidLine(index, index + 1)
                          ? Container(
                              width: 3,
                              color: tripTimelineGreenColor,
                            )
                          : _buildDottedLine(Colors.grey.shade400, 40),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Content Column (Right side)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 35,
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
                        textKey: "${stop.passengerCount} Passenger",
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
                  Row(
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildDottedLine(Color color, double height) {
    // Constrain to 3px width so the dotted stroke can be centered exactly
    return SizedBox(
      width: 3,
      height: height,
      child: CustomPaint(
        painter: DottedLinePainter(
          color: color,
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
