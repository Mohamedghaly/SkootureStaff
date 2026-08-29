import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:flutter/material.dart';

class TaskFilterChip extends StatelessWidget {
  final String labelKey;
  final bool isSelected;
  final VoidCallback onTap;

  const TaskFilterChip({
    super.key,
    required this.labelKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(isSelected ? 12 : 8),
          border: isSelected
              ? null
              : Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 1.5,
                ),
        ),
        child: CustomTextContainer(
          textKey: labelKey,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
