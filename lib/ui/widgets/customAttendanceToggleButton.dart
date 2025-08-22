import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomAttendanceToggleButton extends StatelessWidget {
  final StudentAttendanceStatus selectedStatus;
  final Function(StudentAttendanceStatus status) onStatusChanged;
  final double buttonWidth;
  final double buttonHeight;

  const CustomAttendanceToggleButton({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    this.buttonWidth = 30.0,
    this.buttonHeight = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Present Button
        GestureDetector(
          onTap: () {
            onStatusChanged(StudentAttendanceStatus.present);
          },
          child: Container(
            width: buttonWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              color: selectedStatus == StudentAttendanceStatus.present
                  ? const Color(0xFF4CAF50) // Bright Green
                  : const Color(0xFF4CAF50)
                      .withValues(alpha: 0.2), // Light Green
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: selectedStatus == StudentAttendanceStatus.present
                      ? Colors.white
                      : const Color(0xFF4CAF50),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Absent Button
        GestureDetector(
          onTap: () {
            onStatusChanged(StudentAttendanceStatus.absent);
          },
          child: Container(
            width: buttonWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              color: selectedStatus == StudentAttendanceStatus.absent
                  ? const Color(0xFFF44336) // Bright Red
                  : const Color(0xFFF44336).withValues(alpha: 0.2), // Light Red
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: selectedStatus == StudentAttendanceStatus.absent
                      ? Colors.white
                      : const Color(0xFFF44336),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
