import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassPeriod.dart';
import 'package:flutter/material.dart';

/// Multi-select list of timetable periods used by the "Which Period?" section.
///
/// A period is selected when its [OnlineClassPeriod.id] is in [selectedIds].
class PeriodSelectionList extends StatelessWidget {
  final List<OnlineClassPeriod> periods;
  final Set<int> selectedIds;
  final ValueChanged<OnlineClassPeriod> onToggle;

  const PeriodSelectionList({
    super.key,
    required this.periods,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < periods.length; i++) ...[
          _PeriodTile(
            period: periods[i],
            isSelected: selectedIds.contains(periods[i].id),
            onTap: () => onToggle(periods[i]),
          ),
          if (i != periods.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PeriodTile extends StatelessWidget {
  final OnlineClassPeriod period;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTile({
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE0EDF6)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primary : Theme.of(context).colorScheme.tertiary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CheckBox(isSelected: isSelected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          period.timeRange,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 20 / 14,
                            color: secondary,
                          ),
                        ),
                      ),
                      // "Configured" badge — this period already has an online
                      // class (matches the web link icon).
                      if (period.hasLink) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.link,
                            size: 16, color: Color(0xFF2BA24C)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    period.day,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      color: Color(0xFF6D6E6F),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Square checkbox indicator. Filled primary with a white check when selected.
class _CheckBox extends StatelessWidget {
  final bool isSelected;

  const _CheckBox({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isSelected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected
              ? primary
              : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
