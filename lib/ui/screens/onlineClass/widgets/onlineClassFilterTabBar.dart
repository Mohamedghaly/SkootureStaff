import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassEnums.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Horizontal, scrollable status tabs: `All`, `Live (n)`, `Upcoming (n)`,
/// `Past (n)`. A `null` selection represents the `All` tab.
class OnlineClassFilterTabBar extends StatelessWidget {
  final OnlineClassStatus? selectedStatus;
  final ValueChanged<OnlineClassStatus?> onSelected;
  final int liveCount;
  final int upcomingCount;
  final int pastCount;

  const OnlineClassFilterTabBar({
    super.key,
    required this.selectedStatus,
    required this.onSelected,
    required this.liveCount,
    required this.upcomingCount,
    required this.pastCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.tertiary),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Tab(
              label: Utils.getTranslatedLabel(allKey),
              isSelected: selectedStatus == null,
              onTap: () => onSelected(null),
            ),
            const SizedBox(width: 16),
            _Tab(
              label: '${Utils.getTranslatedLabel(liveKey)} ($liveCount)',
              isSelected: selectedStatus == OnlineClassStatus.live,
              onTap: () => onSelected(OnlineClassStatus.live),
            ),
            const SizedBox(width: 16),
            _Tab(
              label:
                  '${Utils.getTranslatedLabel(upcomingKey)} ($upcomingCount)',
              isSelected: selectedStatus == OnlineClassStatus.upcoming,
              onTap: () => onSelected(OnlineClassStatus.upcoming),
            ),
            const SizedBox(width: 16),
            _Tab(
              label: '${Utils.getTranslatedLabel(pastKey)} ($pastCount)',
              isSelected: selectedStatus == OnlineClassStatus.past,
              onTap: () => onSelected(OnlineClassStatus.past),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
