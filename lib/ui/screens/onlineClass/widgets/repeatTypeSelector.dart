import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassEnums.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Horizontal, single-select list of repeat options shown as radio chips:
/// `No Repeat`, `Every Class`, `Weekly`.
class RepeatTypeSelector extends StatelessWidget {
  final OnlineClassRepeatType selected;
  final ValueChanged<OnlineClassRepeatType> onChanged;

  const RepeatTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final type in OnlineClassRepeatType.values) ...[
            _RepeatChip(
              type: type,
              isSelected: selected == type,
              onTap: () => onChanged(type),
            ),
            if (type != OnlineClassRepeatType.values.last)
              const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _RepeatChip extends StatelessWidget {
  final OnlineClassRepeatType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _RepeatChip({
    required this.type,
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
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primary : secondary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, color: primary),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              Utils.getTranslatedLabel(type.labelKey),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? primary : secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
