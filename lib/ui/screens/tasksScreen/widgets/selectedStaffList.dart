import 'package:eschool_saas_staff/data/models/staffMember.dart';
import 'package:eschool_saas_staff/ui/widgets/circularStaffAvatar.dart';
import 'package:flutter/material.dart';

/// Shows the single selected staff member below the "Select Staff" button.
class SelectedStaffItem extends StatelessWidget {
  final StaffMember staff;
  final VoidCallback onRemove;

  const SelectedStaffItem({
    super.key,
    required this.staff,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CircularStaffAvatar(imageUrl: staff.imageUrl),
          const SizedBox(width: 16),

          // Name & Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  staff.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Remove icon
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.do_not_disturb_on_outlined,
              size: 24,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
