import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// "Details / Tasks" tab bar for profile screens.
///

class ProfileTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const ProfileTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: Utils.getTranslatedLabel(detailsKey),
              isActive: selectedIndex == 0,
              onTap: () => onTabSelected(0),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _TabButton(
              label: Utils.getTranslatedLabel(tasksKey),
              isActive: selectedIndex == 1,
              onTap: () => onTabSelected(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          border: isActive
              ? null
              : Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            color: isActive
                ? Colors.white
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
