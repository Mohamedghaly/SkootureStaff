import 'package:eschool_saas_staff/cubits/transport/transportDashboardCubit.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/pickupTimeRow.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/liveRouteBottomSheet.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveTrackingCard extends StatelessWidget {
  const LiveTrackingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransportDashboardCubit, TransportDashboardState>(
      builder: (context, state) {
        final cubit = context.read<TransportDashboardCubit>();
        final liveSummary = cubit.getLiveSummary();

        return EnrollCard(
          title: Utils.getTranslatedLabel(liveTrackingKey),
          trailing: liveSummary != null
              ? _buildStatusBadge(liveSummary.status)
              : const SizedBox(),
          children: [
            if (liveSummary != null) ...[
              LiveTrackingContent(liveSummary: liveSummary),
              const SizedBox(height: 8),
              PickupTimeRow(
                estimatedTime: liveSummary.estimatedTime,
                onTap: () => LiveRouteBottomSheet.show(context),
              ),
            ] else ...[
              // Show message when there's no active trip
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_bus_outlined,
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Utils.getTranslatedLabel(noOngoingTripKey),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color bgColor;
    Color textColor;
    String displayText;

    switch (status?.toLowerCase()) {
      case 'on_time':
      case 'ontime':
      case 'On time':
        bgColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        displayText = Utils.getTranslatedLabel(onTimeKey);
        break;
      case 'delayed':
      case 'Delayed':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        displayText = Utils.getTranslatedLabel(delayedKey);
        break;
      case 'early':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        displayText = Utils.getTranslatedLabel(earlyKey);
        break;
      default:
        bgColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        displayText = status ?? "N/A";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
