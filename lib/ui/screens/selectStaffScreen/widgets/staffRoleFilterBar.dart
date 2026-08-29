import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Horizontally scrollable role filter bar for
/// the Select Staff screen.

class StaffRoleFilterBar extends StatelessWidget {
  final String? selectedRole;
  final List<String> roles;
  final ValueChanged<String?> onRoleSelected;

  const StaffRoleFilterBar({
    super.key,
    required this.selectedRole,
    required this.roles,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: Utils.getTranslatedLabel('all'),
              isSelected: selectedRole == null,
              onTap: () => onRoleSelected(null),
            ),
            const SizedBox(width: 12),
            ...roles.map(
              (role) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _FilterChip(
                  label: role,
                  isSelected: selectedRole == role,
                  onTap: () => onRoleSelected(role),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          border: isSelected
              ? null
              : Border.all(
                  color:
                      Theme.of(context).colorScheme.tertiary,
                  width: 1.5,
                ),
          borderRadius:
              BorderRadius.circular(isSelected ? 12 : 8),
        ),
        child: Text(
          label,
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
