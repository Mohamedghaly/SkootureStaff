import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PickupTimeRow extends StatelessWidget {
  final String? estimatedTime;
  final VoidCallback onTap;

  const PickupTimeRow({
    super.key,
    this.estimatedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine display time based on whether it's "Reached" or estimated
    final displayTime = estimatedTime != null && estimatedTime!.isNotEmpty
        ? (estimatedTime!.contains('Reached')
            ? estimatedTime! // Show only time if "Reached"
            : '$estimatedTime (Estimated)') // Show with "(Estimated)" otherwise
        : Utils.getTranslatedLabel(notAvailableKey);

    return Row(
      children: [
        Expanded(
          child: LabelValue(
            label: Utils.getTranslatedLabel(pickupTimeKey),
            value: displayTime,
            smallValueStyle: true,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF1F4B63),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                Utils.getImagePath('directions.svg'),
                width: 20,
                height: 20,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
