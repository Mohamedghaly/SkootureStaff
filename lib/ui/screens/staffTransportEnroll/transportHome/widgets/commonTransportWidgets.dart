import 'package:eschool_saas_staff/cubits/transport/transportDashboardCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/routeStopsCubit.dart';
import 'package:eschool_saas_staff/data/models/transportDashboard.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:eschool_saas_staff/app/routes.dart';

class EnrollCard extends StatelessWidget {
  final String title;
  final Widget trailing;
  final List<Widget> children;
  final VoidCallback? onTap;
  final bool showHeader;
  const EnrollCard(
      {super.key,
      required this.title,
      required this.trailing,
      required this.children,
      this.onTap,
      this.showHeader = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              Row(
                children: [
                  Expanded(
                    child: CustomTextContainer(
                      textKey: title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  trailing,
                ],
              ),
              const SizedBox(height: 12),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

class EnrollStatusChip extends StatelessWidget {
  final String title;
  final Color background;
  final Color foreground;
  const EnrollStatusChip(
      {super.key,
      required this.title,
      required this.background,
      required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(4)),
      child: CustomTextContainer(
          textKey: title, style: TextStyle(color: foreground, fontSize: 14)),
    );
  }
}

class LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final bool smallValueStyle;
  final bool addTopSpacing;
  final bool addBottomSpacing;
  const LabelValue(
      {super.key,
      required this.label,
      required this.value,
      this.smallValueStyle = false,
      this.addTopSpacing = true,
      this.addBottomSpacing = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: addBottomSpacing ? 8 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (addTopSpacing) const SizedBox(height: 2),
          CustomTextContainer(
            textKey: label,
            style: const TextStyle(color: Color(0xFF6D6E6F), fontSize: 12),
          ),
          if (addBottomSpacing) const SizedBox(height: 2),
          CustomTextContainer(
            textKey: value,
            style: TextStyle(
              color: const Color(0xFF1A1C1D),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: smallValueStyle ? 1.0 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class IconPill extends StatelessWidget {
  final IconData icon;
  final Color? pillColor;
  const IconPill({super.key, required this.icon, this.pillColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: pillColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
    );
  }
}

class PersonRow extends StatelessWidget {
  final String label;
  final String name;
  final String? phone;
  final String? avatar;
  final VoidCallback? onPhoneTap;
  final VoidCallback? onChatTap;
  const PersonRow({
    super.key,
    required this.label,
    required this.name,
    this.phone,
    this.avatar,
    this.onPhoneTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
            backgroundImage: avatar != null && avatar!.isNotEmpty
                ? NetworkImage(avatar!)
                : null,
            child: avatar == null || avatar!.isEmpty
                ? CustomTextContainer(
                    textKey: name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextContainer(
                    textKey: label,
                    style: const TextStyle(
                        color: Color(0xFF6D6E6F), fontSize: 12)),
                CustomTextContainer(
                  textKey: name,
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500),
                ),
                if (phone != null && phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  CustomTextContainer(
                    textKey: phone!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6D6E6F),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (phone != null && phone!.isNotEmpty) ...[
            GestureDetector(
              onTap: onPhoneTap,
              child: const IconPill(
                  icon: Icons.phone, pillColor: Color(0xFFF7F9FF)),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: onChatTap,
            child: const IconPill(
                icon: Icons.message, pillColor: Color(0xFFF7F9FF)),
          ),
        ],
      ),
    );
  }
}

class LiveTrackingContent extends StatelessWidget {
  final dynamic liveSummary; // Using dynamic to avoid circular imports
  const LiveTrackingContent({super.key, this.liveSummary});
  @override
  Widget build(BuildContext context) {
    final currentLocation = liveSummary?.currentLocation ?? 'Not Available';
    final nextLocation = liveSummary?.nextLocation ?? 'Not Available';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DottedTimeline(),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelValue(
                label: Utils.getTranslatedLabel(currentLocationKey),
                value: currentLocation,
              ),
              const SizedBox(height: 8),
              LabelValue(
                label: Utils.getTranslatedLabel(nextPointKey),
                value: nextLocation,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _DottedTimeline extends StatelessWidget {
  const _DottedTimeline();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TimelineCircle(color: Color(0xFF61C29F), diameter: 14),
        SizedBox(height: 2),
        _DottedLineVertical(
            height: 72,
            color: Color(0xFF61C29F),
            thickness: 2,
            dashLength: 5,
            gap: 5),
        SizedBox(height: 2),
        _DiamondMarker(size: 12, color: Color(0xFF61C29F)),
      ],
    );
  }
}

class _TimelineCircle extends StatelessWidget {
  final Color color;
  final double diameter;
  const _TimelineCircle({required this.color, required this.diameter});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _DiamondMarker extends StatelessWidget {
  final double size;
  final Color color;
  const _DiamondMarker({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
        angle: 45.0 * 3.1415926535 / 180.0,
        child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))));
  }
}

class _DottedLineVertical extends StatelessWidget {
  final double height;
  final Color color;
  final double thickness;
  final double dashLength;
  final double gap;
  const _DottedLineVertical(
      {required this.height,
      required this.color,
      this.thickness = 2,
      this.dashLength = 4,
      this.gap = 4});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: thickness,
        height: height,
        child: CustomPaint(
            painter: _DottedPainter(
                color: color,
                thickness: thickness,
                dashLength: dashLength,
                gap: gap)));
  }
}

class _DottedPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double dashLength;
  final double gap;
  _DottedPainter(
      {required this.color,
      required this.thickness,
      required this.dashLength,
      required this.gap});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    double y = 0;
    while (y < size.height) {
      final double endY = (y + dashLength).clamp(0.0, size.height.toDouble());
      canvas.drawLine(
          Offset(size.width / 2, y), Offset(size.width / 2, endY), paint);
      y += dashLength + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  Future<Map<String, dynamic>> _loadData(BuildContext context) async {
    final cubit = context.read<TransportDashboardCubit>();

    // Await the data fetch if needed
    if (cubit.state is! TransportDashboardFetchSuccess) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final attendance = cubit.getFirstTodayAttendance();
    final plan = cubit.getTransportPlan();
    final statusStyle = cubit.getAttendanceStatusStyle();

    return {
      'attendance': attendance,
      'plan': plan,
      'statusStyle': statusStyle,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return EnrollCard(
            title: Utils.getTranslatedLabel(attendanceKey),
            trailing: EnrollStatusChip(
              title: 'Loading...',
              background: const Color(0xFFF5F5F5),
              foreground: const Color(0xFF9E9E9E),
            ),
            children: [
              LabelValue(
                label: Utils.getTranslatedLabel(pickupPointKey),
                value: 'Loading...',
              ),
            ],
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return EnrollCard(
            title: Utils.getTranslatedLabel(attendanceKey),
            trailing: EnrollStatusChip(
              title: Utils.getTranslatedLabel(notAvailableKey),
              background: const Color(0xFFF5F5F5),
              foreground: const Color(0xFF9E9E9E),
            ),
            children: [
              LabelValue(
                  label: Utils.getTranslatedLabel(pickupPointKey),
                  value: Utils.getTranslatedLabel(notAvailableKey)),
              Row(
                children: [
                  Expanded(
                    child: LabelValue(
                      label: Utils.getTranslatedLabel(pickupTimeKey),
                      value: Utils.getTranslatedLabel(notAvailableKey),
                      smallValueStyle: true,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.attendanceScreen);
                    },
                    child: IconPill(
                        icon: Icons.event,
                        pillColor:
                            const Color(0xFF29638A).withValues(alpha: 0.15)),
                  ),
                ],
              ),
            ],
          );
        }

        // Data loaded successfully
        final data = snapshot.data!;
        final attendance = data['attendance'] as TodayAttendance?;
        final plan = data['plan'] as TransportPlan?;
        final statusStyle = data['statusStyle'] as Map<String, dynamic>;
        debugPrint("this is the ${attendance?.getTripTypeDisplay()}");

        return EnrollCard(
          title: Utils.getTranslatedLabel(attendanceKey),
          trailing: EnrollStatusChip(
            title: statusStyle['text'] ?? 'Unknown',
            background: statusStyle['background'] ?? const Color(0xFFF5F5F5),
            foreground: statusStyle['foreground'] ?? const Color(0xFF9E9E9E),
          ),
          children: [
            LabelValue(
              label: Utils.getTranslatedLabel(pickupPointKey),
              value: plan?.pickupStop?.name ??
                  Utils.getTranslatedLabel(notAvailableKey),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: attendance?.getTripTypeDisplay() != null
                      ? LabelValue(
                          label: attendance?.getTripTypeDisplay() == 'Pickup'
                              ? Utils.getTranslatedLabel(pickupTimeKey)
                              : Utils.getTranslatedLabel(dropTimeKey),
                          value: _getPickupTime(context, attendance),
                          smallValueStyle: true,
                        )
                      : const SizedBox.shrink(),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.attendanceScreen);
                  },
                  child: IconPill(
                    icon: Icons.event,
                    pillColor: const Color(0xFF29638A).withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _getPickupTime(BuildContext context, TodayAttendance? attendance) {
    // First, check if attendance has a time value
    if (attendance?.time != null && attendance!.time!.isNotEmpty) {
      return attendance.time!;
    }

    try {
      // Try to get pickup time from route stops data as fallback
      final routeStopsCubit = context.read<RouteStopsCubit>();
      final userStop = routeStopsCubit.getUserStop();

      if (userStop?.timeDisplay != null) {
        return '${userStop!.timeDisplay} (Scheduled)';
      }
    } catch (e) {
      // RouteStopsCubit not available or error accessing it
    }

    // Fallback to "Not Available" if no time data is found
    return 'Not Available';
  }
}

class RequestCard extends StatelessWidget {
  final String title;
  final String statusText;
  final Color statusBg;
  final String requestedRoute;
  final String requestedPickupPoint;
  const RequestCard({
    super.key,
    required this.title,
    required this.statusText,
    required this.statusBg,
    required this.requestedRoute,
    required this.requestedPickupPoint,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: 313,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextContainer(
                    textKey: title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: CustomTextContainer(
                    textKey: statusText,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LabelValue(
              label: Utils.getTranslatedLabel(requestedRouteKey),
              value: requestedRoute,
            ),
            LabelValue(
              label: Utils.getTranslatedLabel(requestedPickupPointKey),
              value: requestedPickupPoint,
            ),
          ],
        ),
      );
}
